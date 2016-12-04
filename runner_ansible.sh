#!/bin/bash

# VARIABLES SPECIFIC TO THIS BUILD
# OSVERSION=$1
# HDPVERSION=$2

OSVERSION=CentOS7
HDPVERSION=HDP2.5.0

# GLOBAL VARIABLES
rax_credentials_file="~/.raxpub"

RAXACCOUNTID=`grep account ~/.raxpub  | awk {'print $3'}`
RAXUSERNAME=`grep username ~/.raxpub  | awk {'print $3'}`
RAXAPIKEY=`grep api_key ~/.raxpub  | awk {'print $3'}`

# Set other vars we will use in ansible
BUILDIDENTIFIER=`pwgen 20 1`
REGION="LON"
ANSIBLEVERSION="2.1.3.0"
DEPLOYTEMPFOLDER="/root/tmp/ansible-hadoop-BUILDTEST"
RELEASEFOLDER="OPERATINGSYSTEM/$OSVERSION/VERSION/$HDPVERSION"

# Deployment Workstation server settings
SERVERFLAVOR="general1-4"
SSHKEY="root-hdp-jenkins"
OSIMAGE="4319b4ff-f887-4c52-9464-34536d202143"

# ubuntu - fe980b5a-43a0-400d-af56-f0412cadef88
# centos6 - 1a8a4330-ae0d-4e0f-ad9f-6004b8be63c3
# centos7 - 4319b4ff-f887-4c52-9464-34536d202143

KEYLOCATION=~/id_rsa2

export "ANSIBLE_HOST_KEY_CHECKING=False"

ansible-playbook -vvvv -i inventory/localhost playbooks/runner.yml \
  --extra-vars "\
    rax_credentials_file=$rax_credentials_file \
    buildidentifier=$BUILDIDENTIFIER \
    deploytempfolder=$DEPLOYTEMPFOLDER \
    releasefolder=$RELEASEFOLDER \
    cloud_image=$OSIMAGE \
    key_location=$KEYLOCATION \
    cloud_flavor=$SERVERFLAVOR \
    rax_deploy_region=$REGION \
    rax_account=$RAXACCOUNTID \
    rax_username=$RAXUSERNAME \
    rax_apikey=$RAXAPIKEY \
    workstation_ansibleversion=$ANSIBLEVERSION \
    ssh_keyname=$SSHKEY "
