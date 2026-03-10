#!/bin/sh
printf 'service integrated-vtysh-config\n' > /etc/frr/vtysh.conf
chown frr:frr /etc/frr/vtysh.conf 2>/dev/null || true
chmod 640 /etc/frr/vtysh.conf 2>/dev/null || true

set -e

ip link set lo up
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

/usr/lib/frr/frrinit.sh start

exec /bin/sh
