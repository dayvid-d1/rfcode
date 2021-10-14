#!/usr/bin/bash

set -o nounset
set -o errexit

if [ -z ./workspace/reports ]; then
    rm -rf ./workspace/reports/*
fi

git add .
git commit -m "rfcode-update_n"$UPDATE_ID
git push origin master
UPDATE_ID=$(( UPDATE_ID + 1 ))
export UPDATE_ID