module ForemanOrchestrationTemplates
  module Methods

    class HostOutputReference < Reference
      class Jail < Safemode::Jail
        allow :configured, :built, :[]
      end

      def configured
        Reference.new
      end

      def built
        Reference.new
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

    class Create < Base
      def run_plan(*args)
        create_plan(*args)
      end

      def run_read(*args)
        create(*args)
      end

      protected
      def create(type, attributes)
        if type == :host
          HostOutputReference.new
        else
          Reference.new
        end
      end

      def create_plan(type, attributes)
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
    end

  end
end
