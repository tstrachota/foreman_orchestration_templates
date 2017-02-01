module ForemanOrchestrationTemplates
  module Planning
    class TemplateProcessor < Base
      attr_reader :errors

      def initialize(delegate)
        @delegate = delegate
        @errors = []
      end

      def run(template)
        box = Safemode::Box.new(@delegate, @delegate.allowed_methods)
        box.eval(template)
        true
      rescue Racc::ParseError => e
        @errors << _("The template code is invalid: %s") % e.message
        false
      rescue RuntimeError => e
        @errors << e.message
        false
      end

      def self.run(delegate, template)
        instance = self.new(delegate)
        instance.run(template)
        instance.errors
      end
    end
  end
end
