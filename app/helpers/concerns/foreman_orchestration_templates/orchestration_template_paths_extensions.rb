module ForemanOrchestrationTemplates
  module OrchestrationTemplatePathsExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :template_hash_for_member, :nesting
    end

    # TODO: backport the change to Foreman core
    def template_hash_for_member_with_nesting(template, member = nil)
      member = "#{member}_" if member.present?
      # hash_for is protected method
      send("hash_for_#{member}#{template_route_prefix(template.class).split('/').last.singularize}_path", :id => template)
    end
  end
end
