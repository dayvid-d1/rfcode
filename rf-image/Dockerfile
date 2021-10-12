ARG RF_BASE_IMAGE
FROM golang:1.14-buster AS easy-novnc-build
WORKDIR /src

COPY /bin/novnc.sh /etc/
RUN . /etc/novnc.sh; \
    rm /etc/novnc.sh

FROM ${RF_BASE_IMAGE}

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY /install /tmp/
COPY /etc /etc/

RUN . /tmp/install.sh
COPY /bin/menu.xml /etc/xdg/openbox/

WORKDIR /home/app/rfcode
VOLUME /var/log 
VOLUME /home/app/rfcode
EXPOSE 8080

CMD ["sh", "-c", "chown app:app /dev/stdout && exec gosu app supervisord"]