FROM golang:1.17.2-buster AS easy-novnc-build
WORKDIR /src

COPY /bin/novnc.sh /etc/
RUN . /etc/novnc.sh; \
    rm /etc/novnc.sh

FROM marketsquare/robotframework-browser:latest

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
    RUN_TESTS=/home/${USERNAME}/rfcode/run-tests \
    PATH=$PATH:${ROBOT_REPORTS_DIR}:${ROBOT_TESTS_DIR}:${ROBOT_SETUP_DIR} \
    AUTO_BROWSER=chromium
    
COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY /etc /etc/

USER root

COPY /install/setup.sh /tmp/
RUN chmod +x /tmp/setup.sh; \
    /tmp/setup.sh

COPY /bin/menu.xml /etc/xdg/openbox/
COPY /bin/supervisord.conf /etc/
COPY /bin/run-tests /etc/

COPY /install/install.sh /tmp/
RUN chmod +x /tmp/install.sh; \
    /tmp/install.sh    

USER ${USERNAME}}

WORKDIR /home/app/rfcode
#VOLUME /var/log 
VOLUME /home/app/rfcode/test
# VOLUME /home/app/rfcode/reports
# VOLUME /home/app/rfcode/setup

EXPOSE 8080
CMD ["bash", "${USERNAME} -c", "exec gosu app supervisord"]
#CMD ["sh", "-c", "exec gosu app supervisord"]
