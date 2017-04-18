FROM centos:7
MAINTAINER N2SM <support@n2sm.net>

ENV FESS_VERSION=10.3.5
ENV FESS_FILENAME=fess-${FESS_VERSION}.zip
ENV FESS_REMOTE_URI=https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/${FESS_FILENAME}

WORKDIR /tmp

# java
RUN yum -y update && yum -y install \
  java-1.8.0-openjdk \
  unzip \
  && yum clean all

# fess
RUN curl -OL ${FESS_REMOTE_URI} \
    && unzip /tmp/${FESS_FILENAME} -d /opt \
    && rm /tmp/${FESS_FILENAME} \
    && ln -s /opt/fess-${FESS_VERSION} /opt/fess

# thumbnail
RUN yum -y update \
    && yum -y install bzip2 fontconfig freetype freetype-devel fontconfig-devel libstdc++ unoconv libreoffice-headless vlgothic-fonts ImageMagick \
    && yum clean all

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

