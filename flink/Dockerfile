FROM fj0rd/io

ENV PATH=/opt/flink/bin:$PATH
RUN set -eux \
  ; mkdir -p /opt/flink \
  ; curl -sSL https://dlcdn.apache.org/flink/flink-1.16.1/flink-1.16.1-bin-scala_2.12.tgz \
        | tar -zxf - --strip-components=1 -C /opt/flink \
  ; sed 's!\(taskmanager.numberOfTaskSlots\).*$!\1: 8!' -i /opt/flink/conf/flink-conf.yaml \
  ; pip3 --no-cache-dir install apache-flink \
        # numpy pandas \
  ;

RUN set -eux \
  ; v=$(flink -v | rg 'Version: (.+),' -or '$1') \
  ; for c in avro parquet connector-kafka connector-pulsar; do \
        curl -sSLo /opt/flink/lib/flink-sql-${c}-${v}.jar \
        https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-${c}/${v}/flink-sql-${c}-${v}.jar ; \
    done \
  ;
