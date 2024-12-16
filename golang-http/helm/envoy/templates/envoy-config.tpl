{{- define "envoy.data.config" }}
  envoy.yaml: |
   node:
     cluster: upstream
     id: upstream
   dynamic_resources:
      lds_config:
        path: /var/lib/envoy/envoy-lds.yaml
   static_resources:
      clusters:
      - name: httpbin
        http2_protocol_options: {}
        connect_timeout: 
          seconds: 10
        type: LOGICAL_DNS
        transport_socket:
          name: envoy.transport_sockets.tls
          typed_config:
            '@type': type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        load_assignment:
          cluster_name: envoy
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: httpbin.org
                    port_value: 443
        lb_policy: ROUND_ROBIN
      - name: nossl
        http2_protocol_options: {}
        connect_timeout: 
          seconds: 10
        type: LOGICAL_DNS
        transport_socket:
          name: envoy.transport_sockets.tls
          typed_config:
            '@type': type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        load_assignment:
          cluster_name: envoy-1
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: neverssl.com
                    port_value: 443
        lb_policy: ROUND_ROBIN
   admin:
      address:
        socket_address:
          address: 0.0.0.0
          port_value: 9901
{{- end }}