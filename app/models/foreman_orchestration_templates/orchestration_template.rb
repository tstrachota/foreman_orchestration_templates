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
  end
end
