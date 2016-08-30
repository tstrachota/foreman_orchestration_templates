require 'foreman_tasks'

module ForemanOrchestrationTemplates
  class Engine < ::Rails::Engine
    config.autoload_paths.concat(Dir["#{config.root}/app/*/"])
    config.autoload_paths.concat(Dir["#{config.root}/app/*/concerns"])
    config.autoload_paths.concat(Dir["#{config.root}/test/"])

    # Add any db migrations
    initializer 'foreman_orchestration_templates.load_app_instance_data' do |app|
      ForemanOrchestrationTemplates::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_orchestration_templates.register_plugin', after: :finisher_hook do
      Foreman::Plugin.register :foreman_orchestration_templates do
        requires_foreman '>= 1.8'

        menu :top_menu, :orchestration_templates, :url_hash => { :controller => 'foreman_orchestration_templates/orchestration_templates', :action => :index },
          :caption => N_('Orchestration templates'),
          :parent => :hosts_menu

        search_path_override('ForemanOrchestrationTemplates') do |resource|
          "/#{resource.demodulize.underscore.pluralize}/auto_complete_search"
        end
      end
    end

    initializer 'foreman_orchestration_templates.apipie' do
      # rubocop:disable Metrics/LineLength
      Apipie.configuration.api_controllers_matcher << "#{ForemanOrchestrationTemplates::Engine.root}/app/controllers/foreman_orchestration_templates/api/v2/*.rb"
      Apipie.configuration.checksum_path += ['/foreman_orchestration_templates/api/']
    end

    initializer 'foreman_orchestration_templates.require_dynflow', before: 'foreman_tasks.initialize_dynflow' do
      ::ForemanTasks.dynflow.require!
      ::ForemanTasks.dynflow.config.eager_load_paths << File.join(ForemanOrchestrationTemplates::Engine.root, 'app/services/foreman_orchestration_templates/tasks')
    end

    config.to_prepare do
      TemplatePathsHelper.send(:include, ForemanOrchestrationTemplates::OrchestrationTemplatePathsExtensions)
      ProvisioningTemplatesHelper.send(:include, ForemanOrchestrationTemplates::OrchestrationTemplatesExtensions)
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanOrchestrationTemplates::Engine.load_seed
      end
    end
  end
end
