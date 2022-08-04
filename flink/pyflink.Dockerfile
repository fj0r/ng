FROM flink:1.15.1

# install python3: it has updated Python to 3.9 in Debian 11 and so install Python 3.7 from source
# it currently only supports Python 3.6, 3.7 and 3.8 in PyFlink officially.

ENV XDG_CONFIG_HOME=/etc \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai \
    PYTHONUNBUFFERED=x \
    NODE_ROOT=/opt/node
ENV PATH=${NODE_ROOT}/bin:$PATH

RUN set -eux \
  ; apt-get update -y \
  ; apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libffi-dev \
  ; wget https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tgz \
  ; tar -xvf Python-3.8.8.tgz \
  ; cd Python-3.8.8 \
  ; ./configure --without-tests --enable-shared \
  ; make -j6 \
  ; make install \
  ; ldconfig /usr/local/lib \
  ; cd .. && rm -f Python-3.8.8.tgz && rm -rf Python-3.8.8 \
  ; ln -s /usr/local/bin/python3 /usr/local/bin/python \
  \
  ; curl -sSLO https://files.pythonhosted.org/packages/45/00/4c83408e971312a2b49d04252e7439d79ce7af2672bd026d70e259e4ba15/apache-flink-1.15.1.tar.gz \
  ; curl -sSLO https://files.pythonhosted.org/packages/90/91/fb89ce235c3279771d18513e4701d685d2265729bf9d12f8af86964a7b3b/apache-flink-libraries-1.15.1.tar.gz \
  ; pip3 install apache-flink-libraries*.tar.gz && pip3 install apache-flink*.tar.gz \
  ; rm -f apache-flink*.tar.gz \
  \
  ; apt-get clean && rm -rf /var/lib/apt/lists/*


RUN set -eux \
  ; apt-get update -y \
  ; apt-get install -y \
      git gnupg s3fs ripgrep \
      sudo procps htop cron logrotate tzdata \
      curl ca-certificates rsync tcpdump socat \
      jq tree fuse xz-utils zstd zip unzip \
      lsof inetutils-ping iproute2 iptables net-tools \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  ; ln -sf /usr/bin/python3 /usr/bin/python \
  ; pip3 --no-cache-dir install \
        # aiofile fastapi uvicorn \
        debugpy pydantic pytest \
        httpx hydra-core typer pyyaml deepmerge \
        PyParsing structlog python-json-logger \
        decorator more-itertools cachetools \
  \
  ; mkdir -p /opt/node \
  ; node_version=$(curl -sSL https://nodejs.org/en/download/ | rg 'Latest LTS Version.*<strong>(.+)</strong>' -or '$1') \
  ; curl -sSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C /opt/node \
  \
  ; mkdir -p /opt/language-server \
  ; npm install --location=global \
                quicktype \
                pyright \
                vscode-json-languageserver \
                yaml-language-server \
  ; sed -i "s/\(exports.KUBERNETES_SCHEMA_URL = \)\(.*\)$/\1process.env['KUBERNETES_SCHEMA_URL'] || \2/" $(dirname $(which yaml-language-server))/../lib/node_modules/yaml-language-server/out/server/src/languageservice/utils/schemaUrls.js \
  ; npm cache clean -f \
  \
  ; lua_ls_url=$(curl -sSL https://api.github.com/repos/josa42/coc-lua-binaries/releases -H 'Accept: application/vnd.github.v3+json' \
               | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux') \
  ; mkdir -p /opt/language-server/sumneko_lua \
  ; curl -sSL ${lua_ls_url} | tar zxf - \
      -C /opt/language-server/sumneko_lua \
      --strip-components=1 \
  \
  ; nvim_url=$(curl -sSL https://api.github.com/repos/neovim/neovim/releases -H 'Accept: application/vnd.github.v3+json' \
             | jq -r '.[0].assets[].browser_download_url' | grep -v sha256sum | grep linux64.tar.gz) \
  ; curl -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip /usr/local/bin/nvim \
  ; git clone --depth=1 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; git clone --depth=1 https://github.com/wbthomason/packer.nvim $XDG_CONFIG_HOME/nvim/pack/packer/start/packer.nvim \
  ; nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' \
  \
  ; tsl=$(cat $XDG_CONFIG_HOME/nvim/lua/lang/treesitter_lang.json|jq -r 'join(" ")') \
  ; nvim --headless -c "TSUpdateSync ${tsl}" -c 'quit' \
  ; rm -rf $XDG_CONFIG_HOME/nvim/pack/packer/*/*/.git \
  ; pip3 --no-cache-dir install \
        neovim neovim-remote \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

