#!/bin/bash

ES_LOGFILE=/var/log/elasticsearch/elasticsearch.log
ES_HOST=localhost:9200

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

cat ${ES_LOGFILE}
tail -f ${ES_LOGFILE} &
curl -XGET "$ES_HOST/_cluster/health?wait_for_status=yellow&timeout=3m"

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
