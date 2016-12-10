## HDP deployment testing scripts

This will be used by Jenkins to verify if changes (commits / pull requests) to the following repository are correct:
https://github.com/rackerlabs/ansible-hadoop

Plans are to test these deployment setups:


| HDP Version  | CentOS7 | CentOS6 | Ubuntu |
| ------------ | ------- | ------ | ------- |
| 2.2  | X  | X  | X  |
| 2.3  | X  | X  | X  |
| 2.4  | X  | X  | X  |
| 2.5  | Y  | X  | Y  |


X - Test failing
Y - Test passing


Structure for tests, variables will be grabbed from jenkins multi-configuration matrix:

```
$ runner_ansible.sh <OSVERSION> <HDPVERSION>
```


For example:

```
$ runner_ansible.sh CentOS7 2.5
```

The script will build the newest patch version available. For example if we choose 2.5 HDP release, it will build HDP 2.5.3, as that is the most current at the moment.


The testing is performed by: 
* Bootstraping a new workstation node in RAX cloud
* Setting up workstation node to specifications listed in ansible-hadoop repo
* Copying over the current repofiles from jenkins server to workstation
* Editing the repofiles configuration (in specific build folder) on workstation server
* Cleaning up any previous deployments (servers, CBS volumes) in the testing region
* Deploying HDP/CDH based with this configuration, from the workstation server
* Cleaning up after current deployment (remove servers and cbs volumes)

The integration test is written in ansible, the trigger script is bash.


