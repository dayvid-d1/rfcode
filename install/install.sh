#!/bin/sh

set -x
set -o nounset
set -o errexit

timestamp() {
	date +"%Y-%m-%d %T"
}

mkdir -p $ROBOT_DIR
mkdir -p $ROBOT_DATA_DIR
mkdir -p $ROBOT_SETUP_DIR
mkdir -p $ROBOT_BROWSER_DIR
mkdir -p $ROBOT_TESTS_DIR
mkdir -p $ROBOT_REPORTS_DIR
mkdir -p /usr/share/desktop-directories

echo "$(timestamp) Accessibility rights for: "$USERNAME
export PATH=$PATH:${ROBOT_REPORTS_DIR}:${ROBOT_TESTS_DIR}:${ROBOT_SETUP_DIR}
groupadd --gid $USER_GID $USERNAME
useradd --home-dir $ROBOT_DIR --shell /bin/bash --uid $USER_UID --gid $USER_GID $USERNAME
chown -R $USERNAME:$USERNAME $ROBOT_DIR
chown -R $USERNAME:$USERNAME /dev/stdout
chown -R $USERNAME:$USERNAME /var/log
chmod -R ugo+rwx,g+s ${ROBOT_DIR} /var/log /dev/stdout

echo "$(timestamp) Permissions for others"
chmod -R 777 $ROBOT_DIR
chmod -R 777 /dev/stdout
chmod -R 777 /var/log
chmod 777 /etc/run-tests.sh
dos2unix /etc/run-tests.sh

echo "$(timestamp) rfbrowser initialization"
rfbrowser init
npm i -g playwright
npx playwright install
npx playwright install-deps
rm -rf  /tmp/*
