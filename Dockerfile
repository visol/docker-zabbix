FROM zabbix/zabbix-server-2.4
MAINTAINER Jonas Renggli <jonas.renggli@visol.ch>

ADD assets/externalscripts/* ${ZS_ExternalScripts}/
