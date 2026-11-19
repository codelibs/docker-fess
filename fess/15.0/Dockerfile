# The Java runtime is the Temurin JRE from the Adoptium release, downloaded and verified in the
# "jre" stage and copied onto a bare Ubuntu, so the runtime moves to a new Temurin release by
# changing TEMURIN_VERSION, without waiting for the eclipse-temurin image to be rebuilt. The
# packages the eclipse-temurin image used to install are installed explicitly below, so the image
# keeps the tools and the Java environment of the earlier releases of this line.
ARG UBUNTU_RELEASE=jammy

# Temurin release as <version>+<build>, from https://github.com/adoptium/temurin21-binaries/releases
# (the repository name carries the feature release, which is read from this value).
ARG TEMURIN_VERSION=21.0.13.1+2

FROM ubuntu:${UBUNTU_RELEASE} AS jre
ARG TEMURIN_VERSION

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl; \
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
    rm -f "${file}"; \
    /opt/java/openjdk/bin/java --version

FROM ubuntu:${UBUNTU_RELEASE}
ARG TEMURIN_VERSION

# The Java and locale environment the Temurin image sets
ENV JAVA_HOME=/opt/java/openjdk \
    JAVA_VERSION=jdk-${TEMURIN_VERSION} \
    PATH="/opt/java/openjdk/bin:${PATH}" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY --from=jre /opt/java/openjdk /opt/java/openjdk

ENV FESS_APP_TYPE=docker

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates fontconfig locales p11-kit tzdata wget imagemagick unoconv poppler-utils && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG FESS_VERSION=15.0.0

RUN groupadd -g 1001 fess && \
    useradd -u 1001 -g fess --system --no-create-home --home /var/lib/fess fess

ARG CACHEBUST=1
RUN set -x && \
    curl -LfsSo /tmp/fess-${FESS_VERSION}.deb \
      https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.deb && \
    dpkg -i /tmp/fess-${FESS_VERSION}.deb && \
    rm -rf /tmp/fess-${FESS_VERSION}.deb && \
    for f in $(find /usr/share/fess/app/WEB-INF/ -type f | grep log4j2.xml) ; do sed -i 's/[^\t]*<!-- //' $f; sed -i 's/\/> -->/\/>/' $f; done  && \
    mkdir /opt/fess && \
    chown -R fess.fess /opt/fess && \
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess && \
    echo "export FESS_APP_TYPE=$FESS_APP_TYPE" >>  /usr/share/fess/bin/fess.in.sh && \
    echo "export FESS_OVERRIDE_CONF_PATH=/opt/fess" >>  /usr/share/fess/bin/fess.in.sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/share/fess
EXPOSE 8080

USER root
COPY run.sh /usr/share/fess/run.sh
ENTRYPOINT ["/usr/share/fess/run.sh"]
