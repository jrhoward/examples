To learn about this sandbox and for instructions on how to run it please head over
to the [Envoy docs](https://www.envoyproxy.io/docs/envoy/latest/start/sandboxes/golang.html).


```sh

brew install docker
brew install colima
brew install k3d

k3d cluster create qadi

# either start or restart
brew services colima restart|start

k3d cluster stop qadi
K3D_FIX_DNS=0 k3d cluster start qadi


# Build envoy !! note may not be needed any more
docker-compose -f docker-compose-go.yaml run --rm go_plugin_compile


# log into docker to build the and push images

dockler login

# build and push where x is the patch version of MAJOR.MINOR.PATCH
./build-script.sh x

# build and push file-watch where x is the patch version of MAJOR.MINOR.PATCH

./file-watch/build-script.sh x


# update the deployment versions in deployment/envoy.yaml

kubectl scale deployment envoy -n envoy --replicas 0

kubectl apply -f deployment/envoy.yaml

# port forward service end point to local host

kubectl port-forward -n envoy svc/envoy 9443:8443

# test

curl -v https://localhost:8443/headers -k







```


xDS config see

https://www.envoyproxy.io/docs/envoy/latest/configuration/overview/bootstrap

https://www.envoyproxy.io/docs/envoy/latest/api-docs/xds_protocol

```sh
kubectl apply -f envoy.yaml 
kubectl rollout restart deployment/envoy -n envoy
kubectl describe pod  -n envoy
kubectl port-forward  svc/envoy 8881:80 -n envoy


curl -v localhost:8881/headers
```


https://ahmet.im/blog/kubernetes-inotify/