Docker Compose for Fess
=======================

## Description

This repository provides compose files for running Fess and OpenSearch with Docker Compose.

Compose command is available on Docker Desktop.
Therefore, Windows and Mac users do not need to install it.
For Linux users, please see [Installing Compose V2](https://docs.docker.com/compose/cli-command/#installing-compose-v2).

## Usage

### Fess with OpenSearch:

```bash
docker compose -f compose.yaml -f compose-opensearch3.yaml up -d
```

### Fess with OpenSearch and Dashboards

```bash
docker compose -f compose.yaml -f compose-opensearch3.yaml -f compose-dashboards3.yaml up -d
```

### Fess with OpenSearch and MinIO

```bash
docker compose -f compose.yaml -f compose-opensearch3.yaml -f compose-minio.yaml up -d
```

### Stop Fess

```bash
docker compose -f compose.yaml -f ...(snip)... down
```

### Remove Local Volumes

```bash
docker volume rm compose_search01_data compose_search01_dictionary
```

