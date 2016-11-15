module ForemanOrchestrationTemplates
  module Planning
    class Reference
      class Jail < Safemode::Jail
        # TODO: configured and built are here only for host reference, sort out how to solve it
        allow :[], :configured, :built
      end

      def [](subkey)
        self
      end
    end

    class HostOutputReference
      class Jail < Safemode::Jail
        allow :configured, :built, :[]
      end

      def configured
        Reference.new
      end

      def built
        Reference.new
      end

      def [](key)
        Reference.new
      end
    end


    class Reader < Base

      def allowed_methods
        @allowed_methods ||= super + @registry.keys + [
          :input,
          :create,
          :execute,
          :sequence
        ]
      end

      attr_reader :inputs

      def sequence(&block)
        yield
      end

      def initialize(registry)
        @registry = registry
        @inputs = {}
      end

      def input(name, params={})
        params[:type] ||= :text
        params[:label] ||= name.to_s.gsub('_', ' ').capitalize
        @inputs[name] = params
        if params[:type] == :select_resource
          params[:resource].constantize.new
        else
          @inputs[name]
        end
      end

      def create(type, attributes)
        if type == :host
          HostOutputReference.new
        else
          Reference.new
        end
      end

      def execute(*args)
        Reference.new
      end

      protected
      def execute_method
        :run_read
      end
    end
  end
end
