# The Java runtime is the one from the official Temurin image, copied onto a bare Alpine instead of
# building on that image, which also installs gnupg, openssl, p11-kit-trust and musl-locales.
# classes_nocoops.jsa is left out: it is the class data sharing archive
# the JVM maps only when the heap is above 32 GB and compressed oops are off, and such a heap
# starts without class data sharing and without a warning. classes.jsa, which every smaller heap
# maps, stays.
FROM eclipse-temurin:21-jre-alpine AS jre
RUN rm /opt/java/openjdk/lib/server/classes_nocoops.jsa

# Base image: the Alpine release the Temurin runtime above is built on. Move the two together.
FROM alpine:3.24

# The slim variant of fess/snapshot. It leaves out the plugins that 15.9 moved out of the war
# (fess-script-groovy, fess-storage-s3, fess-storage-gcs and the four fess-sso-* authenticators),
# so script_type=groovy and every data store, job or crawler script that leaves script_type unset,
# s3: and gcs: and every sso.type do not work until one is added back, at startup with
# FESS_PLUGINS or in a derived image with `bin/fess-setup install plugin`. Like fess/snapshot, it
# has none of the tools bin/generate-thumbnail calls, so only HTML pages get thumbnails.

# Metadata labels for better container management
LABEL maintainer="CodeLibs" \
      org.opencontainers.image.title="Fess (slim)" \
      org.opencontainers.image.description="Enterprise search server powered by OpenSearch" \
      org.opencontainers.image.url="https://fess.codelibs.org/" \
      org.opencontainers.image.source="https://github.com/codelibs/docker-fess" \
      org.opencontainers.image.vendor="CodeLibs" \
      org.opencontainers.image.licenses="Apache-2.0"

# The Java and locale environment the Temurin image sets
ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:${PATH}" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY --from=jre /opt/java/openjdk /opt/java/openjdk

# Set environment variable for Fess application type
ENV FESS_APP_TYPE=docker

# Set Fess version as a build argument
ARG FESS_VERSION=15.9.0-SNAPSHOT

# This ARG is used to bust the cache when needed
ARG CACHEBUST=1

# Combine RUN instructions to reduce image layers and size
RUN set -x && \
    # 1. Install minimal dependencies (including unzip for extraction and zip for the zstd-jni
    #    step, both removed in step 5). fontconfig, ttf-dejavu and tzdata are what the Temurin
    #    image installs for Java's font handling and zone data.
    apk add --no-cache \
        bash \
        curl \
        coreutils \
        fontconfig \
        ttf-dejavu \
        tzdata \
        unzip \
        zip && \
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
    #    zstd-jni, which extracts .zst and .tar.zst files, is the one jar in the distribution with
    #    native code. It bundles its library for 17 OS and architecture combinations and loads
    #    linux/<os.arch> on Linux, musl included, so only that one is kept, which cuts the jar
    #    from 6.5 MB to about 0.4 MB. os.arch is read from the java this image runs, with perf data
    #    off so that it leaves no /tmp/hsperfdata_root behind, and the build fails if the jar has
    #    no library for it rather than leaving an image that cannot extract those files.
    arch=$("${JAVA_HOME}/bin/java" -XX:-UsePerfData -XshowSettings:properties -version 2>&1 | sed -n 's/^ *os\.arch = //p') && \
    jar=$(ls /usr/share/fess/app/WEB-INF/lib/zstd-jni-*.jar) && \
    zip -sf "${jar}" | grep -q "^ *linux/${arch}/libzstd-jni-.*\.so$" || (echo "zstd-jni has no native library for linux/${arch}" && exit 1) && \
    zip -q -d "${jar}" '*.so' '*.dylib' '*.dll' -x "linux/${arch}/*" && \
    # 5. Remove unzip and zip after use to keep image minimal
    apk del unzip zip && \
    # 6. Create necessary directories
    mkdir -p /etc/default /etc/fess /opt/fess /var/tmp/fess /var/log/fess /var/lib/fess && \
    # 7. Uncomment logging configurations in log4j2.xml files for console output
    for f in $(find /usr/share/fess/app/WEB-INF/ -type f | grep log4j2.xml) ; do \
      sed -i 's/[^\t]*<!-- //' $f; sed -i 's/\/> -->/\/>/' $f; done  && \
    # 8. Configure Fess to load custom configurations from /opt/fess
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess && \
    # 9. Create /etc/default/fess. These are container defaults only: each entry
    #    keeps a value already present in the environment, so every one of them
    #    can be overridden with `docker run -e` / compose `environment:`.
    echo 'export FESS_CONF_PATH="${FESS_CONF_PATH:-/etc/fess}"' >> /etc/default/fess && \
    echo 'export FESS_OVERRIDE_CONF_PATH="${FESS_OVERRIDE_CONF_PATH:-/opt/fess}"' >> /etc/default/fess && \
    echo 'export FESS_TEMP_PATH="${FESS_TEMP_PATH:-/var/tmp/fess}"' >> /etc/default/fess && \
    echo 'export FESS_LOG_PATH="${FESS_LOG_PATH:-/var/log/fess}"' >> /etc/default/fess && \
    echo 'export FESS_VAR_PATH="${FESS_VAR_PATH:-/var/lib/fess}"' >> /etc/default/fess && \
    echo 'export FESS_PORT="${FESS_PORT:-8080}"' >> /etc/default/fess && \
    #    bin/fess.in.sh lets FESS_HEAP_SIZE override FESS_MIN_MEM/FESS_MAX_MEM,
    #    so the heap default is only applied when neither of the pair is given.
    echo 'if [ -z "${FESS_MIN_MEM}${FESS_MAX_MEM}" ] ; then export FESS_HEAP_SIZE="${FESS_HEAP_SIZE:-512m}" ; fi' >> /etc/default/fess && \
    echo 'export FESS_DICTIONARY_PATH="${FESS_DICTIONARY_PATH:-/var/lib/opensearch/config/}"' >> /etc/default/fess && \
    echo 'export SEARCH_ENGINE_HTTP_URL="${SEARCH_ENGINE_HTTP_URL:-http://localhost:9200}"' >> /etc/default/fess && \
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
    CMD curl -f "http://localhost:${FESS_PORT:-8080}${FESS_CONTEXT_PATH%/}/api/v2/health" || exit 1

# The entrypoint script `run.sh` performs setup tasks that require root.
# Therefore, the container must be started as root.
# The script itself is responsible for starting the Fess process.
USER root
ENTRYPOINT ["/usr/share/fess/run.sh"]
