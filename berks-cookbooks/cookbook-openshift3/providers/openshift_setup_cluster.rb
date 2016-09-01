#
# Cookbook Name:: cookbook-openshift3
# Providers:: openshift_setup_cluster
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'socket'
require 'timeout'

use_inline_resources
provides :openshift_setup_cluster if defined? provides

def whyrun_supported?
  true
end

action :setup do
  connect_to_peer = 'NOK'
  while connect_to_peer == 'NOK'
    cmd = Mixlib::ShellOut.new('crm_node -q').run_command
    if cmd.exitstatus == 1
      Mixlib::ShellOut.new("pcs cluster auth -u hacluster -p #{new_resource.cluster_password} #{new_resource.master_hosts.join(' ')} &> /dev/null").run_command
      Mixlib::ShellOut.new("pcs cluster setup --name openshift_master #{new_resource.master_hosts.join(' ')} --force &> /dev/null").run_command
      Mixlib::ShellOut.new('pcs cluster start --all &> /dev/null').run_command
      sleep 5
    else
      cmd = Mixlib::ShellOut.new('crm_node -q | grep 1').run_command
      if cmd.exitstatus == 1
        Mixlib::ShellOut.new("pcs cluster auth -u hacluster -p #{new_resource.cluster_password} #{new_resource.master_hosts.join(' ')} &> /dev/null").run_command
        Mixlib::ShellOut.new("pcs cluster setup --name openshift_master #{new_resource.master_hosts.join(' ')} --force &> /dev/null").run_command
        Mixlib::ShellOut.new('pcs cluster start --all &> /dev/null').run_command
        sleep 5
      else
        Mixlib::ShellOut.new('pcs cluster enable --all').run_command
        connect_to_peer = 'OK'
      end
    end
  end
  new_resource.updated_by_last_action(true)
end

action :init do
  connect_master = 'NOK'
  while connect_master == 'NOK'
    cmd = Mixlib::ShellOut.new("crm_mon --as-xml | grep -E 'resource id=\"master\".*role=\"Started\"'")
    cmd.run_command
    if cmd.exitstatus == 0
      connect_master = 'OK'
    else
      sleep(10)
    end
  end
  new_resource.updated_by_last_action(true)
end
