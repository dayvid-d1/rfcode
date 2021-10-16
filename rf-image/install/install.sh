#!/usr/bin/bash

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
groupadd --gid $USER_GID $USERNAME
useradd --home-dir $ROBOT_DIR --shell /bin/bash --uid $USER_UID --gid $USER_GID $USERNAME
chown -R $USERNAME:$USERNAME $ROBOT_DIR
chown -R $USERNAME:$USERNAME /dev/stdout
chown -R $USERNAME:$USERNAME /var/log

echo "$(timestamp) rfbrowser initialization"
npm i acorn-import-assertions
rfbrowser init --skip-browsers
echo "$(timestamp) Installing Playwright"
PLAYWRIGHT_BROWSERS_PATH=$ROBOT_BROWSER_DIR 
export PLAYWRIGHT_BROWSERS_PATH
npm i playwright install
rm -rf  /tmp/*

echo "$(timestamp) Permissions for others"
chmod 700 $ROBOT_DIR
chmod 700 /dev/stdout
chmod 700 /var/log
chmod 755 /etc/run-tests

dos2unix /etc/run-tests