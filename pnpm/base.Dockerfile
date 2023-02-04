FROM ubuntu:jammy

ENV NODE_ROOT=/opt/node
ENV PNPM_HOME=/opt/pnpm
ENV PATH=${PNPM_HOME}:${NODE_ROOT}/bin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        curl ca-certificates \
        ripgrep git \
        xz-utils zstd \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  ;

RUN set -eux \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl -sSL https://nodejs.org/en/download/ | rg 'Latest LTS Version.*<strong>(.+)</strong>' -or '$1') \
  ; curl -sSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p /opt/language-server \
  ; npm install --location=global pnpm \
  ; mkdir -p ${PNPM_HOME} \
  ; pnpm config set store-dir ${PNPM_HOME} \
  ; mkdir -p /opt/pnpm \
  ; pnpm config set store-dir /opt/pnpm \
  ; npm cache clean -f \
  ;
