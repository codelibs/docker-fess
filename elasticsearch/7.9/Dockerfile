ARG ES_TYPE=elasticsearch

FROM docker.elastic.co/elasticsearch/${ES_TYPE}:7.9.3

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-fess:7.9.0 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-extension:7.9.1 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-configsync:7.9.0 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-dataformat:7.9.0 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-minhash:7.9.1 -b && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/elasticsearch/config/elasticsearch.yml && \
    mkdir /usr/share/elasticsearch/config/dictionary && \
    chown elasticsearch /usr/share/elasticsearch/config/dictionary

