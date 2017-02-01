module ForemanOrchestrationTemplates
  class OrchestrationJob < ActiveRecord::Base
    include Authorizable

    has_one :configuration, :class_name => ForemanOrchestrationTemplates::Configuration.name, :dependent => :destroy
    belongs_to :task, :class_name => ForemanTasks::Task.name

    validates :name, :presence => true
    validates :configuration, :presence => true

    before_validation :set_default_name

    scoped_search :on => :id, :complete_value => false
    scoped_search :on => :name, :complete_value => true, :default_order => true
    scoped_search :in => :configuration, :on => :template_id, :complete_value => false

    def template
      configuration.template if configuration
    end

    def self.run_template(template, inputs)
      job = OrchestrationJob.new
      job.task = ForemanTasks.async_task(ForemanOrchestrationTemplates::Tasks::OrchestrationJobAction, template.template_without_metadata, inputs, User.current)

      configuration = Configuration.new(:values => inputs, :template => template, :orchestration_job => job)
      configuration.save!

      job.save!
      job
    end

    def actions
      if task.nil?
        []
      else
        task.main_action.all_planned_actions.select { |action| action.is_a?(ForemanOrchestrationTemplates::Tasks::BaseAction) }
      end
    end

    def status
      if task.nil?
        :configuration
      elsif task.state == 'paused'
        :paused
      elsif task.state == 'stopped'
        if task.result == 'success'
          :finished
        else
          :failed
        end
      else
        :running
      end
    end

    protected
    def set_default_name
      self.name ||= "#{template.name} @ #{DateTime.now.to_formatted_s(:db)}"
    end
  end
end
