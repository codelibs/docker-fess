#!/bin/bash

/sbin/service elasticsearch start
/sbin/service fess start

ES_LOGFILE=/var/log/elasticsearch/elasticsearch.log
FESS_LOGFILE=/var/log/fess/fess.log

while [ ! -f ${ES_LOGFILE} ] || [ ! -f ${FESS_LOGFILE} ]
do
  sleep 1s
done

tail -f ${ES_LOGFILE} -f ${FESS_LOGFILE}
