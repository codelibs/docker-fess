#!/bin/bash

if [[ "x${FESS_DICTIONARY_PATH}" != "x" ]] ; then
  sed -i -e "s|^FESS_DICTIONARY_PATH=.*|FESS_DICTIONARY_PATH=${FESS_DICTIONARY_PATH}|" /etc/default/fess
fi

if [[ "x${ES_HTTP_URL}" = "x" ]] ; then
  ES_HTTP_URL=http://localhost:9200
else
  sed -i -e "s|^ES_HTTP_URL=.*|ES_HTTP_URL=${ES_HTTP_URL}|" /etc/default/fess
fi

if [[ "x${ES_TYPE}" != "x" ]] ; then
  FESS_JAVA_OPTS="${FESS_JAVA_OPTS} -Dfess.config.elasticsearch.type=${ES_TYPE}"
fi

if [[ "x${ES_USERNAME}" != "x" ]] ; then
  FESS_JAVA_OPTS="${FESS_JAVA_OPTS} -Dfess.config.elasticsearch.username=${ES_USERNAME}"
fi

if [[ "x${ES_PASSWORD}" != "x" ]] ; then
  FESS_JAVA_OPTS="${FESS_JAVA_OPTS} -Dfess.config.elasticsearch.password=${ES_PASSWORD}"
fi

if [[ "x${FESS_JAVA_OPTS}" != "x" ]] ; then
  echo "FESS_JAVA_OPTS=\"${FESS_JAVA_OPTS}\"" >> /etc/default/fess
fi

if [[ "x${PING_RETRIES}" = "x" ]] ; then
  PING_RETRIES=3
fi

if [[ "x${PING_INTERVAL}" = "x" ]] ; then
  PING_INTERVAL=60
fi

start_fess() {
  ln -s /opt/java/openjdk/bin/java /usr/bin/java
  touch /var/log/fess/fess-crawler.log \
        /var/log/fess/fess-suggest.log \
        /var/log/fess/fess-thumbnail.log \
        /var/log/fess/audit.log \
        /var/log/fess/fess.log
  chown fess:fess /var/log/fess/fess-crawler.log \
                  /var/log/fess/fess-suggest.log \
                  /var/log/fess/fess-thumbnail.log \
                  /var/log/fess/audit.log \
                  /var/log/fess/fess.log
  tail -f /var/log/fess/*.log &
  /etc/init.d/fess start
}

wait_app() {
  if [[ "x${FESS_CONTEXT_PATH}" = "x" ]] ; then
    ping_path=/json/ping
  else
    ping_path=${FESS_CONTEXT_PATH}/json/ping
  fi
  while true ; do
    status=$(curl -w '%{http_code}\n' -s -o /dev/null "http://localhost:8080${ping_path}")
    if [[ x"${status}" = x200 ]] ; then
      error_count=0
    else
      error_count=$((error_count + 1))
    fi
    if [[ ${error_count} -ge ${PING_RETRIES} ]] ; then
      echo "Fess is not available."
      exit 1
    fi
    sleep ${PING_INTERVAL}
  done
}

start_fess

if [[ "x${RUN_SHELL}" = "xtrue" ]] ; then
  /bin/bash
else
  wait_app
fi
