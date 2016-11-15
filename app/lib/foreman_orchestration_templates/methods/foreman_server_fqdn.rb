module ForemanOrchestrationTemplates
  module Methods
    class ForemanServerFqdn < Base
      def run
        foreman_server_fqdn
      end

      protected
      def foreman_server_fqdn
        config = URI.parse(Setting[:foreman_url])
        config.host
      end
    end
  end
end
