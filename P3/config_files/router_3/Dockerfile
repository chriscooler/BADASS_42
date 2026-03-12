FROM frrouting/frr:latest

RUN apk update \
 && apk add --no-cache iproute2 iputils tcpdump busybox-extras \
 && sed -i 's/bgpd=no/bgpd=yes/'  /etc/frr/daemons \
 && sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons \
 && sed -i 's/isisd=no/isisd=yes/' /etc/frr/daemons

RUN ln -sf /sbin/ip /usr/bin/ip && ln -sf /sbin/ip /bin/ip

ENV ENV=/etc/shinit
RUN printf 'alias ip=/sbin/ip\nexport PATH=/sbin:/usr/sbin:$PATH\n' > /etc/shinit

COPY config.sh /usr/local/bin/config.sh
RUN chmod +x /usr/local/bin/config.sh

COPY frr.conf /etc/frr/frr.conf
RUN chown frr:frr /etc/frr/frr.conf && chmod 640 /etc/frr/frr.conf


ENTRYPOINT ["sh", "-c", "/usr/local/bin/config.sh; exec sh"]

