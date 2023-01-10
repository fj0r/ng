FROM ubuntu:jammy

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends  git \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  ;

RUN set -eux \
  ; mkdir -p /opt/node \
  ; node_version=$(curl -sSL https://nodejs.org/en/download/ | rg 'Latest LTS Version.*<strong>(.+)</strong>' -or '$1') \
  ; curl -sSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C /opt/node \
  \
  ; mkdir -p /opt/language-server \
  ; npm install --location=global pnpm \
  ; pnpm install --location=global \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
        rescript \
        typescript-language-server typescript \
        vite vite-plugin-solid solid-js \
        @volar/vue-language-server vue \
  ; pnpm cache clean -f \
  ;

RUN set -eux \
  ; git clone --depth=1 https://github.com/microsoft/vscode-node-debug2.git /opt/language-server/vscode-node-debug2 \
  ; cd /opt/language-server/vscode-node-debug2 \
  ; pnpm install \
  ; NODE_OPTIONS=--no-experimental-fetch pnpm run build \
  ; pnpm cache clean -f

