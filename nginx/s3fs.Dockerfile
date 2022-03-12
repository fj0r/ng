FROM fj0rd/ng:latest

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        s3fs \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

