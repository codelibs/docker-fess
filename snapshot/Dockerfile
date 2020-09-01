FROM amd64/adoptopenjdk:11-jre-hotspot-bionic

ENV ES_DOWNLOAD_URL https://artifacts.elastic.co/downloads/elasticsearch
ENV FESS_APP_TYPE docker

RUN apt-get update && \
    apt-get install -y imagemagick procps unoconv ant xpdf && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG FESS_VERSION=13.9.0-SNAPSHOT
ARG ELASTIC_VERSION=7.9.0

RUN groupadd -g 1000 elasticsearch && \
    groupadd -g 1001 fess && \
    useradd -u 1000 elasticsearch -g elasticsearch && \
    useradd -u 1001 fess -g fess

ARG CACHEBUST=1
RUN set -x && \
    curl -LfsSo /tmp/elasticsearch-${ELASTIC_VERSION}.deb \
      ${ES_DOWNLOAD_URL}/elasticsearch-oss-${ELASTIC_VERSION}-amd64.deb && \
    dpkg -i /tmp/elasticsearch-${ELASTIC_VERSION}.deb && \
    rm -rf /tmp/elasticsearch-${ELASTIC_VERSION}.deb && \
    curl -LfsSo /tmp/fess-${FESS_VERSION}.deb \
      https://fess.codelibs.org/snapshot/fess-${FESS_VERSION}.deb && \
    dpkg -i /tmp/fess-${FESS_VERSION}.deb && \
    rm -rf /tmp/fess-${FESS_VERSION}.deb && \
    ant -f /usr/share/fess/bin/plugin.xml -Dtarget.dir=/tmp \
      -Dplugins.dir=/usr/share/elasticsearch/plugins install.plugins && \
    rm -rf /tmp/elasticsearch-* && \
    mkdir /opt/fess && \
    chown -R fess.fess /opt/fess && \
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess && \
    echo "export FESS_APP_TYPE=$FESS_APP_TYPE" >>  /usr/share/fess/bin/fess.in.sh && \
    echo "export FESS_OVERRIDE_CONF_PATH=/opt/fess" >>  /usr/share/fess/bin/fess.in.sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY elasticsearch/config /etc/elasticsearch
RUN chown root:elasticsearch /etc/elasticsearch/* && \
    chmod 660 /etc/elasticsearch/*

WORKDIR /usr/share/fess
EXPOSE 8080 9200 9300

USER root
COPY run.sh /usr/share/fess/run.sh
ENTRYPOINT /usr/share/fess/run.sh
