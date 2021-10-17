FROM golang:1.17.2-buster AS easy-novnc-build
WORKDIR /src

COPY /bin/novnc.sh /etc/
RUN . /etc/novnc.sh; \
    rm /etc/novnc.sh

FROM ubuntu:20.04

ARG RF_USER
ENV USER_UID=1000 \
    USER_GID=1000 \
    SCREEN_COLOUR_DEPTH=24 \
    SCREEN_HEIGHT=1080 \
    SCREEN_WIDTH=1920 \
    TZ=UTC \
    USERNAME=${RF_USER} \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    ROBOT_DIR=/home/${RF_USER}/rfcode \
    ROBOT_DATA_DIR=/home/${RF_USER}/rfcode/data    \
    ROBOT_SETUP_DIR=/home/${RF_USER}/rfcode/setup \
    ROBOT_BROWSER_DIR=/home/${RF_USER}/rfcode/setup/pw-browsers \
    PLAYWRIGHT_BROWSERS_PATH=${ROBOT_BROWSER_DIR} \
    ROBOT_TESTS_DIR=/home/${RF_USER}/rfcode/test \
    ROBOT_REPORTS_DIR=/home/${RF_USER}/rfcode/reports \
    RUN_TESTS=/home/${RF_USER}/rfcode/run-tests \
    PATH=$PATH:${ROBOT_REPORTS_DIR}:${ROBOT_TESTS_DIR}:${ROBOT_SETUP_DIR} \
    AUTO_BROWSER=chromium
    
COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY /etc /etc/

COPY /install/setup.sh /tmp/
RUN dos2unix /tmp/setup.sh; \
    chmod +x /tmp/setup.sh; \
    /tmp/setup.sh
COPY /install/install.sh /tmp/
RUN dos2unix /tmp/install.sh; \
    chmod +x /tmp/install.sh; \
    /tmp/install.sh

COPY /bin/supervisord.conf /etc/
COPY /bin/run-tests /etc/
COPY /bin/menu.xml /etc/xdg/openbox/
    #rm -rf /var/lib/apt/lists /var/cache/apt/*.bin; \
    #apt-get clean; \

WORKDIR /home/app/rfcode
VOLUME /var/log 
VOLUME /home/app/rfcode/test
VOLUME /home/app/rfcode/reports
VOLUME /home/app/rfcode/setup
EXPOSE 8080
CMD ["sh", "-c", "chown app:app /dev/stdout && chown app:app /home/app/rfcode && exec gosu app supervisord"]
#CMD ["sh", "-c", "exec gosu app supervisord"]
