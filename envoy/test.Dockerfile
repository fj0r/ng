FROM envoyproxy/envoy-distroless:v1.23-latest as envoy
FROM io

ENV PATH=/opt/envoy/bin:$PATH
COPY --from=envoy /usr/local /opt/envoy
COPY envoy.yaml /envoy.yaml
