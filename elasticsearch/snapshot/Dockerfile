FROM alpine:3 AS builder

ARG CONFIGSYNC_URL=https://repo1.maven.org/maven2/org/codelibs/elasticsearch-configsync/7.16.0/elasticsearch-configsync-7.16.0.zip

RUN apk update && apk add curl && \
    curl -o /tmp/configsync.zip $CONFIGSYNC_URL && \
    mkdir -p /tmp/configsync && \
    unzip -d /tmp/configsync /tmp/configsync.zip

FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.2

ARG ANALYSIS_EXTENSION_PLUGIN=org.codelibs:elasticsearch-analysis-extension:7.16.0
ARG ANALYSIS_FESS_PLUGIN=org.codelibs:elasticsearch-analysis-fess:7.16.0
ARG MINHASH_PLUGIN=org.codelibs:elasticsearch-minhash:7.16.0

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install $ANALYSIS_FESS_PLUGIN -b  && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install $ANALYSIS_EXTENSION_PLUGIN -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install $MINHASH_PLUGIN -b && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/elasticsearch/config/elasticsearch.yml && \
    mkdir /usr/share/elasticsearch/config/dictionary && \
    chown elasticsearch /usr/share/elasticsearch/config/dictionary
COPY --from=builder /tmp/configsync/ /usr/share/elasticsearch/modules/configsync/
