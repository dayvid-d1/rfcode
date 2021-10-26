#!/usr/bin/bash

set -o nounset
set -o errexit

#===================================================================================
echo "RF-IMAGE SETUP"
#===================================================================================

RF_IMAGE="ghcr.io/dayvid-d1/rf-image:test"
ROBOT_THREADS=4
USER=app
RESOURCES="$PWD/workspace"

rm -rf "$PWD/workspace/reports/*"
curl -sOL https://raw.githubusercontent.com/dayvid-d1/rfcode/master/install/rf-image.sh
chmod +x ./rf-image.sh
./rf-image.sh \
    -i ${RF_IMAGE} \
    -t ${ROBOT_THREADS} \
    -r ${RESOURCES} \
    -p ${USER}

#===================================================================================
#===================================================================================


#===================================================================================
echo "CADDY SETUP"
#===================================================================================

CADDY_IMAGE="davidclement/caddy-image:latest"
CADDY_SECRET="JDJhJDEwJDNwT1ZKamJrRGEwdDNYWEN0RlBrdU9NcE5FazNabW0xVVk0dXpReUUxaWtiVEtoR1hJMUdt"
CADDY_PORT=8129

curl -sOL https://raw.githubusercontent.com/dayvid-d1/caddy/master/caddy-image.sh?token=ATN6XKVBPO5GR4PO3W5LRODBPADCW
chmod +x ./caddy-image.sh
#./caddy-image.sh \
#    -i ${CADDY_IMAGE} \
#    -u ${USER} \
#    -s ${CADDY_SECRET} \
#    -p ${CADDY_PORT}
#===================================================================================
#===================================================================================
