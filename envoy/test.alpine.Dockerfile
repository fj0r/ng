FROM envoyproxy/envoy-debug:v1.23-latest as envoy
FROM alpine

ENV PATH=/opt/envoy/bin:$PATH
COPY --from=envoy /usr/local /opt/envoy
COPY envoy.yaml /envoy.yaml
