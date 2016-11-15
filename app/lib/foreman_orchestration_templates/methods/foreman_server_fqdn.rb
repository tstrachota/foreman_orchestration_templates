module ForemanOrchestrationTemplates
  module Methods
    class ForemanServerFqdn

      def run_read
        foreman_server_fqdn
      end

      def run_plan
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
