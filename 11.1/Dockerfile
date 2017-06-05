FROM centos:7
LABEL maintainer "N2SM <support@n2sm.net>"

ENV FESS_VERSION=11.1.1

WORKDIR /tmp

RUN yum -y install \
    java-1.8.0-openjdk unzip \
# thumbnail
    bzip2 fontconfig freetype freetype-devel fontconfig-devel libstdc++ unoconv libreoffice-headless vlgothic-fonts ImageMagick \
    && yum clean all

# fess
RUN curl -OL https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/fess-${FESS_VERSION}.zip \
    && unzip /tmp/fess-${FESS_VERSION}.zip -d /opt \
    && rm /tmp/fess-${FESS_VERSION}.zip \
    && ln -s /opt/fess-${FESS_VERSION} /opt/fess

RUN curl -OL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
    && tar xvf phantomjs-2.1.1-linux-x86_64.tar.bz2 \
    && cp phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin \
    && rm -rf phantomjs-2.1.1-linux-x86_64

WORKDIR /opt/fess

RUN useradd fess \
  && gpasswd -a fess fess \
  && chown -R fess:fess ./
USER fess

ENTRYPOINT [ "/opt/fess/bin/fess" ]
CMD [ "/opt/fess/bin/fess" ]

EXPOSE 8080 9201 9301

