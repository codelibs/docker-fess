#!/bin/bash

temp_dir=/tmp
plugin_dir=/usr/share/fess/app/WEB-INF/plugin

print_log() {
  log_level=$1
  message=$2
  echo '{"@timestamp":"'$(date -u "+%Y-%m-%dT%H:%M:%S.%3NZ")'","log.level": "'${log_level}'","message":"'"${message}"'", "ecs.version": "1.2.0","service.name":"fess","event.dataset":"app","process.thread.name":"bootstrap","log.logger":"run.sh"}'
}

if [[ "x${FESS_DICTIONARY_PATH}" != "x" ]] ; then
  sed -i -e "s|^FESS_DICTIONARY_PATH=.*|FESS_DICTIONARY_PATH=${FESS_DICTIONARY_PATH}|" /etc/sysconfig/fess
fi

if [[ "x${SEARCH_ENGINE_HTTP_URL}" != "x" ]] ; then
  sed -i -e "s|^SEARCH_ENGINE_HTTP_URL=.*|SEARCH_ENGINE_HTTP_URL=${SEARCH_ENGINE_HTTP_URL}|" /etc/sysconfig/fess
elif [[ "x${ES_HTTP_URL}" != "x" ]] ; then
  print_log WARN "ES_HTTP_URL is deprecated."
  sed -i -e "s|^SEARCH_ENGINE_HTTP_URL=.*|SEARCH_ENGINE_HTTP_URL=${ES_HTTP_URL}|" /etc/sysconfig/fess
else
  SEARCH_ENGINE_HTTP_URL=http://localhost:9200
fi

if [[ "x${SEARCH_ENGINE_TYPE}" != "x" ]] ; then
  FESS_JAVA_OPTS="${FESS_JAVA_OPTS} -Dfess.config.search_engine.type=${SEARCH_ENGINE_TYPE}"
elif [[ "x${ES_TYPE}" != "x" ]] ; then
  print_log WARN "ES_TYPE is deprecated."
  FESS_JAVA_OPTS="${FESS_JAVA_OPTS} -Dfess.config.search_engine.type=${ES_TYPE}"
fi

if [[ "x${SEARCH_ENGINE_USERNAME}" != "x" ]] ; then
  FESS_JAVA_OPTS="${FESS_JAVA_OPTS} -Dfess.config.search_engine.username=${SEARCH_ENGINE_USERNAME}"
elif [[ "x${ES_USERNAME}" != "x" ]] ; then
  print_log WARN "ES_USERNAME is deprecated."
  FESS_JAVA_OPTS="${FESS_JAVA_OPTS} -Dfess.config.search_engine.username=${ES_USERNAME}"
fi

if [[ "x${SEARCH_ENGINE_PASSWORD}" != "x" ]] ; then
  FESS_JAVA_OPTS="${FESS_JAVA_OPTS} -Dfess.config.search_engine.password=${SEARCH_ENGINE_PASSWORD}"
elif [[ "x${ES_PASSWORD}" != "x" ]] ; then
  print_log WARN "ES_PASSWORD is deprecated."
  FESS_JAVA_OPTS="${FESS_JAVA_OPTS} -Dfess.config.search_engine.password=${ES_PASSWORD}"
fi

if [[ "x${FESS_JAVA_OPTS}" != "x" ]] ; then
  echo "FESS_JAVA_OPTS=\"${FESS_JAVA_OPTS}\"" >> /etc/sysconfig/fess
fi

if [[ "x${PING_RETRIES}" = "x" ]] ; then
  PING_RETRIES=3
fi

if [[ "x${PING_INTERVAL}" = "x" ]] ; then
  PING_INTERVAL=60
fi

download_plugin() {
  plugin_id=$1
  plugin_name=$(echo ${plugin_id} | sed -e "s/:.*//")
  plugin_version=$(echo ${plugin_id} | sed -e "s/.*://")
  if [[ ${plugin_name} == fess-ds-* ]] \
    || [[ ${plugin_name} == fess-ingest-* ]] \
    || [[ ${plugin_name} == fess-script-* ]] \
    || [[ ${plugin_name} == fess-theme-* ]] \
    || [[ ${plugin_name} == fess-webapp-* ]] \
    ; then
    plugin_file="${plugin_name}-${plugin_version}.jar"
    if [[ ${plugin_version} == *-SNAPSHOT ]] ; then
      metadata_file="${temp_dir}/maven-metadata.$$"
      metadata_url="https://oss.sonatype.org/content/repositories/snapshots/org/codelibs/fess/${plugin_name}/${plugin_version}/maven-metadata.xml"
      if ! curl -fs -o "${metadata_file}" "${metadata_url}" ; then
        print_log ERROR "Failed to download from ${metadata_url}."
        return
      fi
      version_timestamp=$(cat ${metadata_file} | grep "<timestamp>" | head -n1 | sed -e "s,.*timestamp>\(.*\)</timestamp.*,\1,")
      version_buildnum=$(cat ${metadata_file} | grep "<buildNumber>" | head -n1 | sed -e "s,.*buildNumber>\(.*\)</buildNumber.*,\1,")
      rm -f ${metadata_file}
      plugin_file=$(echo ${plugin_file} | sed -e "s/SNAPSHOT/${version_timestamp}-${version_buildnum}/")
      plugin_url="https://oss.sonatype.org/content/repositories/snapshots/org/codelibs/fess/${plugin_name}/${plugin_version}/${plugin_file}"
    else
      plugin_url="https://repo.maven.apache.org/maven2/org/codelibs/fess/${plugin_name}/${plugin_version}/${plugin_file}"
    fi
    print_log INFO "Downloading from ${plugin_url}"
    if ! curl -fs -o "${temp_dir}/${plugin_file}" "${plugin_url}" > /dev/null; then
      print_log ERROR "Failed to download ${plugin_file}."
      return
    fi
    if ! curl -fs -o "${temp_dir}/${plugin_file}.sha1" "${plugin_url}.sha1" > /dev/null; then
      print_log ERROR "Failed to download ${plugin_file}.sha1."
      return
    fi
    if ! echo "$(cat "${temp_dir}/${plugin_file}.sha1") "${temp_dir}/${plugin_file}|sha1sum -c > /dev/null ; then
      print_log ERROR "Invalid checksum for ${plugin_file}."
      return
    fi
    print_log INFO "Installing ${plugin_file}"
    rm -f "${temp_dir}/${plugin_file}.sha1"
    mv "${temp_dir}/${plugin_file}" "${plugin_dir}"
    chown fess:fess "${plugin_dir}/${plugin_file}"
  fi
}

start_fess() {
  . /etc/init.d/functions
  rm -f /usr/bin/java
  ln -s /opt/java/openjdk/bin/java /usr/bin/java
  touch /var/log/fess/fess-crawler.log \
        /var/log/fess/fess-suggest.log \
        /var/log/fess/fess-thumbnail.log \
        /var/log/fess/fess-urls.log \
        /var/log/fess/audit.log \
        /var/log/fess/fess.log
  chown fess:fess /var/log/fess/fess-crawler.log \
                  /var/log/fess/fess-suggest.log \
                  /var/log/fess/fess-thumbnail.log \
                  /var/log/fess/fess-urls.log \
                  /var/log/fess/audit.log \
                  /var/log/fess/fess.log
  tail -qF /var/log/fess/fess-crawler.log /var/log/fess/fess-suggest.log /var/log/fess/fess-thumbnail.log /var/log/fess/fess.log &
  print_log INFO "Starting Fess service."
  /etc/init.d/fess start > /dev/null 2>&1
}

wait_app() {
  if [[ "x${FESS_CONTEXT_PATH}" = "x" ]] ; then
    ping_path=/api/v1/health
  else
    ping_path=${FESS_CONTEXT_PATH}/api/v1/health
  fi
  while true ; do
    status=$(curl -w '%{http_code}\n' -s -o /dev/null "http://localhost:8080${ping_path}")
    if [[ x"${status}" = x200 ]] ; then
      error_count=0
    else
      error_count=$((error_count + 1))
    fi
    if [[ ${error_count} -ge ${PING_RETRIES} ]] ; then
      print_log ERROR "Fess is not available."
      exit 1
    fi
    sleep ${PING_INTERVAL}
  done
}

for plugin_id in $FESS_PLUGINS ; do
  download_plugin $(echo ${plugin_id} | sed -e "s,/,,g")
done

start_fess

if [[ "x${RUN_SHELL}" = "xtrue" ]] ; then
  /bin/bash
else
  wait_app
fi
