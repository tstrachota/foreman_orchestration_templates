module ForemanOrchestrationTemplates
  class OrchestrationJobsController < ApplicationController
    include ::ForemanOrchestrationTemplates::Parameters::OrchestrationTemplate
    include Foreman::Controller::AutoCompleteSearch

    before_filter :find_template, :only => [:new, :create]
    before_filter :find_job, :only => [:show]

    def index
      @jobs = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    end

    def new
      tpl_reader = ForemanOrchestrationTemplates::Tasks::Planning::Reader.new
      ForemanOrchestrationTemplates::Tasks::Planning::TemplateProcessor.run(tpl_reader, @template.template)
      @inputs = tpl_reader.inputs
    end

    def create
      job = OrchestrationJob.run_template(@template, params[:configuration])
      process_success :success_redirect => orchestration_job_path(job)
    end

    def show
    end

    def find_template
      @template = OrchestrationTemplate.find(params[:template_id])
    end

    def find_job
      @job = OrchestrationJob.find(params[:id])
    end
  end
end
