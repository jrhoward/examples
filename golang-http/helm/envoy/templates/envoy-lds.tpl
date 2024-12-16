{{- define "envoy.data.envoy-lds.tpl" }}
  envoy-lds.tpl: |
    resources:
    - "@type": type.googleapis.com/envoy.config.listener.v3.Listener
      name: listener_0
      address:
          socket_address:
              address: 0.0.0.0
              port_value: 8443
      filter_chains:
          - filters:
                - name: envoy.filters.network.http_connection_manager
                  typed_config:
                      "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
                      stat_prefix: http_proxy
                      route_config:
                          name: all
                          virtual_hosts:
                              - name: envoy
                                domains:
                                    - "envoy.envoy.svc.cluster.local:8443"
                                routes:
                                    - match: { prefix: "/" }
                                      route:
                                          cluster: envoy
                              - name: app1
                                domains:
                                    - "app1.envoy.svc.cluster.local:8443"
                                routes:
                                    - match: { prefix: "/" }
                                      route:
                                          cluster: app1
                                          prefix_rewrite: "/headers"
                      http_filters:
                          - name: envoy.filters.http.router
                            typed_config:
                                "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
                                upstream_http_filters:
                                    - name: upstream_header
                                      typed_config:
                                          "@type": type.googleapis.com/envoy.extensions.filters.http.header_mutation.v3.HeaderMutation
                                          mutations:
                                              request_mutations:
                                                  append:
                                                      header:
                                                          key: "authorization"
                                                          value: {{.Token}}
                                    - name: envoy.filters.http.upstream_codec
                                      typed_config:
                                          "@type": type.googleapis.com/envoy.extensions.filters.http.upstream_codec.v3.UpstreamCodec
            transport_socket:
                name: envoy.transport_sockets.tls
                typed_config:
                    "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
                    common_tls_context:
                        tls_certificates:
                            # The following self-signed certificate pair is generated using:
                            # $ openssl req -x509 -newkey rsa:2048 -keyout a/front-proxy-key.pem -out  a/front-proxy-crt.pem \
                            #       -days 3650 -nodes -subj '/CN=front-envoy'
                            #
                            # Instead of feeding it as an inline_string, certificate pair can also be fed to Envoy
                            # via filename. Reference: https://envoyproxy.io/docs/envoy/latest/api-v3/config/core/v3/base.proto#config-core-v3-datasource.
                            #
                            # Or in a dynamic configuration scenario, certificate pair can be fetched remotely via
                            # Secret Discovery Service (SDS). Reference: https://envoyproxy.io/docs/envoy/latest/configuration/security/secret.
                            - certificate_chain:
                                  inline_string: |
                                      -----BEGIN CERTIFICATE-----
                                      MIICqDCCAZACCQCquzpHNpqBcDANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDDAtm
                                      cm9udC1lbnZveTAeFw0yMDA3MDgwMTMxNDZaFw0zMDA3MDYwMTMxNDZaMBYxFDAS
                                      BgNVBAMMC2Zyb250LWVudm95MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
                                      AQEAthnYkqVQBX+Wg7aQWyCCb87hBce1hAFhbRM8Y9dQTqxoMXZiA2n8G089hUou
                                      oQpEdJgitXVS6YMFPFUUWfwcqxYAynLK4X5im26Yfa1eO8La8sZUS+4Bjao1gF5/
                                      VJxSEo2yZ7fFBo8M4E44ZehIIocipCRS+YZehFs6dmHoq/MGvh2eAHIa+O9xssPt
                                      ofFcQMR8rwBHVbKy484O10tNCouX4yUkyQXqCRy6HRu7kSjOjNKSGtjfG+h5M8bh
                                      10W7ZrsJ1hWhzBulSaMZaUY3vh5ngpws1JATQVSK1Jm/dmMRciwlTK7KfzgxHlSX
                                      58ENpS7yPTISkEICcLbXkkKGEQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQCmj6Hg
                                      vwOxWz0xu+6fSfRL6PGJUGq6wghCfUvjfwZ7zppDUqU47fk+yqPIOzuGZMdAqi7N
                                      v1DXkeO4A3hnMD22Rlqt25vfogAaZVToBeQxCPd/ALBLFrvLUFYuSlS3zXSBpQqQ
                                      Ny2IKFYsMllz5RSROONHBjaJOn5OwqenJ91MPmTAG7ujXKN6INSBM0PjX9Jy4Xb9
                                      zT+I85jRDQHnTFce1WICBDCYidTIvJtdSSokGSuy4/xyxAAc/BpZAfOjBQ4G1QRe
                                      9XwOi790LyNUYFJVyeOvNJwveloWuPLHb9idmY5YABwikUY6QNcXwyHTbRCkPB2I
                                      m+/R4XnmL4cKQ+5Z
                                      -----END CERTIFICATE-----
                              private_key:
                                  inline_string: |
                                      -----BEGIN PRIVATE KEY-----
                                      MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC2GdiSpVAFf5aD
                                      tpBbIIJvzuEFx7WEAWFtEzxj11BOrGgxdmIDafwbTz2FSi6hCkR0mCK1dVLpgwU8
                                      VRRZ/ByrFgDKcsrhfmKbbph9rV47wtryxlRL7gGNqjWAXn9UnFISjbJnt8UGjwzg
                                      Tjhl6EgihyKkJFL5hl6EWzp2Yeir8wa+HZ4Achr473Gyw+2h8VxAxHyvAEdVsrLj
                                      zg7XS00Ki5fjJSTJBeoJHLodG7uRKM6M0pIa2N8b6HkzxuHXRbtmuwnWFaHMG6VJ
                                      oxlpRje+HmeCnCzUkBNBVIrUmb92YxFyLCVMrsp/ODEeVJfnwQ2lLvI9MhKQQgJw
                                      tteSQoYRAgMBAAECggEAeDGdEkYNCGQLe8pvg8Z0ccoSGpeTxpqGrNEKhjfi6NrB
                                      NwyVav10iq4FxEmPd3nobzDPkAftfvWc6hKaCT7vyTkPspCMOsQJ39/ixOk+jqFx
                                      lNa1YxyoZ9IV2DIHR1iaj2Z5gB367PZUoGTgstrbafbaNY9IOSyojCIO935ubbcx
                                      DWwL24XAf51ez6sXnI8V5tXmrFlNXhbhJdH8iIxNyM45HrnlUlOk0lCK4gmLJjy9
                                      10IS2H2Wh3M5zsTpihH1JvM56oAH1ahrhMXs/rVFXXkg50yD1KV+HQiEbglYKUxO
                                      eMYtfaY9i2CuLwhDnWp3oxP3HfgQQhD09OEN3e0IlQKBgQDZ/3poG9TiMZSjfKqL
                                      xnCABMXGVQsfFWNC8THoW6RRx5Rqi8q08yJrmhCu32YKvccsOljDQJQQJdQO1g09
                                      e/adJmCnTrqxNtjPkX9txV23Lp6Ak7emjiQ5ICu7iWxrcO3zf7hmKtj7z+av8sjO
                                      mDI7NkX5vnlE74nztBEjp3eC0wKBgQDV2GeJV028RW3b/QyP3Gwmax2+cKLR9PKR
                                      nJnmO5bxAT0nQ3xuJEAqMIss/Rfb/macWc2N/6CWJCRT6a2vgy6xBW+bqG6RdQMB
                                      xEZXFZl+sSKhXPkc5Wjb4lQ14YWyRPrTjMlwez3k4UolIJhJmwl+D7OkMRrOUERO
                                      EtUvc7odCwKBgBi+nhdZKWXveM7B5N3uzXBKmmRz3MpPdC/yDtcwJ8u8msUpTv4R
                                      JxQNrd0bsIqBli0YBmFLYEMg+BwjAee7vXeDFq+HCTv6XMva2RsNryCO4yD3I359
                                      XfE6DJzB8ZOUgv4Dvluie3TB2Y6ZQV/p+LGt7G13yG4hvofyJYvlg3RPAoGAcjDg
                                      +OH5zLN2eqah8qBN0CYa9/rFt0AJ19+7/smLTJ7QvQq4g0gwS1couplcCEnNGWiK
                                      72y1n/ckvvplmPeAE19HveMvR9UoCeV5ej86fACy8V/oVpnaaLBvL2aCMjPLjPP9
                                      DWeCIZp8MV86cvOrGfngf6kJG2qZTueXl4NAuwkCgYEArKkhlZVXjwBoVvtHYmN2
                                      o+F6cGMlRJTLhNc391WApsgDZfTZSdeJsBsvvzS/Nc0burrufJg0wYioTlpReSy4
                                      ohhtprnQQAddfjHP7rh2LGt+irFzhdXXQ1ybGaGM9D764KUNCXLuwdly0vzXU4HU
                                      q5sGxGrC1RECGB5Zwx2S2ZY=
                                      -----END PRIVATE KEY-----
  {{- end }}