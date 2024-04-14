FROM eclipse-temurin:17-jre-focal

ENV FESS_APP_TYPE docker

RUN apt-get update && \
    apt-get install -y imagemagick unoconv poppler-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG FESS_VERSION=14.13.0

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
ENTRYPOINT /usr/share/fess/run.sh
