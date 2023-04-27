#FROM fj0rd/io:base as assets
#
#RUN set -eux \
#  ; apt-get update \
#  ; apt-get upgrade -y \
#  ; DEBIAN_FRONTEND=noninteractive \
#    apt-get install -y --no-install-recommends binutils \
#  ; mkdir -p /opt/assets \
#  \
#  ; wasmtime_url=$(curl -sSL https://api.github.com/repos/bytecodealliance/wasmtime/releases -H 'Accept: application/vnd.github.v3+json' \
#                 | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-linux | grep -v api) \
#  ; curl -sSL ${wasmtime_url} | tar Jxf - --strip-components=1 -C /opt/assets --wildcards '*/wasmtime' \
#  ; find /opt/assets -type f -exec grep -IL . "{}" \; | xargs -L 1 strip


#FROM fj0rd/scratch:goofys as goofys

FROM fj0rd/io:base
#COPY --from=assets /opt/assets /usr/local/bin
#COPY --from=goofys / /

ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      pwgen python3 python3-pip ipython3 \
      # python3-dev python3-setuptools \
  ; pip3 --no-cache-dir install \
        # aiofile fastapi uvicorn \
        debugpy pydantic pytest \
        httpx hydra-core typer pyyaml deepmerge \
        PyParsing structlog python-json-logger \
        decorator more-itertools cachetools \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

#######################
#         dev         #
#######################
ENV NODE_ROOT=/opt/node
ENV LS_ROOT=/opt/language-server
ENV PATH=${NODE_ROOT}/bin:$PATH

# '[.[]|select(.prerelease == false)][0].assets[].browser_download_url'
# '.[0].assets[].browser_download_url'
RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends gnupg build-essential \
  ; mkdir -p /opt/node \
  ; node_version=$(curl -sSL https://nodejs.org/en/download/ | rg 'Latest LTS Version.*<strong>(.+)</strong>' -or '$1') \
  ; curl -sSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C /opt/node \
  \
  ; mkdir -p ${LS_ROOT} \
  ; npm install --location=global \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
  ; npm cache clean -f \
  \
  ; lua_ls_url=$(curl -sSL https://api.github.com/repos/sumneko/lua-language-server/releases -H 'Accept: application/vnd.github.v3+json' \
               | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux-x64') \
  ; mkdir -p ${LS_ROOT}/sumneko_lua \
  ; curl -sSL ${lua_ls_url} | tar zxf - \
      -C ${LS_ROOT}/sumneko_lua \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;

