FROM amazoncorretto:21-al2023

ENV FESS_APP_TYPE=docker

RUN dnf install -y ImageMagick poppler-utils initscripts glibc-langpack-en \
    && dnf clean all
#   unoconv

ARG FESS_VERSION=15.1.0-SNAPSHOT

RUN groupadd -g 1001 fess && \
    useradd -u 1001 -g fess --system --no-create-home --home /var/lib/fess fess

ARG CACHEBUST=1
RUN set -x && \
    curl -LfsSo /tmp/fess-${FESS_VERSION}.rpm \
      https://fess.codelibs.org/snapshot/fess-${FESS_VERSION}.rpm && \
    rpm -i /tmp/fess-${FESS_VERSION}.rpm && \
    rm -rf /tmp/fess-${FESS_VERSION}.rpm && \
    for f in $(find /usr/share/fess/app/WEB-INF/ -type f | grep log4j2.xml) ; do sed -i 's/[^\t]*<!-- //' $f; sed -i 's/\/> -->/\/>/' $f; done  && \
    mkdir /opt/fess && \
    chown -R fess.fess /opt/fess && \
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="$FESS_OVERRIDE_CONF_PATH:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess && \
    echo "export FESS_APP_TYPE=$FESS_APP_TYPE" >>  /usr/share/fess/bin/fess.in.sh && \
    echo "export FESS_OVERRIDE_CONF_PATH=/opt/fess" >>  /usr/share/fess/bin/fess.in.sh && \
    dnf clean all

WORKDIR /usr/share/fess
EXPOSE 8080

USER root
COPY run.sh /usr/share/fess/run.sh
ENTRYPOINT ["/usr/share/fess/run.sh"]
