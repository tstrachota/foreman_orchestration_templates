module ForemanOrchestrationTemplates
  module Planning
    class DynflowAdapter
      def initialize(parent_action)
        @parent_action = parent_action
      end

      def plan_action(action_class, input)
        @parent_action.send(:plan_action, action_class, input)
      end

      def sequence(&block)
        @parent_action.send(:sequence, &block)
      end
    end
  end
end
