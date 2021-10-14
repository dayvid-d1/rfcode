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

chmod +x ./caddy/caddy-image.sh
dos2unix ./caddy/caddy-image.sh
. ./caddy/caddy-image.sh \
    -i ${CADDY_IMAGE} \
    -u ${CADDY_USER} \
    -s ${CADDY_SECRET} \
    -p ${CADDY_PORT}
#===================================================================================
#===================================================================================



#===================================================================================
echo "RF-IMAGE SETUP"
#===================================================================================

RF_IMAGE=davidclement/rf-image:latest
CONTINENT="America"
PLACE="New_York"
ROBOT_THREADS=4
RF_PORT=8181

chmod +x ./rf-image/rf-image.sh
dos2unix ./rf-image/rf-image.sh
. ./rf-image/rf-image.sh \
    -i ${RF_IMAGE} \
    -c ${CONTINENT} \
    -l ${PLACE} \
    -t ${ROBOT_THREADS} \
    -p ${RF_PORT} \
    -m ${CADDY_USER}

start chrome http://localhost:8181/



#===================================================================================
#===================================================================================