#!/usr/bin/env bash
mv /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.example
mv /etc/zabbix_agentd.conf /etc/zabbix_agentd.example
mkdir -p /etc/zabbix/zabbix_agentd.d/
chown zabbix. /etc/zabbix/zabbix_agentd.d
chown zabbix. /etc/zabbix_agentd.conf

cat <<- EOF >/etc/zabbix_agentd.conf
PidFile=/run/zabbix/zabbix_agentd.pid
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
