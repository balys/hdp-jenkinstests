In here I will write ansible-hadoop playbook jenkins integration tests.

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
$ RUNNER.sh <OSVERSION> <HDPVERSION>
```


For example:

```
$ RUNNER.sh CentOS7 2.5.0
```

