#!/bin/sh
set -e

ip link set lo up
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

ip link add br0 type bridge
ip link set dev br0 up

ip link add name vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up

brctl addif br0 vxlan10
brctl addif br0 eth0

/usr/lib/frr/frrinit.sh start

exec /bin/sh
