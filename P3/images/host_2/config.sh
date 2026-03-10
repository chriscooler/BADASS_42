#!/bin/sh
ip link set eth0 up
ip addr add 192.168.10.2/24 dev eth0

exec /bin/sh
