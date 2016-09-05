default['cookbook-openshift3']['oauth_Identity'] = 'LDAPPasswordIdentityProvider'

default['cookbook-openshift3']['openshift_master_identity_provider']['HTPasswdPasswordIdentityProvider'] = { 'name' => 'htpasswd_auth', 'login' => true, 'challenge' => true, 'kind' => 'HTPasswdPasswordIdentityProvider', 'filename' => "#{default['cookbook-openshift3']['openshift_common_master_dir']}/openshift-passwd" }

#default['cookbook-openshift3']['openshift_master_identity_provider']['LDAPPasswordIdentityProvider'] = { 'name' => 'ldap_identity1', 'login' => true, 'challenge' => true, 'kind' => 'LDAPPasswordIdentityProvider', 'ldap_server' => 'ldap1.domain.local', 'ldap_bind_dn' => '', 'ldap_bind_password' => '', 'ldap_insecure' => true, 'ldap_base_ou' => 'OU=people,DC=domain,DC=local', 'ldap_preferred_username' => 'uid' }

default['cookbook-openshift3']['openshift_master_identity_provider']['LDAPPasswordIdentityProvider'] = { 'name' => 'ldap_identity', 'login' => true, 'challenge' => true, 'kind' => 'LDAPPasswordIdentityProvider', 'ldap_server' => 'directory.mdevlab.com', 'ldap_bind_dn' => 'CN=openshift,OU=Service Accounts,OU=Markit,DC=directory,DC=mdevlab,DC=com', 'ldap_bind_password' => 'Welcome1', 'ldap_insecure' => true, 'ldap_base_ou' => 'ou=Standard Users,ou=Markit,dc=directory,dc=mdevlab,dc=com', 'ldap_preferred_username' => 'sAMAccountName' }


default['cookbook-openshift3']['openshift_master_identity_provider']['RequestHeaderIdentityProvider'] = { 'name' => 'header_provider_identify', 'login' => false, 'challenge' => false, 'kind' => 'RequestHeaderIdentityProvider', 'headers' => %w(X-Remote-User SSO-User), 'clientCA' => "#{default['cookbook-openshift3']['openshift_common_master_dir']}/master/ca.crt" }

default['cookbook-openshift3']['openshift_master_htpasswd'] = "#{default['cookbook-openshift3']['openshift_common_master_dir']}/openshift-passwd"
