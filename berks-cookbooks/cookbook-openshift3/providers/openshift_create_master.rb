#
# Cookbook Name:: cookbook-openshift3
# Providers:: openshift_create_master
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'openssl'

use_inline_resources
provides :openshift_create_master if defined? provides

def whyrun_supported?
  true
end

named_certificates = []

action :create do
  named_certificate_original = new_resource.named_certificate
  named_certificate_original.each do |named|
    certfile = named['certfile']
    raw = ::File.read certfile
    certificate = OpenSSL::X509::Certificate.new raw
    common_name = certificate.subject.to_a.find { |e| e.include?('CN') }[1].split(' ')
    begin
      subject_alt_name = certificate.extensions.find { |e| e.oid == 'subjectAltName' }.value.tr(',', '').gsub(/DNS:/, '').split(' ')
    rescue NoMethodError
      print 'No SAN detected'
    ensure
      names = subject_alt_name.nil? ? common_name : common_name + subject_alt_name
      named_hash = {}
      named_hash.store('certfile', named['certfile'])
      named_hash.store('keyfile', named['keyfile'])
      named_hash.store('names', names)
      named_certificates << named_hash
    end
  end

  service "#{new_resource.openshift_service_type}-master"
  service "#{new_resource.openshift_service_type}-master-api"
  service "#{new_resource.openshift_service_type}-master-controllers"

  if new_resource.cluster
    template new_resource.master_file do
      source 'master.yaml.erb'
      variables(
        erb_corsAllowedOrigins: new_resource.origins,
        single_instance: new_resource.single_instance,
        erb_master_named_certificates: named_certificates,
        etcd_servers: new_resource.etcd_servers,
        masters_size: new_resource.masters_size
      )
      notifies :restart, "service[#{new_resource.openshift_service_type}-master-api]", :delayed
      notifies :restart, "service[#{new_resource.openshift_service_type}-master-controllers]", :delayed
    end
  else
    template new_resource.master_file do
      source 'master.yaml.erb'
      variables(
        erb_corsAllowedOrigins: new_resource.origins,
        single_instance: new_resource.single_instance,
        erb_master_named_certificates: named_certificates,
        etcd_servers: new_resource.etcd_servers,
        masters_size: new_resource.masters_size
      )
      notifies :restart, "service[#{new_resource.openshift_service_type}-master]", :delayed
    end
  end
end
