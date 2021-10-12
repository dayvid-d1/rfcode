#!/bin/sh

set -o nounset
set -o errexit

mkdir -p workspace



. ./caddy/caddy-image.sh 

BASE_IMAGE=ubuntu:latest
RF_IMAGE=davidclement/rf-image:latest
RESOURCES="$(dirname "$PWD")/rfcode/workspace"
CONTAINER_NAME=rfcode-app

. ./rf-image/rf-image.sh \
    -i ${BASE_IMAGE} \
    -r ${RF_IMAGE} \
    -d ${RESOURCES} \
    -n ${CONTAINER_NAME}