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

apt-get update -y
xargs apt-get install -y --no-install-recommends </etc/package-list
curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
apt-get update -y
apt-get install -y nodejs
pip3 install --disable-pip-version-check --no-cache-dir --no-warn-script-location -r /etc/requirements.txt

echo "$(timestamp) Accessibility rights for: "$USERNAME
# groupadd --gid $USER_GID $USERNAME
# useradd --home-dir $ROBOT_DIR --shell /bin/bash --uid $USER_UID --gid $USER_GID $USERNAME
# chown -R $USERNAME:$USERNAME $ROBOT_DIR
# chown -R $USERNAME:$USERNAME /dev/stdout
# chown -R $USERNAME:$USERNAME /var/log

echo "$(timestamp) Permissions for others"
chmod -R 777 $ROBOT_DIR
chmod -R 777 /dev/stdout
chmod -R 777 /var/log
chmod 777 /etc/run-tests
dos2unix /etc/run-tests

echo "$(timestamp) rfbrowser initialization"
npm install acorn@^8
rfbrowser init
echo "$(timestamp) Installing Playwright"
#PLAYWRIGHT_BROWSERS_PATH=$ROBOT_BROWSER_DIR npm i -D playwright
rm -rf  /tmp/*
