#!/usr/bin/env bash
if [ ! -z "${PREBOOT}" ]; then
  bash $PREBOOT
fi

#sed -i 's/$ngx_resolver/'"${NGX_RESOLVER:-8.8.8.8}"'/' /etc/nginx/nginx.conf

stop () {
    kill -s QUIT $ngx
}

trap stop SIGINT SIGTERM SIGQUIT

nginx &
ngx="$!"

init_ssh () {
    for i in "${!ed25519_@}"; do
        _AU=${i:8}
        _HOME_DIR=$(getent passwd ${_AU} | cut -d: -f6)
        mkdir -p ${_HOME_DIR}/.ssh
        eval "echo \"ssh-ed25519 \$$i\" >> ${_HOME_DIR}/.ssh/authorized_keys"
        chown ${_AU} -R ${_HOME_DIR}/.ssh
        chmod go-rwx -R ${_HOME_DIR}/.ssh
    done

    # Fix permissions, if writable
    if [ -w ~/.ssh ]; then
        chown root:root ~/.ssh && chmod 700 ~/.ssh/
    fi
    if [ -w ~/.ssh/authorized_keys ]; then
        chown root:root ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
    fi
}

__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ ! -z "$__ssh" ]; then
    echo "[$(date -Is)] starting ssh"
    init_ssh
    /usr/bin/dropbear -REFems -p 22 2>&1 &
    sshd="$!"
fi



#############################################
if [ ! -z "${POSTBOOT}" ]; then
  bash $POSTBOOT
fi
wait -n $ngx $sshd && exit $?
