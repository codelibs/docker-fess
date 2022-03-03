FROM openjdk:8-jre
LABEL maintainer "N2SM <support@n2sm.net>"

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV ES_DOWNLOAD_URL https://artifacts.elastic.co/downloads/elasticsearch
ENV FESS_APP_TYPE docker

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      imagemagick \
      procps \
      unoconv \
      ant \
      && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG FESS_VERSION=12.5.3
ARG ELASTIC_VERSION=6.6.2

RUN groupadd -g 1000 elasticsearch && \
    groupadd -g 1001 fess && \
    useradd -u 1000 elasticsearch -g elasticsearch && \
    useradd -u 1001 fess -g fess

RUN set -x && \
    wget --progress=dot:mega ${ES_DOWNLOAD_URL}/elasticsearch-oss-${ELASTIC_VERSION}.deb \
      -O /tmp/elasticsearch-${ELASTIC_VERSION}.deb && \
    dpkg -i /tmp/elasticsearch-${ELASTIC_VERSION}.deb && \
    rm -rf /tmp/elasticsearch-${ELASTIC_VERSION}.deb

RUN set -x && \
    wget --progress=dot:mega https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.deb -O /tmp/fess-${FESS_VERSION}.deb && \
    dpkg -i /tmp/fess-${FESS_VERSION}.deb && \
    rm -rf /tmp/fess-${FESS_VERSION}.deb
RUN ant -f /usr/share/fess/bin/plugin.xml -Dtarget.dir=/tmp \
    -Dplugins.dir=/usr/share/elasticsearch/plugins install.plugins && \
    rm -rf /tmp/elasticsearch-*
RUN mkdir /opt/fess && \
    chown -R fess.fess /opt/fess && \
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess
RUN echo "export FESS_APP_TYPE=$FESS_APP_TYPE" >>  /usr/share/fess/bin/fess.in.sh
RUN echo "export FESS_OVERRIDE_CONF_PATH=/opt/fess" >>  /usr/share/fess/bin/fess.in.sh

COPY elasticsearch/config /etc/elasticsearch

WORKDIR /usr/share/fess
EXPOSE 8080 9200 9300

USER root
COPY run.sh /usr/share/fess/run.sh
ENTRYPOINT /usr/share/fess/run.sh
