module ForemanOrchestrationTemplates
  module Tasks
    class CreateResourceAction < BaseAction

      def run
        obj = create_object(input)
        obj.save!
        create_output(obj, output)
      rescue ActiveRecord::RecordInvalid => e
        obj.errors.full_messages.each do |m|
          add_message(:error, m)
        end
        raise e
      end

      protected

      def create_object(parameters)
        object_params = parameters['parameters'] || {}
        object = get_class(parameters['type']).new

        set_parameters(object, object_params)
      end

      def get_class(type)
        type.to_s.camelize.constantize
      end

      def create_output(obj, output_hash = {})
        output_hash['object'] = JSON.parse(obj.attributes.to_json)
        output_hash
      end

      def set_parameters(object, object_params)
        object_params.each do |key, value|
          if object.respond_to?("#{key}=")
            object.send("#{key}=", value)
            # TODO: else, add warning message
          end
        end

        object
      end
    end
  end
end
