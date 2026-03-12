FROM alpine:latest

RUN apk add --no-cache iproute2
COPY config.sh /usr/local/bin/config.sh
RUN chmod +x /usr/local/bin/config.sh
ENTRYPOINT ["sh", "-c", "/usr/local/bin/config.sh; exec sh"]
