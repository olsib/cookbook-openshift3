#
# Cookbook Name:: cookbook-openshift3
# Recipe:: nodes_certificates
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

node_servers = node['cookbook-openshift3']['use_params_roles'] && !Chef::Config[:solo] ? search(:node, %(role:"#{node['cookbook-openshift3']['node_servers']}")).sort! : node['cookbook-openshift3']['node_servers']

directory node['cookbook-openshift3']['openshift_master_generated_configs_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

if node['cookbook-openshift3']['use_wildcard_nodes']
  execute 'Generate certificate directory for Wildcard node servers' do
    command 'mkdir -p /tmp/wildcard_nodes'
    creates "#{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/wildcard_nodes.tgz"
  end

  execute 'Generate certificate for Wildcard node servers' do
    command "#{node['cookbook-openshift3']['openshift_common_admin_binary']} create-api-client-config \
            --client-dir=/tmp/wildcard_nodes \
            --certificate-authority=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.crt \
            --signer-cert=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.crt --signer-key=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.key \
            --signer-serial=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.serial.txt --user='system:node:wildcard_nodes'\
            --groups=system:nodes --master=#{node['cookbook-openshift3']['openshift_master_api_url']}"
    creates "#{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/wildcard_nodes.tgz"
  end

  execute 'Generate the node server certificate for Wildcard node servers' do
    command "#{node['cookbook-openshift3']['openshift_common_admin_binary']} ca create-server-cert --cert=server.crt --key=server.key --overwrite=true \
             --hostnames=#{node['cookbook-openshift3']['wildcard_domain']} --signer-cert=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.crt --signer-key=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.key \
             --signer-serial=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.serial.txt && mv server.{key,crt} /tmp/wildcard_nodes"
    cwd '/tmp'
    creates "#{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/wildcard_nodes.tgz"
  end

  execute 'Generate a tarball for Wildcard node servers' do
    command "tar czvf #{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/wildcard_nodes.tgz \
              -C /tmp/wildcard_nodes . --remove-files && chown apache: #{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/wildcard_nodes.tgz"
    creates "#{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/wildcard_nodes.tgz"
  end
else
  node_servers.each do |node_server|
    execute "Generate certificate directory for #{node_server['fqdn']}" do
      command "mkdir -p /tmp/#{node_server['fqdn']}"
      creates "#{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/#{node_server['fqdn']}.tgz"
    end

    execute "Generate certificate for #{node_server['fqdn']}" do
      command "#{node['cookbook-openshift3']['openshift_common_admin_binary']} create-api-client-config \
              --client-dir=/tmp/#{node_server['fqdn']} \
              --certificate-authority=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.crt \
              --signer-cert=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.crt --signer-key=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.key \
              --signer-serial=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.serial.txt --user='system:node:#{node_server['fqdn']}' \
              --groups=system:nodes --master=#{node['cookbook-openshift3']['openshift_master_api_url']}"
      creates "#{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/#{node_server['fqdn']}.tgz"
    end

    execute "Generate the node server certificate for #{node_server['fqdn']}" do
      command "#{node['cookbook-openshift3']['openshift_common_admin_binary']} ca create-server-cert --cert=server.crt --key=server.key --overwrite=true \
              --hostnames=#{node_server['fqdn'] + ',' + node_server['ipaddress']} --signer-cert=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.crt --signer-key=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.key \
              --signer-serial=#{node['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.serial.txt && mv server.{key,crt} /tmp/#{node_server['fqdn']}"
      cwd '/tmp'
      creates "#{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/#{node_server['fqdn']}.tgz"
    end

    execute "Generate a tarball for #{node_server['fqdn']}" do
      command "tar czvf #{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/#{node_server['fqdn']}.tgz \
               -C /tmp/#{node_server['fqdn']} . --remove-files && chown apache: #{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/#{node_server['fqdn']}.tgz"
      creates "#{node['cookbook-openshift3']['openshift_master_generated_configs_dir']}/#{node_server['fqdn']}.tgz"
    end
  end
end
