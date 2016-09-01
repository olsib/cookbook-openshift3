#
# Cookbook Name:: cookbook-openshift3
# Resources:: openshift_setup_cluster
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

provides :openshift_setup_cluster
resource_name :openshift_setup_cluster

actions :setup, :init

default_action :setup

attribute :master_hosts, kind_of: Array, regex: /.*/, required: false, default: []
attribute :cluster_password, kind_of: String, regex: /.*/, required: false, default: nil
