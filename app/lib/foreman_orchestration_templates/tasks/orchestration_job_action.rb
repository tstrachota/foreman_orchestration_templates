module ForemanOrchestrationTemplates
  module Tasks
    class OrchestrationJobAction < BaseAction
      def plan(template, inputs, current_user)
        dynflow_adaptor = ForemanOrchestrationTemplates::Tasks::Planning::DynflowAdapter.new(self)
        ForemanOrchestrationTemplates::Tasks::Planning::TemplateProcessor.run(
          ForemanOrchestrationTemplates::Tasks::Planning::Planner.new(dynflow_adaptor, inputs, current_user.try(:id)),
          template
        )
        plan_self
      end
    end
  end
end
