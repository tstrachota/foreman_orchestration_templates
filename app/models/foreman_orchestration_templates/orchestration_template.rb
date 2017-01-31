module ForemanOrchestrationTemplates
  class OrchestrationTemplate < ::Template
    include Authorizable
    include Taxonomix

    audited :allow_mass_assignment => true

    has_many :configurations, :class_name => ForemanOrchestrationTemplates::Configuration.name,
                              :foreign_key => :template_id,
                              :inverse_of => :template
    has_many :audits, :as => :auditable, :class_name => Audited.audit_class.name

    def self.base_class
      self
    end
    self.table_name = 'templates'

    # Override method in Taxonomix as Template is not used attached to a Host,
    # and matching a Host does not prevent removing a template from its taxonomy.
    def used_taxonomy_ids(type)
      []
    end

    def saved_configurations
      configurations.where(:template_id => nil)
    end

    def job_configurations
      configurations.where.not(:template_id => nil)
    end

    def self.import!(name, text, metadata)
      current = self.find_by_name(name)
      if current.nil?
        template = self.new(:name => name, :template => text)
        return {
          :status => template.save!,
          :result => "Template '#{name}' created",
          :old => "",
          :new => text
        }
      else
        old_text = current.template.dup
        current.template = text
        return {
          :status => current.save!,
          :result => "Template '#{name}' updated",
          :old => old_text,
          :new => text
        }
      end
    end
  end
end
