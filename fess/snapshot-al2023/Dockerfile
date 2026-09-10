# Base image with Java 21 on Amazon Linux 2023
FROM amazoncorretto:21-al2023

# Metadata labels for better container management
LABEL maintainer="CodeLibs" \
      org.opencontainers.image.title="Fess" \
      org.opencontainers.image.description="Enterprise search server powered by OpenSearch" \
      org.opencontainers.image.url="https://fess.codelibs.org/" \
      org.opencontainers.image.source="https://github.com/codelibs/docker-fess" \
      org.opencontainers.image.vendor="CodeLibs" \
      org.opencontainers.image.licenses="Apache-2.0"

# Set environment variables for Fess application
ENV FESS_APP_TYPE=docker

# Set Fess version as a build argument
ARG FESS_VERSION=15.9.0-SNAPSHOT

# This ARG is used to bust the cache when needed
ARG CACHEBUST=1

# Combine RUN instructions to reduce image layers and size
RUN set -x && \
    # 1. Install dependencies without weak dependencies
    dnf install -y --setopt=install_weak_deps=false \
        ImageMagick \
        poppler-utils \
        initscripts \
        glibc-langpack-en && \
    # 2. Create a dedicated user and group for Fess
    groupadd -g 1001 fess && \
    useradd -u 1001 -g fess --system --no-create-home --home /var/lib/fess fess && \
    # 3. Download and verify Fess package
    curl -LfsSo /tmp/fess-${FESS_VERSION}.rpm \
      https://fess.codelibs.org/snapshot/fess-${FESS_VERSION}.rpm && \
    # Verify download by checking file size is reasonable (>5MB for a valid Fess rpm package)
    [ $(stat -c%s /tmp/fess-${FESS_VERSION}.rpm) -gt 5242880 ] || (echo "Downloaded file too small, likely corrupted" && exit 1) && \
    # 4. Install Fess from the rpm package
    rpm -i --nodeps /tmp/fess-${FESS_VERSION}.rpm && \
    rm -f /tmp/fess-${FESS_VERSION}.rpm && \
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
    # 10. Clean up dnf cache to reduce image size
    dnf clean all

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
