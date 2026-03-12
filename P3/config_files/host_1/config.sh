#!/bin/sh
ip link set eth1 up
ip addr add 20.1.1.1/24 dev eth1

exec /bin/sh
