# The Java runtime is the Temurin JRE from the Adoptium release, downloaded and verified in the
# "jre" stage and copied onto a bare Ubuntu, so curl and the locales package stay out of the final
# image. To move to a newer runtime, change TEMURIN_VERSION below; the Ubuntu release is
# UBUNTU_RELEASE. classes_nocoops.jsa is left out: it is the class data sharing archive the JVM
# maps only when the heap is above 32 GB and compressed oops are off, and such a heap starts
# without class data sharing and without a warning. classes.jsa, which every smaller heap maps,
# stays.
ARG UBUNTU_RELEASE=noble

FROM ubuntu:${UBUNTU_RELEASE} AS jre

# Temurin release as <version>+<build>, from https://github.com/adoptium/temurin21-binaries/releases
# (the repository name carries the feature release, which is read from this value).
ARG TEMURIN_VERSION=21.0.13+9

# locales builds the compiled en_US.UTF-8 locale, whose archive is copied to the final image;
# without a UTF-8 locale Java falls back to ASCII for file names.
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl locales; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8; \
    case "$(dpkg --print-architecture)" in \
      amd64) arch=x64 ;; \
      arm64) arch=aarch64 ;; \
      *) echo "Unsupported architecture: $(dpkg --print-architecture)"; exit 1 ;; \
    esac; \
    major="${TEMURIN_VERSION%%.*}"; \
    file="OpenJDK${major}U-jre_${arch}_linux_hotspot_$(echo "${TEMURIN_VERSION}" | tr + _).tar.gz"; \
    url="https://github.com/adoptium/temurin${major}-binaries/releases/download/jdk-$(echo "${TEMURIN_VERSION}" | sed 's/+/%2B/')/${file}"; \
    cd /tmp; \
    curl -fsSL --retry 3 -O "${url}"; \
    # The checksum is the one published beside the archive, in `sha256sum` format.
    curl -fsSL --retry 3 "${url}.sha256.txt" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    tar -xzf "${file}" -C /opt/java/openjdk --strip-components=1 --no-same-owner; \
    rm -f "${file}" /opt/java/openjdk/lib/server/classes_nocoops.jsa; \
    /opt/java/openjdk/bin/java --version

FROM ubuntu:${UBUNTU_RELEASE}

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

# The Java and locale environment. en_US.UTF-8 needs its compiled locale, so the 3 MB locale
# archive generated in the jre stage is copied along with the runtime instead of installing the
# locales package.
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
ARG FESS_VERSION=15.10.0-SNAPSHOT

# This ARG is used to bust the cache when needed
ARG CACHEBUST=1

# Combine RUN instructions to reduce image layers and size
RUN set -x && \
    # 1. Update package list and install dependencies without recommended packages. The deb
    #    package depends on adduser, which the bare image does not have; ca-certificates is for
    #    curl, zip is for the zstd-jni step, which removes it again, and fontconfig and tzdata are
    #    what Java needs for font handling and zone data.
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
