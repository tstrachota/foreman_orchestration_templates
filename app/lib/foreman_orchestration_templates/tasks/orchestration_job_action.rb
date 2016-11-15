module ForemanOrchestrationTemplates
  module Tasks
    class OrchestrationJobAction < BaseAction
      def plan(template, inputs, current_user)
        dynflow_adaptor = ForemanOrchestrationTemplates::Planning::DynflowAdapter.new(self)
        registry = ForemanOrchestrationTemplates.registry
        ForemanOrchestrationTemplates::Planning::TemplateProcessor.run(
          ForemanOrchestrationTemplates::Planning::Planner.new(dynflow_adaptor, registry, inputs, current_user.try(:id)),
          template
        )
        plan_self
      end
    end
  end
end
