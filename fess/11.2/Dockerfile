FROM openjdk:8-jre
LABEL maintainer "N2SM <support@n2sm.net>"

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

ENV FESS_VERSION 11.2.2
ENV ELASTIC_VERSION 5.4.2
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

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-fess:5.4.2 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-ja:5.4.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-synonym:5.4.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-configsync:5.4.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-dataformat:5.4.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-langfield:5.4.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-minhash:5.4.1

COPY elasticsearch/config /etc/elasticsearch
COPY fess/config /etc/fess

WORKDIR /usr/share/fess
EXPOSE 9200 9300 8080

USER root
COPY run.sh /etc/run.sh
ENTRYPOINT /etc/run.sh
