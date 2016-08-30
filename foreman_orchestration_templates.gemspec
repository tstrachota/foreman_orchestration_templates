require File.expand_path('../lib/foreman_orchestration_templates/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_orchestration_templates'
  s.version     = ForemanOrchestrationTemplates::VERSION
  s.date        = Date.today.to_s
  s.authors     = ['Tomáš Strachota']
  s.email       = ['tstrachota@redhat.com']
  s.homepage    = 'https://github.com/theforeman/foreman_orchestration_templates'
  s.summary     = 'Plugin for orchestrating actions accross multiple hosts in the Foreman.'
  s.description = 'Plugin for orchestrating actions accross multiple hosts in the Foreman.'

  s.files      = Dir['{app,config,db,doc,lib,locale}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'foreman-tasks', ">= 0.7.3"
end
