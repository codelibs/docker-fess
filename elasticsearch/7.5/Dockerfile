FROM docker.elastic.co/elasticsearch/elasticsearch:7.5.1

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-fess:7.5.0 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-extension:7.5.0 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-configsync:7.5.0 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-dataformat:7.5.0 -b && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-minhash:7.5.0 -b && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/elasticsearch/config/elasticsearch.yml && \
    mkdir /usr/share/elasticsearch/config/dictionary && \
    chown elasticsearch /usr/share/elasticsearch/config/dictionary

ENV ES_PATH_CONF '/var/lib/elasticsearch/config'
ENV FESS_DICTIONARY_PATH '/var/lib/elasticsearch/config/'

RUN mkdir -p /var/lib/elasticsearch/config && \
    mv /usr/share/elasticsearch/config /var/lib/elasticsearch/

VOLUME [ "/usr/share/elasticsearch/data" ]
