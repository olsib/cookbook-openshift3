### Version specific Openshift 3.1.x ###

If you are running a Openshift 3.1.x environment you'll need to set docker_version to "1.8.2.x" Docker 1.9 is currently not supported due to performance issues.

### Common setting ###

<table>
<thead><tr><td><b>cookbook-openshift3 config item</b></td><td><b>Description</b></td><td><b>Default</b></td></tr></thead>
<tbody>
<tr><td>openshift_deployment_type</td><td>Set the deployment type for OSE ('origin' or 'enterprise').</td><td>enterprise</td></tr>
<tr><td>openshift_common_public_hostname</td><td>Set the master public hostname.</td><td>Output of 'ohai fqdn' if single master. Otherwise sets to openshift_cluster_name</td></tr>
<tr><td>openshift_HA</td><td>Set whether or not to deploy a highly-available services for OSE.</td><td>false</td></tr>
<tr><td>docker_version</td><td>Set the version of Docker to be installed.</td><td>nil</td></tr>
<tr><td>docker_log_options</td><td>Set the capability for managing Docker container logs.</td><td>nil</td></tr>
<tr><td>deploy_containerized</td><td>Set whether or not to deploy a containerized version of Openshift.</td><td>false</td></tr>
<tr><td>
deploy_example</td><td>Set whether or not to deploy the openshift example templates files.<td>false</td></tr>
<tr><td>
deploy_dnsmasq</td><td>Set whether or not to deploy the dnsmasq resolution against SkyDNS. Need to have NetworkManager running<td>false</td></tr>
<tr><td>install_method</td><td>Set the installing method for packing.</td><td>yum</td></tr>
<tr><td>
yum_repositories</td><td>Set the yum repositories. [*yum_repos*](https://github.com/chef-cookbooks/yum/blob/master/README.md#parameters)</td><td></td></tr>
<tr><td>httpd_xfer_port</td><td>Set the port used for retrieving certificates.</td><td>9999</td></tr>
<tr><td>set_nameserver</td><td>Set the nameserver(s) for the host.</td><td>false</td></tr>
<tr><td>register_dns</td><td>Set the registration of the host against the SOA nameserver.</td><td>false</td></tr>
<tr><td>core_packages</td><td>Set the list of the pre-requisite packages.</td><td>['libselinux-python', 'wget', 'vim-enhanced', 'net-tools', 'bind-utils', 'git', 'bash-completion docker', 'bash-completion', 'dnsmasq']</td></tr>
<tr><td>osn_cluster_dns_domain</td><td>Set the SkyDNS domain name.</td>cluster.local<td></td></tr>
<tr><td>enabled_firewall_additional_rules_node</td><td>Set the list of additional FW rules to set for a node.</td><td>[]</td></tr>
<tr><td>openshift_data_dir</td><td>Set the default directory for OSE data.</td><td>/var/lib/origin</td></tr>
<tr><td>openshift_master_cluster_password</td><td>Set the default password for the pcs administration account.</td><td>'openshift_cluster'</td></tr>
<tr><td>openshift_common_master_dir</td><td>Set the default root directory for master.</td><td>/etc/origin</td></tr>
<tr><td>openshift_common_node_dir</td><td>Set the default root directory for node.</td><td>/etc/origin</td></tr>
<tr><td>openshift_common_portal_net</td><td>Set the default user-defined networks for Kubernetes. Set to 172.30.0.0/16 to match the default Docker CIDR. Once set, do not update.</td><td>172.30.0.0/16</td></tr>
<tr><td>openshift_docker_insecure_registry_arg</td><td>Set the list of insecure registries for Docker.</td><td>nil</td></tr>
<tr><td>openshift_docker_add_registry_arg</td><td>Set the list of registries to add to Docker.</td><td>nil</td></tr>
<tr><td>openshift_docker_block_registry_arg</td><td>Set the list of registries to block in Docker.</td><td>nil</td></tr>
<tr><td>openshift_common_default_nodeSelector</td><td>Set the default label for node selector.</td><td>region=user</td></tr>
<tr><td>openshift_common_infra_label</td><td>Set the default label for Infra project (default, openshift-infra).</td><td>region=infra</td></tr>
<tr><td>openshift_common_examples_base</td><td></td><td>'/usr/share/openshift/examples'</td></tr>
<tr><td>openshift_common_hostname</td><td>Set the master common name.</td><td>Output of 'ohai fqdn'</td></tr>
<tr><td>openshift_common_ip</td><td>Set the default IP for the node.</td><td>Output of 'ohai ipaddress'</td></tr>
<tr><td>openshift_common_infra_project</td><td>Set the list of default Infra project.</td><td>['default','openshift-infra']</td></tr>
<tr><td>openshift_common_service_accounts_additional</td><td>Set the list of additional service accounts to create.</td><td>[]</td></tr>
<tr><td>openshift_common_use_openshift_sdn</td><td>Set whether or not to use SDN network.</td><td>true</td></tr>
<tr><td>openshift_common_sdn_network_plugin_name</td><td>Set the default SDN plugin name.</td><td>redhat/openshift-ovs-subnet</td></tr>
<tr><td>openshift_common_registry_url</td><td>Set the default registry URL.</td><td>'openshift3/ose-${component}:${version}'</td></tr>
<tr><td>openshift_master_bind_addr</td><td>Set default bind address.</td><td>'0.0.0.0'</td></tr>
<tr><td>openshift_master_api_port</td><td>Set default listening port for Master API.</td><td>8443</td></tr>
<tr><td>openshift_master_console_port</td><td>Set the default listening port for console.</td><td>8443</td></tr>
<tr><td>openshift_master_public_api_url</td><td>Set the default public URL for connecting to the API.</td><td>https://openshift_common_public_hostname:8443</td></tr>
<tr><td>openshift_master_api_url</td><td>Set the default internal URL for connecting to the API. Reserved to master(s). Not recommended to change</td><td>https://openshift_common_public_hostname:8443</td></tr>
<tr><td>openshift_master_console_url</td><td>Set the default public URL for connecting to the Web Console.</td><td>https://openshift_common_public_hostname:8443/console</td></tr>
<tr><td>openshift_master_console_port</td><td>Set the default listening port for console.</td><td>8443</td></tr>
<tr><td>openshift_master_controllers_port</td><td>Set the default listening port for controllers.</td><td>8444</td></tr>
<tr><td>openshift_master_controller_lease_ttl</td><td>Set the default lease TTL for controllers.</td><td>30</td></tr>
<tr><td>openshift_master_embedded_dns</td><td>Set whether or not to use the embedded DNS.</td><td>true</td></tr>
<tr><td>openshift_master_embedded_kube</td><td>Set whether ot not the use the embedded Kubernetes server.</td><td>true</td></tr>
<tr><td>openshift_master_debug_level</td><td>Set the default level for master logging.</td><td>2 </td></tr>
<tr><td>openshift_master_dns_port</td><td>Set the default port for SkyDNS.</td><td>When deploy_dnsmasq is set to "true" : 8053. Otherwise : 53</td></tr>
<tr><td>openshift_master_label</td><td>Set the default label for master selector.</td><td>region=infra</td></tr>
<tr><td>openshift_master_generated_configs_dir</td><td>Set the default directory for generating the node certificates.</td><td>/var/www/html/generated-configs'</td></tr>
<tr><td>openshift_master_router_subdomain</td><td>Set the default domain for the HaProxy routeaProxy.</td><td>cloudapps.domain.local'</td></tr>
<tr><td>openshift_master_sdn_cluster_network_cidr</td><td>Set the default SDN Network address.</td><td>10.1.0.0/16</td></tr>
<tr><td>openshift_master_sdn_host_subnet_length</td><td>Set the default number of allocated bit for hosts.</td><td>8</td></tr>
<tr><td>openshift_master_session_max_seconds</td><td>Set maximum session time in second.</td><td>3600</td></tr>
<tr><td>openshift_master_access_token_max_seconds</td><td>Set maximum access token lifetime in second.</td><td>86400</td></tr>
<tr><td>openshift_master_auth_token_max_seconds</td><td>Set maximum Oauth token lifetime in second.</td><td>500</td></tr>
<tr><td>openshift_node_debug_level</td><td>Set the default level for node logging.</td><td>2</td></tr>
<tr><td>openshift_node_iptables_sync_period</td><td>Set the default kube-proxy iptables sync period.</td><td>5s</td></tr>
<tr><td>openshift_node_max_pod</td><td>Set the maximum number of running PODs on a node.</td><td>40</td></tr>
<tr><td>openshift_node_sdn_mtu_sdn</td><td>Set the default MTU size for SDN.</td><td>1450</td></tr>
<tr><td>openshift_node_minimum_container_ttl_duration']</td><td>The minimum age that a container is eligible for garbage collection.</td><td>10s</td></tr>
<tr><td>openshift_node_maximum_dead_containers_per_container']</td><td>The number of instances to retain per pod container.</td><td>2</td></tr>
<tr><td>openshift_node_maximum_dead_containers']</td><td>The maximum number of total dead containers in the node.</td><td>100</td></tr>
<tr><td>openshift_node_image_gc_high_threshold']</td><td>The percent of disk usage which triggers image garbage collection.</td><td>90</td></tr>
<tr><td>openshift_node_image_gc_low_threshold']</td><td>The percent of disk usage to which image garbage collection attempts to free.</td><td>80</td></tr>
<tr><td>master_generated_certs_dir</td><td>Set the default directory for generating the master certificates.</td><td>/var/www/html/master/generated_certs</td></tr>
<tr><td>etcd_generated_certs_dir</td><td>Set the default directory for generating the etcd certificates.</td><td>/var/www/html/etcd/generated_certs</td></tr>
<tr><td>etcd_cof_dir</td><td>Set the default root directory for etcd configs.</td><td>/etc/etcd</td></tr>
<tr><td>etcd_intial_cluster_token</td><td>'etcd-cluster-1'</td><td>etcd-cluster-1</td></tr>
<tr><td>etcd_data_dir</td><td>Set the default root directory for etcd data.</td><td>/var/lib/etcd</td></tr>
<tr><td>etcd_client_port</td><td>Set default listening port for ETCD Client.</td><td>2379</td></tr>
<tr><td>etcd_peer_port</td><td>Set default listening port for ETCD Peer.</td><td>2380</td></tr>
</tbody>
</table>

### Highly-availability settings ###

<table>
<thead><tr><td><b>cookbook-openshift3 config item</b></td><td><b>Description</b></td><td><b>Default</b></td></tr></thead>
<tr><td>openshift_cluster_name</td><td>Set the cluster public hostname.</td><td>nil</td></tr>
<tr><td>openshift_master_cluster_vip</td><td>Set the cluster public IP address (Mandatory when using Pacemaker deployment).</td><td>nil</td></tr>
<tr><td>openshift_HA_method</td><td>Set the HA Master method ('native' or 'pacemaker').</td><td>native</td></tr>
</table>

### Identity provider settings ###

<table>
<thead><tr><td><b>cookbook-openshift3 config item</b></td><td><b>Description</b></td><td><b>Default</b></td></tr></thead>
<tr><td>oauth_Identity</td><td>Set the default identity provider ('HTPasswdPasswordIdentityProvider', 'LDAPPasswordIdentityProvider', 'RequestHeaderIdentityProvider').</td><td>HTPasswdPasswordIdentityProvider</td></tr>
</table>
