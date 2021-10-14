#!/usr/bin/bash

set -o nounset
set -o errexit

timestamp() {
	date +"%Y-%m-%d %T"
}


mkdir -p $ROBOT_DIR
mkdir -p $ROBOT_DATA_DIR
mkdir -p $ROBOT_SETUP_DIR
mkdir -p $ROBOT_TESTS_DIR
mkdir -p $ROBOT_REPORTS_DIR
mkdir -p /usr/share/desktop-directories

echo "$(timestamp) Folder accessibility for user"
groupadd --gid $USER_GID $USERNAME
useradd --home-dir $ROBOT_DIR --shell /bin/bash --uid $USER_UID --gid $USER_GID $USERNAME
chown -R $USERNAME:$USERNAME $ROBOT_DIR
chown -R $USERNAME:$USERNAME /dev/stdout
chown -R $USERNAME:$USERNAME /var/log

echo "$(timestamp) Setup dependencies"
#apt-get update -y
xargs apt-get install -y --no-install-recommends </tmp/package-list
apt-get clean
rm -rf /var/lib/apt/lists /var/cache/apt/*.bin

pip3 install --disable-pip-version-check --no-cache-dir --no-warn-script-location -r /tmp/requirements.txt
rfbrowser init

rm -rf  /tmp/*

chmod 700 $ROBOT_DIR
chmod 700 /dev/stdout
chmod 700 /var/log
chmod 700 /etc/run-tests

dos2unix /etc/run-tests