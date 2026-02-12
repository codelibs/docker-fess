Docker Compose for Fess
=======================

## Description

This repository provides compose files for running Fess and OpenSearch with Docker Compose.

Compose command is available on Docker Desktop.
Therefore, Windows and Mac users do not need to install it.
For Linux users, please see [Installing Compose V2](https://docs.docker.com/compose/cli-command/#installing-compose-v2).

## Compose Files

| File | Description |
|------|-------------|
| `compose.yaml` | Base configuration for Fess (required) |
| `compose-opensearch3.yaml` | OpenSearch 3.x backend |
| `compose-dashboards3.yaml` | OpenSearch Dashboards for visualization |
| `compose-minio.yaml` | MinIO object storage integration |
| `compose-ollama.yaml` | Ollama LLM service for AI/RAG Chat |
| `compose-ollama-gpu.yaml` | Ollama LLM service with NVIDIA GPU support |

## Usage

### Fess with OpenSearch

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

### Fess with OpenSearch and Ollama (AI/RAG Chat)

```bash
docker compose -f compose.yaml -f compose-opensearch3.yaml -f compose-ollama.yaml up -d
```

After starting, pull an LLM model:

```bash
docker exec -it ollama01 ollama pull gemma3:4b
```

### Fess with OpenSearch and Ollama with GPU (AI/RAG Chat)

GPU support requires [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html).

```bash
docker compose -f compose.yaml -f compose-opensearch3.yaml -f compose-ollama-gpu.yaml up -d
```

After starting, pull a model optimized for GPU:

```bash
# For 16GB VRAM (e.g., RTX 5060 Ti)
docker exec -it ollama01 ollama pull gpt-oss:20b
```

### Tips: Using a Local Directory for Ollama Model Data

By default, Ollama model data is stored in a Docker volume. If you prefer to use a local directory (e.g., for sharing models across environments or easier backups), see the comments in `compose-ollama.yaml` or `compose-ollama-gpu.yaml` for instructions on switching the volume configuration.

### Stop Fess

```bash
docker compose -f compose.yaml -f compose-opensearch3.yaml down
```

### Remove Local Volumes

```bash
docker volume rm compose_search01_data compose_search01_dictionary
```

## Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| Fess | http://localhost:8080 | Enterprise search web UI |
| OpenSearch | http://localhost:9200 | Search engine API |
| OpenSearch Dashboards | http://localhost:5601 | Data visualization (when enabled) |
| MinIO Console | http://localhost:9000 | Object storage (when enabled) |
| Ollama API | http://localhost:11434 | LLM API (when enabled) |

## Environment Variables

### Fess (compose.yaml)

| Variable | Default | Description |
|----------|---------|-------------|
| `SEARCH_ENGINE_HTTP_URL` | `http://search01:9200` | Backend search engine URL |
| `FESS_DICTIONARY_PATH` | `/usr/share/opensearch/config/dictionary/` | Path to dictionary files |
| `FESS_PLUGINS` | (none) | Space-separated list of plugins (format: `plugin-name:version`) |

### OpenSearch (compose-opensearch3.yaml)

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENSEARCH_JAVA_OPTS` | `-Xms1g -Xmx1g` | JVM heap size settings |

## Prerequisites

### System Requirements

- Docker and Docker Compose installed
- For OpenSearch: `vm.max_map_count` must be at least 262144

### Setting vm.max_map_count

```bash
# Linux (temporary)
sudo sysctl -w vm.max_map_count=262144

# Linux (permanent)
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
```

## Notes

### Combining Multiple Services

When using multiple overlay files that set `FESS_JAVA_OPTS`, the last file's value takes precedence. If you need to combine options from multiple services (e.g., MinIO + Ollama), create a custom compose file with merged `FESS_JAVA_OPTS`.

Example for MinIO + Ollama:

```yaml
services:
  fess01:
    environment:
      - "FESS_JAVA_OPTS=-Dfess.system.storage.accesskey=... -Dfess.system.storage.secretkey=... -Dfess.system.storage.endpoint=http://minio01:9000 -Dfess.system.storage.bucket=fess -Drag.llm.ollama.api.url=http://ollama01:11434"
```
