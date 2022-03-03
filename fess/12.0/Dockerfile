FROM openjdk:8-jre
LABEL maintainer "N2SM <support@n2sm.net>"

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

ENV FESS_VERSION 12.0.3
ENV ELASTIC_VERSION 6.1.3
ENV ES_DOWNLOAD_URL https://artifacts.elastic.co/downloads/elasticsearch

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      imagemagick \
      procps \
      unoconv \
      && \
    apt-get clean

RUN groupadd -g 1000 elasticsearch && \
    groupadd -g 1001 fess && \
    useradd -u 1000 elasticsearch -g elasticsearch && \
    useradd -u 1001 fess -g fess

RUN set -x && \
    wget --progress=dot:mega ${ES_DOWNLOAD_URL}/elasticsearch-${ELASTIC_VERSION}.deb -O /tmp/elasticsearch-${ELASTIC_VERSION}.deb && \
    dpkg -i /tmp/elasticsearch-${ELASTIC_VERSION}.deb && \
    rm -rf /tmp/elasticsearch-${ELASTIC_VERSION}.deb && \
    \
    wget --progress=dot:mega https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.deb -O /tmp/fess-${FESS_VERSION}.deb && \
    dpkg -i /tmp/fess-${FESS_VERSION}.deb && \
    rm -rf /tmp/fess-${FESS_VERSION}.deb

RUN mkdir /opt/fess && \
    chown -R fess.fess /opt/fess && \
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="/opt/fess:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-fess:6.1.0 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-ja:6.1.0 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-synonym:6.1.0 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-configsync:6.1.2 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-dataformat:6.1.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-langfield:6.1.0 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-minhash:6.1.0

COPY elasticsearch/config /etc/elasticsearch
COPY fess/config /etc/fess

WORKDIR /usr/share/fess
EXPOSE 9200 9300 8080

USER root
COPY run.sh /etc/run.sh
ENTRYPOINT /etc/run.sh
