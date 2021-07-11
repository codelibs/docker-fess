FROM docker.elastic.co/elasticsearch/elasticsearch:7.13.3

ARG ANALYSIS_EXTENSION_PLUGIN=org.codelibs:elasticsearch-analysis-extension:7.13.0
ARG ANALYSIS_FESS_PLUGIN=org.codelibs:elasticsearch-analysis-fess:7.13.0
ARG MINHASH_PLUGIN=org.codelibs:elasticsearch-minhash:7.13.0
ARG CONFIGSYNC_URL=https://repo.maven.apache.org/maven2/org/codelibs/elasticsearch-configsync/7.13.0/elasticsearch-configsync-7.13.0.zip

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install $ANALYSIS_FESS_PLUGIN -b  && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install $ANALYSIS_EXTENSION_PLUGIN -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install $MINHASH_PLUGIN -b && \
    curl -o /tmp/configsync.zip $CONFIGSYNC_URL && \
    mkdir -p /usr/share/elasticsearch/modules/configsync && \
    unzip -d /usr/share/elasticsearch/modules/configsync /tmp/configsync.zip && \
    rm /tmp/configsync.zip && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/elasticsearch/config/elasticsearch.yml && \
    mkdir /usr/share/elasticsearch/config/dictionary && \
    chown elasticsearch /usr/share/elasticsearch/config/dictionary

