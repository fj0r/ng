FROM fj0rd/io:base

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV DEV_DEPS \
        apache2-utils \
        libpcre3-dev libssl-dev \
        zlib1g-dev

ENV BUILD_DEPS lsb-release software-properties-common build-essential git gnupg

ENV PATH=/opt/nginx/sbin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    $DEV_DEPS $BUILD_DEPS \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; mkdir -p /opt/helix \
  ; helix_url=$(curl -sSL https://api.github.com/repos/helix-editor/helix/releases -H 'Accept: application/vnd.github.v3+json' | jq -r '.[0].assets[].browser_download_url' | grep x86_64-linux) \
  ; curl -sSL ${helix_url} | tar Jxf - -C /opt/helix --strip-components=1 \
  ; ln -sf /opt/helix/hx /usr/local/bin/h \
  ; mkdir -p ~/.config/helix \
  ; curl -sSL https://raw.githubusercontent.com/fj0r/configuration/main/helix/config.toml > ~/.config/helix/config.toml \
  \
  ; build_dir=/root/build \
  ; mkdir -p $build_dir \
  \
  ; cd $build_dir \
  ; NCHAN_VER=$(curl -sSL https://api.github.com/repos/slact/nchan/tags -H 'Accept: application/vnd.github.v3+json' | jq -r '.[0].name' | cut -c 2-) \
  ; curl -sSL https://github.com/slact/nchan/archive/v${NCHAN_VER}.tar.gz | tar -zxf - \
  \
  ; cd $build_dir \
  ; mkdir njs \
  ; curl -sSL http://hg.nginx.org/njs/archive/tip.tar.gz | tar -zxf - --strip-component=1 -C njs \
  \
  ; cd $build_dir \
  ; NGINX_VER=$(curl -sSL https://api.github.com/repos/nginx/nginx/tags -H 'Accept: application/vnd.github.v3+json' | jq -r '.[0].name' | cut -c 9-) \
  ; curl -sSL https://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar -zxf - \
  \
  ; cd nginx-${NGINX_VER} \
  ; ./configure --prefix=/opt/nginx \
        --with-threads \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-http_auth_request_module \
        --with-http_addition_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_slice_module \
        --with-http_sub_module \
        --with-http_stub_status_module \
        --with-http_realip_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_realip_module \
        --with-stream_ssl_preread_module \
        --add-module=../njs/nginx \
        --add-dynamic-module=../nchan-${NCHAN_VER} \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
  ; make \
  ; make install \
  \
  ; rm -rf $build_dir \
  ; ln -fs /opt/nginx/conf /etc/nginx \
  ; mkdir -p /etc/nginx/conf.d \
  ; echo 'shopt -s cdable_vars' >> /root/.bashrc \
  ; echo 'export logs=/opt/nginx/logs' >> /root/.bashrc \
  \
  ; apt-get -y remove ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY config /etc/nginx
#COPY reload-nginx /usr/local/bin
WORKDIR /srv

VOLUME [ "/srv" ]
EXPOSE 80 443

ENTRYPOINT [ "/entrypoint.sh" ]

ENV WEB_ROOT=
ENV TUNNEL_FIXED=
