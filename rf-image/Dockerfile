FROM golang:1.17.2-buster AS easy-novnc-build
WORKDIR /src

COPY /bin/novnc.sh /etc/
RUN . /etc/novnc.sh; \
    rm /etc/novnc.sh

FROM ubuntu:latest

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
    ROBOT_TESTS_DIR=/home/${RF_USER}/rfcode/test \
    ROBOT_REPORTS_DIR=/home/${RF_USER}/rfcode/reports \
    RUN_TESTS=/home/${RF_USER}/rfcode/run-tests \
    PATH=$PATH:${ROBOT_REPORTS_DIR}:${ROBOT_TESTS_DIR}:${ROBOT_SETUP_DIR} \
    AUTO_BROWSER=chromium

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY /etc /etc/

RUN apt-get update; \
    xargs apt-get install -y --no-install-recommends </etc/package-list; \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash; \
    nvm install 14.4.0; \
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -; \
    apt-get install -y nodejs; \
    npm init; \
    apt install build-essential; \
    rm -rf /var/lib/apt/lists /var/cache/apt/*.bin; \
    apt-get clean; \
    pip3 install --disable-pip-version-check --no-cache-dir --no-warn-script-location -r /etc/requirements.txt 
COPY /bin/menu.xml /etc/xdg/openbox/

COPY /install /tmp/
RUN dos2unix /tmp/install.sh; \
    . /tmp/install.sh

WORKDIR /home/app/rfcode
VOLUME /var/log 
VOLUME /home/app/rfcode/test
VOLUME /home/app/rfcode/reports
VOLUME /home/app/rfcode/setup
EXPOSE 8080

CMD ["sh", "-c", "chown app:app /dev/stdout && chown app:app /home/app/rfcode && exec gosu app supervisord"]