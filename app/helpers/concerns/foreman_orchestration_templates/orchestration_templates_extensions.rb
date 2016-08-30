module ForemanOrchestrationTemplates
  module OrchestrationTemplatesExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :permitted_actions, :orchestration
    end

    def permitted_actions_with_orchestration(template)
      original = permitted_actions_without_orchestration(template)

      if template.is_a?(OrchestrationTemplate)
        original.unshift(display_link_if_authorized(_('Run'), hash_for_new_orchestration_job_path(:template_id => template.id))) unless template.snippet
      end

      original
    end
  end
end
