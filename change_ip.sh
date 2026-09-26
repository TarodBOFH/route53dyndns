#!/bin/sh
#IP=`ssh user@router_ip "/sbin/ifconfig ppp0 " | awk '/dr:/{gsub(/.*:/,"",$2);print$2}'` # old ifconfig vyatta report
#IP=`dig +short myip.opendns.com @resolver1.opendns.com`  # requires external connection
#IP=`ssh $GW_USER@$GW_IP "/sbin/ifconfig pppoe0" 2> /dev/null | awk '/inet/{gsub(/.*:/,"",$2);print$2}'` # new ifconfig vyatta report


# Set interface from environment variable, defaulting to pppoe1
WAN_IF="${WAN_IF:-pppoe1}"

# 1. Fetch current public IPv4 address from $WAN_IF
IP=$(ssh "$GW_USER@$GW_IP" "ip -4 addr show dev $WAN_IF" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)

# 2. Guard against SSH failure or empty IP
if [ -z "$IP" ]; then
    echo "Error: Could not retrieve public IP from $GW_IP ($WAN_IF)" >&2
    exit 1
fi

# 3. Read last recorded IP safely
LAST_IP=""
if [ -f /var/lastip ]; then
    LAST_IP=$(cat /var/lastip)
fi

# 4. Update Route53 if IP changed
if [ "$LAST_IP" != "$IP" ]; then
    python route53.py "$IP"
    if [ $? -eq 0 ]; then
        echo "$IP" > /var/lastip
        echo "Successfully updated Route53 to $IP"
    else
        echo "Error updating Route53" >&2
        exit 1
    fi
fi
