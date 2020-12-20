#!/bin/sh
i=0
limit=60
while true; do
  /change_ip.sh
  i=$((i+1))
  if [ $i -gt $limit ]; then
    i=0
    echo "0.0.0.0" > /var/lastip
  fi
  sleep 1m
done
