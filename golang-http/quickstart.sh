#!/usr/bin/env bash
export K3D_FIX_DNS=0

set -e

BBlack='\033[1;30m'
BBlue='\033[1;34m'
BGreen='\033[1;32m'
nc='\033[0m'

echo -e "${BBlack}Checking deps...${nc}"
k3d --version &> /dev/null || (printf "Please install k3d:\n\nbrew install k3d\n"; exit 1)
docker --version &> /dev/null || (printf "Please install docker:\n\nbrew install docker\n"; exit 1)
docker-compose --version &> /dev/null || (printf "Please install docker-compose:\n\nbrew install docker-compose\n"; exit 1)
colima --version &> /dev/null || (printf "Please install colima:\n\nbrew install colima\n"; exit 1)
kubectl version &> /dev/null || (printf "Please install kubectl:\n\nbrew install kubectl\n"; exit 1)
helm version &> /dev/null || (printf "Please install helm:\n\nbrew install helm\n"; exit 1)
go version &> /dev/null || (printf "Please install golang:\n\nbrew install golang\n"; exit 1)
echo -e "${BGreen}OK${nc}"
echo

echo -e "${BBlack}Checking docker colima context status...${nc}"
(docker info | grep colima) &> /dev/null || (printf "Docker engine is not using colima. Please run:\ncolima start\n"; exit 1)
echo -e "${BGreen}OK${nc}"
echo

echo -e "${BBlack}Checking for existing clusters...${nc}"
k3d cluster ls >&1
echo
echo -e "${BBlack}Create a ${BBlue}new${BBlack} k3d cluster?${nc} [y/N] "
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
echo -e "${BBlack}Checking for existing containers...${nc}"
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
