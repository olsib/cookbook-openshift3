#
# Cookbook Name:: cookbook-openshift3
# Resources:: openshift_reghost
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

provides :openshift_reghost
#resource_name :openshift_reghost

actions :create, :delete

default_action :create

attribute :type,      equal_to: [:cname, :a]
attribute :ttl,       kind_of: Integer, default: 86_400
attribute :host,      kind_of: String,  name_attribute: true
attribute :ipaddr,    kind_of: String,  default: node['ipaddress']
attribute :server,    kind_of: String,  regex: Resolv::IPv4::Regex, default: node['cookbook-openshift3']['nsupdate_server']
attribute :keyalgo,   kind_of: String,  regex: /.*/, required: true, default: nil
attribute :keyname,   kind_of: String,  regex: /.*/, required: true, default: nil
attribute :keysecret, kind_of: String,  regex: /.*/, required: true, default: nil
