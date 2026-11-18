# The Java runtime is the Temurin JRE from the Adoptium release, downloaded and verified in the
# "jre" stage and copied onto a bare Alpine, so the runtime moves to a new Temurin release by
# changing TEMURIN_VERSION, without waiting for the eclipse-temurin image to be rebuilt. The
# packages the eclipse-temurin image used to install are installed explicitly below, so the image
# keeps the tools and the Java environment of the earlier releases of this line.
ARG ALPINE_VERSION=3.24

# Temurin release as <version>+<build>, from https://github.com/adoptium/temurin21-binaries/releases
# (the repository name carries the feature release, which is read from this value).
ARG TEMURIN_VERSION=21.0.13+9

FROM alpine:${ALPINE_VERSION} AS jre
ARG TEMURIN_VERSION

RUN set -eux; \
    apk add --no-cache curl; \
    case "$(uname -m)" in \
      x86_64) arch=x64 ;; \
      aarch64) arch=aarch64 ;; \
      *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;; \
    esac; \
    major="${TEMURIN_VERSION%%.*}"; \
    file="OpenJDK${major}U-jre_${arch}_alpine-linux_hotspot_$(echo "${TEMURIN_VERSION}" | tr + _).tar.gz"; \
    url="https://github.com/adoptium/temurin${major}-binaries/releases/download/jdk-$(echo "${TEMURIN_VERSION}" | sed 's/+/%2B/')/${file}"; \
    cd /tmp; \
    curl -fsSL --retry 3 -O "${url}"; \
    # The checksum is the one published beside the archive, in `sha256sum` format.
    curl -fsSL --retry 3 "${url}.sha256.txt" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    tar -xzf "${file}" -C /opt/java/openjdk --strip-components=1 --no-same-owner; \
    rm -f "${file}"; \
    /opt/java/openjdk/bin/java --version

FROM alpine:${ALPINE_VERSION}
ARG TEMURIN_VERSION

# Metadata labels for better container management
LABEL maintainer="CodeLibs" \
      org.opencontainers.image.title="Fess" \
      org.opencontainers.image.description="Enterprise search server powered by OpenSearch" \
      org.opencontainers.image.url="https://fess.codelibs.org/" \
      org.opencontainers.image.source="https://github.com/codelibs/docker-fess" \
      org.opencontainers.image.vendor="CodeLibs" \
      org.opencontainers.image.licenses="Apache-2.0"

# The Java and locale environment the Temurin image sets
ENV JAVA_HOME=/opt/java/openjdk \
    JAVA_VERSION=jdk-${TEMURIN_VERSION} \
    PATH="/opt/java/openjdk/bin:${PATH}" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY --from=jre /opt/java/openjdk /opt/java/openjdk

# Set environment variable for Fess application type
ENV FESS_APP_TYPE=docker

# Set Fess version as a build argument
ARG FESS_VERSION=15.8.0

# This ARG is used to bust the cache when needed
ARG CACHEBUST=1

# Combine RUN instructions to reduce image layers and size
RUN set -x && \
    # 1. Install minimal dependencies (including unzip for extraction)
    apk add --no-cache \
        bash \
        curl \
        ca-certificates \
        coreutils \
        fontconfig \
        gnupg \
        musl-locales \
        musl-locales-lang \
        openssl \
        p11-kit-trust \
        ttf-dejavu \
        tzdata \
        unzip && \
    # 2. Create a dedicated user and group for Fess
    addgroup -g 1001 fess && \
    adduser -u 1001 -G fess -S -h /var/lib/fess fess && \
    # 3. Download and verify Fess package (zip version)
    curl -LfsSo /tmp/fess-${FESS_VERSION}.zip \
      https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.zip && \
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

# Add health check to monitor container health
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:8080/api/v2/health || exit 1

# The entrypoint script `run.sh` performs setup tasks that require root.
# Therefore, the container must be started as root.
# The script itself is responsible for starting the Fess process.
USER root
ENTRYPOINT ["/usr/share/fess/run.sh"]
