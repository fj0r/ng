FROM fj0rd/io:go

RUN set -eux \
  ; go get -u github.com/caddyserver/xcaddy/cmd/xcaddy
