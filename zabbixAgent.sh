#!/usr/bin/env bash
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum install -y zabbix-agent
mv /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.example

cat <<- EOF >/etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
AllowKey=system.run[*]
 LogRemoteCommands=1
Server=172.20.130.105
ServerActive=172.20.130.105,172.0.0.1
Hostname=${HOSTNAME^^}
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

systemctl restart zabbix-agent
systemctl enable zabbix-agent

exit