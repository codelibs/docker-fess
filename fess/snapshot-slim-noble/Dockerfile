# The Java runtime is the one from the official Temurin image, copied onto a bare Ubuntu Noble
# instead of building on that image, which also installs gnupg, wget, p11-kit and the locales
# package. classes_nocoops.jsa is
# left out: it is the class data sharing archive the JVM maps only when the heap is above 32 GB
# and compressed oops are off, and such a heap starts without class data sharing and without a
# warning. classes.jsa, which every smaller heap maps, stays.
FROM eclipse-temurin:21-jre-noble AS jre
RUN rm /opt/java/openjdk/lib/server/classes_nocoops.jsa

# Base image: Ubuntu Noble
FROM ubuntu:noble

# The slim variant of fess/snapshot-noble. It leaves out the plugins that 15.9 moved out of the
# war (fess-script-groovy, fess-storage-s3, fess-storage-gcs and the four fess-sso-* authenticators),
# so script_type=groovy and every data store, job or crawler script that leaves script_type unset,
# s3: and gcs: and every sso.type do not work until one is added back, at startup with
# FESS_PLUGINS or in a derived image with `bin/fess-setup install plugin`. It also leaves out the
# tools bin/generate-thumbnail calls (ImageMagick, poppler-utils and unoconv), so only HTML pages
# get thumbnails.

# Metadata labels for better container management
LABEL maintainer="CodeLibs" \
      org.opencontainers.image.title="Fess (slim)" \
      org.opencontainers.image.description="Enterprise search server powered by OpenSearch" \
      org.opencontainers.image.url="https://fess.codelibs.org/" \
      org.opencontainers.image.source="https://github.com/codelibs/docker-fess" \
      org.opencontainers.image.vendor="CodeLibs" \
      org.opencontainers.image.licenses="Apache-2.0"

# The Java and locale environment the Temurin image sets. en_US.UTF-8 needs its compiled locale,
# so the 3 MB locale archive the Temurin image generated is copied along with the runtime instead
# of installing the locales package; without a UTF-8 locale Java falls back to ASCII for file names.
ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:${PATH}" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY --from=jre /opt/java/openjdk /opt/java/openjdk
COPY --from=jre /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive

# Set environment variables for Fess application
ENV FESS_APP_TYPE=docker

# Set Fess version as a build argument
ARG FESS_VERSION=15.9.0-SNAPSHOT

# This ARG is used to bust the cache when needed
ARG CACHEBUST=1

# Combine RUN instructions to reduce image layers and size
RUN set -x && \
    # 1. Update package list and install dependencies without recommended packages. The deb
    #    package depends on adduser, which the bare image does not have; ca-certificates is for
    #    curl, zip is for the zstd-jni step, which removes it again, and fontconfig and tzdata are
    #    what the Temurin image installs for Java's font handling and zone data.
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        adduser \
        ca-certificates \
        curl \
        zip \
        fontconfig \
        tzdata && \
    # 2. Create a dedicated user and group for Fess
    groupadd -g 1001 fess && \
    useradd -u 1001 -g fess --system --no-create-home --home /var/lib/fess fess && \
    # 3. Download and verify Fess package
    curl -LfsSo /tmp/fess-${FESS_VERSION}.deb \
      https://fess.codelibs.org/snapshot/fess-${FESS_VERSION}.deb && \
    # Note: Checksum verification would be ideal but snapshot builds may not have published checksums
    # Verify download by checking file size is reasonable (>5MB for a valid Fess deb package)
    [ $(stat -c%s /tmp/fess-${FESS_VERSION}.deb) -gt 5242880 ] || (echo "Downloaded file too small, likely corrupted" && exit 1) && \
    # 4. Install Fess from the deb package
    dpkg -i /tmp/fess-${FESS_VERSION}.deb && \
    rm -f /tmp/fess-${FESS_VERSION}.deb && \
    #    zstd-jni, which extracts .zst and .tar.zst files, is the one jar in the distribution with
    #    native code. It bundles its library for 17 OS and architecture combinations and loads
    #    linux/<os.arch> on Linux, so only that one is kept, which cuts the jar from 6.5 MB to
    #    about 0.4 MB. os.arch is read from the java this image runs, with perf data off so that it
    #    leaves no /tmp/hsperfdata_root behind, and the build fails if the jar has no library for
    #    it rather than leaving an image that cannot extract those files.
    #    zip rewrites the jar as root, so it is given back to fess:fess, the owner the package sets.
    arch=$("${JAVA_HOME}/bin/java" -XX:-UsePerfData -XshowSettings:properties -version 2>&1 | sed -n 's/^ *os\.arch = //p') && \
    jar=$(ls /usr/share/fess/app/WEB-INF/lib/zstd-jni-*.jar) && \
    zip -sf "${jar}" | grep -q "^ *linux/${arch}/libzstd-jni-.*\.so$" || (echo "zstd-jni has no native library for linux/${arch}" && exit 1) && \
    zip -q -d "${jar}" '*.so' '*.dylib' '*.dll' -x "linux/${arch}/*" && \
    chown fess:fess "${jar}" && \
    apt-get purge -y zip && \
    # 5. Uncomment logging configurations in log4j2.xml files for console output
    for f in $(find /usr/share/fess/app/WEB-INF/ -type f | grep log4j2.xml) ; do \
      sed -i 's/[^\t]*<!-- //' $f; sed -i 's/\/> -->/\/>/' $f; done  && \
    # 6. Create directory for custom configurations
    mkdir /opt/fess && \
    chown -R fess:fess /opt/fess && \
    # 7. Configure Fess to load custom configurations from /opt/fess
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess && \
    # 8. Set Fess environment variables
    echo "export FESS_APP_TYPE=$FESS_APP_TYPE" >> /usr/share/fess/bin/fess.in.sh && \
    echo "export FESS_OVERRIDE_CONF_PATH=/opt/fess" >> /usr/share/fess/bin/fess.in.sh && \
    # 9. Clean up apt cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
