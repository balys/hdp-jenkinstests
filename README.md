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


Structure for tests:

```
HDPVERSION_OS.sh
```


For example:

```
HDP2.5.0_CentOS7.sh
```

