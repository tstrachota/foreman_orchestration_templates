module ForemanOrchestrationTemplates
  module Tasks
    module Planning
      class ::Dynflow::ExecutionPlan::OutputReference
        class Jail < Safemode::Jail
          allow :[]
        end
      end

      class HostOutputReferenceWrapper
        class Jail < Safemode::Jail
          allow :configured, :built, :[]
        end

        def initialize(original, planning_adapter)
          @original = original
          @planning_adapter = planning_adapter
        end

        def method_missing(name, *args, &block)
          @original.send(name, *args, &block)
        end

        def configured
          plan_wait('until' => 'configured', 'host_id' => @original[:object][:id]).output
        end

        def built
          plan_wait('until' => 'built', 'host_id' => @original[:object][:id]).output
        end

        protected
        def plan_wait(input)
          @planning_adapter.plan_action(ForemanOrchestrationTemplates::Tasks::WaitUntilHostInStateAction, input)
        end
      end

      class Planner < Base
        ALOWED_METHODS = Base::ALOWED_METHODS + [
          :input,
          :create,
          :execute,
          :sequence
        ]

        attr_reader :inputs

        def initialize(planning_adapter, inputs = {}, current_user_id = nil)
          @inputs = inputs
          @planning_adapter = planning_adapter
          @current_user_id = current_user_id
        end

        def input(name, params={})
          if params[:type] == :select_resource
            params[:resource].constantize.find(@inputs[name].to_i)
          else
            @inputs[name]
          end
        end

        def sequence(&block)
          @planning_adapter.sequence(&block)
        end

        def create(type, attributes)
          attributes[:type] = type
          attributes = attributes.with_indifferent_access
          attributes[:parameters] = references_to_ids(type_to_class(type), attributes[:parameters] || {})
          attributes[:current_user_id] = @current_user_id

          if type == :host
            action = ForemanOrchestrationTemplates::Tasks::CreateHostAction
            HostOutputReferenceWrapper.new(plan_action(action, attributes).output, @planning_adapter)
          else
            action = ForemanOrchestrationTemplates::Tasks::CreateResourceAction
            plan_action(action, attributes).output
          end
        end

        def execute(attributes)
          attributes[:on] = [attributes[:on]] unless attributes[:on].is_a? Array
          attributes[:on].map! do |host_ref|
            if host_ref.is_a? Integer
              Host.unscoped.find(host_ref).name
            elsif host_ref.is_a? String
              Host.unscoped.find_by_name(host_ref).name
            elsif host_ref.is_a? Host::Base
              host_ref.name
            elsif host_ref.is_a? Dynflow::ExecutionPlan::OutputReference
              host_ref
            else
              raise "Unknown host reference #{host_ref}(#{host_ref.class})"
            end
          end
          attributes[:template_id] = JobTemplate.find_by_name(attributes[:template]) unless attributes[:template]
          attributes[:current_user_id] = @current_user_id

          # :on => item or array of names or ids
          # :script
          # :template
          # :template_id
          # :name
          # :inputs
          plan_action(ForemanOrchestrationTemplates::Tasks::ExecuteScriptAction, attributes.with_indifferent_access).output
        end

        protected
        def plan_action(action_class, input)
          @planning_adapter.plan_action(action_class, input)
        end

        def references_to_ids(type_class, parameters)
          type_class.reflections.values.each do |reflection|
            if parameters[reflection.name]
              if reflection.macro == :has_many
                new_param_name = "#{reflection.name.to_s.singularize}_ids"
                parameters[new_param_name] = parameters.delete(reflection.name).map { |r| reference_to_id(r) }
              else
                new_param_name = "#{reflection.name}_id"
                parameters[new_param_name] = reference_to_id(parameters.delete(reflection.name))
              end
            end
          end
          parameters
        end

        def reference_to_id(reference)
          if reference.is_a?(::Dynflow::ExecutionPlan::OutputReference)
            reference[:id]
          elsif reference.respond_to?(:id)
            reference.id
          else
            raise "Instance of #{reference.class.name} doesn't respond to id!"
          end
        end
      end
    end
  end
end
