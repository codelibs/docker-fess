# The Java runtime is the one from the official Temurin image, copied onto a bare Ubuntu Noble
# instead of building on that image, which also installs gnupg, wget, p11-kit and the locales
# package. classes_nocoops.jsa is left out: it is the class data sharing archive the JVM maps only
# when the heap is above 32 GB and compressed oops are off, and such a heap starts without class
# data sharing and without a warning. classes.jsa, which every smaller heap maps, stays.
FROM eclipse-temurin:21-jre-noble AS jre
RUN rm /opt/java/openjdk/lib/server/classes_nocoops.jsa

# Base image: Ubuntu Noble
FROM ubuntu:noble

# Metadata labels for better container management
LABEL maintainer="CodeLibs" \
      org.opencontainers.image.title="Fess" \
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
    #    curl, and fontconfig and tzdata are what the Temurin image installs for Java's font
    #    handling and zone data. The rest are the tools bin/generate-thumbnail calls.
    #    unoconv needs LibreOffice import filters for the formats it is asked to convert, and
    #    --no-install-recommends leaves those out: unoconv alone pulls libreoffice-core and
    #    libreoffice-common, which carry no document filter, so `unoconv -f pdf` on a .docx
    #    exits 6 without writing a PDF and every Office thumbnail fails. The thumbnail
    #    generator is registered for Word, Excel and PowerPoint documents (fess_thumbnail.xml),
    #    so the three matching filter packages are named here. They cost about 127 MB.
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        adduser \
        ca-certificates \
        curl \
        fontconfig \
        tzdata \
        imagemagick \
        unoconv \
        libreoffice-writer \
        libreoffice-calc \
        libreoffice-impress \
        python3-setuptools \
        poppler-utils && \
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
    # 9. Install the plugins that carry what the distribution used to bundle. 15.9 moved the
    #    Groovy script engine, the S3 and GCS storage backends and the four SSO authenticators
    #    out of the war, so leaving them out would drop behaviour the 15.8 image had: a data
    #    store, job or crawler script with no script_type still resolves to groovy, and s3:,
    #    gcs: and every sso.type would stop working. Every plugin names its own version
    #    rather than letting bin/fess-setup pick one, so that the image can be rebuilt from
    #    the jars it was built with: the plugins of a Fess line are released separately, so
    #    one shared version would be wrong as soon as one of them ships a fix of its own.
    #    A -SNAPSHOT still resolves to the latest timestamped build of that line. Every jar
    #    is checked against the SHA-1 the repository publishes, and a version that cannot be
    #    resolved fails the build instead of leaving the image short.
    #    The package installs the tree as fess:fess, so the jars are chowned to match.
    /usr/share/fess/bin/fess-setup install plugin \
      fess-script-groovy:15.9.0-SNAPSHOT \
      fess-storage-gcs:15.9.0-SNAPSHOT \
      fess-storage-s3:15.9.0-SNAPSHOT \
      fess-sso-saml:15.9.0-SNAPSHOT \
      fess-sso-spnego:15.9.0-SNAPSHOT \
      fess-sso-entraid:15.9.0-SNAPSHOT \
      fess-sso-oidc:15.9.0-SNAPSHOT && \
    chown -R fess:fess /usr/share/fess/app/WEB-INF/plugin && \
    # 10. Clean up apt cache to reduce image size
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
