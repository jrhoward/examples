To learn about this sandbox and for instructions on how to run it please head over
to the [Envoy docs](https://www.envoyproxy.io/docs/envoy/latest/start/sandboxes/golang.html).


```sh
dockler login
docker tag golang-http-proxy  jatrat/envoy-gateway:v0.0.1
docker push jatrat/envoy-gateway:v0.0.1
```


xDS config see

https://www.envoyproxy.io/docs/envoy/latest/configuration/overview/bootstrap

https://www.envoyproxy.io/docs/envoy/latest/api-docs/xds_protocol
