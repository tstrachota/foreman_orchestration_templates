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

      def allowed_inputs
        @allowed_inputs ||= [
          :select,
          :select_resource,
          :text
        ]
      end

      def foreman_server
        host = Host.unscoped.where(:name => foreman_server_fqdn).first
        if host.nil?
          nic = Nic::Base.find_by_ip(foreman_server_fqdn)
          raise "Foreman host #{foreman_server_fqdn} not found" if nic.nil?
          host = Host.unscoped.find(nic.host_id)
        end
        host
      end

      def current_organization
        Organization.current
      end

      def current_location
        Location.current
      end

      def method_missing(method_name, *args)
        if method_exist?(method_name)
          method(method_name).send(execute_method, *args)
        else
          super
        end
      end

      protected
      attr_reader :registry, :execute_method

      def method_exist?(method_name)
        !registry[method_name].nil?
      end

      def method(method_name)
        @methods ||= {}
        @methods[method_name] ||= registry[method_name].constantize.new(@planning_adapter)
      end
    end
  end
end
