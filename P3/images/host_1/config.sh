#!/bin/sh
ip link set eth1 up
ip addr add 192.168.10.1/24 dev eth1

exec /bin/sh
