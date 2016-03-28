FROM centos:7
MAINTAINER codelibs <oss@n2sm.net>
ENV container docker

ENV ES_VERSION=2.1.2
ENV ES_FILENAME=elasticsearch-${ES_VERSION}.rpm
ENV ES_REMOTE_URI=https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/${ES_VERSION}/${ES_FILENAME}

ENV FESS_VERSION=10.0.3
ENV FESS_FILENAME=fess-${FESS_VERSION}.rpm
ENV FESS_REMOTE_URI=https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/${FESS_FILENAME}

WORKDIR /tmp

# java install
RUN yum -y update && yum -y install \
  java-1.8.0-openjdk && yum clean all

# elasticsearch install
RUN curl -O ${ES_REMOTE_URI}
RUN rpm -ivh /tmp/${ES_FILENAME}

RUN cat /etc/elasticsearch/elasticsearch.yml > /tmp/elasticsearch.yml.tmp
RUN echo "cluster.name: elasticsearch" >> /tmp/elasticsearch.yml.tmp
RUN echo "node.name: \"ES Node 1\"" >> /tmp/elasticsearch.yml.tmp
RUN echo "index.number_of_shards: 1" >> /tmp/elasticsearch.yml.tmp
RUN echo "index.number_of_replicas: 0" >> /tmp/elasticsearch.yml.tmp
RUN echo "http.cors.enabled: true" >> /tmp/elasticsearch.yml.tmp
RUN echo 'http.cors.allow-origin: "*"' >> /tmp/elasticsearch.yml.tmp
RUN echo 'network.host: "0"' >> /tmp/elasticsearch.yml.tmp
RUN echo "configsync.config_path: /var/lib/elasticsearch/config" >> /tmp/elasticsearch.yml.tmp
RUN mv -f /tmp/elasticsearch.yml.tmp /etc/elasticsearch/elasticsearch.yml
RUN sed -e "s/es.logger.level: INFO/es.logger.level: DEBUG/" /etc/elasticsearch/logging.yml > /tmp/logging.yml.tmp
RUN mv -f /tmp/logging.yml.tmp /etc/elasticsearch/logging.yml

RUN rm /tmp/${ES_FILENAME}
RUN systemctl enable elasticsearch.service

# fess install
RUN curl -OL ${FESS_REMOTE_URI}
RUN rpm -ivh /tmp/${FESS_FILENAME}
RUN cp -r /usr/share/fess/es/plugins/* /usr/share/elasticsearch/plugins/

RUN rm /tmp/${FESS_FILENAME}
RUN systemctl enable fess.service

WORKDIR /usr/share/fess

ENTRYPOINT [ "/sbin/init" ]
