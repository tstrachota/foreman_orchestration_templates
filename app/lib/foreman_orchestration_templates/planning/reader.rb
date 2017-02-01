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

    class Reader < Base

      def allowed_methods
        @allowed_methods ||= super + @registry.keys + [
          :input,
          :execute,
          :sequence
        ]
      end

      attr_reader :inputs

      def sequence(&block)
        yield
      end

      def initialize(registry, input_values = {})
        @registry = registry
        @inputs = {}
        @input_values = input_values
      end

      def input(name, params={})
        params[:type] ||= :text

        # TODO: create specific exception
        raise "Unknown input type #{params[:type]}" unless allowed_inputs.include?(params[:type])

        params[:label] ||= name.to_s.gsub('_', ' ').capitalize
        params[:value] = @input_values[name] || params[:value]
        @inputs[name] = params
        if params[:type] == :select_resource
          if params[:value]
            params[:resource].constantize.find(params[:value].to_i)
          else
            params[:resource].constantize.new
          end
        else
          params[:value]
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
