#!/bin/bash
#IP=`ssh user@router_ip "/sbin/ifconfig ppp0 " | awk '/dr:/{gsub(/.*:/,"",$2);print$2}'`
#IP=`dig +short myip.opendns.com @resolver1.opendns.com`
IP=`ssh user@router_ip "/sbin/ifconfig pppoe0" 2> /dev/null | awk '/dr:/{gsub(/.*:/,"",$2);print$2}'`
/usr/bin/python route53.py $IP
