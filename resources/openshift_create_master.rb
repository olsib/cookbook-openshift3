#
# Cookbook Name:: cookbook-openshift3
# Resources:: openshift_create_master
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

provides :openshift_create_master
#resource_name :openshift_create_master

actions :create

default_action :create

attribute :named_certificate, kind_of: Array, regex: /.*/, required: true, default: []
attribute :origins, kind_of: Array, regex: /.*/, required: true, default: []
attribute :single_instance, kind_of: [TrueClass, FalseClass], required: false, default: true
attribute :master_file, kind_of: String, regex: /.*/, required: true, default: nil
attribute :etcd_servers, kind_of: Array, regex: /.*/, required: false, default: []
attribute :masters_size, kind_of: [String, Integer], regex: /.*/, required: false, default: nil
attribute :openshift_service_type, kind_of: [String, Integer], regex: /.*/, required: true, default: nil
attribute :cluster, kind_of: [TrueClass, FalseClass], regex: /.*/, required: false, default: false
