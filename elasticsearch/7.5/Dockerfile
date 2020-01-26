FROM docker.elastic.co/elasticsearch/elasticsearch:7.5.2

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-fess:7.5.1 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-extension:7.5.1 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-configsync:7.5.1 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-dataformat:7.5.1 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-minhash:7.5.1 -b && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/elasticsearch/config/elasticsearch.yml && \
    mkdir /usr/share/elasticsearch/config/dictionary && \
    chown elasticsearch /usr/share/elasticsearch/config/dictionary

