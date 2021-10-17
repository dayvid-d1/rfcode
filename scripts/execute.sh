#!/usr/bin/bash

set -o nounset
set -o errexit

#===================================================================================
echo "CADDY SETUP"
#===================================================================================

CADDY_IMAGE="davidclement/caddy-image:latest"
CADDY_USER="app"
CADDY_SECRET="JDJhJDEwJDF5U3AuelBxMENaN2o4M1lHWS92cE9iU1QyNjRSWTlCRFJYdmFYT0l3VlRtaXBCcXlGMGRx"
CADDY_PORT=8129

chmod +x ./scripts/caddy-image.sh
#dos2unix ./scripts/caddy-image.sh
./scripts/caddy-image.sh \
    -i ${CADDY_IMAGE} \
    -u ${CADDY_USER} \
    -s ${CADDY_SECRET} \
    -p ${CADDY_PORT}
#===================================================================================
#===================================================================================



#===================================================================================
echo "RF-IMAGE SETUP"
#===================================================================================

RF_IMAGE=ghcr.io/dayvid-d1/rf-image:test
ROBOT_THREADS=4
RF_PORT=8181
RESOURCES="$(dirname "$PWD")/workspace"

chmod +x ./scripts/rf-image.sh
#dos2unix ./scripts/rf-image.sh
./scripts/rf-image.sh \
    -i ${RF_IMAGE} \
    -t ${ROBOT_THREADS} \
    -p ${RF_PORT} \
    -m ${CADDY_USER} \
    -r ${RESOURCES}

#curl chrome http://localhost:8181/


#===================================================================================
#===================================================================================
