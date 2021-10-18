#!/usr/bin/bash

set -x
set -o nounset
set -o errexit

usage() {
  echo "Usage: ./slims-image.sh [ -i | --image ] [ -v | --vol ] [ -c | --container ] [ -u | --user ] [ -s | --secret ] [ -p | --port ][ -h | --help ]"
  echo " -i  | --image                        Image name f.e. '-i davidclement/caddy-image:latest'"
  echo " -v  | --vol                          Volume name f.e. '-v caddy-volume'"
  echo " -c  | --container                    Container name f.e. '-c caddy-app'"
  echo " -u  | --user                         Caddy User f.e. '-u rfcode'"
  echo " -s  | --secret                        Caddy secret f.e. '-s xyz'"
  echo " -p  | --port                         Caddy port f.e. '-p 8129'"
  echo " -h  | --help                         Show this menu"
}

CURRENT_DIR=${PWD}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
timestamp() {
	date +"%Y-%m-%d %T"
}

CADDY_IMAGE=''
CADDY_CONTAINER_NAME=''
CADDY_VOLUME_NAME=''
CADDY_USER=''
CADDY_SECRET=''
CADDY_PORT=''

while(($#)) ; do
    case $1 in
        -i | --image )                  shift
                                        CADDY_IMAGE="$1"
                                        shift
                                        ;;
        -c | --container )              shift
                                        CADDY_CONTAINER_NAME="$1"
                                        shift
                                        ;;                                        
        -v | --volume )                 shift
                                        CADDY_VOLUME_NAME="$1"
                                        shift
                                        ;;
        -u | --user )                   shift
                                        CADDY_USER="$1"
                                        shift
                                        ;;
        -s | --secret )                 shift
                                        CADDY_SECRET="$1"
                                        shift
                                        ;;
        -p | --port )                   shift
                                        CADDY_PORT="$1"
                                        shift
                                        ;;
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

if [[ ! -n "$CADDY_IMAGE" ]]; then
	echo "$(timestamp) ERROR: Caddy image name not provided"
	exit 1
fi
if [[ ! -n "$CADDY_CONTAINER_NAME" ]]; then
	CADDY_CONTAINER_NAME="caddy-app"
fi
if [[ ! -n "$CADDY_VOLUME_NAME" ]]; then
	CADDY_VOLUME_NAME="caddy-volume"
fi
if [[ ! -n "$CADDY_USER" ]]; then
	echo "$(timestamp) ERROR: Caddy username not provided"
	exit 1
fi
if [[ ! -n "$CADDY_SECRET" ]]; then
	echo "$(timestamp) ERROR: Caddy secret not provided"
	exit 1
fi
if [[ ! -n "$CADDY_PORT" ]]; then
	echo "$(timestamp) ERROR: Caddy port not provided"
	exit 1
fi

if [ ! -z $(docker ps -q -f name=${CADDY_CONTAINER_NAME}) ]; then    
  docker container stop ${CADDY_CONTAINER_NAME}
fi

if [ "$(docker container inspect -f '{{.State.Status}}' ${CADDY_CONTAINER_NAME})" == "exited" ]; then
  echo "$(timestamp) Removing old caddy container"
  docker container rm ${CADDY_CONTAINER_NAME}      
    
  if [ "$(docker volume inspect -f '{{.Scope}}' ${CADDY_VOLUME_NAME})" == "local" ]; then
    echo "$(timestamp) Removing old caddy volume"
    docker volume rm $CADDY_VOLUME_NAME
  fi
fi  

echo "$(timestamp) Pulling image"
docker pull $CADDY_IMAGE

echo "$(timestamp) Creating new caddy volume"
docker volume create $CADDY_VOLUME_NAME

echo "$(timestamp) Initiating caddy container run"
docker run --name=$CADDY_CONTAINER_NAME \
  --detach \
  -v=$CADDY_VOLUME_NAME:/data \
  --restart=unless-stopped \
  --env=APP_USERNAME="${CADDY_USER}" \
  --env=APP_PASSWORD_HASH="${CADDY_SECRET}" \
  --publish=${CADDY_PORT}:8080 \
  $CADDY_IMAGE
