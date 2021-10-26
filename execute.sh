#!/usr/bin/bash

set -o nounset
set -o errexit
usage() {
  echo "Usage: ./execute.sh [ -c | --caddyimage ] [ -r | --rfimage ] ]
                            [ -t | --caddytoken ] [ -s | --caddyhash ] [ -d | --threads ]
                            [ -u | --user] [ -p | --port] [ -h | --help ]"
}

RF_IMAGE=''
ROBOT_THREADS=''
USER=''
RESOURCES=''
CADDY_IMAGE=''
CADDY_HASH=''
PORT=''
CADDY_TOKEN=''

while(($#)) ; do
    case $1 in
        -c | --caddyimage )             shift
                                        CADDY_IMAGE="$1"
                                        shift
                                        ;;
        -r | --rfimage )                shift
                                        RF_IMAGE="$1"
                                        shift
                                        ;;
        -t | --caddytoken )             shift
                                        CADDY_TOKEN="$1"
                                        shift
                                        ;;
        -s | --caddyhash )              shift
                                        CADDY_HASH="$1"
                                        shift
                                        ;;                                   
        -p | --port )                   shift
                                        PORT="$1"
                                        shift
                                        ;;
        -u | --user )                   shift
                                        USER="$1"
                                        shift
                                        ;;
        -d | --threads )                shift
                                        ROBOT_THREADS="$1"
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
	RF_IMAGE="ghcr.io/dayvid-d1/rf-image:test"
    #RF_IMAGE="davidclement/rf-image:latest"
fi
if [[ ! -n "$CADDY_IMAGE" ]]; then
	CADDY_IMAGE="davidclement/caddy-image:latest"
fi
if [[ ! -n "$CADDY_TOKEN" ]]; then
	echo "$(timestamp) ERROR: RF image name not provided"
	exit 1
fi
if [[ ! -n "$CADDY_HASH" ]]; then
	CADDY_HASH="JDJhJDEwJDNwT1ZKamJrRGEwdDNYWEN0RlBrdU9NcE5FazNabW0xVVk0dXpReUUxaWtiVEtoR1hJMUdt"
fi
if [[ ! -n "$PORT" ]]; then
    PORT=8129
fi
if [[ ! -n "$ROBOT_THREADS" ]]; then
    ROBOT_THREADS=4
fi
if [[ ! -n "$USER" ]]; then
    USER=app
fi


#===================================================================================
echo "RF-IMAGE SETUP"
#===================================================================================

RESOURCES="$PWD/workspace"
rm -rf "$PWD/workspace/reports/*"

RF_URL="https://raw.githubusercontent.com/dayvid-d1/rfcode/master/install/rf-image.sh"
curl -sOL ${RF_URL}
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

CADDY_URL="https://"${CADDY_TOKEN}"@raw.githubusercontent.com/dayvid-d1/caddy/master/install/caddy-image.sh"
curl -sOL ${CADDY_URL} 
chmod +x ./caddy-image.sh
./caddy-image.sh \
    -i ${CADDY_IMAGE} \
    -u ${USER} \
    -s ${CADDY_SECRET} \
    -p ${PORT}
#===================================================================================
#===================================================================================
