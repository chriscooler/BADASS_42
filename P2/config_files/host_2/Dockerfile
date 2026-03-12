# P2 host (Alpine, overlay 30.1.1.0/24). config.sh au démarrage.
FROM alpine:latest

RUN apk add --no-cache iproute2 tcpdump
COPY config.sh /usr/local/bin/config.sh
RUN chmod +x /usr/local/bin/config.sh
ENTRYPOINT ["sh", "-c", "/usr/local/bin/config.sh; exec sh"]
