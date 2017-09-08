FROM openjdk:8-jre
LABEL maintainer "N2SM <support@n2sm.net>"

ARG FESS_VERSION

RUN groupadd -g 1000 fess && \
    useradd -u 1000 fess -g fess
RUN set -x \
  && wget --progress=dot:mega https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.deb -O /fess-${FESS_VERSION}.deb \
# don't allow the package to install its sysctl file (causes the install to fail)
# Failed to write '262144' to '/proc/sys/vm/max_map_count': Read-only file system
	&& dpkg-divert --rename /usr/lib/sysctl.d/fess.conf \
	\
	&& apt-get update \
	&& dpkg -i /fess-${FESS_VERSION}.deb \
  && rm -rf /fess-${FESS_VERSION}.deb

USER fess
ENV PATH /usr/share/fess/bin:$PATH
WORKDIR /usr/share/fess

RUN set -ex && for fessdirs in logs; do \
        mkdir -p "$fessdirs"; \
        chown -R fess:fess "$fessdirs"; \
    done

COPY bin bin
COPY config /etc/fess


USER root
RUN chown -R fess:fess bin /etc/fess && \
    chmod 0750 bin/fess-docker

USER fess
RUN cp -r /etc/fess/* /usr/share/fess/app/WEB-INF/classes && \
    cp -r /etc/fess/* /usr/share/fess/lib/classes

CMD ["/bin/bash", "bin/fess-docker"]

EXPOSE 8080
