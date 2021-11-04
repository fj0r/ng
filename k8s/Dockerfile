FROM fj0rd/io:base

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; export DEBIAN_FRONTEND=noninteractive \
  ; apt-get install -y --no-install-recommends gnupg\
  ; echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_Testing/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list \
  ; curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_Testing/Release.key | sudo apt-key add - \
  ; apt-get update -qq \
  ; apt-get install -y --no-install-recommends \
        skopeo buildah podman \
  \
  ; k8s_ver=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | cut -c 2-) \
  ; curl -L https://dl.k8s.io/v${k8s_ver}/kubernetes-client-linux-amd64.tar.gz \
    | tar zxf - --strip-components=3 -C /usr/local/bin kubernetes/client/bin/kubectl \
  ; chmod +x /usr/local/bin/kubectl \
  \
  ; helm_ver=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/helm/helm/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  ; curl -L https://get.helm.sh/helm-v${helm_ver}-linux-amd64.tar.gz \
        | tar zxvf - -C /usr/local/bin linux-amd64/helm --strip-components=1 \
  \
  ; istio_ver=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/istio/istio/releases | jq -r '.[0].tag_name') \
  ; curl -L https://github.com/istio/istio/releases/download/${istio_ver}/istio-${istio_ver}-linux-amd64.tar.gz \
        | tar zxvf - -C /usr/local/bin istio-${istio_ver}/bin/istioctl --strip-components=2 \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i /etc/locale.gen \
		-e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
		-e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
	; locale-gen \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
