To learn about this sandbox and for instructions on how to run it please head over
to the [Envoy docs](https://www.envoyproxy.io/docs/envoy/latest/start/sandboxes/golang.html).


```sh


brew services colima restart

k3d cluster stop qdos
K3D_FIX_DNS=0 k3d cluster start qdos

docker-compose -f docker-compose-go.yaml run --rm go_plugin_compile


docker-compose pull
docker-compose up --build -d
docker-compose ps

docker-compose stop
docker-compose rm


dockler login
docker tag golang-http-proxy  jatrat/envoy-gateway:v0.0.1
docker push jatrat/envoy-gateway:v0.0.1

kubectl get pods -n envoy -o wide

curl -v localhost:8881/headers


NEWTAG="v0.0.6" docker-compose -f docker-compose-go.yaml run --rm go_plugin_compile && docker-compose up --build -d && sleep 5 && docker-compose ps && docker-compose stop && docker-compose rm && docker tag golang-http-proxy  jatrat/envoy-gateway:${NEWTAG} && docker push jatrat/envoy-gateway:${NEWTAG}

kubectl set image -f deployment/envoy.yaml envoy=jatrat/envoy-gateway:${NEWTAG} --local -o yaml


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