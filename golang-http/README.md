To learn about this sandbox and for instructions on how to run it please head over
to the [Envoy docs](https://www.envoyproxy.io/docs/envoy/latest/start/sandboxes/golang.html).

For local devevelopment purposes VSCode is easy to use and has some good extension for K8s

Install:

- Microsoft Kubernetes extension
- Microsft Docker extension
- Team google Go extension
- Rdd Hat Yaml extension


```sh
brew install golang
brew install docker
brew install docker-compose
brew install colima
brew install k3d
brew install kubectl
brew install helm

# either start or restart / docker will run inside this colima linux vm
brew services colima restart| start

# k3d will run inside
K3D_FIX_DNS=0 k3d cluster create qadi

# other commeds 
k3d cluster stop qadi
K3D_FIX_DNS=0 k3d cluster start qadi

# log into docker to build the and push images

dockler login

# build and push envoy where x is the patch version of MAJOR.MINOR.PATCH
./build-script.sh x

# build and push file-watch where x is the patch version of MAJOR.MINOR.PATCH

./file-watch/build-script.sh x


# update the deployment versions in deployment/envoy.yaml

kubectl scale deployment envoy -n envoy --replicas 0

kubectl apply -f deployment/envoy.yaml

# port forward service end point to local host

kubectl port-forward -n envoy svc/envoy 9443:8443

# test

curl -v https://localhost:9443/headers -k


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