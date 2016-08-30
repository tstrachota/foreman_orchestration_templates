module ForemanOrchestrationTemplates
  module Tasks
    module Planning
      class Base
        ALOWED_METHODS = [
          :find,
          :foreman_server_fqdn,
          :foreman_server,
          :current_organization,
          :current_location
        ]

        def foreman_server_fqdn
          config = URI.parse(Setting[:foreman_url])
          config.host
        end

        def foreman_server
          host = Host.unscoped.where(:name => foreman_server_fqdn).first
          if host.nil?
            host_id = Nic::Base.find_by_ip(foreman_server_fqdn).host_id
            host = Host.unscoped.find(host_id)
          end
          host
        end

        def find(type, attributes, *rest)
          type_to_class(type).where(attributes).first
        end

        def current_organization
          Organization.current
        end

        def current_location
          Location.current
        end

        protected
        def type_to_class(type)
          type.to_s.camelize.constantize
        end
      end
    end
  end
end
