module ForemanOrchestrationTemplates
  module Tasks
    class ExecuteScriptAction < BaseAction
      include Dynflow::Action::Polling

      def humanized_name
        'Execute script: ' + input[:name]
      end

      def done?
        external_task['pending_count'] && (external_task['pending_count'] <= 0)
      end

      def on_finish
        if external_task['failed_count'] > 0
          error! 'Some tasks failed'
        end
      end

      def timeout
        input['timeout'] || 2 * 60 * 60 # 2 hours default
      end

      def invoke_external_task
        raise "Missing either template_id or script" if !input[:template_id] && !input[:script]

        set_current_user
        schedule_timeout(timeout) unless timeout <= 0


        template_inputs = build_template_inputs(input.fetch(:inputs, {}))

        if !input[:template_id]
          template = JobTemplate.find_by_name(input[:name])
          if template.nil?
            template = JobTemplate.new(
              :name => input[:name],
              :template => input[:script],
              :provider_type => 'SSH'
            )
            template_inputs.each do |key, val|
              template.template_inputs << TemplateInput.new(:name => key, :input_type => :user)
            end
            template.organizations = Organization.all
            template.locations = Location.all
            template.save!
          else
            template.template = input[:script]
            template.save!
          end
          input[:template_id] = template.id
        end

        composer_params = {
          :job_template_id => input[:template_id],
          :search_query => build_search_query(input[:on]),
          :targeting_type => Targeting::DYNAMIC_TYPE,
          :inputs => template_inputs
        }


        composer = JobInvocationComposer.from_api_params(composer_params)
        composer.job_invocation.description = 'Orchestration: ' + template.name
        task = composer.trigger!

        output[:task_id] = task.id
        build_status
      end

      def poll_external_task
        build_status
      end

      def build_status
        ForemanTasks::Task.find(output[:task_id]).output
      end

      protected

      def build_template_inputs(inputs)
        result = {}
        inputs.map do |key, val|
          result[key.to_s] = val
        end
        result
      end

      def build_search_query(hostnames)
        hostnames.map { |name| "name = #{name}" }.join(" OR ")
      end
    end
  end
end
