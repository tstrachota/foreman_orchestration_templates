module ForemanOrchestrationTemplates
  module Methods
  end
end

ForemanOrchestrationTemplates.registry[:foreman_server_fqdn] = 'ForemanOrchestrationTemplates::Methods::ForemanServerFqdn'
ForemanOrchestrationTemplates.registry[:create] = 'ForemanOrchestrationTemplates::Methods::Create'
ForemanOrchestrationTemplates.registry[:execute] = 'ForemanOrchestrationTemplates::Methods::Execute' if Object.const_defined? 'ForemanRemoteExecution'
