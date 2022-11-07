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

ENV NVIM_PRESET=core \
    PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      pwgen s3fs python3 python3-pip ipython3 \
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
  ; mkdir -p /opt/language-server \
  ; npm install --location=global \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
  ; npm cache clean -f \
  \
  ; lua_ls_url=$(curl -sSL https://api.github.com/repos/sumneko/lua-language-server/releases -H 'Accept: application/vnd.github.v3+json' \
               | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux-x64') \
  ; mkdir -p /opt/language-server/sumneko_lua \
  ; curl -sSL ${lua_ls_url} | tar zxf - \
      -C /opt/language-server/sumneko_lua \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; nvim_url=$(curl -sSL https://api.github.com/repos/neovim/neovim/releases -H 'Accept: application/vnd.github.v3+json' \
             | jq -r '[.[]|select(.prerelease==false)][0].assets[].browser_download_url' | grep -v sha256sum | grep linux64.tar.gz) \
  ; curl -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip /usr/local/bin/nvim \
  ; git clone --depth=1 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; git clone --depth=1 https://github.com/wbthomason/packer.nvim $XDG_CONFIG_HOME/nvim/pack/packer/start/packer.nvim \
  ; nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' \
  \
  ; tsl=$(cat $XDG_CONFIG_HOME/nvim/lua/lang/treesitter_lang.json|jq -r 'join(" ")') \
  ; nvim --headless -c "TSUpdateSync ${tsl}" -c 'quit' \
  ; rm -rf $XDG_CONFIG_HOME/nvim/pack/packer/*/*/.git

ENV S3ENDPOINT=
ENV S3BUCKET=
ENV S3MOUNTPOINT=
ENV S3REGION=
ENV S3ACCESS_KEY=
ENV S3SECRET_KEY=
