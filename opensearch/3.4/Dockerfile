FROM opensearchproject/opensearch:3.4.0

# Metadata labels for better container management
LABEL maintainer="CodeLibs" \
      org.opencontainers.image.title="Fess OpenSearch" \
      org.opencontainers.image.description="OpenSearch customized for Fess with required plugins" \
      org.opencontainers.image.url="https://fess.codelibs.org/" \
      org.opencontainers.image.source="https://github.com/codelibs/docker-fess" \
      org.opencontainers.image.vendor="CodeLibs" \
      org.opencontainers.image.licenses="Apache-2.0"

ARG ANALYSIS_EXTENSION_PLUGIN=org.codelibs.opensearch:opensearch-analysis-extension:3.4.0
ARG ANALYSIS_FESS_PLUGIN=org.codelibs.opensearch:opensearch-analysis-fess:3.4.0
ARG MINHASH_PLUGIN=org.codelibs.opensearch:opensearch-minhash:3.4.0
ARG CONFIGSYNC_PLUGIN=org.codelibs.opensearch:opensearch-configsync:3.4.0

# Remove unnecessary plugins and install Fess-specific plugins
RUN /usr/share/opensearch/bin/opensearch-plugin remove opensearch-security-analytics && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-performance-analyzer && \
    /usr/share/opensearch/bin/opensearch-plugin install $ANALYSIS_FESS_PLUGIN -b  && \
    /usr/share/opensearch/bin/opensearch-plugin install $ANALYSIS_EXTENSION_PLUGIN -b && \
    /usr/share/opensearch/bin/opensearch-plugin install $MINHASH_PLUGIN -b && \
    /usr/share/opensearch/bin/opensearch-plugin install $CONFIGSYNC_PLUGIN -b && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/opensearch/config/opensearch.yml && \
    mkdir /usr/share/opensearch/config/dictionary && \
    chown opensearch /usr/share/opensearch/config/dictionary

# Add health check to monitor OpenSearch health
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -f http://localhost:9200/_cluster/health || exit 1

