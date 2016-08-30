module ForemanOrchestrationTemplates
  module Tasks
    class BaseAction < Actions::Base

      def messages
        output.fetch('messages', []).map do |msg|
          Message.new(msg)
        end
      end

      def add_message(type, text)
        output['messages'] ||= []
        output['messages'] << {
          'type' => type,
          'text' => text
        }
      end

      def humanized_state
        if run_step.state.to_s == 'suspended'
          'running'
        else
          run_step.state
        end
      end

      protected
      def set_current_user
        User.current = User.find(input[:current_user_id]) unless input[:current_user_id].nil?
      end
    end
  end
end
