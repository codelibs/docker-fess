FROM alpine:3 AS builder

ARG CONFIGSYNC_URL=https://repo1.maven.org/maven2/org/codelibs/elasticsearch-configsync/8.0.1/elasticsearch-configsync-8.0.1.zip

RUN apk update && apk add curl && \
    curl -o /tmp/configsync.zip $CONFIGSYNC_URL && \
    mkdir -p /tmp/configsync && \
    unzip -d /tmp/configsync /tmp/configsync.zip

FROM docker.elastic.co/elasticsearch/elasticsearch:8.0.0

ARG ANALYSIS_EXTENSION_PLUGIN=org.codelibs:elasticsearch-analysis-extension:8.0.0
ARG ANALYSIS_FESS_PLUGIN=org.codelibs:elasticsearch-analysis-fess:8.0.0
ARG MINHASH_PLUGIN=org.codelibs:elasticsearch-minhash:8.0.0

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-kuromoji -b  && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-nori -b  && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-smartcn -b  && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install $ANALYSIS_FESS_PLUGIN -b  && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install $ANALYSIS_EXTENSION_PLUGIN -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install $MINHASH_PLUGIN -b && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/elasticsearch/config/elasticsearch.yml && \
    mkdir /usr/share/elasticsearch/config/dictionary && \
    chown elasticsearch /usr/share/elasticsearch/config/dictionary
COPY --from=builder /tmp/configsync/ /usr/share/elasticsearch/modules/configsync/
