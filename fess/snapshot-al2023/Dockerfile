# Base image with Java 21 on Amazon Linux 2023
FROM amazoncorretto:21-al2023

# Set environment variable for Fess application type
ENV FESS_APP_TYPE=docker

# Set Fess version as a build argument
ARG FESS_VERSION=15.1.0-SNAPSHOT

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
    # 3. Download Fess package
    curl -LfsSo /tmp/fess-${FESS_VERSION}.rpm \
      https://fess.codelibs.org/snapshot/fess-${FESS_VERSION}.rpm && \
    # 4. Install Fess from the rpm package
    rpm -i /tmp/fess-${FESS_VERSION}.rpm && \
    rm -f /tmp/fess-${FESS_VERSION}.rpm && \
    # 5. Uncomment logging configurations in log4j2.xml files for console output
    find /usr/share/fess/app/WEB-INF/ -type f -name "*log4j2.xml" \
      -exec sed -i -E 's/^[ \t]*<!--(.*)-->/\1/' {} + && \
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

# Set working directory
WORKDIR /usr/share/fess

# Expose Fess port
EXPOSE 8080

# Copy the startup script into the container.
# This script requires root privileges to run.
USER root
COPY run.sh /usr/share/fess/run.sh

# The entrypoint script `run.sh` performs setup tasks that require root.
# Therefore, the container must be started as root.
# The script itself is responsible for starting the Fess process.
ENTRYPOINT ["/usr/share/fess/run.sh"]