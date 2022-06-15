Docker Compose for Fess
=======================

## Description


This repository provides compose files for running Fess and Elasticsearch or OpenSearch with Docker Compose.

Compose command is available on Docker Desktop.
Therefore, Windows and Mac users do not need to install it.
For Linux users, please see [Installing Compose V2](https://docs.docker.com/compose/cli-command/#installing-compose-v2).


## Usage

### Fess with Elasticsearch

Fess with Elasticsearch 8:

```
$ docker compose -f compose.yaml -f compose-elasticsearch8.yaml up -d
```

Fess with Elasticsearch 7:

```
$ docker compose -f compose.yaml -f compose-elasticsearch7.yaml up -d
```

### Fess with Elasticsearch and Kibana:

```
$ docker compose -f compose.yaml -f compose-elasticsearch8.yaml -f compose-kibana8.yaml up -d
```

### Fess with Elasticsearch cluster and MinIO

```
$ docker compose -f compose.yaml -f compose-elasticsearch8.yaml -f compose-minio.yaml up -d
```

### Fess with OpenSearch

Fess with OpenSearch:

```
$ docker compose --env-file .env.opensearch -f compose.yaml -f compose-opensearch2.yaml up -d
```

### Stop Fess

```
$ docker compose -f compose.yaml -f ...(snip)... down

```

### Remove Local Volumes

```
$ docker volume rm compose_esdata01 compose_esdictionary01 compose_esdata02 compose_esdictionary02

```
