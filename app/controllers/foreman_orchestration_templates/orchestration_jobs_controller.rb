module ForemanOrchestrationTemplates
  class OrchestrationJobsController < ApplicationController
    include ::ForemanOrchestrationTemplates::Parameters::OrchestrationTemplate
    include Foreman::Controller::AutoCompleteSearch

    before_filter :find_template, :only => [:new, :create, :process_change]
    before_filter :find_job, :only => [:show, :destroy]

    def index
      params[:order] ||= 'id ASC'
      @jobs = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    end

    def new
      read_template(@template)
    end

    def create
      job = OrchestrationJob.run_template(@template, params[:configuration])
      process_success :success_redirect => orchestration_job_path(job)
    end

    def destroy
      if @job.destroy
        process_success
      else
        process_error
      end
    end

    def show
      read_template(@job.template)
    end

    def process_change
      read_template(@template)
      render :partial => "form"
    end

    def find_template
      @template = OrchestrationTemplate.find(params[:template_id])
    end

    def find_job
      @job = OrchestrationJob.find(params[:id])
    end

    protected

    def read_template(template)
      tpl_reader = ForemanOrchestrationTemplates::Planning::Reader.new(ForemanOrchestrationTemplates.registry, params[:configuration] || {})
      @errors = ForemanOrchestrationTemplates::Planning::TemplateProcessor.run(tpl_reader, template.template_without_metadata)
      @inputs = tpl_reader.inputs
    end
  end
end
