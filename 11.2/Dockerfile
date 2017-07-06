FROM centos:7
LABEL maintainer "N2SM <support@n2sm.net>"

ENV FESS_VERSION=11.2.1
ENV PHANTOMJS_VERSION=2.1.1

WORKDIR /tmp

RUN yum -y install \
    java-1.8.0-openjdk unzip \
# thumbnail
    bzip2 fontconfig freetype freetype-devel fontconfig-devel libstdc++ unoconv libreoffice-headless vlgothic-fonts ImageMagick \
    && yum clean all

RUN curl -OL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 \
    && tar xvf phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 \
    && cp phantomjs-${PHANTOMJS_VERSION}-linux-x86_64/bin/phantomjs /usr/local/bin \
    && rm -rf phantomjs-${PHANTOMJS_VERSION}-linux-x86_64

# fess
RUN curl -OL https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.zip \
    && unzip /tmp/fess-${FESS_VERSION}.zip -d /opt \
    && rm /tmp/fess-${FESS_VERSION}.zip \
    && ln -s /opt/fess-${FESS_VERSION} /opt/fess

WORKDIR /opt/fess
RUN useradd fess \
    && gpasswd -a fess fess \
    && mkdir -p ./es/config/node_1 \
    && echo "network.host: 0.0.0.0" > ./es/config/node_1/elasticsearch.yml \
    && chown -R fess:fess ./
USER fess

ENTRYPOINT [ "/opt/fess/bin/fess" ]
CMD [ "/opt/fess/bin/fess" ]

EXPOSE 8080 9201 9301

