module ForemanOrchestrationTemplates
  module Methods
    class Reference
      class Jail < Safemode::Jail
        allow :[]
      end

      def [](subkey)
        self
      end
    end
  end
end
