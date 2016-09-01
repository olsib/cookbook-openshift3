#
# Cookbook Name:: cookbook-openshift3
# Providers:: openshift_reghost
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

use_inline_resources
provides :openshift_reghost if defined? provides

def whyrun_supported?
  true
end

action :create do
  ruby_block "Creating DNS Record - #{new_resource.host}" do
    block do
      IO.popen("nsupdate -y #{new_resource.keyalgo}:#{new_resource.keyname}:#{new_resource.keysecret} -v", 'r+') do |pipe|
        pipe.puts "server #{new_resource.server}" unless new_resource.server.nil?
        pipe.puts "update delete #{new_resource.host} #{new_resource.ttl} #{new_resource.type}"
        pipe.puts "update add #{new_resource.host} #{new_resource.ttl} #{new_resource.type} #{new_resource.ipaddr}"
        pipe.puts 'show'
        pipe.puts 'send'

        pipe.close_write
        Chef::Log.info pipe.read
      end
    end

    action :create
  end
  new_resource.updated_by_last_action(true)
end

action :delete do
  ruby_block "Deleting DNS Record - #{new_resource.host}" do
    block do
      IO.popen("nsupdate -y #{new_resource.keyalgo}:#{new_resource.keyname}:#{new_resource.keysecret} -v", 'r+') do |pipe|
        pipe.puts "server #{new_resource.server}" unless new_resource.server.nil?
        pipe.puts "update delete #{new_resource.host} #{new_resource.type}"
        pipe.puts 'show'
        pipe.puts 'send'

        pipe.close_write
        Chef::Log.info pipe.read
      end
    end

    action :create
  end
  new_resource.updated_by_last_action(true)
end
