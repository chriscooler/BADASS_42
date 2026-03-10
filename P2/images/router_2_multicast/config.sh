#!/bin/sh
printf 'service integrated-vtysh-config\n' > /etc/frr/vtysh.conf
chown frr:frr /etc/frr/vtysh.conf 2>/dev/null || true
chmod 640 /etc/frr/vtysh.conf 2>/dev/null || true


ip addr add 10.1.1.2/24 dev eth0
ip link set eth0 up
ip link set eth1 up

ip link add br0 type bridge
ip link set br0 up

ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 local 10.1.1.2 dstport 4789
ip link set vxlan10 up

ip link set eth1 master br0
ip link set vxlan10 master br0
