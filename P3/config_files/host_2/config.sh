#!/bin/sh
ip link set eth0 up
ip addr add 20.1.1.3/24 dev eth0

exec /bin/sh
