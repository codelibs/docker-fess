# The Java runtime is the Azul Zulu JRE, downloaded and verified in the
# "jre" stage and copied onto a bare Ubuntu, so the runtime moves to a new Zulu release by
# changing JRE_VERSION and ZULU_VERSION, without waiting for the eclipse-temurin image to be rebuilt. The
# packages the eclipse-temurin image used to install are installed explicitly below, so the image
# keeps the tools and the Java environment of the earlier releases of this line.
ARG UBUNTU_RELEASE=noble

# Azul Zulu JRE: JRE_VERSION is the OpenJDK version and build, ZULU_VERSION the Zulu release, which
# together name the archive zulu<ZULU_VERSION>-ca-jre<version>-linux_<arch>.tar.gz of
# https://cdn.azul.com/zulu/bin/. Zulu is used because it publishes the glibc aarch64 builds.
ARG JRE_VERSION=21.0.13.1+2
ARG ZULU_VERSION=21.54.201

FROM ubuntu:${UBUNTU_RELEASE} AS jre
ARG JRE_VERSION
ARG ZULU_VERSION

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl; \
    case "$(dpkg --print-architecture)" in \
      amd64) arch=x64 ;; \
      arm64) arch=aarch64 ;; \
      *) echo "Unsupported architecture: $(dpkg --print-architecture)"; exit 1 ;; \
    esac; \
    jdk="${JRE_VERSION%%+*}"; \
    file="zulu${ZULU_VERSION}-ca-jre${jdk}-linux_${arch}.tar.gz"; \
    # The checksum is the one Azul publishes for the archive in its metadata API.
    sha256="$(curl -fsSL --retry 3 "https://api.azul.com/metadata/v1/zulu/packages/?java_version=${jdk}&os=linux&arch=${arch}&java_package_type=jre&archive_type=tar.gz&release_status=ga&availability_types=CA&page_size=100&include_fields=sha256_hash" | tr '{' '\n' | sed -n "s/.*\"name\":\"${file}\".*\"sha256_hash\":\"\([0-9a-f]\{64\}\)\".*/\1/p")"; \
    [ -n "${sha256}" ]; \
    cd /tmp; \
    curl -fsSL --retry 3 -O "https://cdn.azul.com/zulu/bin/${file}"; \
    echo "${sha256}  ${file}" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    tar -xzf "${file}" -C /opt/java/openjdk --strip-components=1 --no-same-owner; \
    rm -f "${file}"; \
    # The JDK trust store is rebuilt from the Ubuntu CA bundle: the Zulu one lacks about 50 roots that the
    # Temurin images of these lines trust (for example D-TRUST, Telekom Security, HARICA and Certum).
    # The certificates are stored unencrypted, as in the JDK's own cacerts, because the JVM opens the
    # trust store without a password and would otherwise see no certificate at all.
    rm -f /opt/java/openjdk/lib/security/cacerts; \
    for pem in /etc/ssl/certs/*.pem; do \
      /opt/java/openjdk/bin/keytool -J-Dkeystore.pkcs12.certProtectionAlgorithm=NONE \
        -importcert -noprompt -storetype PKCS12 \
        -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit \
        -alias "$(basename "${pem}" .pem | tr -c 'A-Za-z0-9._\n-' _)" < "${pem}" > /dev/null; \
    done; \
    /opt/java/openjdk/bin/java --version

FROM ubuntu:${UBUNTU_RELEASE}
ARG JRE_VERSION

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
    JAVA_VERSION=jdk-${JRE_VERSION} \
    PATH="/opt/java/openjdk/bin:${PATH}" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY --from=jre /opt/java/openjdk /opt/java/openjdk

# Set environment variables for Fess application
ENV FESS_APP_TYPE=docker

# Set Fess version as a build argument
ARG FESS_VERSION=15.6.1

# This ARG is used to bust the cache when needed
ARG CACHEBUST=1

# Combine RUN instructions to reduce image layers and size
RUN set -x && \
    # 1. Update package list and install dependencies without recommended packages
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        fontconfig \
        locales \
        p11-kit \
        tzdata \
        wget \
        curl \
        imagemagick \
        libheif-plugin-libde265 \
        unoconv \
        python3-setuptools \
        poppler-utils && \
    #    The en_US.UTF-8 locale of the LANG above; without it Java falls back to ASCII.
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    # 2. Create a dedicated user and group for Fess
    groupadd -g 1001 fess && \
    useradd -u 1001 -g fess --system --no-create-home --home /var/lib/fess fess && \
    # 3. Download and verify Fess package
    curl -LfsSo /tmp/fess-${FESS_VERSION}.deb \
      https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.deb && \
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
    CMD curl -f http://localhost:8080/api/v1/health || exit 1

# The entrypoint script `run.sh` performs setup tasks that require root.
# Therefore, the container must be started as root.
# The script itself is responsible for starting the Fess process.
USER root
ENTRYPOINT ["/usr/share/fess/run.sh"]
