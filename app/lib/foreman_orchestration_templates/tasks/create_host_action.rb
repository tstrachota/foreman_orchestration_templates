module ForemanOrchestrationTemplates
  module Tasks
    class CreateHostAction < CreateResourceAction
      def humanized_name
        'Create host '+input['parameters']['name']
      end

      protected

      def create_object(parameters)
        object_params = parameters['parameters']
        object_params['managed'] ||= true
        object_params['build'] ||= true if object_params['managed']


        initial_params = {
          'interfaces_attributes' => object_params.delete('interfaces_attributes') || {},
          'hostgroup_id' => object_params.delete('hostgroup_id')
        }

        object = get_class(parameters['type']).new(initial_params)
        object = set_parameters(object, object_params)

        initialize_manged_host(object, object_params) if object.is_a? Host::Managed

        object
      end

      def initialize_manged_host(object, object_params)
        object.apply_compute_profile(InterfaceMerge.new(:merge_compute_attributes => true))
        object.apply_compute_profile(ComputeAttributeMerge.new)

        # Start the machine automatically
        if object.compute_resource.try(:type) == "Foreman::Model::Libvirt"
          object.compute_attributes ||= {}
          object.compute_attributes['start'] ||= '1'
        end
      end

    end
  end
end
