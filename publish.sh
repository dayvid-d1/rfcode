#!/usr/bin/bash

set -o nounset
set -o errexit

if [ -z ./workspace/reports ]; then
    rm -rf ./workspace/reports/*
fi

export UPDATE_ID=9
git add .
git commit -m "rfcode-update_n"$UPDATE_ID
git push origin master

export UPDATE_ID=$(( UPDATE_ID + 1 ))