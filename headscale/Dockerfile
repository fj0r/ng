FROM fj0rd/io:base
WORKDIR /app

RUN set -eux \
  ; yq_url=$(curl -sSL https://api.github.com/repos/mikefarah/yq/releases -H 'Accept: application/vnd.github.v3+json' \
          | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux_amd64.tar') \
  ; curl -sSL ${yq_url} | tar zxf - && mv yq_linux_amd64 /usr/local/bin/yq \
  \
  ; hs_url=$(curl -sSL https://api.github.com/repos/juanfont/headscale/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '[.[]|select(.prerelease == false)][].assets[].browser_download_url' | grep 'linux_amd64$' | head -n 1) \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    sqlite3 ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; curl -sSLo /usr/local/bin/headscale ${hs_url} \
  ; chmod +x /usr/local/bin/headscale \
  ; mkdir -p /etc/headscale \
  ; mkdir -p /var/lib/headscale


COPY entrypoint.sh /
COPY config.yaml /headscale.config.yaml
COPY derp-example.yaml /derp-example.yaml

EXPOSE 8080
EXPOSE 8081

ENV GIN_MODE=release
ENV IP_PREFIX=10.10.0.0/16
ENV NAMESERVER=
ENV DOMAIN=
ENV SERVER_URL=
ENV NAMESPACES=

ENTRYPOINT ["/entrypoint.sh"]
