FROM postgres:14

ENV BUILD_DEPS \
    git \
    cmake \
    binutils \
    m4 \
    pkg-config \
    lsb-release \
    libcurl4-openssl-dev \
    uuid-dev \
    build-essential \
    libpq-dev \
    python3-dev \
    libkrb5-dev \
    postgresql-server-dev-${PG_MAJOR}

#ENV BUILD_CITUS_DEPS \
#    libicu-dev \
#    liblz4-dev \
#    libpam0g-dev \
#    libreadline-dev \
#    libselinux1-dev \
#    libxslt-dev \
#    libzstd-dev

ENV XDG_CONFIG_HOME=/etc
#ENV LANG zh_CN.utf8
ENV TIMEZONE=Asia/Shanghai
RUN set -eux \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i /etc/locale.gen \
      -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
      -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
      postgresql-plpython3-${PG_MAJOR} \
      postgresql-${PG_MAJOR}-wal2json \
      postgresql-${PG_MAJOR}-mysql-fdw \
      postgresql-${PG_MAJOR}-rum \
      postgresql-${PG_MAJOR}-similarity \
      postgresql-${PG_MAJOR}-rational \
      postgresql-${PG_MAJOR}-cron \
      postgresql-${PG_MAJOR}-extra-window-functions \
      postgresql-${PG_MAJOR}-first-last-agg \
      postgresql-${PG_MAJOR}-ip4r \
      postgresql-${PG_MAJOR}-hll \
      postgresql-${PG_MAJOR}-jsquery \
      postgresql-${PG_MAJOR}-pgaudit \
      pgxnclient \
      python3 python3-pip python3-setuptools \
      libcurl4 curl jq ca-certificates tmux \
      uuid mariadb-client \
      ${BUILD_DEPS:-} \
      #${BUILD_CITUS_DEPS:-} \
  \
  ; curl -sSL https://github.com/fj0r/configuration/raw/main/_tmux.conf -o /etc/skel/.tmux.conf \
  ; ln -fs /etc/skel/.tmux.conf /root/.tmux.conf \
  \
  ; nvim_url=$(curl -sSL https://api.github.com/repos/neovim/neovim/releases -H 'Accept: application/vnd.github.v3+json' \
             | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep -v sha256sum | grep linux64.tar.gz) \
  ; curl -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip /usr/local/bin/nvim \
  #; rm -rf $XDG_CONFIG_HOME/nvim \
  ; git clone --depth=1 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; git clone --depth=1 https://github.com/wbthomason/packer.nvim $XDG_CONFIG_HOME/nvim/pack/packer/start/packer.nvim \
  ; nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' \
  ; rm -rf $XDG_CONFIG_HOME/nvim/pack/packer/*/*/.git \
  \
  ; pip3 --no-cache-dir install \
      numpy httpx pyyaml deepmerge cachetools \
      pydantic more-itertools fn.py PyParsing \
  ; pip3 --no-cache-dir install \
      pgcli pygments \
  \
  ; curl -s https://packagecloud.io/install/repositories/timescale/timescaledb/script.deb.sh | bash \
  ; apt-get install -y --no-install-recommends timescaledb-2-postgresql-${PG_MAJOR} \
  \
  ; curl -sSL https://install.citusdata.com/community/deb.sh | bash \
  ; citus_pkg=$(apt search postgresql-${PG_MAJOR}-citus | awk -F'/' 'NR==3 {print $1}') \
  ; apt-get install -y --no-install-recommends ${citus_pkg} \
  \
  ; build_dir=/root/build \
  ; mkdir -p $build_dir \
  \
  ; cd $build_dir \
  ; git clone https://github.com/jaiminpan/pg_jieba \
  ; cd pg_jieba \
  ; git submodule update --init --recursive  \
  ; mkdir build \
  ; cd build \
  ; cmake .. -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/${PG_MAJOR}/server \
  ; make \
  ; make install \
  \
  ; cd $build_dir \
  ; curl -sSLO https://packages.groonga.org/debian/groonga-apt-source-latest-bullseye.deb \
  ; apt install -y -V ./groonga-apt-source-latest-bullseye.deb \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
      postgresql-${PG_MAJOR}-pgdg-pgroonga \
  \
  ; cd $build_dir \
  ; mkdir pg_hint_plan \
  ; curl -sSL https://github.com/ossc-db/pg_hint_plan/archive/refs/tags/REL14_1_4_0.tar.gz | tar zxf - -C pg_hint_plan --strip-components=1 \
  ; cd pg_hint_plan \
  ; make && make install \
  \
  ; cd $build_dir \
  ; git clone https://github.com/adjust/clickhouse_fdw.git \
  ; cd clickhouse_fdw \
  ; mkdir build && cd build \
  ; cmake .. \
  ; make && make install \
  #\
  #; cd $build_dir \
  #; git clone https://github.com/timescale/timescaledb.git \
  #; cd timescaledb \
  #; git checkout master \
  #; ./bootstrap \
  #; cd build && make \
  #; make install \
  #; cd $build_dir \
  #; citus_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/citusdata/citus/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  #; curl -sSL https://github.com/citusdata/citus/archive/refs/tags/v${citus_version}.tar.gz | tar zxf - \
  #; cd citus-${citus_version} \
  #; ./configure \
  #; make && make install \
  #\
  #; cd $build_dir \
  #; anonymizer_version=$(curl -sSL "https://gitlab.com/api/v4/projects/7709206/releases" | jq -r '.[0].name') \
  #; curl -sSL https://gitlab.com/dalibo/postgresql_anonymizer/-/archive/${anonymizer_version}/postgresql_anonymizer-${anonymizer_version}.tar.gz \
  #  | tar zxf - \
  #; cd postgresql_anonymizer-${anonymizer_version} \
  #; make extension \
  #; make install \
  #\
  \
  #; cd $build_dir \
  #; zson_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/postgrespro/zson/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  #; curl -sSL https://github.com/postgrespro/zson/archive/refs/tags/v${zson_version}.tar.gz | tar zxf - \
  #; cd zson-${zson_version} \
  #; make && make install \
  #\
  \
  ; rm -rf $build_dir \
  \
  ; mkdir -p /opt/pg_flame \
  ; pg_flame_url=$(curl -sSL https://api.github.com/repos/fj0r/pg_flame/releases -H "Accept: application/vnd.github.v3+json" \
      | jq -r '.[0].assets[].browser_download_url' | grep pg_flame.tar.gz) \
  ; curl -sSL ${pg_flame_url} | tar zxf - -C /opt/pg_flame \
  \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  #    ${BUILD_CITUS_DEPS:-} \
  ; apt-get clean -y && rm -rf /var/lib/apt/lists/*


COPY .psqlrc /root
COPY pgcli_config /root/.config/pgcli/config
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN ln -sf usr/local/bin/docker-entrypoint.sh / # backwards compat

ENV PGCONF_PG_JIEBA__HMM_MODEL=
ENV PGCONF_PG_JIEBA__BASE_DICT=
ENV PGCONF_PG_JIEBA__USER_DICT=
ENV PGCONF_SHARED_BUFFERS=2GB
ENV PGCONF_WORK_MEM=32MB
ENV PGCONF_EFFECTIVE_CACHE_SIZE=8GB
ENV PGCONF_EFFECTIVE_IO_CONCURRENCY=200
ENV PGCONF_RANDOM_PAGE_COST=1.1
ENV PGCONF_WAL_LEVEL=logical
ENV PGCONF_MAX_REPLICATION_SLOTS=10
#ENV PGCONF_SHARED_PRELOAD_LIBRARIES="'citus,pg_stat_statements,timescaledb,pg_jieba.so'"
ENV PGCONF_SHARED_PRELOAD_LIBRARIES="'citus,pg_stat_statements,timescaledb'"
ENV PGCONF_LOG_MIN_DURATION_STATEMENT=1000
