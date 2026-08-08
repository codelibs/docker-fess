FROM public.ecr.aws/opensearchproject/opensearch:3.8.0

# The Fess plugins are published to maven.codelibs.org instead of Maven Central, so
# they are installed by URL: the opensearch-plugin installer resolves the
# group:artifact:version form against repo1.maven.org only. build_os.sh overrides
# these arguments with timestamped snapshot URLs from the snapshot repository.
ARG PLUGIN_REPO=https://maven.codelibs.org/release/org/codelibs/opensearch
ARG PLUGIN_VERSION=3.8.1
ARG ANALYSIS_EXTENSION_PLUGIN=${PLUGIN_REPO}/opensearch-analysis-extension/${PLUGIN_VERSION}/opensearch-analysis-extension-${PLUGIN_VERSION}.zip
ARG ANALYSIS_FESS_PLUGIN=${PLUGIN_REPO}/opensearch-analysis-fess/${PLUGIN_VERSION}/opensearch-analysis-fess-${PLUGIN_VERSION}.zip
ARG MINHASH_PLUGIN=${PLUGIN_REPO}/opensearch-minhash/${PLUGIN_VERSION}/opensearch-minhash-${PLUGIN_VERSION}.zip
ARG CONFIGSYNC_PLUGIN=${PLUGIN_REPO}/opensearch-configsync/${PLUGIN_VERSION}/opensearch-configsync-${PLUGIN_VERSION}.zip

RUN /usr/share/opensearch/bin/opensearch-plugin remove opensearch-security-analytics && \
    /usr/share/opensearch/bin/opensearch-plugin remove opensearch-performance-analyzer && \
    /usr/share/opensearch/bin/opensearch-plugin install $ANALYSIS_FESS_PLUGIN -b  && \
    /usr/share/opensearch/bin/opensearch-plugin install $ANALYSIS_EXTENSION_PLUGIN -b && \
    /usr/share/opensearch/bin/opensearch-plugin install $MINHASH_PLUGIN -b && \
    /usr/share/opensearch/bin/opensearch-plugin install $CONFIGSYNC_PLUGIN -b && \
    echo 'configsync.config_path: ${FESS_DICTIONARY_PATH}' >> /usr/share/opensearch/config/opensearch.yml && \
    mkdir /usr/share/opensearch/config/dictionary && \
    chown opensearch /usr/share/opensearch/config/dictionary

