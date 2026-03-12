FROM frrouting/frr:latest

RUN sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons && \
    sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons && \
    sed -i 's/isisd=no/isisd=yes/' /etc/frr/daemons && \
    sed -i 's/zebra=no/zebra=yes/' /etc/frr/daemons

RUN apk add --no-cache busybox-extras

RUN echo "service integrated-vtysh-config" > /etc/frr/vtysh.conf

CMD ["/bin/sh", "-c", "/usr/lib/frr/docker-start & exec sh"]
