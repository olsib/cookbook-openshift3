default['cookbook-openshift3']['master_servers'] = [{"fqdn" => "openshift1.localdomain", "ipaddress" => "10.35.196.58"}]
default['cookbook-openshift3']['node_servers'] = [{"fqdn" => "openshift1.localdomain", "ipaddress" => "10.35.196.58"}]
default['cookbook-openshift3']['oauth_Identity'] = 'LDAPPasswordIdentityProvider'
default['cookbook-openshift3']['openshift_master_identity_provider']['LDAPPasswordIdentityProvider'] = [{"name" => "ldap_identity","login" => true,"challenge" => true, "kind" => "LDAPPasswordIdentityProvider", "ldap_server" => "directory.mdevlab.com", "ldap_bind_dn" => "CN=openshift,OU=Service Accounts,OU=Markit,DC=directory,DC=mdevlab,DC=com", "ldap_bind_password" => "Welcom1", "ldap_insecure" => true,"ldap_base_ou" => "ou=Standard Users,ou=Markit,dc=directory,dc=mdevlab,dc=com?sAMAccountName", "ldap_preferred_username" => "sAMAccountName"}]
