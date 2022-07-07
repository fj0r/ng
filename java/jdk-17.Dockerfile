FROM fj0rd/io

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; mkdir -p /usr/share/man/man1 \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      openjdk-17-jdk \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

RUN set -eux \
  ; mkdir -p /opt/language-server/jdtls \
  ; jdtls_latest=$(curl -sSL https://download.eclipse.org/jdtls/snapshots/latest.txt) \
  ; curl -sSL https://download.eclipse.org/jdtls/snapshots/${jdtls_latest} \
    | tar --no-same-owner -zxf - -C /opt/language-server/jdtls \
  \
  ; echo 'done'

