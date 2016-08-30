module ForemanOrchestrationTemplates
  module OrchestrationJobsHelper

    def panel_class(action)
      case action.run_step.state
      when :success
        'success'
      when :error
        'danger'
      when :running
        'primary'
      else
        'info ' + action.run_step.state.to_s
      end
    end

    def action_partial_path(partial_name)
      "foreman_orchestration_templates/orchestration_jobs/actions/#{partial_name}"
    end

    def action_partial(action)
      partial_name = action.class.name.split('::').last.underscore
      if lookup_context.find_all(action_partial_path('_'+partial_name)).any?
        action_partial_path(partial_name)
      else
        action_partial_path('default')
      end
    end

    def object_link(object)
      object
    end
  end
end
