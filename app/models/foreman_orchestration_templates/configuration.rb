module ForemanOrchestrationTemplates
  class Configuration < ActiveRecord::Base
    belongs_to :template, :class_name => ForemanOrchestrationTemplates::OrchestrationTemplate.name
    belongs_to :orchestration_job, :class_name => ForemanOrchestrationTemplates::OrchestrationJob.name

    validates :template, :presence => true

    serialize :values, Hash

    self.table_name = 'orchestration_configurations'

    def default_description
      if !orcehstration_job.nil?
        _('Configuration for %s') % orcehstration_job.name
      elsif !template.nil?
        _('Saved configuration for %s') % template.name
      end
    end
  end
end
