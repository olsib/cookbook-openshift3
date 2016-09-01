#
# Cookbook Name:: cookbook-openshift3
# Recipe:: node
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

master_servers = node['cookbook-openshift3']['use_params_roles'] && !Chef::Config[:solo] ? search(:node, %(role:"#{node['cookbook-openshift3']['master_servers']}")).sort! : node['cookbook-openshift3']['master_servers']
node_servers = node['cookbook-openshift3']['use_params_roles'] && !Chef::Config[:solo] ? search(:node, %(role:"#{node['cookbook-openshift3']['node_servers']}")).sort! : node['cookbook-openshift3']['node_servers']
path_certificate = node['cookbook-openshift3']['use_wildcard_nodes'] ? 'wildcard_nodes.tgz' : "#{node['fqdn']}.tgz"

if node_servers.find { |server_node| server_node['fqdn'] == node['fqdn'] }
  file '/usr/local/etc/.firewall_node_additional.txt' do
    content node['cookbook-openshift3']['enabled_firewall_additional_rules_node'].join('\n')
    owner 'root'
    group 'root'
  end

  node['cookbook-openshift3']['enabled_firewall_rules_node'].each do |rule|
    iptables_rule rule do
      action :enable
    end
  end

  directory node['cookbook-openshift3']['openshift_node_config_dir'] do
    recursive true
  end

  if node['cookbook-openshift3']['deploy_containerized']
    execute 'Pull NODE docker image' do
      command "docker pull #{node['cookbook-openshift3']['openshift_docker_node_image']}:#{node['cookbook-openshift3']['openshift_docker_image_version']}"
      not_if "docker images  | grep #{node['cookbook-openshift3']['openshift_docker_node_image']}.*#{node['cookbook-openshift3']['openshift_docker_image_version']}"
    end

    execute 'Pull OVS docker image' do
      command "docker pull #{node['cookbook-openshift3']['openshift_docker_ovs_image']}:#{node['cookbook-openshift3']['openshift_docker_image_version']}"
      not_if "docker images  | grep #{node['cookbook-openshift3']['openshift_docker_ovs_image']}.*#{node['cookbook-openshift3']['openshift_docker_image_version']}"
    end

    template "/etc/systemd/system/#{node['cookbook-openshift3']['openshift_service_type']}-node-dep.service" do
      source 'service_node-deps-containerized.service.erb'
      notifies :reload, 'service[daemon-reload]', :immediately
    end

    template "/etc/systemd/system/#{node['cookbook-openshift3']['openshift_service_type']}-node.service" do
      source 'service_node-containerized.service.erb'
      notifies :reload, 'service[daemon-reload]', :immediately
    end

    template '/etc/systemd/system/openvswitch.service' do
      source 'service_openvsitch-containerized.service.erb'
      notifies :reload, 'service[daemon-reload]', :immediately
    end

    template '/etc/sysconfig/openvswitch' do
      source 'service_openvswitch.sysconfig.erb'
      notifies :restart, 'service[openvswitch]', :immediately
    end
  end

  template "/etc/sysconfig/#{node['cookbook-openshift3']['openshift_service_type']}-node" do
    source 'service_node.sysconfig.erb'
    notifies :restart, "service[#{node['cookbook-openshift3']['openshift_service_type']}-node]", :delayed
  end

  package "#{node['cookbook-openshift3']['openshift_service_type']}-node" do
    action :install
    not_if { node['cookbook-openshift3']['deploy_containerized'] }
  end

  package "#{node['cookbook-openshift3']['openshift_service_type']}-sdn-ovs" do
    action :install
    only_if { node['cookbook-openshift3']['openshift_common_use_openshift_sdn'] == true }
    not_if { node['cookbook-openshift3']['deploy_containerized'] }
  end

  remote_file "Retrieve certificate from Master[#{master_servers.first['fqdn']}]" do
    path "#{node['cookbook-openshift3']['openshift_node_config_dir']}/#{node['fqdn']}.tgz"
    source "http://#{master_servers.first['ipaddress']}:#{node['cookbook-openshift3']['httpd_xfer_port']}/generated-configs/#{path_certificate}"
    action :create_if_missing
    notifies :run, 'execute[Extract certificate to Node folder]', :immediately
    retries 12
    retry_delay 5
  end

  execute 'Extract certificate to Node folder' do
    command "tar xzf #{node['fqdn']}.tgz"
    cwd node['cookbook-openshift3']['openshift_node_config_dir']
    action :nothing
  end

  if node['cookbook-openshift3']['deploy_dnsmasq']
    template '/etc/dnsmasq.d/origin-dns.conf' do
      source 'origin-dns.conf.erb'
    end

    cookbook_file '/etc/NetworkManager/dispatcher.d/99-origin-dns.sh' do
      source '99-origin-dns.sh'
      owner 'root'
      group 'root'
      mode '0755'
      action :create
      notifies :restart, 'service[NetworkManager]', :immediately
    end

  end

  template node['cookbook-openshift3']['openshift_node_config_file'] do
    source 'node.yaml.erb'
    notifies :restart, "service[#{node['cookbook-openshift3']['openshift_service_type']}-node]", :immediately
    notifies :enable, "service[#{node['cookbook-openshift3']['openshift_service_type']}-node]", :immediately
  end

  selinux_policy_boolean 'virt_use_nfs' do
    value true
  end

  service "#{node['cookbook-openshift3']['openshift_service_type']}-node" do
    action :start
  end
end
