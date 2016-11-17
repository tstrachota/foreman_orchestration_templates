module ForemanOrchestrationTemplates
  module Methods
    class Find < Base
      def run(type, attributes, *rest)
        type_to_class(type).where(attributes).first
      end
    end
  end
end
