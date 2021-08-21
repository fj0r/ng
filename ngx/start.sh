#!/bin/sh
sed -i 's/$ngx_resolver/'"${NGX_RESOLVER:-8.8.8.8}"'/' /etc/nginx/nginx.conf

stop () {
    kill -s QUIT $ngx
}

trap stop SIGINT SIGTERM SIGQUIT
nginx &
ngx=$!
wait $ngx
