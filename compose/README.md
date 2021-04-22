Docker Compose for Fess
=======================

## Description


This is example compose file for running Fess and Elasticsearch with Docker Compose.

## Usage

### Run Fess

Fess with Elasticsearch for single node:

```
$ docker-compose -f docker-compose.yml -f docker-compose.standalone.yml up -d
```

Fess with Elasticsearch cluster:

```
$ docker-compose -f docker-compose.yml -f docker-compose.cluster.yml up -d
```

Fess with Elasticsearch cluster and Kibana:

```
$ docker-compose -f docker-compose.yml -f docker-compose.cluster.yml -f docker-compose.kibana.yml up -d
```

Fess with Elasticsearch cluster and MinIO:

```
$ docker-compose -f docker-compose.yml -f docker-compose.cluster.yml -f docker-compose.minio.yml up -d
```

### Stop Fess

```
$ docker-compose -f docker-compose.yml -f ...(snip)... down

```

### Remove Local Volumes

```
$ docker volume rm compose_esdata01 compose_esdictionary01 compose_esdata02 compose_esdictionary02

```
