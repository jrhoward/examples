#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ]; then
    echo "version number is required"
    exit
fi


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

docker build -t file-watch .

docker tag file-watch  jatrat/file-watch:v0.0.$1
docker push jatrat/file-watch:v0.0.$1
exit 0
#kubectl apply -f deployment/envoy.yaml 
#sleep 10

#kubectl get pods -n envoy -o wide
