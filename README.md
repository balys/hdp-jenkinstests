## HDP deployment testing scripts

This will be used by Jenkins to verify if changes (commits / pull requests) to the following repository are correct:
https://github.com/rackerlabs/ansible-hadoop

Plans are to test these deployment setups:


| HDP Version  | CentOS7 | CentOS6 | Ubuntu |
| ------------ | ------- | ------ | ------- |
| 2.2.9  | X  | X  | X  | X  |
| 2.3.6  | X  | X  | X  | X  |
| 2.4.3  | X  | X  | X  | X  |
| 2.5.0  | X  | X  | X  | X  |


X - Not tested
Y - Tested


Structure for tests, variables will be grabbed from jenkins multi-configuration matrix:

```
$ runner_ansible.sh <OSVERSION> <HDPVERSION>
```


For example:

```
$ runner_ansible.sh CentOS7 2.5.0
```


The testing is performed by: 
* bootstraping a new workstation node in RAX cloud
* setting up workstation node to specifications listed in ansible-hadoop repo
* copying over the current repofiles from jenkins server
* editing the configuration to specific build folder on workstation server
* deploying HDP/CDH based with this configuration.

The integration test is written in ansible, the trigger script is bash.


