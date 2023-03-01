ARG FLINK_VERSION=1.16.1
FROM fj0rd/ng:py39

ENV FLINK_HOME=/opt/flink MVN_HOME=/opt/mvn
ENV PATH=${FLINK_HOME}/bin:${MVN_HOME}/bin:$PATH
ENV BUILD_DEPS build-essential libsnappy1v5 gettext-base libjemalloc-dev
RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        openjdk-11-jdk \
        ${BUILD_DEPS} \
  \
  ; mkdir ${MVN_HOME} \
  ; mvn_version=$(curl -sSL https://api.github.com/repos/apache/maven/releases/latest | jq -r '.name') \
  ; curl https://dlcdn.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz \
      | tar zxf - -C ${MVN_HOME} --strip-components=1 \
  \
  ; mkdir -p ${FLINK_HOME} \
  ; curl -sSL https://dlcdn.apache.org/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_2.12.tgz \
        | tar -zxf - --strip-components=1 -C ${FLINK_HOME} \
  ; sed 's!\(taskmanager.numberOfTaskSlots\).*$!\1: 8!' -i ${FLINK_HOME}/conf/flink-conf.yaml \
  ; pip3 --no-cache-dir install apache-flink apache-flink-libraries \
        # numpy pandas \
  ; apt-get remove -y ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;

RUN set -eux \
  ; for c in avro parquet connector-kafka connector-pulsar; do \
        curl -sSLo ${FLINK_HOME}/lib/flink-sql-${c}-${FLINK_VERSION}.jar \
        https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-${c}/${FLINK_VERSION}/flink-sql-${c}-${FLINK_VERSION}.jar ; \
    done \
  ;
