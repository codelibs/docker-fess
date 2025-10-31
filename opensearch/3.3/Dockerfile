FROM opensearchproject/opensearch:3.3.2

ARG ANALYSIS_EXTENSION_PLUGIN=org.codelibs.opensearch:opensearch-analysis-extension:3.3.1
ARG ANALYSIS_FESS_PLUGIN=org.codelibs.opensearch:opensearch-analysis-fess:3.3.1
ARG MINHASH_PLUGIN=org.codelibs.opensearch:opensearch-minhash:3.3.1
ARG CONFIGSYNC_PLUGIN=org.codelibs.opensearch:opensearch-configsync:3.3.1

RUN /usr/share/opensearch/bin/opensearch-plugin remove opensearch-security-analytics && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-performance-analyzer && \
    /usr/share/opensearch/bin/opensearch-plugin install $ANALYSIS_FESS_PLUGIN -b  && \
    /usr/share/opensearch/bin/opensearch-plugin install $ANALYSIS_EXTENSION_PLUGIN -b && \
    /usr/share/opensearch/bin/opensearch-plugin install $MINHASH_PLUGIN -b && \
    /usr/share/opensearch/bin/opensearch-plugin install $CONFIGSYNC_PLUGIN -b && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/opensearch/config/opensearch.yml && \
    mkdir /usr/share/opensearch/config/dictionary && \
    chown opensearch /usr/share/opensearch/config/dictionary

