FROM adoptopenjdk:11-jre-hotspot-bionic

ENV FESS_APP_TYPE docker

RUN apt-get update && \
    apt-get install -y imagemagick procps unoconv ant xpdf && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG FESS_VERSION=13.12.2

RUN groupadd -g 1001 fess && \
    useradd -u 1001 fess -g fess

ARG CACHEBUST=1
RUN set -x && \
    curl -LfsSo /tmp/fess-${FESS_VERSION}.deb \
      https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.deb && \
    dpkg -i /tmp/fess-${FESS_VERSION}.deb && \
    rm -rf /tmp/fess-${FESS_VERSION}.deb && \
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
