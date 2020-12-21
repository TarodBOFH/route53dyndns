#!/bin/sh
#IP=`ssh user@router_ip "/sbin/ifconfig ppp0 " | awk '/dr:/{gsub(/.*:/,"",$2);print$2}'` # old ifconfig vyatta report
#IP=`dig +short myip.opendns.com @resolver1.opendns.com`  # requires external connection
IP=`ssh $GW_USER@$GW_IP "/sbin/ifconfig pppoe0" 2> /dev/null | awk '/inet/{gsub(/.*:/,"",$2);print$2}'` # new ifconfig vyatta report
LAST_IP=`cat /var/lastip`
if [ -z "$IP" ] && [ $LAST_IP != $IP ]; then
  python route53.py $IP
fi
