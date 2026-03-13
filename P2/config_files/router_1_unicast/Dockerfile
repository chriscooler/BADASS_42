FROM frrouting/frr:latest

RUN apk add --no-cache iproute2 iputils tcpdump \
 && sed -i 's/bgpd=no/bgpd=yes/'  /etc/frr/daemons \
 && sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons \
 && sed -i 's/isisd=no/isisd=yes/' /etc/frr/daemons
RUN ln -sf /sbin/ip /usr/bin/ip 2>/dev/null || true
ENV ENV=/etc/shinit
RUN printf 'export PATH=/sbin:/usr/sbin:$PATH\n' > /etc/shinit

COPY config.sh /usr/local/bin/config.sh
COPY unicast.sh /usr/local/bin/unicast.sh
COPY multicast.sh /usr/local/bin/multicast.sh

RUN chmod +x /usr/local/bin/unicast.sh
RUN chmod +x /usr/local/bin/multicast.sh
RUN chmod +x /usr/local/bin/config.sh

ENTRYPOINT ["sh", "-c", "/usr/local/bin/config.sh; exec sh"]
