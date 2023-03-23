FROM envoyproxy/envoy-distroless:v1.23-latest as envoy
FROM fj0rd/io:base

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PATH=/opt/envoy/bin:$PATH
ENV XDG_CONFIG_HOME=/etc

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    $BUILD_DEPS \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; apt-get -y remove ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY --from=envoy /usr/local /opt/envoy
COPY envoy.yaml /
COPY entrypoint.sh /entrypoint.sh
#COPY reload-nginx /usr/local/bin
WORKDIR /srv

VOLUME [ "/srv" ]
EXPOSE 80 443

ENTRYPOINT [ "/entrypoint.sh" ]

ENV WEB_ROOT=
