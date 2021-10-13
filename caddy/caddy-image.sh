#!/usr/bin/bash

set -o nounset
set -o errexit

usage() {
  echo "Usage: ./slims-image.sh [ -h | --help ]"
  echo " -h  | --help                         Show this menu"
}

CURRENT_DIR=${PWD}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
timestamp() {
	date +"%Y-%m-%d %T"
}

CADDY_IMAGE="davidclement/caddy-image:latest"
CONTAINER_NAME='caddy-app'

while(($#)) ; do
    case $1 in
        -h | --help )                   shift
                                        usage
                                        exit
                                        ;;
        * )                             echo "unknown option $1"
                                        usage
                                        exit
                                        ;;
    esac
done
CADDY_IMAGE_ID=""
CADDY_IMAGE_ID=$(docker image inspect --format=\"{{.Id}}\" ${CADDY_IMAGE} 2> /dev/null) :;


if [ -z "$CADDY_IMAGE_ID" ]; then
  cd "$SCRIPT_DIR"
  echo "$(timestamp) Building Base image"
  docker build -t $CADDY_IMAGE .
  echo "$(timestamp) Base image built successfully"
fi
cd ${CURRENT_DIR}

VOLUME_NAME="caddy-volume"
CONTAINER_RUNNING=$(docker inspect --format=\"{{.State.Running}}\" ${CONTAINER_NAME} 2> /dev/null) :;
CONTAINER_STATUS=$(docker inspect --format=\"{{.State.Status}}\" ${CONTAINER_NAME} 2> /dev/null) :;
VOLUME_SCOPE=$(docker volume inspect --format=\"{{.Scope}}\" ${VOLUME_NAME} 2> /dev/null) :;

echo "$(timestamp) Caddy container $CONTAINER_NAME to be set"
if [ "$CONTAINER_RUNNING" = "\"false\"" ] || [ -z "$CONTAINER_RUNNING" ]; then   
  if [ "${CONTAINER_STATUS}" = "\"exited\"" ] || [ "${CONTAINER_STATUS}" = "\"created\"" ]; then
    echo "$(timestamp) Removing old caddy container"
    docker container rm ${CONTAINER_NAME}
  fi  

  if [ "${VOLUME_SCOPE}" = "\"local\"" ]; then
    echo "$(timestamp) Removing old caddy volume"
    docker volume rm $VOLUME_NAME
  fi

  echo "$(timestamp) Creating new caddy volume"
  docker volume create $VOLUME_NAME

  echo "$(timestamp) Initiating caddy container run"
  docker run --name=$CONTAINER_NAME \
    --detach \
    --restart=always \
    -v=$VOLUME_NAME:/data \
    --env=APP_USERNAME="genohm" \
    --env=APP_PASSWORD_HASH="JDJhJDEwJDF5U3AuelBxMENaN2o4M1lHWS92cE9iU1QyNjRSWTlCRFJYdmFYT0l3VlRtaXBCcXlGMGRx" \
    --publish=8129:8080 \
    $CADDY_IMAGE
fi