#!/bin/sh

set -ex

USER_UID=1000
USER_GID=1000
export USERNAME=app
export DEBIAN_FRONTEND=noninteractive
export LANG=en_US.UTF-8
export DATA_DIR=/data

apt-get update -y
apt-get install -y --no-install-recommends gosu
apt-get clean
rm -rf /var/lib/apt/lists

groupadd --gid ${USER_GID} ${USERNAME}
useradd --home-dir ${DATA_DIR} --shell /bin/bash --uid ${USER_UID} --gid ${USER_GID} ${USERNAME}
mkdir -p ${DATA_DIR}
chown ${USERNAME}:${USERNAME} ${DATA_DIR}
chmod -R ugo+rwx,g+s ${DATA_DIR}