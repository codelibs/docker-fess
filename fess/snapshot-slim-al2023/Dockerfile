# Base image: the minimal Amazon Linux 2023 image, which the headless Corretto 21 runtime is
# installed onto below. The amazoncorretto images are built on the standard Amazon Linux image,
# which adds dnf with its Python runtime.
FROM public.ecr.aws/amazonlinux/amazonlinux:2023-minimal

# The slim variant of fess/snapshot-al2023. It leaves out the plugins that 15.9 moved out of the
# war (fess-script-groovy, fess-storage-s3, fess-storage-gcs and the four fess-sso-* authenticators),
# so script_type=groovy and every data store, job or crawler script that leaves script_type unset,
# s3: and gcs: and every sso.type do not work until one is added back, at startup with
# FESS_PLUGINS or in a derived image with `bin/fess-setup install plugin`. It also leaves out the
# tools bin/generate-thumbnail calls (ImageMagick and poppler-utils), so only HTML pages get
# thumbnails. It installs the headless runtime rather than the full JDK the other variant is built
# on, so there is no /usr/lib/jvm/java, which is why run.sh links java through JAVA_HOME.

# Metadata labels for better container management
LABEL maintainer="CodeLibs" \
      org.opencontainers.image.title="Fess (slim)" \
      org.opencontainers.image.description="Enterprise search server powered by OpenSearch" \
      org.opencontainers.image.url="https://fess.codelibs.org/" \
      org.opencontainers.image.source="https://github.com/codelibs/docker-fess" \
      org.opencontainers.image.vendor="CodeLibs" \
      org.opencontainers.image.licenses="Apache-2.0"

# The minimal image does not set it; this is the value the amazoncorretto images use.
ENV JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto

# Set environment variables for Fess application
ENV FESS_APP_TYPE=docker

# Set Fess version as a build argument
ARG FESS_VERSION=15.9.0-SNAPSHOT

# This ARG is used to bust the cache when needed
ARG CACHEBUST=1

# Combine RUN instructions to reduce image layers and size
RUN set -x && \
    # 1. Install Java and the dependencies without weak dependencies. dnf is microdnf in the
    #    minimal image, which only takes 0 or 1 for install_weak_deps. The steps below call
    #    groupadd, useradd and find, which the minimal image does not have, so shadow-utils and
    #    findutils are named.
    dnf install -y --setopt=install_weak_deps=0 \
        java-21-amazon-corretto-headless \
        initscripts \
        glibc-langpack-en \
        shadow-utils \
        findutils && \
    #    The Java package also installs lib/src.zip, the 52 MB JDK source archive, which nothing
    #    reads at runtime and which the amazoncorretto images delete as well. It is already
    #    compressed, so leaving it in would cost as much in a pull as on disk.
    rm -f /usr/lib/jvm/java-21-amazon-corretto/lib/src.zip && \
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
    # 9. Clean up dnf cache to reduce image size
    dnf clean all

# The locale the other images use, which glibc-langpack-en above provides. It is set only after
# that package is installed, so the build does not run under a locale that does not exist yet.
# Without a UTF-8 locale Java falls back to ASCII for file names.
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

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
