FROM opensearchproject/opensearch:2.13.0

ARG ANALYSIS_EXTENSION_PLUGIN=org.codelibs.opensearch:opensearch-analysis-extension:2.13.1
ARG ANALYSIS_FESS_PLUGIN=org.codelibs.opensearch:opensearch-analysis-fess:2.13.1
ARG MINHASH_PLUGIN=org.codelibs.opensearch:opensearch-minhash:2.13.1
ARG CONFIGSYNC_PLUGIN=org.codelibs.opensearch:opensearch-configsync:2.13.1

RUN /usr/share/opensearch/bin/opensearch-plugin install $ANALYSIS_FESS_PLUGIN -b  && \
    /usr/share/opensearch/bin/opensearch-plugin install $ANALYSIS_EXTENSION_PLUGIN -b && \
    /usr/share/opensearch/bin/opensearch-plugin install $MINHASH_PLUGIN -b && \
    /usr/share/opensearch/bin/opensearch-plugin install $CONFIGSYNC_PLUGIN -b && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/opensearch/config/opensearch.yml && \
    mkdir /usr/share/opensearch/config/dictionary && \
    chown opensearch /usr/share/opensearch/config/dictionary

