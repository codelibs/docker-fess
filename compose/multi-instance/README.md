# Fess with OpenSearch Multi-Instance Setup using Docker Compose

This repository provides a Docker Compose configuration to run multiple instances of Fess connected to a single OpenSearch cluster.
This setup allows you to manage multiple Fess instances, each with its own indices, within a shared OpenSearch backend.

## Overview

- **OpenSearch**: A search engine and analytics suite forked from Elasticsearch.
- **Fess**: A powerful search platform based on OpenSearch/Elasticsearch.

This setup is designed to run multiple instances of Fess, each configured with its own set of indices, all sharing a single OpenSearch backend.
This is useful in scenarios where you need to segregate data or configurations across different Fess instances while utilizing a common search backend.

## Prerequisites

- Docker
- Docker Compose

Ensure Docker and Docker Compose are installed on your system before proceeding.

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/codelibs/docker-fess.git
cd docker-fess/compose/multi-instance
```

### 2. Docker Compose Configuration

This setup uses multiple Docker Compose files:

- **compose.yaml**: Defines the OpenSearch service.
- **compose-fess01.yaml**: Defines the first Fess instance.
- **compose-fess02.yaml**: Defines the second Fess instance.

You can add additional `compose-fessXX.yaml` files to create more Fess instances.

### 3. Start the Services

To start the OpenSearch and Fess services, run the following command:

```bash
docker compose -f compose.yaml -f compose-fess01.yaml -f compose-fess02.yaml up -d
```

This command will start the OpenSearch cluster and the two Fess instances (fess01 and fess02).

### 4. Access the Services

- **OpenSearch**: Available at `http://localhost:9200`
- **Fess01**: Available at `http://localhost:8080`
- **Fess02**: Available at `http://localhost:8081`

### 5. Scaling Up

To add more Fess instances, create a new `compose-fessXX.yaml` file with a unique configuration. For example, `compose-fess03.yaml`:

```yaml
services:
  fess03:
    image: ghcr.io/codelibs/fess:snapshot
    container_name: fess03
    environment:
      - "SEARCH_ENGINE_HTTP_URL=http://search01:9200"
      - "FESS_DICTIONARY_PATH=${FESS_DICTIONARY_PATH:-/usr/share/opensearch/config/dictionary/}"
      - "FESS_JAVA_OPTS=-Dfess.config.index.document.search.index=fess03.search -Dfess.config.index.document.update.index=fess03.update -Dfess.config.index.document.suggest.index=fess03 -Dfess.config.index.document.crawler.index=fess03_crawler -Dfess.config.index.config.index=fess03_config -Dfess.config.index.user.index=fess03_user -Dfess.config.index.log.index=fess03_log -Dfess.config.index.dictionary.prefix=fess03"
    ports:
      - "8082:8080"
    networks:
      - search_net
    depends_on:
      - search01
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    restart: unless-stopped
```

Then start the new instance with:

```bash
docker compose -f compose.yaml -f compose-fess01.yaml -f compose-fess02.yaml -f compose-fess03.yaml up -d
```

### 6. Stopping the Services

To stop the services, run:

```bash
docker compose -f compose.yaml -f compose-fess01.yaml -f compose-fess02.yaml ... down
```

This will stop and remove all containers defined in the Docker Compose files.

### 7. Data Persistence

The OpenSearch data and Fess dictionary files are persisted using Docker volumes:

- `searchdata01`: Persists OpenSearch data.
- `searchdict01`: Persists the Fess dictionary.

These volumes ensure that your data remains intact even if the containers are stopped or removed.

## Notes

- Ensure that each Fess instance has a unique set of index names by properly setting the `FESS_JAVA_OPTS` environment variable in each `compose-fessXX.yaml` file.
- Adjust the memory settings and other configurations as needed for your environment.

