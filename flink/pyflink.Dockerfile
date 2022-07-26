FROM debian:bullseye as build
RUN set -eux \
  ; git clone --depth=1 https://github.com/apache/flink.git \
  ; cd flink \
  ; python -m pip install -r flink-python/dev/dev-requirements.txt \
  ; cd flink-python; python setup.py sdist bdist_wheel \
  ; cd apache-flink-libraries; python setup.py sdist \
  ; cd .. \
  ; mkdir -p /assets \
  ; mv apache-flink-libraries/dist/*.tar.gz /assets

FROM flink:latest

# install python3: it has updated Python to 3.9 in Debian 11 and so install Python 3.7 from source
# it currently only supports Python 3.6, 3.7 and 3.8 in PyFlink officially.

RUN apt-get update -y && \
apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libffi-dev && \
wget https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz && \
tar -xvf Python-3.7.9.tgz && \
cd Python-3.7.9 && \
./configure --without-tests --enable-shared && \
make -j6 && \
make install && \
ldconfig /usr/local/lib && \
cd .. && rm -f Python-3.7.9.tgz && rm -rf Python-3.7.9 && \
ln -s /usr/local/bin/python3 /usr/local/bin/python && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

# install PyFlink

COPY --from=build /assets/apache-flink*.tar.gz /opt/pyflink
RUN pip3 install /opt/pyflink/*.tar.gz

