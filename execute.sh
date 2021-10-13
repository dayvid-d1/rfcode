#!/usr/bin/bash

set -o nounset
set -o errexit

#===================================================================================
# CADDY SETUP
#===================================================================================

CADDY_IMAGE="davidclement/caddy-image:latest"
CADDY_CONTAINER_NAME='caddy-app'
CADDY_VOLUME_NAME="caddy-volume"
CADDY_USER="genohm"
CADDY_SECRET="JDJhJDEwJDF5U3AuelBxMENaN2o4M1lHWS92cE9iU1QyNjRSWTlCRFJYdmFYT0l3VlRtaXBCcXlGMGRx"
CADDY_PORT=8129

chmod +x ./caddy/caddy-image.sh
. ./caddy/caddy-image.sh \
    -i ${CADDY_IMAGE} \
    -c ${CADDY_CONTAINER_NAME} \
    -v ${CADDY_VOLUME_NAME} \
    -u ${CADDY_USER} \
    -s ${CADDY_SECRET} \
    -p ${CADDY_PORT}
#===================================================================================
#===================================================================================



#===================================================================================
#RF-IMAGE SETUP
#===================================================================================
BASE_IMAGE=ubuntu:latest
RF_IMAGE=davidclement/rf-image:latest
mkdir -p workspace
RESOURCES="$(dirname "$PWD")/rfcode/workspace"
CONTAINER_NAME=rfcode-app

chmod +x ./rf-image/rf-image.sh
. ./rf-image/rf-image.sh \
    -i ${BASE_IMAGE} \
    -r ${RF_IMAGE} \
    -d ${RESOURCES} \
    -n ${CONTAINER_NAME}

#===================================================================================
#===================================================================================