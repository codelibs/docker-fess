# Base image with Java 21 JRE on Alpine
FROM eclipse-temurin:21-jre-alpine

# Metadata labels for better container management
LABEL maintainer="CodeLibs" \
      org.opencontainers.image.title="Fess" \
      org.opencontainers.image.description="Enterprise search server powered by OpenSearch" \
      org.opencontainers.image.url="https://fess.codelibs.org/" \
      org.opencontainers.image.source="https://github.com/codelibs/docker-fess" \
      org.opencontainers.image.vendor="CodeLibs" \
      org.opencontainers.image.licenses="Apache-2.0"

# Set environment variable for Fess application type
ENV FESS_APP_TYPE=docker

# Set Fess version as a build argument
ARG FESS_VERSION=15.1.0-SNAPSHOT

# This ARG is used to bust the cache when needed
ARG CACHEBUST=1

# Combine RUN instructions to reduce image layers and size
RUN set -x && \
    # 1. Install minimal dependencies (including unzip for extraction)
    apk add --no-cache \
        bash \
        curl \
        coreutils \
        unzip && \
    # 2. Create a dedicated user and group for Fess
    addgroup -g 1001 fess && \
    adduser -u 1001 -G fess -S -h /var/lib/fess fess && \
    # 3. Download and verify Fess package (zip version)
    curl -LfsSo /tmp/fess-${FESS_VERSION}.zip \
      https://fess.codelibs.org/snapshot/fess-${FESS_VERSION}.zip && \
    # Note: Checksum verification would be ideal but snapshot builds may not have published checksums
    # Verify download by checking file size is reasonable (>10MB for a valid Fess distribution)
    [ $(stat -c%s /tmp/fess-${FESS_VERSION}.zip) -gt 10485760 ] || (echo "Downloaded file too small, likely corrupted" && exit 1) && \
    # 4. Extract Fess archive
    unzip -q /tmp/fess-${FESS_VERSION}.zip -d /opt && \
    mv /opt/fess-${FESS_VERSION} /usr/share/fess && \
    rm -f /tmp/fess-${FESS_VERSION}.zip && \
    # 5. Remove unzip after use to keep image minimal
    apk del unzip && \
    # 6. Create necessary directories
    mkdir -p /etc/default /etc/fess /opt/fess /var/tmp/fess /var/log/fess /var/lib/fess && \
    # 7. Uncomment logging configurations in log4j2.xml files for console output
    for f in $(find /usr/share/fess/app/WEB-INF/ -type f | grep log4j2.xml) ; do \
      sed -i 's/[^\t]*<!-- //' $f; sed -i 's/\/> -->/\/>/' $f; done  && \
    # 8. Configure Fess to load custom configurations from /opt/fess
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess && \
    # 9. Create /etc/default/fess
    echo "FESS_CONF_PATH=/etc/fess" >> /etc/default/fess && \
    echo "FESS_OVERRIDE_CONF_PATH=/opt/fess" >> /etc/default/fess && \
    echo "FESS_TEMP_PATH=/var/tmp/fess" >> /etc/default/fess && \
    echo "FESS_LOG_PATH=/var/log/fess" >> /etc/default/fess && \
    echo "FESS_VAR_PATH=/var/lib/fess" >> /etc/default/fess && \
    echo "FESS_PORT=8080" >> /etc/default/fess && \
    echo "FESS_HEAP_SIZE=512m" >> /etc/default/fess && \
    echo "FESS_DICTIONARY_PATH=/var/lib/opensearch/config/" >> /etc/default/fess && \
    echo "SEARCH_ENGINE_HOME=/usr/share/opensearch/" >> /etc/default/fess && \
    echo "SEARCH_ENGINE_HTTP_URL=http://localhost:9200" >> /etc/default/fess && \
    echo "export FESS_CONF_PATH FESS_OVERRIDE_CONF_PATH FESS_TEMP_PATH FESS_LOG_PATH FESS_VAR_PATH FESS_PORT FESS_HEAP_SIZE FESS_DICTIONARY_PATH SEARCH_ENGINE_HOME SEARCH_ENGINE_HTTP_URL" >> /etc/default/fess && \
    # 10. Create and copy configuration files
    touch /etc/fess/system.properties && \
    mv /usr/share/fess/lib/classes/tomcat_config.properties \
       /usr/share/fess/lib/classes/logging.properties \
       /usr/share/fess/app/WEB-INF/classes/fess_config.properties \
       /usr/share/fess/app/WEB-INF/classes/fess_env_*.properties \
       /usr/share/fess/app/WEB-INF/classes/tika.xml \
       /etc/fess && \
    # 11. Set proper ownership for all Fess-related directories and files
    chown -R fess:fess /usr/share/fess /etc/default/fess /etc/fess /opt/fess /var/tmp/fess /var/log/fess /var/lib/fess

# Set working directory
WORKDIR /usr/share/fess

# Expose Fess port
EXPOSE 8080

# Copy the startup script into the container and set permissions
COPY run.sh /usr/share/fess/run.sh
RUN chmod +x /usr/share/fess/run.sh

# Add health check to monitor container status
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${FESS_PORT}/api/v1/health || exit 1

# The entrypoint script `run.sh` performs setup tasks that require root.
# Therefore, the container must be started as root.
# The script itself is responsible for starting the Fess process.
USER root
ENTRYPOINT ["/usr/share/fess/run.sh"]
