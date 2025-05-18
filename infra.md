- hosts
- vcenter


## vcenter

https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/vcenterreceiver

receivers:
  vcenter:
    endpoint: http://localhost:15672
    username: mon.obs.vcenter@infra.dev.pndrs.de
    password: ${env:VCENTER_PASSWORD}
    collection_interval: 5m
    initial_delay: 1s
    metrics: []


## bbm

User: mon.obs.bmc (ILO/iDRAC)
ILO5+6
Idrac 9.x
 
-> Redfish API ?
https://github.com/influxdata/telegraf/blob/master/plugins/inputs/redfish/README.md
https://github.com/mrlhansen/idrac_exporter


-> Hassan Mohammed 
wir müssen an die redfish api -> frage ist ob direkt denkbar ist oder ne vm dazwischen muss irgendwo.


##  NetApp: prometheus-netapp-exporter
https://ypbind.de/maus/projects/prometheus-netapp-exporter/index.html
Direct Access required!