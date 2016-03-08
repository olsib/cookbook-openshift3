#
# Cookbook Name:: cookbook-openshift3
# Recipe:: master_config_post
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

service_accounts = node['cookbook-openshift3']['openshift_common_service_accounts_additional'].any? ? node['cookbook-openshift3']['openshift_common_service_accounts'] + node['cookbook-openshift3']['openshift_common_service_accounts_additional'] : node['cookbook-openshift3']['openshift_common_service_accounts']

service_accounts.each do |serviceaccount|
  execute "Creation service account: \"#{serviceaccount['name']}\" ; Namespace: \"#{serviceaccount['namespace']}\"" do
    command 'echo "{\"kind\": \"ServiceAccount\",\"apiVersion\": \"v1\",\"metadata\": {\"name\": \"${serviceaccount}\"}}" | oc create -f - -n ${namespace}'
    environment(
      'serviceaccount' => serviceaccount['name'],
      'namespace' => serviceaccount['namespace']
    )
    not_if "#{node['cookbook-openshift3']['openshift_common_client_binary']} get sa #{serviceaccount['name']} -n #{serviceaccount['namespace']}"
  end

  next unless serviceaccount.key?('scc')
  execute "Add SCC to service account: \"#{serviceaccount['name']}\" ; Namespace: \"#{serviceaccount['namespace']}\"" do
    command "#{node['cookbook-openshift3']['openshift_common_admin_binary']} policy add-scc-to-user privileged system:serviceaccount:#{serviceaccount['namespace']}:#{serviceaccount['name']}"
    not_if "#{node['cookbook-openshift3']['openshift_common_client_binary']} get scc/privileged -n default -o yaml | grep default:#{serviceaccount['name']}"
  end
end

node['cookbook-openshift3']['openshift_common_infra_project'].each do |project|
  execute "Enforce #{project} project node-selector" do
    command "#{node['cookbook-openshift3']['openshift_common_client_binary']} get namespace #{project} -o yaml | sed '/annotations:/a\\    openshift.io/node-selector: #{node['cookbook-openshift3']['openshift_common_infra_label']}' | #{node['cookbook-openshift3']['openshift_common_client_binary']} replace -n #{project} -f -"
    not_if "#{node['cookbook-openshift3']['openshift_common_client_binary']} get namespace #{project} -o yaml | grep openshift.io/node-selector"
  end
end
