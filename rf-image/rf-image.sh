#!/bin/sh

set -o nounset
set -o errexit

function usage {
  echo "Usage: ./slims-image.sh [ -b | --bimage] [ -r | --rimage] [ -h | --help ]"
  echo " -b  | --bimage                       Base Image f.e. '-i ubuntu:latest'"
  echo " -r  | --rimage                       RF Image f.e. '-i rf-image:latest'"
  echo " -n  | --name                         Container name f.e. '-n rf-app'"
  echo " -d  | --directory                    Resource directory f.e. '-d ./rfcode'"
  echo " -h  | --help                         Show this menu"
}

CURRENT_DIR=${PWD}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
timestamp() {
	date +"%Y-%m-%d %T"
}

RF_BASE_IMAGE=''
RF_IMAGE=''
RF_CONTAINER_NAME=''
RF_RESOURCES=''

while(($#)) ; do
    case $1 in
        -i | --image )                  shift
                                        RF_BASE_IMAGE="$1"
                                        shift
                                        ;;
        -r | --rimage )                 shift
                                        RF_IMAGE="$1"
                                        shift
                                        ;;
        -n | --name )                   shift
                                        RF_CONTAINER_NAME="$1"
                                        shift
                                        ;;
        -d | --directory )              shift
                                        RF_RESOURCES="$1"
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

if [[ ! -n "$RF_BASE_IMAGE" ]]; then
	echo "$(timestamp) ERROR: Base image name not provided"
	exit 1
fi
if [[ ! -n "$RF_IMAGE" ]]; then
	echo "$(timestamp) ERROR: RF image name not provided"
	exit 1
fi
if [[ ! -n "$RF_CONTAINER_NAME" ]]; then
	echo "$(timestamp) ERROR: Container name not provided"
	exit 1
fi
if [[ ! -n "$RF_RESOURCES" ]]; then
	echo "$(timestamp) ERROR: Resrouces directory name not provided"
	exit 1
fi
RF_BASE_IMAGE_ID=$(docker image inspect --format=\"{{.Id}}\" ${RF_BASE_IMAGE} 2> /dev/null) :;
RF_IMAGE_ID=$(docker image inspect --format=\"{{.Id}}\" ${RF_IMAGE} 2> /dev/null) :;


#if [ -z "$RF_IMAGE_ID" ]; then
  cd "$SCRIPT_DIR"
  echo "$(timestamp) Building Base image"
  docker build \
  --build-arg RF_BASE_IMAGE=$RF_BASE_IMAGE \
  -t $RF_IMAGE .
  echo "$(timestamp) Base image built successfully"
#fi
cd ${CURRENT_DIR}

RF_VOLUME_NAME="rf-volume"
RF_CONTAINER_RUNNING=$(docker inspect --format=\"{{.State.Running}}\" ${RF_CONTAINER_NAME} 2> /dev/null) :;
RF_CONTAINER_STATUS=$(docker inspect --format=\"{{.State.Status}}\" ${RF_CONTAINER_NAME} 2> /dev/null) :;
RF_VOLUME_SCOPE=$(docker volume inspect --format=\"{{.Scope}}\" ${RF_VOLUME_NAME} 2> /dev/null) :;

echo "$(timestamp) RF container $RF_CONTAINER_NAME to be set"
if [ "$RF_CONTAINER_RUNNING" = "\"false\"" ] || [ -z "$RF_CONTAINER_RUNNING" ]; then   
  if [ "${RF_CONTAINER_STATUS}" = "\"exited\"" ] || [ "${RF_CONTAINER_STATUS}" = "\"created\"" ]; then
    echo "$(timestamp) Removing old rf container"
    docker container rm ${RF_CONTAINER_NAME}
  fi  

  if [ "${RF_VOLUME_SCOPE}" = "\"local\"" ]; then
    echo "$(timestamp) Removing old rf volume"
    docker volume rm $RF_VOLUME_NAME
  fi

  echo "$(timestamp) Creating new rf volume"
  docker volume create $RF_VOLUME_NAME

  PABOT_OPTIONS='--testlevelsplit --artifactsinsubfolders'
  ROBOT_OPTIONS='--loglevel DEBUG'
  CONTINENT=America
  PLACE=New_York
  docker run --name=$RF_CONTAINER_NAME \
    --detach \
    --privileged \
    -v "/${RF_RESOURCES}":/home/app/rfcode/ \
    -v "/${RF_RESOURCES}/logs":/var/log/ \
    -e ROBOT_THREADS=4 \
    -e TZ=${CONTINENT}/${PLACE} \
    -e CONTINENT=${CONTINENT} \
    -e PLACE=${PLACE} \
    -e ZIP_REPORT=false  \
    -e ALLURE_REPORT=false \
    -e AWS_UPLOAD_TO_S3=false \
    -e PLAYWRIGHT_SKIP_BROWSER_GC=1 \
    -e NVM_SYMLINK_CURRENT=true \
    -e ROBOT_THREADS=1 \
    -e PABOT_OPTIONS="--testlevelsplit --artifactsinsubfolders" \
    -e ROBOT_OPTIONS="--loglevel DEBUG" \
    -p 8080:8080 \
    $RF_IMAGE
fi