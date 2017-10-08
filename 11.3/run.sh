#!/bin/bash

ES_LOGFILE=/var/log/elasticsearch/elasticsearch.log

service elasticsearch start

counter=1
ret=1
while [ $ret != 0 -a $counter -le 60 ] ; do
  echo "Checking Elasticsearch status #$counter"
  grep "] started$" $ES_LOGFILE > /dev/null 2>&1
  ret=$?
  counter=`expr $counter + 1`
  sleep 1
done

service fess start

tail -f ${ES_LOGFILE} /var/log/fess/*.log
