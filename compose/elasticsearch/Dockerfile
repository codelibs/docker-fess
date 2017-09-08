FROM docker.elastic.co/elasticsearch/elasticsearch-alpine-base:latest
LABEL maintainer "N2SM <support@n2sm.net>"

ARG ELASTIC_VERSION
ARG ES_DOWNLOAD_URL
ARG ES_JAVA_OPTS

ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

WORKDIR /usr/share/elasticsearch

RUN wget ${ES_DOWNLOAD_URL}/elasticsearch-${ELASTIC_VERSION}.tar.gz && \
    EXPECTED_SHA=$(wget -O - ${ES_DOWNLOAD_URL}/elasticsearch-${ELASTIC_VERSION}.tar.gz.sha1) && \
    test $EXPECTED_SHA == $(sha1sum elasticsearch-${ELASTIC_VERSION}.tar.gz | awk '{print $1}') && \
    tar zxf elasticsearch-${ELASTIC_VERSION}.tar.gz && \
    chown -R elasticsearch:elasticsearch elasticsearch-${ELASTIC_VERSION} && \
    mv elasticsearch-${ELASTIC_VERSION}/* . && \
    rmdir elasticsearch-${ELASTIC_VERSION} && \
    rm elasticsearch-${ELASTIC_VERSION}.tar.gz

RUN set -ex && for esdirs in config data logs; do \
        mkdir -p "$esdirs"; \
        chown -R elasticsearch:elasticsearch "$esdirs"; \
    done

USER elasticsearch

RUN ./bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-fess:5.5.0 && \
    ./bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-ja:5.5.0 && \
    ./bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-synonym:5.5.0 && \
    ./bin/elasticsearch-plugin install org.codelibs:elasticsearch-configsync:5.5.0 && \
    ./bin/elasticsearch-plugin install org.codelibs:elasticsearch-dataformat:5.5.0 && \
    ./bin/elasticsearch-plugin install org.codelibs:elasticsearch-langfield:5.5.0 && \
    ./bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-kuromoji-neologd:5.5.0 && \
    ./bin/elasticsearch-plugin install org.codelibs:elasticsearch-minhash:5.5.0
COPY config config
COPY bin bin

USER root
RUN chown -R elasticsearch:elasticsearch config bin && \
    chmod 0750 bin/es-docker

USER elasticsearch
CMD ["/bin/bash", "bin/es-docker"]

EXPOSE 9200 9300
