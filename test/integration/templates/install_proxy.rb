proxy = input :host, :description => 'Target host to install proxy on', :type => :select_resource, :resource => 'Host'

generate_certs_inputs = {
  :proxy_fqdn => proxy.name
}
execute :on => foreman_server, :name => 'Generate proxy certificates', :inputs => generate_certs_inputs, :script => <<-TPL
  proxy_fqdn=<%= input(proxy_fqdn) %>
  capsule_dir=~/proxy_certificates/$proxy_fqdn
  mkdir -p $capsule_dir

  pushd $capsule_dir
  capsule-certs-generate --no-colors --capsule-fqdn "<%= input(proxy_fqdn) %>" --certs-tar "./certs.tar" > ./cert_generate_out.txt 2>&1
  cat ./cert_generate_out.txt | egrep '^[ ]*foreman-installer|^[ ]*--' > ./capsule_installer.sh

  scp capsule_installer.sh $proxy_fqdn:~/
  scp certs.tar $proxy_fqdn:~/

  popd

  # rm -rf $capsule_dir
TPL

execute :on => proxy, :name => 'Add proxy repos', :script => <<-TPL
  yum -y localinstall http://fedorapeople.org/groups/katello/releases/yum/3.2/katello/el7/x86_64/katello-repos-latest.rpm
  yum -y localinstall http://yum.theforeman.org/releases/1.13/el7/x86_64/foreman-release.rpm
  yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
  yum -y localinstall http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum -y install foreman-release-scl
TPL

install_proxy_inputs = {
  :katello_fqdn => 'katello.example.com'
}
execute :on => proxy, :name => 'Install proxy', :inputs => install_proxy_inputs, :script => <<-TPL
  yum -y update
  yum install -y katello-capsule

  yum -y localinstall http://katello.example.com/pub/katello-ca-consumer-latest.noarch.rpm
  subscription-manager register --org "Default_Organization"

  foreman-installer --scenario capsule\
                    --parent-fqdn           "katello.example.com"\
                    --register-in-foreman   "true"\
                    --foreman-base-url      "https://katello.example.com"\
                    --trusted-hosts         "katello.example.com"\
                    --trusted-hosts         "mycapsule.example.com"\
                    --oauth-consumer-key    "UVrAZfMaCfBiiWejoUVLYCZHT2xhzuFV"\
                    --oauth-consumer-secret "ZhH8p7M577ttNU3WmUGWASag3JeXKgUX"\
                    --pulp-oauth-secret     "TPk42MYZ42nAE3rZvyLBh7Lxob3nEUi8"\
                    --certs-tar             "~/mycapsule.example.com-certs.tar"
TPL


