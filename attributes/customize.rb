require 'chef/log'
Chef::Log.level = :debug

#Chef::Log.info(node["opsworks"]["instance"]["hostname"])

default['cookbook-openshift3']['master_servers'] = [{"fqdn" => node["opsworks"]["instance"]["hostname"]+".localdomain", "ipaddress" => node["opsworks"]["instance"]["private_ip"]}]
default['cookbook-openshift3']['node_servers'] = [{"fqdn" => node["opsworks"]["instance"]["hostname"]+".localdomain", "ipaddress" => node["opsworks"]["instance"]["private_ip"]}]

default['cookbook-openshift3']['oauth_Identity'] = 'LDAPPasswordIdentityProvider'
#default['cookbook-openshift3']['openshift_master_identity_provider']['LDAPPasswordIdentityProvider'] = [{"name" => "ldap_identity","login" => true,"challenge" => true, "kind" => "LDAPPasswordIdentityProvider","ldap_server" => "directory.mdevlab.com","ldap_bind_dn" => "CN=openshift,OU=Service Accounts,OU=Markit,DC=directory,DC=mdevlab,DC=com", "ldap_bind_password" => "Welcome1", "ldap_insecure" => true,"ldap_base_ou" => "ou=Standard Users,ou=Markit,dc=directory,dc=mdevlab,dc=com?sAMAccountName", "ldap_preferred_username" => "sAMAccountName"}]

default['cookbook-openshift3']['openshift_master_identity_provider']['LDAPPasswordIdentityProvider'] = { 'name' => 'ldap_identity', 'login' => true, 'challenge' => true, 'kind' => 'LDAPPasswordIdentityProvider', 'ldap_server' => 'directory.mdevlab.com', 'ldap_bind_dn' => 'CN=openshift,OU=Service Accounts,OU=Markit,DC=directory,DC=mdevlab,DC=com', 'ldap_bind_password' => 'Welcome1', 'ldap_insecure' => true, 'ldap_base_ou' => 'ou=Standard Users,ou=Markit,dc=directory,dc=mdevlab,dc=com', 'ldap_preferred_username' => 'sAMAccountName' }
