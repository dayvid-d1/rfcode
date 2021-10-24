#!/usr/bin/sh

set -x
set -o nounset
set -o errexit

timestamp() {
	date +"%Y-%m-%d %T"
}


echo "$(timestamp) Setting up container dependencies"
apt-get update
xargs apt-get install -y --no-install-recommends </etc/package-list

wget https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tgz
tar xzf Python-3.8.9.tgz
cd Python-3.8.9
./configure --enable-optimizations
make -j 2
make alt install


curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
apt-get install -yqq nodejs

pip3 install --disable-pip-version-check --no-cache-dir --no-warn-script-location -r /etc/requirements.txt

rm -rf /var/lib/apt/lists
