FROM public.ecr.aws/opensearchproject/opensearch:3.8.0

# Metadata labels for better container management
LABEL maintainer="CodeLibs" \
      org.opencontainers.image.title="Fess OpenSearch" \
      org.opencontainers.image.description="OpenSearch customized for Fess with required plugins" \
      org.opencontainers.image.url="https://fess.codelibs.org/" \
      org.opencontainers.image.source="https://github.com/codelibs/docker-fess" \
      org.opencontainers.image.vendor="CodeLibs" \
      org.opencontainers.image.licenses="Apache-2.0"

# Fess plugins are distributed through the CodeLibs repository, so they are
# installed from an explicit URL rather than Maven Central coordinates.
ARG PLUGIN_VERSION=3.8.0
ARG PLUGIN_REPO_URL=https://maven.codelibs.org/release/org/codelibs/opensearch
ARG ANALYSIS_EXTENSION_PLUGIN=${PLUGIN_REPO_URL}/opensearch-analysis-extension/${PLUGIN_VERSION}/opensearch-analysis-extension-${PLUGIN_VERSION}.zip
ARG ANALYSIS_FESS_PLUGIN=${PLUGIN_REPO_URL}/opensearch-analysis-fess/${PLUGIN_VERSION}/opensearch-analysis-fess-${PLUGIN_VERSION}.zip
ARG MINHASH_PLUGIN=${PLUGIN_REPO_URL}/opensearch-minhash/${PLUGIN_VERSION}/opensearch-minhash-${PLUGIN_VERSION}.zip
ARG CONFIGSYNC_PLUGIN=${PLUGIN_REPO_URL}/opensearch-configsync/${PLUGIN_VERSION}/opensearch-configsync-${PLUGIN_VERSION}.zip

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

