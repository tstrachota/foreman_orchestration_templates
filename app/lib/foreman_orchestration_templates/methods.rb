module ForemanOrchestrationTemplates
  module Methods
  end
end

ForemanOrchestrationTemplates.registry[:foreman_server_fqdn] = ForemanOrchestrationTemplates::Methods::ForemanServerFqdn.new
