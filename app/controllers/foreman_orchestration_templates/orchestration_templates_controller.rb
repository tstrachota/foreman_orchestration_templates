module ForemanOrchestrationTemplates
  class OrchestrationTemplatesController < ::TemplatesController
    include ::ForemanOrchestrationTemplates::Parameters::OrchestrationTemplate
    include Foreman::Controller::AutoCompleteSearch

    def load_vars_from_template
      return unless @template

      @locations        = @template.locations
      @organizations    = @template.organizations
    end

    def index
      @templates = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    end

    def new
      @template = OrchestrationTemplate.new
    end

    private

    def resource_class
      @resource_class ||= ForemanOrchestrationTemplates::OrchestrationTemplate
    end

    def type_name_singular
      @type_name_singular ||= 'orchestration_template'
    end

    def type_name_plural
      @type_name_singular ||= 'orchestration_templates'
    end

  end
end
