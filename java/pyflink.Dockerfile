FROM fj0rd/io

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        python3-dev python3-setuptools \
        libopenblas-dev liblapack-dev \
  ; pip3 --no-cache-dir install apache-flink \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
