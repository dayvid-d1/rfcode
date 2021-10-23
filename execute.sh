#!/usr/bin/bash

set -o nounset
set -o errexit

#===================================================================================
echo "RF-IMAGE SETUP"
#===================================================================================

RF_IMAGE=davidclement/rf-image:latest
ROBOT_THREADS=4
RF_USER=app
RESOURCES="$PWD/workspace"

rm -rf "$PWD/workspace/reports/*"
curl -sOL https://raw.githubusercontent.com/dayvid-d1/rfcode/master/install/rf-image.sh
chmod +x ./rf-image.sh
./rf-image.sh \
    -i ${RF_IMAGE} \
    -t ${ROBOT_THREADS} \
    -r ${RESOURCES}

#===================================================================================
#===================================================================================


#===================================================================================
echo "CADDY SETUP"
#===================================================================================

CADDY_IMAGE="davidclement/caddy-image:latest"
CADDY_USER="app"
CADDY_SECRET="JDJhJDEwJDNwT1ZKamJrRGEwdDNYWEN0RlBrdU9NcE5FazNabW0xVVk0dXpReUUxaWtiVEtoR1hJMUdt"
CADDY_PORT=8129

curl -sOL https://raw.githubusercontent.com/dayvid-d1/caddy/master/install/caddy-image.sh
chmod +x ./caddy-image.sh
./caddy-image.sh \
    -i ${CADDY_IMAGE} \
    -u ${RF_USER} \
    -s ${CADDY_SECRET} \
    -p ${CADDY_PORT}
#===================================================================================
#===================================================================================