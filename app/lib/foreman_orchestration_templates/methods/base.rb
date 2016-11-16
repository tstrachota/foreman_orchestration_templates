module ForemanOrchestrationTemplates
  module Methods
    class Base

      def initialize(planning_adapter = nil)
        @planning_adapter = planning_adapter
      end

      def run_read
        run
      end

      def run_plan
        run
      end

      def run
      end

      protected
      def type_to_class(type)
        type.to_s.camelize.constantize
      end

      def plan_action(action_class, input)
        @planning_adapter.plan_action(action_class, input)
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
    end
  end
end
