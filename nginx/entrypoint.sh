#!/usr/bin/env bash

set -e

if [[ "$DEBUG" == 'true' ]]; then
    set -x
fi

if [ ! -z "$STARTUP_SCRIPT" ]; then
  bash $STARTUP_SCRIPT
fi

# Add users if $1=user:uid:gid set
set_user () {
    IFS=':' read -ra UA <<< "$1"
    _NAME=${UA[0]}
    _UID=${UA[1]:-1000}
    _GID=${UA[2]:-1000}

    getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
    getent passwd ${_NAME} >/dev/null 2>&1 || useradd -m -u ${_UID} -g ${_GID} -G sudo -s /bin/bash -c "$2" ${_NAME}
}

init_ssh () {
    if [ -n "$user" ]; then
        for u in $(echo $user | tr "," "\n"); do
            set_user ${u} 'SSH User'
        done
    fi

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


stop() {
    # Get PID
    pid=$(cat /var/run/services)
    echo "Received SIGINT or SIGTERM. Shutting down"
    # Set TERM
    kill -SIGTERM ${pid}
    # Wait for exit
    wait ${pid}
    # All done.
    echo -n '' > /var/run/services
    echo "Done."
}

env | grep -E '_|HOME|ROOT|PATH|DIR|VERSION|LANG|TIME|MODULE|BUFFERED' \
    | grep -Ev '^(_|HOME|USER|LS_COLORS)=' \
   >> /etc/environment

trap stop SIGINT SIGTERM #ERR EXIT


################################################################################
################################################################################
__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ ! -z "$__ssh" ]; then
    echo "[$(date -Is)] starting ssh"
    init_ssh
    /usr/bin/dropbear -REFms -p 22 2>&1 &
    echo -n "$! " >> /var/run/services
fi

################################################################################
echo "[$(date -Is)] starting nginx"
################################################################################
if [ ! -z "$WEB_ROOT" ]; then
    sed -i 's!\(set $root\).*$!\1 '"\'$WEB_ROOT\'"';!' /etc/nginx/nginx.conf
fi

if grep -q '$ngx_resolver' /etc/nginx/nginx.conf; then
    sed -i 's/$ngx_resolver/'"${NGX_RESOLVER:-8.8.8.8}"'/' /etc/nginx/nginx.conf
fi

/opt/nginx/sbin/nginx 2>&1 &
echo -n "$! " >> /var/run/services

################################################################################
################################################################################
if [ ! -z "$S3SECRET_KEY" ]; then
    echo "[$(date -Is)] starting s3fs"

    s3opt=""
    for i in "${!s3_@}"; do
        _key=${i:3}
        _value=$(eval "echo \$$i")
        if [ -z "$_value" ]; then
            s3opt+="-o $_key "
        else
            s3opt+="-o $_key=$_value "
        fi
    done

    echo "${S3ACCESS_KEY}:${S3SECRET_KEY}" > /.passwd-s3fs
    chmod go-rwx /.passwd-s3fs

    if [ ! -z "${S3REGION}" ]; then
        _region="-o endpoint=$S3REGION"
    else
        _region="-o use_path_request_style"
    fi
    cmd="s3fs -f $s3opt -o bucket=$S3BUCKET -o passwd_file=/.passwd-s3fs -o url=$S3ENDPOINT $_region ${S3MOUNTPOINT:/data}"
    echo $cmd
    eval $cmd 2>&1 &
    echo -n "$! " >> /var/run/services
fi

################################################################################

wait -n $(cat /var/run/services) && exit $?
