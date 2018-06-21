#!/bin/bash

ns=$(awk '/nameserver/ {print $2; exit}' /etc/resolv.conf)
echo "Using $ns for nameserver"
sed -i "s/NAMESERVER/${ns}/g" /usr/local/etc/haproxy/haproxy.cfg

haproxy -V -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -sf $(cat /run/haproxy.pid) -L $HOSTNAME
