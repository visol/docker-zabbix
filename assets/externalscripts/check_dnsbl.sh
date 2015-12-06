#!/bin/bash
zabbix_conf=/usr/local/etc/zabbix_server.conf
external_scripts=`grep ^[^\#] $zabbix_conf | grep ExternalScript | cut -d "=" -f 2`
DNSLBL_LIST=$external_scripts/dnsbl.txt
host=$1
ip=`host $host | grep "has address" | head -n 1 | awk '{print $4}'`

if [[ ! -f "$DNSLBL_LIST" ]]
then
	echo "Could not find $DNSLBL_LIST"
	exit 1;
fi
		

if [[ -z "$ip" ]]
then
	echo "Could not get valid ip address for $host"
	exit 1;
fi

rev_ip=`echo $ip | sed -r 's/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/\4.\3.\2.\1/'`

{
listed=0

for dnsbl in `cat $DNSLBL_LIST | grep -v "#"`
do
	if host -W 1 -t a $rev_ip.$dnsbl >/dev/null 2>&1
	then
		echo $host dnsbl_blacklisted on $dnsbl
		host -t txt $rev_ip.$dnsbl | sed "s/^/$host dnsbl_details /"
		listed=`expr $listed + 1`
	fi
done
echo $host dnsbl_status $listed
} | zabbix_sender -z 127.0.0.1 -r -i - > /dev/null 2>&1 &


exit 0


