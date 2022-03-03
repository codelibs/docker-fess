FROM centos:7
MAINTAINER N2SM <support@n2sm.net>

ENV FESS_VERSION=10.2.3
ENV FESS_FILENAME=fess-${FESS_VERSION}.zip
ENV FESS_REMOTE_URI=https://github.com/codelibs/fess/releases/download/fess-${FESS_VERSION}/${FESS_FILENAME}

WORKDIR /tmp

# java
RUN yum -y update && yum -y install \
  java-1.8.0-openjdk \
  unzip \
  && yum clean all

# fess
RUN curl -OL ${FESS_REMOTE_URI}
RUN unzip /tmp/${FESS_FILENAME} -d /opt
RUN rm /tmp/${FESS_FILENAME}
RUN ln -s /opt/fess-${FESS_VERSION} /opt/fess

WORKDIR /opt/fess

RUN useradd fess \
  && gpasswd -a fess fess \
  && chown -R fess:fess ./
USER fess

ENTRYPOINT [ "/opt/fess/bin/fess" ]
CMD [ "/opt/fess/bin/fess" ]

EXPOSE 8080 9201 9301
