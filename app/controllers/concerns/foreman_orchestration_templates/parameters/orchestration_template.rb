module ForemanOrchestrationTemplates::Parameters::OrchestrationTemplate
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix
  include Foreman::Controller::Parameters::Template
  include Foreman::Controller::Parameters::TemplateCombination

  class_methods do
    def orchestration_template_params_filter
      Foreman::ParameterFilter.new(::ForemanOrchestrationTemplates::OrchestrationTemplate).tap do |filter|
        add_taxonomix_params_filter(filter)
        add_template_params_filter(filter)
      end
    end
  end

  def orchestration_template_params
    self.class.orchestration_template_params_filter.filter_params(params, parameter_filter_context)
  end
end
