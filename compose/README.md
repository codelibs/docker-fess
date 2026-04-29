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
| `compose-gemini.yaml` | Google Gemini LLM (cloud API) for AI/RAG Chat |
| `compose-openai.yaml` | OpenAI LLM (cloud API) for AI/RAG Chat |

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
docker exec -it ollama01 ollama pull gemma4:e4b
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

### Fess with OpenSearch and Google Gemini (AI/RAG Chat)

```bash
export GEMINI_API_KEY="AIzaSy..."  # Get one at https://aistudio.google.com/apikey
docker compose -f compose.yaml -f compose-opensearch3.yaml -f compose-gemini.yaml up -d
```

The Gemini overlay installs the `fess-llm-gemini` plugin via `FESS_PLUGINS`,
sets `rag.chat.enabled=true` and `rag.llm.name=gemini`, and forwards the API key.
Override the model with `GEMINI_MODEL` (default: `gemini-2.5-flash`).

### Fess with OpenSearch and OpenAI (AI/RAG Chat)

```bash
export OPENAI_API_KEY="sk-..."  # Get one at https://platform.openai.com/api-keys
docker compose -f compose.yaml -f compose-opensearch3.yaml -f compose-openai.yaml up -d
```

The OpenAI overlay installs the `fess-llm-openai` plugin via `FESS_PLUGINS`,
sets `rag.chat.enabled=true` and `rag.llm.name=openai`, and forwards the API key.
Override the model with `OPENAI_MODEL` (default: `gpt-5-mini`).

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
| Google Gemini | https://generativelanguage.googleapis.com | Cloud LLM API (when `compose-gemini.yaml` is used) |
| OpenAI | https://api.openai.com | Cloud LLM API (when `compose-openai.yaml` is used) |

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

### Behind an HTTP Proxy (Cloud LLMs)

When the Fess container reaches the Internet through a corporate proxy
(typical for `compose-gemini.yaml` / `compose-openai.yaml`), append the
proxy options to `FESS_JAVA_OPTS` in your overlay file:

```yaml
services:
  fess01:
    environment:
      - "FESS_JAVA_OPTS=-Dfess.config.rag.chat.enabled=true -Dfess.config.rag.llm.gemini.api.key=${GEMINI_API_KEY} -Dfess.system.rag.llm.name=gemini -Dhttps.proxyHost=proxy.example.com -Dhttps.proxyPort=8080"
```

### Why `FESS_JAVA_OPTS` Instead of Bare Environment Variables?

Fess does not auto-map shell-style environment variables such as
`RAG_CHAT_ENABLED` or `RAG_LLM_GEMINI_API_KEY` to internal properties.
All RAG / LLM settings must be passed as JVM options:

| Setting kind | Prefix | Example |
|---|---|---|
| `fess_config.properties` keys (`rag.chat.enabled`, `rag.llm.gemini.api.key`, ...) | `-Dfess.config.` | `-Dfess.config.rag.chat.enabled=true` |
| `system.properties` keys (`rag.llm.name`) | `-Dfess.system.` | `-Dfess.system.rag.llm.name=gemini` |

`rag.llm.name` is also editable from the admin UI ("System > General"),
which persists the value in OpenSearch. The `-Dfess.system.*` form only
acts as the initial default before that value is written.
