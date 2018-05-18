FROM centos:7
LABEL maintainer "Rubberbird Tech"

ENV FESS_VERSION 12.1.2
ENV ELASTIC_VERSION 6.2.4
ENV ES_DOWNLOAD_URL https://artifacts.elastic.co/downloads/elasticsearch
ENV FESS_APP_TYPE docker

RUN yum install -y java-1.8.0-openjdk-devel imagemagick procps unoconv wget sed initscripts

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk

RUN groupadd -g 1000 elasticsearch && \
    groupadd -g 1001 fess && \
    useradd -u 1000 elasticsearch -g elasticsearch && \
    useradd -u 1001 fess -g fess

RUN set -x && \
    echo $JAVA_HOME && \
    wget --progress=dot:mega ${ES_DOWNLOAD_URL}/elasticsearch-${ELASTIC_VERSION}.rpm -O /tmp/elasticsearch-${ELASTIC_VERSION}.rpm && \
    rpm -i /tmp/elasticsearch-${ELASTIC_VERSION}.rpm && \
    rm -rf /tmp/elasticsearch-${ELASTIC_VERSION}.rpm && \
    chkconfig --add elasticsearch
    
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-fess:6.2.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-ja:6.2.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-analysis-synonym:6.2.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-configsync:6.2.2 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-dataformat:6.2.3 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-langfield:6.2.1 && \
    /usr/share/elasticsearch/bin/elasticsearch-plugin install org.codelibs:elasticsearch-minhash:6.2.1

RUN set -x && \
    wget --progress=dot:mega https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.rpm -O /tmp/fess-${FESS_VERSION}.rpm && \
    rpm -i /tmp/fess-${FESS_VERSION}.rpm && \
    rm -rf /tmp/fess-${FESS_VERSION}.rpm
RUN mkdir /opt/fess && \
    chown -R fess.fess /opt/fess && \
    sed -i -e 's#FESS_CLASSPATH="$FESS_CONF_PATH:$FESS_CLASSPATH"#FESS_CLASSPATH="/opt/fess:$FESS_CONF_PATH:$FESS_CLASSPATH"#g' /usr/share/fess/bin/fess
RUN echo "export FESS_APP_TYPE=$FESS_APP_TYPE" >>  /usr/share/fess/bin/fess.in.sh

COPY elasticsearch/config /etc/elasticsearch
COPY fess/config /etc/fess

WORKDIR /usr/share/fess
EXPOSE 9200 9300 8080

USER root
COPY run.sh /etc/run.sh
ENTRYPOINT /etc/run.sh
