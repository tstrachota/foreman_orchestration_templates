module ForemanOrchestrationTemplates
  module Tasks
    class Message
      attr_reader :text, :type

      def initialize(attrs = {})
        @text = attrs[:text]
        @type = attrs[:type]
      end
    end
  end
end
