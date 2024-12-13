#!/bin/bash

set -e

minikube start
kubectl apply -f deployments/envoy.yaml
kubectl apply -f deployments/tenant.yaml

exit 0