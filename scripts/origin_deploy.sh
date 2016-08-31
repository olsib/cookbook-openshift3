#!/bin/bash
#
#
clear
cat << EOF

############################################################
# This installer is suitable for a standalone installation #
# "All in the box" (Master and Node in a server)           #
############################################################

EOF
IP_DETECT=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
DF=""
read -p "Please enter the FQDN of the server: " FQDN
read -p "Please enter the IP of the server (Auto Detect): $IP_DETECT" IP
while [ -z $DF ];
do
  read -p "Please enter the deployment type ([r]pm or [c]ontainer):" DF
  echo
done

if [ -z $IP ] 
then IP=$IP_DETECT
fi

# Add the above information in /etc/hosts
# Remove existing entries
sed -i "/$IP/d" /etc/hosts
echo -e "$IP\t$FQDN" >> /etc/hosts
hostnamectl set-hostname $FQDN
systemctl restart systemd-hostnamed.service
### Update the server
echo "Updating system, please wait..."
yum -y update -q -e 0
### Create the chef-local mode infrastructure
mkdir -p ~/chef-solo-example/{backup,cache,roles,cookbooks,environments}
cd ~/chef-solo-example/cookbooks
### Installing dependencies
echo "Installing prerequisite packages, please wait..."
yum -y install -q https://packages.chef.io/stable/el/7/chef-12.13.37-1.el7.x86_64.rpm git
### Installing cookbooks
git clone -q https://github.com/IshentRas/cookbook-openshift3.git
git clone -q https://github.com/chef-cookbooks/iptables.git
git clone -q https://github.com/chef-cookbooks/yum.git
git clone -q https://github.com/BackSlasher/chef-selinuxpolicy.git selinux_policy
cd ~/chef-solo-example
### Create the dedicated environment for Origin deployment
if [[ $DF =~ ^c ]]
then
cat << EOF > environments/origin.json
{
  "name": "origin",
  "description": "",
  "cookbook_versions": {

  },
  "json_class": "Chef::Environment",
  "chef_type": "environment",
  "default_attributes": {

  },
  "override_attributes": {
    "cookbook-openshift3": {
      "openshift_common_public_hostname": "console.${IP}.nip.io",
      "openshift_deployment_type": "origin",
      "deploy_containerized": true,
      "master_servers": [
        {
          "fqdn": "${FQDN}",
          "ipaddress": "$IP"
        }
      ],
      "node_servers": [
        {
          "fqdn": "${FQDN}",
          "ipaddress": "$IP"
        }
      ]
    }
  }
}
EOF
else
cat << EOF > environments/origin.json
{
  "name": "origin",
  "description": "",
  "cookbook_versions": {

  },
  "json_class": "Chef::Environment",
  "chef_type": "environment",
  "default_attributes": {

  },
  "override_attributes": {
    "cookbook-openshift3": {
      "openshift_common_public_hostname": "console.${IP}.nip.io",
      "openshift_deployment_type": "origin",
      "master_servers": [
        {
          "fqdn": "${FQDN}",
          "ipaddress": "$IP"
        }
      ],
      "node_servers": [
        {
          "fqdn": "${FQDN}",
          "ipaddress": "$IP"
        }
      ]
    }
  }
}
EOF
fi
### Specify the configuration details for chef-solo
cat << EOF > ~/chef-solo-example/solo.rb
cookbook_path [
               '/root/chef-solo-example/cookbooks',
               '/root/chef-solo-example/site-cookbooks'
              ]
environment_path '/root/chef-solo-example/environments'
file_backup_path '/root/chef-solo-example/backup'
file_cache_path '/root/chef-solo-example/cache'
log_location STDOUT
solo true
EOF
### Deploy OSE !!!!
chef-solo --environment origin -o recipe[cookbook-openshift3],recipe[cookbook-openshift3::master],recipe[cookbook-openshift3::node] -c ~/chef-solo-example/solo.rb
if ! $(oc get project test --config=/etc/origin/master/admin.kubeconfig &> /dev/null)
then 
  # Create a demo project
  oadm new-project demo --display-name="Origin Demo Project" --admin=demo
  # Set password for user demo
fi
# Reset password for demo user
htpasswd -b /etc/origin/openshift-passwd demo 1234
# Label the node as infra
oc label node $FQDN region=infra --config=/etc/origin/master/admin.kubeconfig &> /dev/null
cat << EOF

##### Installation DONE ######
#####                   ######
Your installation of Origin is completed.

A demo user has been created for you.
Password is : 1234

Access the console here : https://console.${IP}.nip.io:8443/console

You can also login via CLI : oc login -u demo

Next steps for you (To be performed as system:admin --> oc login -u system:admin):

1) Deploy registry -> oadm registry --service-account=registry --credentials=/etc/origin/master/openshift-registry.kubeconfig --config=/etc/origin/master/admin.kubeconfig
2) Deploy router -> oadm router --service-account=router --credentials=/etc/origin/master/openshift-router.kubeconfig
3) Read the documentation : https://docs.openshift.org/latest/welcome/index.html

You should disconnect and reconnect so as to get the benefit of bash-completion on commands

EOF
