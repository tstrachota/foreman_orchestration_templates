module ForemanOrchestrationTemplates
  module Tasks
    class WaitUntilHostInStateAction < BaseAction
      include Dynflow::Action::Polling

      def humanized_name
        if host.nil?
          'Wait until host is %{state}' % { :state =>  input['until'] }
        else
          'Wait until host %{name} is %{state}' % { :name => host.name, :state =>  input['until'] }
        end
      end

      def host
        @host ||= Host.where(:id => input['host_id']).first
      end

      def done?
        case input['until']
        when 'built'
          get_status('build') == HostStatus::BuildStatus::BUILT
        when 'configured'
          # TODO: get rid of translation sensitivity!
          label = get_status_label('configuration')
          label && ((label.downcase == 'active') || (label.downcase == 'no changes'))
        else
          false
        end
      end

      def statuses
        external_task || {}
      end

      def get_status(type)
        external_task[type] && external_task[type]['status']
      end

      def get_status_label(type)
        external_task[type] && external_task[type]['label']
      end

      def timeout
        input['timeout'] || 2 * 60 * 60 # 2 hours default
      end

      def invoke_external_task
        schedule_timeout(timeout) unless timeout <= 0
        build_status
      end

      def poll_external_task
        fail(_("'%s' is a required parameter") % 'host_id') unless input.key?('host_id')

        host = Host.find(input['host_id'])
        create_output(host, output)
        build_status(host)
      end

      def poll_interval
        30
      end

      protected

      def create_output(host, output_hash = {})
        output_hash['object'] = JSON.parse(host.attributes.to_json)
        output_hash['object']['facts'] = JSON.parse(host.facts.to_json)
        output_hash
      end

      def build_status(host = nil)
        if host.nil?
          {}
        else
          host.host_statuses.inject({}) do |result, status|
            status_info = {
              'status' => status.to_status,
              'label' => status.to_label
            }
            result.merge({ status.class.status_name.downcase => status_info })
          end
        end
      end
    end
  end
end
