# P3 host (Alpine). Pas d’IP par défaut ; config.sh au démarrage.
FROM alpine:latest

RUN apk add --no-cache iproute2
COPY config.sh /usr/local/bin/config.sh
RUN chmod +x /usr/local/bin/config.sh
ENTRYPOINT ["sh", "-c", "/usr/local/bin/config.sh; exec sh"]
