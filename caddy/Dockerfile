FROM golang:1.14-buster AS caddy-build

############################################
WORKDIR /src
COPY /etc/caddy_image.sh /etc/
RUN . /etc/caddy_image.sh; \
    rm /etc/caddy_image.sh
FROM debian:buster

############################################
COPY /etc/caddy_setup.sh /etc/

RUN apt-get update; \
    apt-get install -y dos2unix; \
    dos2unix /etc/caddy_setup.sh; \
    . /etc/caddy_setup.sh; \
    rm /etc/caddy_setup.sh
COPY --from=caddy-build /bin/caddy /usr/local/bin/
COPY /etc/Caddyfile /etc/

VOLUME /data
WORKDIR /data
EXPOSE 8080

CMD ["sh", "-c", "exec gosu app /usr/local/bin/caddy run -adapter caddyfile -config /etc/Caddyfile"]