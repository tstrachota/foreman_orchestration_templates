require 'foreman_orchestration_templates/methods'

module ForemanOrchestrationTemplates
  module Planning
    class Base

      def allowed_methods
        @allowed_methods ||= [
          :find,
          :foreman_server,
          :current_organization,
          :current_location
        ]
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

      def method_missing(method, *args)
        if registry[method]
          registry[method].send(execute_method, *args)
        else
          super
        end
      end

      protected
      attr_reader :registry, :execute_method

      def type_to_class(type)
        type.to_s.camelize.constantize
      end
    end
  end
end
