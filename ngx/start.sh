#!/bin/sh
sed -i 's/$ngx_resolver/'"${NGX_RESOLVER:-8.8.8.8}"'/' /etc/nginx/nginx.conf

stop () {
    kill -s QUIT $ngx
}

trap stop SIGINT SIGTERM SIGQUIT
nginx &
ngx=$!

ssh-keygen -A

mkdir -p /etc/ssh/authorized_keys
for i in "${!ed25519_@}"; do
    _AU=${i:8}
    eval "echo \"ssh-ed25519 \$$i\" >> /etc/ssh/authorized_keys/${_AU}"
done

/usr/sbin/sshd -D -e &
sshd=$!

wait -n $ngx $sshd
