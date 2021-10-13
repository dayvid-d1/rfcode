#!/usr/bin/bash

set -o nounset
set -o errexit

function usage {
  echo "Usage: ./slims-image.sh [ -b | --bimage] [ -i | --image] [ -v | --vname] [ -n | --cname] [ -r | --resources]
                                [ -c | --continent] [ -l | --location] [ -t | --threads] [ -z | --zip] [ -a | --allure]
                                [ -u | --upload] [ -g | --gc] [ -s | --symlink] [ -p | --port] [ -h | --help ]"
  echo " -b  | --bimage                       Base Image f.e. '-b ubuntu:latest'"
  echo " -i  | --image                        RF Image f.e. '-i rf-image:latest'"
  echo " -v  | --vname                        Volumne name f.e. '-v rf-vol'"
  echo " -n  | --cname                        Container name f.e. '-n rf-app'"
  echo " -r  | --resources                    Resource directory f.e. '-d ./rfcode'"
  echo " -c  | --continent                    Continent f.e. '-c America'"  
  echo " -l  | --location                     Location f.e. '-l New York'"
  echo " -t  | --threads                      Robot threads f.e. '-t 4'"
  echo " -z  | --zip                          Zip report f.e. '-z true'"
  echo " -a  | --allure                       Allure report f.e. '-a true'"
  echo " -u  | --upload                       Continent f.e. '-c America'"
  echo " -g  | --gc                           Playwright skip browser gc f.e. '-g 1'"
  echo " -s  | --symlink                      NVM Symlink Current f.e. '-s true'"
  echo " -p  | --port                         Port f.e. '-p 8080'"  
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
RF_VOLUME_NAME=''
RF_RESOURCES=''

CONTINENT=''
PLACE=''
ROBOT_THREADS=''
ZIP_REPORT=''
ALLURE_REPORT=''
AWS_UPLOAD_TO_S3=''
PLAYWRIGHT_SKIP_BROWSER_GC=''
NVM_SYMLINK_CURRENT=''
RF_PORT=''


while(($#)) ; do
    case $1 in
        -b | --bmage )                  shift
                                        RF_BASE_IMAGE="$1"
                                        shift
                                        ;;
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
        -p | --port )                   shift
                                        RF_PORT="$1"
                                        shift
                                        ;;
        -r | --resources )              shift
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
  RF_BASE_IMAGE=ubuntu:latest
fi
if [[ ! -n "$RF_IMAGE" ]]; then
	echo "$(timestamp) ERROR: RF image name not provided"
	exit 1
fi
if [[ ! -n "$RF_CONTAINER_NAME" ]]; then
	RF_CONTAINER_NAME="rfcode-app"
fi
if [[ ! -n "$RF_VOLUME_NAME" ]]; then
	RF_VOLUME_NAME="rf-volume"
fi
if [[ ! -n "$RF_RESOURCES" ]]; then
	RF_RESOURCES="$(dirname "$PWD")/workspace"
fi
if [[ ! -n "$CONTINENT" ]]; then
	echo "$(timestamp) ERROR: Continent not provided"
	exit 1
fi
if [[ ! -n "$PLACE" ]]; then
	echo "$(timestamp) ERROR: Location not provided"
	exit 1
fi
if [[ ! -n "$ROBOT_THREADS" ]]; then
	ROBOT_THREADS=1
fi
if [[ ! -n "$ZIP_REPORT" ]]; then
	ZIP_REPORT=false
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
if [[ ! -n "$RF_PORT" ]]; then
	RF_PORT=8080
fi

RF_IMAGE_ID=""
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

RF_CONTAINER_RUNNING=''
RF_CONTAINER_STATUS=''
RF_VOLUME_SCOPE=''

RF_CONTAINER_RUNNING=$(docker inspect --format=\"{{.State.Running}}\" ${RF_CONTAINER_NAME} 2> /dev/null)
RF_CONTAINER_STATUS=$(docker inspect --format=\"{{.State.Status}}\" ${RF_CONTAINER_NAME} 2> /dev/null)
RF_VOLUME_SCOPE=$(docker volume inspect --format=\"{{.Scope}}\" ${RF_VOLUME_NAME} 2> /dev/null)

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
  
  docker run --rm \
    --name=$RF_CONTAINER_NAME \
    --user=app \
    -v "/${RF_RESOURCES}":/home/app/rfcode/ \
    -v "/${RF_RESOURCES}/logs":/var/log/ \
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
    -p ${RF_PORT}:8080 \
    $RF_IMAGE
fi