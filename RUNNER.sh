#!/bin/bash

# GLOBAL VARIABLES
RAXACCOUNTID=`grep account /root/.raxpub  | awk {'print $3'}`
RAXUSERNAME=`grep username /root/.raxpub  | awk {'print $3'}`
RAXAPIKEY=`grep api_key /root/.raxpub  | awk {'print $3'}`

# Get a RAX auth token
RAXAUTHTOKEN=`curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X POST -d "{\"auth\":{\"RAX-KSKEY:apiKeyCredentials\":{\"username\":\"$RAXUSERNAME\", \"apiKey\":\"$RAXAPIKEY\"}}}" -H "Content-Type: application/json" | python -m json.tool | grep '"token":' -A5 | grep '"id"' | awk {'print $2'} | cut -d\" -f2`

# VARIABLES SPECIFIC TO THIS BUILD
SERVERFLAVOR="general1-4"
SSHKEY="root-hdp-jenkins"
REGION="LON"
OSIMAGE="4319b4ff-f887-4c52-9464-34536d202143"  # CentOS7
KEYLOCATION=/root/.ssh/id_rsa2
BUILDIDENTIFIER=`pwgen 20 1`
ANSIBLEVERSION="2.1.3.0"


#_-----------------------
#  MAIN ACTION
#_-----------------------
BRLINE="\n------------------------------------------------------------------------------------\n"

echo "Creating a workstation server named [HDP-testing-jenkins-$BUILDIDENTIFIER] in Rackspace Cloud.."
#SERVERID=`curl -s -X POST https://$REGION.servers.api.rackspacecloud.com/v2/$RAXACCOUNTID/servers -d "{\"server\" : {\"name\" : \"HDP-testing-jenkins-$BUILDIDENTIFIER\",\"imageRef\": \"$OSIMAGE\",\"flavorRef\": \"$SERVERFLAVOR\", \"key_name\": \"$SSHKEY\"}}" -H "Content-Type: application/json" -H "X-Auth-Token: $RAXAUTHTOKEN" | python -m json.tool | grep '"id"' | awk {'print $2'} | cut -d\" -f2`
# SERVERID="8176d990-eaa2-43bc-9ea9-63885e47713f"
SERVERID=e0118434-ef26-4a5c-b40f-f81ca90bac00

echo "Created server with ID $SERVERID.."

echo "Waiting 120 seconds for workstation server to come up.."
#sleep 120;


echo "Get IP address of workstation server.."
SERVERIP=`curl -s -X GET https://$REGION.servers.api.rackspacecloud.com/v2/$RAXACCOUNTID/servers/$SERVERID  -H "X-Auth-Token: $RAXAUTHTOKEN" | python -m json.tool | grep "accessIPv4"| awk {'print $2'} | cut -d\" -f2`


echo "Testing SSH access to cloud server with IP $SERVERIP.."
WORKSTATIONSSH="ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l root -i $KEYLOCATION $SERVERIP"
echo `$WORKSTATIONSSH "whoami;hostname"`


echo "Copying the repo folder to temporary location.."
rm -rf /tmp/ansible-hadoop-BUILDTEST
cp -a /var/lib/jenkins/workspace/ansible-hadoop /tmp/ansible-hadoop-BUILDTEST


echo "Archiving the repo folder and uploading to workstation server [HDP-testing-jenkins-$BUILDIDENTIFIER]"
cd /tmp
tar czf /tmp/HDP-testing-jenkins-$BUILDIDENTIFIER.tgz /tmp/ansible-hadoop-BUILDTEST


echo "Cleanup,extract the repo folder to /root/tmp/ansible-hadoop on workstation"
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $KEYLOCATION /tmp/HDP-testing-jenkins-$BUILDIDENTIFIER.tgz root@$SERVERIP:/tmp
$WORKSTATIONSSH "rm -rf /root/tmp/ansible-hadoop-BUILDTEST; tar xf /tmp/HDP-testing-jenkins-$BUILDIDENTIFIER.tgz; ls -al /root/tmp/ansible-hadoop-BUILDTEST"


echo "Install required yum and pip packages on workstation"
$WORKSTATIONSSH "yum -y install epel-release || yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
$WORKSTATIONSSH "yum install python-virtualenv python-pip python-devel sshpass git vim-enhanced libffi libffi-devel gcc openssl-devel -y"
$WORKSTATIONSSH "pip install ansible==$ANSIBLEVERSION pyrax"


echo "Check ansible version"
$WORKSTATIONSSH "ansible --version"


echo "Set up pyrax module credentials for access to Rackspace Cloud"
$WORKSTATIONSSH "echo -e \"[rackspace_cloud]\nusername = $RAXUSERNAME\napi_key = $RAXAPIKEY\" > /root/.raxpub"


echo "Change ansible-hadoop variables specific to this build.."


echo "Change the key value in playbooks/group_vars/all to $SSHKEY"
$WORKSTATIONSSH "sed -i 's/hadoop-ssh-key/$SSHKEY/g' /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/all;"
$WORKSTATIONSSH "grep $SSHKEY /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/all"

echo "Change the domain value in playbooks/group_vars/all to $BUILDIDENTIFIER"
$WORKSTATIONSSH "sed -i 's/localnet/$BUILDIDENTIFIER/g' /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/all;"
$WORKSTATIONSSH "grep $BUILDIDENTIFIER /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/all"

echo "Change the region value in playbooks/group_vars/all to $REGION"
$WORKSTATIONSSH "sed -i \"s/rax_region: 'ORD'/rax_region: '$REGION' /g\" /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/all"
$WORKSTATIONSSH "grep $REGION /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/all"

echo "Settings for [masternode] deployment from playbooks/group_vars/master-nodes-templates.."
$WORKSTATIONSSH "echo \"---

cluster_interface: 'eth0'
cloud_nodes_count: 3
cloud_image: 'CentOS 7 (PVHVM)'
cloud_flavor: 'performance2-15'
build_datanode_cbs: true
cbs_disks_size: 100
cbs_disks_type: 'SATA'
hadoop_disk: xvde
namenode_disk: xvdf
masterservices_disk: xvdg
datanode_disks: ['xvdf', 'xvdg']
\" > /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/master-nodes"
$WORKSTATIONSSH "cat /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/master-nodes"


echo "Settings for [slavenode] deployment from playbooks/group_vars/slave-nodes-templates.."
$WORKSTATIONSSH "echo \"---

cluster_interface: 'eth0'
cloud_nodes_count: 3
cloud_image: 'CentOS 7 (PVHVM)'
cloud_flavor: 'performance2-15'
build_datanode_cbs: true
cbs_disks_size: 100
cbs_disks_type: 'SATA'
datanode_disks: ['xvdf','xvdg']
\" > /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/slave-nodes"
$WORKSTATIONSSH "cat /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/slave-nodes"


echo "Settings for [edgenode] deployment from playbooks/group_vars/edge-nodes.."
$WORKSTATIONSSH "echo \"---

cluster_interface: 'eth1'
cloud_nodes_count: 1
cloud_image: 'CentOS 7 (PVHVM)'
cloud_flavor: 'performance2-15'
hadoop_disk: xvde
\" > /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/edge-nodes"
$WORKSTATIONSSH "cat /root/tmp/ansible-hadoop-BUILDTEST/playbooks/group_vars/edge-nodes"


# Running scripts which trigger ansible..

echo "List files in our temporary deployment folder.."
$WORKSTATIONSSH "ls -al /root/tmp/ansible-hadoop-BUILDTEST"

echo "Upload the SSH key - [$SSHKEY]"
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $KEYLOCATION /root/.ssh/id_rsa2 root@$SERVERIP:/root/.ssh/id_rsa
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $KEYLOCATION /root/.ssh/id_rsa2.pub root@$SERVERIP:/root/.ssh/id_rsa.pub

echo "Run provisioning.."
$WORKSTATIONSSH "cd /root/tmp/ansible-hadoop-BUILDTEST; rm -f /root/tmp/ansible-hadoop-BUILDTEST/playbooks/hortonworks.retry; bash provision_rax.sh"

echo "Run bootstrap.."
$WORKSTATIONSSH "cd /root/tmp/ansible-hadoop-BUILDTEST; bash bootstrap_rax.sh"

echo "Run hadoop deployment.."
$WORKSTATIONSSH "cd /root/tmp/ansible-hadoop-BUILDTEST; bash hortonworks_rax.sh"

exit 0;

