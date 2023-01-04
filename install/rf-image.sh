#!/bin/bash

set -x
set -o nounset
set -o errexit

usage() {
  echo "Usage: ./rf-image.sh [ -i | --image] [ -v | --vname] [ -n | --cname] [ -r | --resources]
                                [ -c | --continent] [ -l | --location] [ -t | --threads] [ -z | --zip] [ -a | --allure]
                                [ -u | --upload] [ -g | --gc] [ -s | --symlink] [ -s | --symlink] [ -p | --person]
                                [ -o | --cbrowser] [ -w | --abrowser] [ -h | --help ]"
}

CURRENT_DIR=${PWD}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
timestamp() {
	date +"%Y-%m-%d %T"
}

RF_IMAGE=''
RF_CONTAINER_NAME=''
RF_VOLUME_NAME=''
RF_RESOURCES=''
RF_USER=''

CONTINENT=''
PLACE=''
ROBOT_THREADS=''
ZIP_REPORT=''
ALLURE_REPORT=''
AWS_UPLOAD_TO_S3=''
PLAYWRIGHT_SKIP_BROWSER_GC=''
NVM_SYMLINK_CURRENT=''

CROSS_BROWSER=''
AUTO_BROWSER=''

while(($#)) ; do
    case $1 in
        -i | --image )                 shift
                                        RF_IMAGE="$1"
                                        shift
                                        ;;
        -n | --cname )                  shift
                                        RF_CONTAINER_NAME="$1"
                                        shift
                                        ;;                                        
        -v | --vname )                  shift
                                        RF_VOLUME_NAME="$1"
                                        shift
                                        ;;
        -c | --continent )              shift
                                        CONTINENT="$1"
                                        shift
                                        ;;
        -l | --location )               shift
                                        PLACE="$1"
                                        shift
                                        ;;
        -t | --threads )                shift
                                        ROBOT_THREADS="$1"
                                        shift
                                        ;;
        -z | --zip )                    shift
                                        ZIP_REPORT="$1"
                                        shift
                                        ;;
        -a | --allure )                 shift
                                        ALLURE_REPORT="$1"
                                        shift
                                        ;;
        -u | --upload )                 shift
                                        AWS_UPLOAD_TO_S3="$1"
                                        shift
                                        ;;
        -g | --gc )                  shift
                                        PLAYWRIGHT_SKIP_BROWSER_GC="$1"
                                        shift
                                        ;;
        -s | --symlink )                shift
                                        NVM_SYMLINK_CURRENT="$1"
                                        shift
                                        ;;      
        -r | --resources )              shift
                                        RF_RESOURCES="$1"
                                        shift
                                        ;;                                                
        -o | --cbrowser )               shift
                                        CROSS_BROWSER="$1"
                                        shift
                                        ;;                                                
        -w | --abrowser )               shift
                                        AUTO_BROWSER="$1"
                                        shift
                                        ;;                                                
        -p | --person )                 shift
                                        RF_USER="$1"
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

if [[ ! -n "$RF_IMAGE" ]]; then
	echo "$(timestamp) ERROR: RF image name not provided"
	exit 1
fi
if [[ ! -n "$RF_USER" ]]; then
	RF_USER="app"
fi
if [[ ! -n "$RF_CONTAINER_NAME" ]]; then
	RF_CONTAINER_NAME="rfcode-app"
fi
if [[ ! -n "$RF_VOLUME_NAME" ]]; then
	RF_VOLUME_NAME="rf-volume"
fi
if [[ ! -n "$RF_RESOURCES" ]]; then
	RF_RESOURCES="${CURRENT_DIR}/workspace"
fi
if [[ ! -n "$CONTINENT" ]]; then
	CONTINENT="America"
fi
if [[ ! -n "$PLACE" ]]; then
	PLACE="New_York"
fi
if [[ ! -n "$ROBOT_THREADS" ]]; then
	ROBOT_THREADS=1
fi
if [[ ! -n "$ZIP_REPORT" ]]; then
	ZIP_REPORT=false
fi
if [[ ! -n "$CROSS_BROWSER" ]]; then
	CROSS_BROWSER=false
fi
if [[ ! -n "$AUTO_BROWSER" ]]; then
	AUTO_BROWSER="chromium"
fi
if [[ ! -n "$ALLURE_REPORT" ]]; then
	ALLURE_REPORT=false
fi
if [[ ! -n "$AWS_UPLOAD_TO_S3" ]]; then
	AWS_UPLOAD_TO_S3=false
fi
if [[ ! -n "$PLAYWRIGHT_SKIP_BROWSER_GC" ]]; then
	PLAYWRIGHT_SKIP_BROWSER_GC=1
fi
if [[ ! -n "$NVM_SYMLINK_CURRENT" ]]; then
	NVM_SYMLINK_CURRENT=true
fi

if [ ! -z $(docker ps -q -f name=${RF_CONTAINER_NAME}) ]; then    
  docker container stop ${RF_CONTAINER_NAME}
fi

if [ "$(docker container inspect -f '{{.State.Status}}' ${RF_CONTAINER_NAME})" == "exited" ]; then
  echo "$(timestamp) Removing old caddy container"
  docker container rm ${RF_CONTAINER_NAME}      
    
  if [ "$(docker volume inspect -f '{{.Scope}}' ${RF_VOLUME_NAME})" == "local" ]; then
    echo "$(timestamp) Removing old caddy volume"
    docker volume rm $RF_VOLUME_NAME
  fi
fi  

RUN_TESTS='//etc/run-tests.sh'

echo "$(timestamp) Pulling latest image"
docker pull $RF_IMAGE  

echo "$(timestamp) Creating new RF volume"
docker volume create $RF_VOLUME_NAME

echo "$(timestamp) Ensuring RF Directories"
mkdir -p "$RF_RESOURCES/reports"
mkdir -p "$RF_RESOURCES/test"
mkdir -p "$RF_RESOURCES/logs"
mkdir -p "$RF_RESOURCES/setup"
mkdir -p "$RF_RESOURCES/data"

chmod -R 777 $RF_RESOURCES/reports
chmod -R 777 $RF_RESOURCES/logs
chmod -R 777 $RF_RESOURCES/setup
chmod -R 777 $RF_RESOURCES/data
chmod -R 777 $RF_RESOURCES/test

RUN_TESTS="/etc/run-tests.sh"

echo "$(timestamp) Initiating RF container run"
docker run \
  --name=$RF_CONTAINER_NAME \
  --privileged \
  --detach \
  -v "/${RF_RESOURCES}/test":/home/app/rfcode/test \
  -v "/${RF_RESOURCES}/reports":/home/app/rfcode/reports \
  -v "/${RF_RESOURCES}/data":/home/app/rfcode/data \
  -v "/${RF_RESOURCES}/setup":/home/app/rfcode/setup \
  -v "/${RF_RESOURCES}/logs":/var/logs \
  -v=$RF_VOLUME_NAME \
  -e ROBOT_THREADS=4 \
  -e TZ=${CONTINENT}/${PLACE} \
  -e CONTINENT=${CONTINENT} \
  -e PLACE=${PLACE} \
  -e ZIP_REPORT=${ZIP_REPORT}  \
  -e ALLURE_REPORT=${ALLURE_REPORT} \
  -e AWS_UPLOAD_TO_S3=${AWS_UPLOAD_TO_S3} \
  -e PLAYWRIGHT_SKIP_BROWSER_GC=${PLAYWRIGHT_SKIP_BROWSER_GC} \
  -e NVM_SYMLINK_CURRENT=${NVM_SYMLINK_CURRENT} \
  -e ROBOT_THREADS=${ROBOT_THREADS} \
  -e PABOT_OPTIONS="--testlevelsplit --artifactsinsubfolders" \
  -e ROBOT_OPTIONS="--loglevel DEBUG" \
  -e CROSS_BROWSER=${CROSS_BROWSER} \
  -e AUTO_BROWSER=${AUTO_BROWSER} \
  -e RUN_TESTS=${RUN_TESTS} \
  $RF_IMAGE
  
docker exec -i ${RF_CONTAINER_NAME} /bin/bash -c ${RUN_TESTS}
