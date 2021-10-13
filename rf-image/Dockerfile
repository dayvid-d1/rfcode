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

ENV SCREEN_COLOUR_DEPTH=24
ENV SCREEN_HEIGHT=1080
ENV SCREEN_WIDTH=1920
ENV TZ=UTC
ENV USERNAME=app
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV ROBOT_DIR=/home/${USERNAME}/rfcode
ENV ROBOT_DATA_DIR=/home/${USERNAME}/rfcode/data   
ENV ROBOT_SETUP_DIR=/home/${USERNAME}/rfcode/setup
ENV ROBOT_TESTS_DIR=/home/${USERNAME}/rfcode/test
ENV ROBOT_REPORTS_DIR=/home/${USERNAME}/rfcode/reports
ENV RUN_TESTS=/home/${USERNAME}/rfcode/run-tests
ENV PATH=$PATH:${ROBOT_REPORTS_DIR}:${ROBOT_TESTS_DIR}:${ROBOT_SETUP_DIR}
ENV AUTO_BROWSER=chromium

RUN apt-get update; \
    apt-get install -y dos2unix; \
    dos2unix /tmp/install.sh; \
    . /tmp/install.sh
COPY /bin/menu.xml /etc/xdg/openbox/

WORKDIR /home/app/rfcode
VOLUME /var/log 
VOLUME /home/app/rfcode
EXPOSE 8080

CMD ["sh", "-c", "chown app:app /dev/stdout && exec gosu app supervisord"]