require 'foreman_orchestration_templates/engine'

module ForemanOrchestrationTemplates
  def self.registry
    # @task_registry ||= ForemanOrchestrationTemplates::Registry.new
    @task_registry ||= {}
  end
end

