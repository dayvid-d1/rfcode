#!/usr/bin/bash

set -x
set -o nounset
set -o errexit

timestamp() {
	date +"%Y-%m-%d %T"
}

echo "$(timestamp) Setting up container dependencies"
apt-get update -y
xargs apt-get install -y --no-install-recommends </etc/package-list
rm -rf /var/lib/apt/lists /var/cache/apt/*.bin; \
apt-get clean;

pip3 install --disable-pip-version-check --no-cache-dir --no-warn-script-location -r /etc/requirements.txt


