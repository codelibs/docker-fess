FROM openjdk:8-jre

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV FESS_VERSION 10.2.2
ENV FESS_FILENAME=fess-${FESS_VERSION}.deb
ENV FESS_REMOTE_URI=https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/${FESS_FILENAME}

RUN set -x \
  && wget ${FESS_REMOTE_URI} -O /${FESS_FILENAME} \
# don't allow the package to install its sysctl file (causes the install to fail)
# Failed to write '262144' to '/proc/sys/vm/max_map_count': Read-only file system
	&& dpkg-divert --rename /usr/lib/sysctl.d/fess.conf \
	\
	&& apt-get update \
	&& dpkg -i /${FESS_FILENAME} \
  && rm -rf /${FESS_FILENAME}

ENV PATH /usr/share/fess/bin:$PATH

WORKDIR /usr/share/fess

COPY config ./lib/classes

COPY docker-entrypoint.sh /

EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["fess"]
