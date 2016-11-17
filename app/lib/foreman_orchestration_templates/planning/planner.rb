module ForemanOrchestrationTemplates
  module Planning
    class ::Dynflow::ExecutionPlan::OutputReference
      class Jail < Safemode::Jail
        allow :[]
      end
    end

    class Planner < Base

      def allowed_methods
        @allowed_methods ||= super + @registry.keys + [
          :input,
          :execute,
          :sequence
        ]
      end

      attr_reader :inputs

      def initialize(planning_adapter, registry, inputs = {}, current_user_id = nil)
        @inputs = inputs
        @registry = registry
        @planning_adapter = planning_adapter
        @current_user_id = current_user_id
      end

      def input(name, params={})
        if params[:type].to_sym == :select_resource
          params[:resource].constantize.find(@inputs[name].to_i)
        else
          @inputs[name]
        end
      end

      def sequence(&block)
        @planning_adapter.sequence(&block)
      end

      def execute(attributes)
        # Requires: name, (script and name) or template_id

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
        attributes[:current_user_id] = @current_user_id

        # :on => item or array of names or ids
        # :script
        # :template_id
        # :name
        # :inputs
        plan_action(ForemanOrchestrationTemplates::Tasks::ExecuteScriptAction, attributes.with_indifferent_access).output
      end

      protected
      def execute_method
        :run_plan
      end

      def method(method_name)
        @methods ||= {}
        @methods[method_name] ||= registry[method_name].new(@planning_adapter)
      end

      def plan_action(action_class, input)
        @planning_adapter.plan_action(action_class, input)
      end
    end
  end
end
