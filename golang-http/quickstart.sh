#!/usr/bin/env bash

export K3D_FIX_DNS=0

BBlue='\033[1;34m'
nc='\033[0m'

echo "Checking deps..."
k3d --version || (printf "Please install k3d:\nbrew install k3d\n"; exit 1)
docker --version || (printf "Please install docker:\nbrew install docker\n"; exit 1)
docker-compose --version || (printf "Please install docker-compose:\nbrew install docker-compose\n"; exit 1)
colima --version || (printf "Please install colima:\nbrew install colima\n"; exit 1)
kubectl version || (printf "Please install kubectl:\nbrew install kubectl\n"; exit 1)
helm version || (printf "Please install helm:\nbrew install helm\n"; exit 1)
go version || (printf "Please install golang:\nbrew install golang\n"; exit 1)
echo "Checking for existing clusters..."
echo
k3d cluster ls >&1
echo
echo -e "Create a ${BBlue}new${nc} k3d cluster? [y/N] "
read -r ans
case $ans in
    [yY])
        k3d cluster create qadi
        ;;
    *)
        echo "Skipping cluster creation..."
        ;;
esac

echo
echo "Checking for existing containers..."
echo
docker compose ps >&1
echo
read -r -p "Build the docker image for golang-http-proxy (envoy-gateway) and run it? [y/N] " ans
case $ans in
    [yY])
        docker-compose -f docker-compose-go.yaml run --rm go_plugin_compile
        docker-compose pull
        docker-compose up --build -d && docker compose ps
        ;;
    *)
        echo "Skipping build..."
        ;;
esac

echo
read  -r -p "Push new build version to docker hub? [y/N] " ans
case $ans in
    [yY])
        read -r -p "Enter MINOR version bump, e.g. 14: " ver_ans
        docker tag golang-http-proxy  jatrat/envoy-gateway:v0.0."$ver_ans"
        docker push jatrat/envoy-gateway:v0.0."$ver_ans"
        ;;
    *)
        echo "Skipping docker hub push..."
        ;;
esac

echo
read -r -p "Build the docker image for file-watch? [y/N] " ans
case $ans in
    [yY])
        cd file-watch || (echo "could not find file-watch directory"; exit 1)
        docker build -t file-watch .
        cd ..
        ;;
    *)
        echo "Skipping build..."
        ;;
esac

echo
read  -r -p "Push new build version to docker hub? [y/N] " ans
case $ans in
    [yY])
        read -r -p "Enter MINOR version bump, e.g. 14: " ver_ans
        docker tag file-watch  jatrat/file-watch:v0.0."$ver_ans"
        docker push jatrat/file-watch:v0.0."$ver_ans"
        ;;
    *)
        echo "Skipping docker hub push..."
        ;;
esac

echo
read -r -p "Deploy to local cluster? [y/N] " ans
case $ans in
    [yY])
        kubectl apply -f deployment/envoy.yaml >&1
        ;;
    *)
        echo "Skipping deployment..."
        ;;
esac

echo
read -r -p "Run the proxy port forward? [y/N] " ans
case $ans in
    [yY])
        kubectl port-forward -n envoy svc/envoy 9443:8443 || echo "Try again later if pod is still creating."
        ;;
    *)
        exit 0
        ;;
esac

echo
echo "Finished."
exit 0

#To match the first condition
curl -H "x-llm-region: au-east-2" -H "x-llm-providor: Azure" -H "x-llm-model: chat-gpt-4o" https://localhost:9443/headers -k -v

#Curl with wrong headers that don't match first condition
curl -H "x-llm-region: au-east-2" -H "x-llm-providor: AWS" -H "x-llm-model: chat-gpt-4o" https://localhost:9443 -k -v

#Curl with no headers specified
curl -v https://localhost:9443 -k