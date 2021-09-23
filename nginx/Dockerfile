FROM fj0rd/io:base

ARG nginx_repo=nginx/nginx
ARG nchan_repo=slact/nchan
ARG s6overlay_repo=just-containers/s6-overlay

ARG github_header="Accept:application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV DEV_DEPS \
        apache2-utils \
        libpcre3-dev libssl-dev \
        zlib1g-dev

ENV BUILD_DEPS lsb-release software-properties-common build-essential

ENV PATH=/opt/nginx/sbin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    git gnupg \
    $DEV_DEPS $BUILD_DEPS \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; mkdir -p /opt/helix \
  ; helix_url=$(xh $github_api/helix-editor/helix/releases $github_header | jq -r '.[0].assets[].browser_download_url' | grep x86_64-linux) \
  ; xh -F ${helix_url} | tar Jxf - -C /opt/helix --strip-components=1 \
  ; ln -sf /opt/helix/hx /usr/local/bin/h \
  ; mkdir -p ~/.config/helix \
  ; xh -F https://raw.githubusercontent.com/fj0r/configuration/main/helix/config.toml > ~/.config/helix/config.toml \
  \
  ; s6overlay_url=$(xh $github_api/${s6overlay_repo}/releases $github_header | jq -r '.[0].assets[].browser_download_url' | grep -v sig | grep amd64.tar) \
  ; xh -F ${s6overlay_url} | tar xzvf - -C / \
  \
  ; build_dir=/root/build \
  ; mkdir -p $build_dir \
  \
  ; cd $build_dir \
  ; mkdir njs \
  ; xh -F http://hg.nginx.org/njs/archive/tip.tar.gz | tar -zxf - --strip-component=1 -C njs \
  \
  ; cd $build_dir \
  ; NCHAN_VER=$(xh $github_api/${nchan_repo}/tags $github_header | jq -r '.[0].name' | cut -c 2-) \
  ; xh -F https://github.com/${nchan_repo}/archive/v${NCHAN_VER}.tar.gz | tar -zxf - \
  \
  ; cd $build_dir \
  ; NGINX_VER=$(xh $github_api/${nginx_repo}/tags $github_header | jq -r '.[0].name' | cut -c 9-) \
  ; xh -F https://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar -zxf - \
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
  ; make \
  ; make install \
  \
  ; rm -rf $build_dir \
  ; ln -fs /opt/nginx/conf /etc/nginx \
  ; mkdir -p /etc/nginx/conf.d \
  ; echo 'shopt -s cdable_vars' >> /root/.bashrc \
  ; echo 'export or=/etc/nginx' >> /root/.bashrc \
  ; echo 'export logs=/opt/nginx/logs' >> /root/.bashrc \
  \
  ; apt-get -y remove ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY services.n /etc/services.d
COPY config.x /etc/nginx
COPY nchan /etc/nchan
#COPY reload-nginx /usr/local/bin
WORKDIR /srv

VOLUME [ "/srv" ]
EXPOSE 80 443

ENTRYPOINT [ "/init" ]

ENV WEB_SERVERNAME=
ENV WEB_ROOT=
ENV WS_FIXED=
