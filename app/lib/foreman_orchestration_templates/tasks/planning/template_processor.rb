module ForemanOrchestrationTemplates
  module Tasks
    module Planning
      class TemplateProcessor < Base
        def initialize(delegate)
          @delegate = delegate
        end

        def run(template)
          box = Safemode::Box.new(@delegate, @delegate.class::ALOWED_METHODS)
          box.eval(template)
        end

        def self.run(delegate, template)
          self.new(delegate).run(template)
        end
      end
    end
  end
end
