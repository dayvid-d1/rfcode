#!/usr/bin/bash

set -o nounset
set -o errexit

timestamp() {
	date +"%Y-%m-%d %T"
}

echo "$(timestamp) User variables"
USER_UID=1000
USER_GID=1000

echo "$(timestamp) System variables"
export SCREEN_COLOUR_DEPTH=24
export SCREEN_HEIGHT=1080
export SCREEN_WIDTH=1920
export TZ=UTC
export USERNAME=app
export DEBIAN_FRONTEND=noninteractive
export LANG=en_US.UTF-8
export ROBOT_DIR=/home/${USERNAME}/rfcode
export ROBOT_DATA_DIR=/home/${USERNAME}/rfcode/data   
export ROBOT_SETUP_DIR=/home/${USERNAME}/rfcode/setup
export ROBOT_TESTS_DIR=/home/${USERNAME}/rfcode/test
export ROBOT_REPORTS_DIR=/home/${USERNAME}/rfcode/reports
export RUN_TESTS=/home/${USERNAME}/rfcode/run-tests
export PATH=$PATH:${ROBOT_REPORTS_DIR}:${ROBOT_TESTS_DIR}:${ROBOT_SETUP_DIR}
export AUTO_BROWSER=chromium


mkdir -p ${ROBOT_DIR}
mkdir -p ${ROBOT_DATA_DIR}
mkdir -p ${ROBOT_SETUP_DIR}
mkdir -p ${ROBOT_TESTS_DIR}
mkdir -p ${ROBOT_REPORTS_DIR}
mkdir -p /usr/share/desktop-directories

echo "$(timestamp) Folder accessibility for user"
groupadd --gid ${USER_GID} ${USERNAME}
useradd --home-dir ${ROBOT_DIR} --shell /bin/bash --uid ${USER_UID} --gid ${USER_GID} ${USERNAME}
chown ${USERNAME}:${USERNAME} ${ROBOT_DIR}
chmod -R ugo+rwx,g+s ${ROBOT_DIR}

echo "$(timestamp) Setup dependencies"
apt-get update -y
xargs apt-get install -y --no-install-recommends </tmp/package-list
apt-get clean
rm -rf /var/lib/apt/lists /var/cache/apt/*.bin

pip3 install --disable-pip-version-check --no-cache-dir --no-warn-script-location -r /tmp/requirements.txt
rfbrowser init

rm -rf  /tmp/*
chmod +x /etc/run-tests
dos2unix /etc/run-tests