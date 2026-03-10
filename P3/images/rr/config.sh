#!/bin/sh
set -e

ip link set lo up
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

/usr/lib/frr/frrinit.sh start

exec /bin/sh
