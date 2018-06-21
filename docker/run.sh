#!/bin/bash

ns=$(awk '/nameserver/ {print $2; exit}' /etc/resolv.conf)
echo "Using $ns for nameserver"
sed -i "s/NAMESERVER/${ns}/g" /usr/local/etc/haproxy/haproxy.cfg

haproxy_hostname=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
haproxy -V -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -sf $(cat /run/haproxy.pid) -L $haproxy_hostname -D

while true
 do
   # haproxy is started above, now we keep the docker container alive by sleeping
   sleep 999
done
