#
# Cookbook Name:: cookbook-openshift3
# Recipe:: common
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'iptables::default'
include_recipe 'selinux_policy::default'

if node['cookbook-openshift3']['set_nameserver']
  if node['cookbook-openshift3']['nameserver']['nameservers'].empty? || node['cookbook-openshift3']['nameserver']['nameservers'][0].empty?
    Chef::Log.warn("#{cookbook_name}::#{recipe_name} requires that attribute ['nameserver']['nameservers'] is set.")
    Chef::Log.warn("#{cookbook_name}::#{recipe_name} \" Set Nameserver\" will be skipped to prevent a potential breaking change in /etc/resolv.conf.")
    return
  else
    ruby_block 'Disable PEER DNS if present' do
      block do
        peer_settings = Chef::Util::FileEdit.new("/etc/sysconfig/network-scripts/ifcfg-#{node['network']['default_interface']}")
        peer_settings.search_file_replace_line(/^PEERDNS=/, 'PEERDNS=no')
        peer_settings.write_file
      end
    end
    template '/etc/resolv.conf' do
      source 'resolv.conf.erb'
      owner 'root'
      group 'root'
      mode '0644'
      variables node['cookbook-openshift3']['nameserver']
    end
  end
end

if node['cookbook-openshift3']['register_dns']
  if node['cookbook-openshift3']['nameserver']['key_algorithm'].nil? || node['cookbook-openshift3']['nameserver']['key_name'].nil? || node['cookbook-openshift3']['nameserver']['key_secret'].nil?
    Chef::Log.warn("#{cookbook_name}::#{recipe_name} requires the attributes ['nameserver']['key_algorithm'] / ['nameserver']['key_name'] / ['nameserver']['key_secret'] to be set so as to register \"#{node['fqdn']}\" against the DNS.")
    Chef::Log.warn("#{cookbook_name}::#{recipe_name} \"Register DNS\" will be skipped...")
    return
  else
    ose_reghost node['fqdn'] do
      type :a
      keyalgo node['cookbook-openshift3']['nameserver']['key_algorithm']
      keyname node['cookbook-openshift3']['nameserver']['key_name']
      keysecret node['cookbook-openshift3']['nameserver']['key_secret']
    end
  end
end

if node['cookbook-openshift3']['install_method'].eql? 'yum'
  node['cookbook-openshift3']['yum_repositories'].each do |repo|
    yum_repository repo['name'] do
      description "#{repo['name'].capitalize} aPaaS Repository"
      baseurl repo['baseurl']
      gpgcheck repo['gpgcheck'] if repo.key?(:gpgcheck) && !repo['gpgcheck'].nil?
      gpgkey repo['gpgkey'] if repo.key?(:gpgkey) && !repo['gpgkey'].nil?
      sslverify repo['sslverify'] if repo.key?(:sslverify) && !repo['sslverify'].nil?
      action :create
    end
  end
end

service 'firewalld' do
  action [:stop, :disable]
end

package 'deltarpm'

node['cookbook-openshift3']['core_packages'].each do |pkg|
  package pkg
end

bash "Configure Docker to use the default FS type for #{node['fqdn']}" do
  code <<-EOF
    correct_fs=$(df -T /var | egrep -o 'xfs|ext4')
    sed -i "s/xfs/$correct_fs/" /usr/bin/docker-storage-setup
  EOF
  not_if "grep $(df -T /var | egrep -o 'xfs|ext4') /usr/bin/docker-storage-setup"
end

ruby_block 'Change HTTPD port xfer' do
  block do
    ose_settings = Chef::Util::FileEdit.new('/etc/httpd/conf/httpd.conf')
    ose_settings.search_file_replace_line(/^Listen/, "Listen #{node['cookbook-openshift3']['httpd_xfer_port']}")
    ose_settings.write_file
  end
  action :nothing
  notifies :restart, 'service[httpd]', :immediately
end
