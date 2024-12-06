#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ]; then
    echo "version number is required"
    exit
fi


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


docker-compose -f docker-compose-go.yaml run --rm go_plugin_compile
docker-compose pull
docker-compose up --build -d
sleep 5

docker-compose ps

docker-compose stop
docker-compose rm


docker tag golang-http-proxy  jatrat/envoy-gateway:v0.0.$1
docker push jatrat/envoy-gateway:v0.0.$1

kubectl apply -f deployment/envoy.yaml 
sleep 10

kubectl get pods -n envoy -o wide
