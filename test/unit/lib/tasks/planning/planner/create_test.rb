require 'test_plugin_helper'


def dynflow_output_reference(subkeys = nil)
  @last_id ||= 0
  ::Dynflow::ExecutionPlan::OutputReference.new(
    (@last_id += 1).to_s,
    @last_id += 1,
    @last_id += 1,
    subkeys || []
  )
end

class FakeDynflowReference
  attr_reader :output

  def initialize
    @output = dynflow_output_reference
  end
end

class DynflowAdaptorMock < Mocha::Mock
  def initialize(name = nil, &block)
    super(::Mocha::Mockery.instance.unnamed_mock, name, block)
  end

  def expects_action_with(type, input)
    expects(:plan_action).with(
      type,
      input
    ).returns(FakeDynflowReference.new)
  end

  def expects_action
    expects(:plan_action).returns(FakeDynflowReference.new)
  end
end



describe ForemanOrchestrationTemplates::Tasks::Planning::Planner do
  before do
    @adaptor = DynflowAdaptorMock.new('planning_adaptor');
    @planner = ForemanOrchestrationTemplates::Tasks::Planning::Planner.new(@adaptor, {})
  end

  context 'create resource' do
    let(:action_class) { ForemanOrchestrationTemplates::Tasks::CreateResourceAction }

    it 'plans correct action' do
      @adaptor.expects_action_with(action_class, { 'type' => :architecture , 'parameters' => {}, 'current_user_id' => nil })
      @planner.create(:architecture, {})
    end

    it 'passes resource attributes' do
      params = {
        'name' => 'x86_64'
      }
      @adaptor.expects_action_with(action_class, { 'type' => :architecture, 'parameters' => params, 'current_user_id' => nil })
      @planner.create(:architecture, { 'parameters' => params })
    end

    it 'translates has_many resource references to ids' do
      params = {
        'name' => 'x86_64',
        'hostgroups' => [
          mock({:id => 1}),
          mock({:id => 2})
        ]
      }
      expected_params = {
        'name' => 'x86_64',
        'hostgroup_ids' => [1, 2]
      }
      @adaptor.expects_action_with(action_class, { 'type' => :architecture, 'parameters' => expected_params, 'current_user_id' => nil })
      @planner.create(:architecture, { 'parameters' => params })
    end

    it 'translates has_many dynflow resource references to ids' do
      params = {
        'name' => 'x86_64',
        'hostgroups' => [
          dynflow_output_reference([:object1]),
          dynflow_output_reference([:object2])
        ]
      }
      @adaptor.expects_action.with do |action_class, input|
        input['parameters']['hostgroups'].nil? &&
        input['parameters']['hostgroup_ids'][0].subkeys == ['object1', 'id'] &&
        input['parameters']['hostgroup_ids'][1].subkeys == ['object2', 'id']
      end
      @planner.create(:architecture, { 'parameters' => params })
    end

    it 'translates has_one resource references to ids' do
      params = {
        'name' => 'img',
        'operatingsystem' => mock({:id => 3})
      }
      expected_params = {
        'name' => 'img',
        'operatingsystem_id' => 3
      }
      @adaptor.expects_action_with(action_class, { 'type' => :image, 'parameters' => expected_params, 'current_user_id' => nil })
      @planner.create(:image, { 'parameters' => params })
    end

    it 'translates has_one dynflow resource references to ids' do
      params = {
        'name' => 'img',
        'operatingsystem' => dynflow_output_reference([:object1])
      }
      @adaptor.expects_action.with do |action_class, input|
        input['parameters']['operatingsystem'].nil? &&
        input['parameters']['operatingsystem_id'].subkeys == ['object1', 'id']
      end
      @planner.create(:image, { 'parameters' => params })
    end
  end

  context 'create host' do
    let(:action_class) { ForemanOrchestrationTemplates::Tasks::CreateHostAction }

    it 'plans correct action' do
      @adaptor.expects_action_with(action_class, {'type' => :host, 'parameters' => {}, 'current_user_id' => nil })
      @planner.create(:host, {})
    end

    describe '#built' do
      it 'plans wait for action' do
        @adaptor.expects_action_with(action_class, {'type' => :host, 'parameters' => {}, 'current_user_id' => nil })
        @adaptor.expects_action.with do |action_class, input|
          action_class == ForemanOrchestrationTemplates::Tasks::WaitUntilHostInStateAction &&
          input['until'] == 'built' &&
          input['host_id'].subkeys == ['object', 'id']
        end

        @planner.create(:host, {}).built
      end
    end

    describe '#configured' do
      it 'plans wait for action' do
        @adaptor.expects_action_with(action_class, {'type' => :host, 'parameters' => {}, 'current_user_id' => nil })
        @adaptor.expects_action.with do |action_class, input|
          action_class == ForemanOrchestrationTemplates::Tasks::WaitUntilHostInStateAction &&
          input['until'] == 'configured' &&
          input['host_id'].subkeys == ['object', 'id']
        end

        @planner.create(:host, {}).configured
      end
    end
  end
end
