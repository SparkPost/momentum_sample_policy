# Momentum SNMP Domain Query Demo

This is a basic example for how to query specific [SNMP domain stats](https://support.messagesystems.com/docs/web-ref/conf.ref.snmp.php).

**Warning:** _This is will block Momentums scheduler thread and may cause performance impacts._


## Usage

`https://github.com/SparkPost/momentum_sample_policy/tree/master/momentum_snmp_demo`


## Example Output

```
./output/linux/queryMomentum --domain gmail.com --host 127.0.0.1 --port 8162
Domain: gmail.com
OID: 9.103.109.97.105.108.46.99.111.109
Domain Name: 
	1.3.6.1.4.1.19552.1.2.9.103.109.97.105.108.46.99.111.109.0.1
Receptions: 
	1.3.6.1.4.1.19552.1.2.9.103.109.97.105.108.46.99.111.109.1.1
Failures: 
	1.3.6.1.4.1.19552.1.2.9.103.109.97.105.108.46.99.111.109.2.1
Deliveries: 
	1.3.6.1.4.1.19552.1.2.9.103.109.97.105.108.46.99.111.109.3.1
Transient Failures: 
	1.3.6.1.4.1.19552.1.2.9.103.109.97.105.108.46.99.111.109.4.1
Out Connections: 
	1.3.6.1.4.1.19552.1.2.9.103.109.97.105.108.46.99.111.109.5.1
Active Queue Size: 
	1.3.6.1.4.1.19552.1.2.9.103.109.97.105.108.46.99.111.109.6.1
Delay Queue Size: 
	1.3.6.1.4.1.19552.1.2.9.103.109.97.105.108.46.99.111.109.7.1



SNMP Query: 127.0.0.1:8162
-------------
version = 4.2.31.59853 r(Core:4.2.31.1)
domain_name = gmail.com
receptions = 0
failures = 0
deliveries = 10
transient_failures = 0
out_connections = 1
active_queue = 0
delayed_queue = 0
```