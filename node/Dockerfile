FROM fj0rd/ng:latest

RUN set -eux \
  ; xh -F https://deb.nodesource.com/setup_lts.x | bash -
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
      apt-get install -y nodejs \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY node /etc/services.d/node
COPY nginx.conf /etc/nginx/nginx.conf
WORKDIR /app

VOLUME [ "/app" ]
EXPOSE 80 443

ENTRYPOINT [ "/init" ]
