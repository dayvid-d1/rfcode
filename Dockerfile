FROM golang:1.17.2-buster AS easy-novnc-build
WORKDIR /src

COPY /bin/novnc.sh /etc/
RUN . /etc/novnc.sh; \
    rm /etc/novnc.sh

FROM ubuntu:20.04

ARG USERNAME
ENV USER_UID=1000 \
    USER_GID=1000 \
    SCREEN_COLOUR_DEPTH=24 \
    SCREEN_HEIGHT=1080 \
    SCREEN_WIDTH=1920 \
    TZ=UTC \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    ROBOT_DIR=/home/${USERNAME}/rfcode \
    ROBOT_DATA_DIR=/home/${USERNAME}/rfcode/data    \
    ROBOT_SETUP_DIR=/home/${USERNAME}/rfcode/setup \
    ROBOT_BROWSER_DIR=/home/${USERNAME}/rfcode/setup/pw-browsers \
    PLAYWRIGHT_BROWSERS_PATH=${ROBOT_BROWSER_DIR} \
    ROBOT_TESTS_DIR=/home/${USERNAME}/rfcode/test \
    ROBOT_REPORTS_DIR=/home/${USERNAME}/rfcode/reports \
    AUTO_BROWSER=chromium \
    NODE_PATH=/usr/lib/node_modules
    
COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY /etc /etc/

COPY /install/setup.sh /tmp/
RUN chmod +x /tmp/setup.sh; \
    dos2unix /tmp/setup.sh; \
    . /tmp/setup.sh

COPY /bin/menu.xml /etc/xdg/openbox/
COPY /bin/supervisord.conf /etc/
COPY /bin/run-tests.sh /etc/
COPY /bin/package.json  /home/${USERNAME}/rfcode/

COPY /install/install.sh /tmp/
RUN chmod +x /tmp/install.sh; \
    dos2unix /tmp/install.sh; \
    . /tmp/install.sh

WORKDIR /home/app/rfcode
VOLUME /var/log 
VOLUME /home/app/rfcode/test
VOLUME /home/app/rfcode/reports
VOLUME /home/app/rfcode/setup
VOLUME /home/app/rfcode/data

EXPOSE 8080

CMD ["sh", "-c", "chown app:app /dev/stdout && chown app:app /home/app/rfcode && exec gosu app supervisord"]
