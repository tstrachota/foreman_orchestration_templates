name = input(:name, :description => 'Name')
hg = input :host_group, :description => 'Host Group', :type => :select_resource, :resource => 'Hostgroup'
cr = input :compute_resource, :description => 'Compute Resource', :type => :select_resource, :resource => 'ComputeResource'
cp = input :compute_profile, :description => 'Compute Profile', :type => :select_resource, :resource => 'ComputeProfile'

host_params = {
    :name => name,
    :compute_resource => cr,
    :compute_profile => cp,
    :hostgroup => hg
}

proxy = create :host, :parameters => host_params
proxy.configured
