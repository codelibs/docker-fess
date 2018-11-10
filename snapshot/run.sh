#!/bin/bash

ES_LOGFILE=/var/log/elasticsearch/elasticsearch.log

if [ x"$ES_HTTP_URL" = "x" ] ; then
  ES_HTTP_URL=http://localhost:9200
else
  sed -i -e "s/^ES_HTTP_URL=.*/ES_HTTP_URL=$ES_HTTP_URL/" /etc/default/fess
fi

if [ x"$ES_TRANSPORT_URL" = "x" ] ; then
  ES_TRANSPORT_URL=localhost:9300
else
  sed -i -e "s/^ES_TRANSPORT_URL=.*/ES_TRANSPORT_URL=$ES_TRANSPORT_URL/" /etc/default/fess
fi

start_elasticsearch() {
  touch $ES_LOGFILE
  chown elasticsearch:elasticsearch $ES_LOGFILE
  tail -f ${ES_LOGFILE} &

  if [ x"$ES_JAVA_OPTS" != "x" ] ; then
    echo "ES_JAVA_OPTS=$ES_JAVA_OPTS" >> /etc/default/elasticsearch
  fi
  service elasticsearch start

  counter=1
  ret=1
  while [ $ret != 0 -a $counter -le 60 ] ; do
    echo "Checking Elasticsearch status #$counter"
    grep "started" $ES_LOGFILE > /dev/null 2>&1
    ret=$?
    counter=`expr $counter + 1`
    sleep 1
  done

  curl -XGET "$ES_HTTP_URL/_cluster/health?wait_for_status=yellow&timeout=3m"
}

if [ x"$USE_EXTERNAL_ELASTICSEARCH" != "xtrue" ] ; then
  start_elasticsearch
fi

touch /var/log/fess/fess-crawler.log /var/log/fess/fess-suggest.log \
      /var/log/fess/fess-thumbnail.log \
      /var/log/fess/audit.log  /var/log/fess/fess.log
chown fess:fess /var/log/fess/fess-crawler.log /var/log/fess/fess-suggest.log \
      /var/log/fess/fess-thumbnail.log \
      /var/log/fess/audit.log  /var/log/fess/fess.log
service fess start

if [ x"$RUN_SHELL" = "xtrue" ] ; then
  /bin/bash
else
  tail -fq /var/log/fess/*.log
fi
