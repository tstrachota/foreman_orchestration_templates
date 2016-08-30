require 'test_plugin_helper'

describe 'processing create_host.rb' do
  let(:template) { File.read(File.dirname(__FILE__) + '/../templates/create_host.rb') }

  it 'reads the template' do
    tpl_reader = ForemanOrchestrationTemplates::Tasks::Planning::Reader.new
    ForemanOrchestrationTemplates::Tasks::Planning::TemplateProcessor.run(tpl_reader, template)
  end

  it 'plans the template' do
  end
end
