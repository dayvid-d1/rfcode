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

ARG RF_USER
ENV USER_UID 1000
ENV USER_GID 1000
ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920
ENV TZ UTC
ENV USERNAME ${RF_USER}
ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV ROBOT_DIR /home/${RF_USER}/rfcode
ENV ROBOT_DATA_DIR /home/${RF_USER}/rfcode/data   
ENV ROBOT_SETUP_DIR /home/${RF_USER}/rfcode/setup
ENV ROBOT_TESTS_DIR /home/${RF_USER}/rfcode/test
ENV ROBOT_REPORTS_DIR /home/${RF_USER}/rfcode/reports
ENV RUN_TESTS /home/${RF_USER}/rfcode/run-tests
ENV PATH $PATH:${ROBOT_REPORTS_DIR}:${ROBOT_TESTS_DIR}:${ROBOT_SETUP_DIR}
ENV AUTO_BROWSER chromium

RUN apt-get update; \
    apt-get install -y dos2unix; \
    dos2unix /tmp/install.sh; \
    . /tmp/install.sh
COPY /bin/menu.xml /etc/xdg/openbox/

WORKDIR /home/app/rfcode
VOLUME /var/log 
VOLUME /home/app/rfcode/test
VOLUME /home/app/rfcode/reports
EXPOSE 8080

CMD ["sh", "-c", "chown app:app /dev/stdout && chown app:app /home/app/rfcode && exec gosu app supervisord"]