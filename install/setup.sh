#!/usr/bin/bash

set -x
set -o nounset
set -o errexit

timestamp() {
	date +"%Y-%m-%d %T"
}

apt-get update
xargs apt-get install -y --no-install-recommends </etc/package-list
echo "$(timestamp) Setting up container dependencies"
echo "deb https://deb.nodesource.com/node_12.x buster main" > /etc/apt/sources.list.d/nodesource.list
wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
apt-get install -yqq nodejs
pip3 install -U pip
pip3 install --disable-pip-version-check --no-cache-dir --no-warn-script-location -r /etc/requirements.txt

rm -rf /var/lib/apt/lists /var/cache/apt/*.bin
apt-get clean