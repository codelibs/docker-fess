Docker Compose for Fess with Vanilla OpenSearch
===============================================

## Overview

This repository provides compose files for running Fess and OpenSearch with Docker Compose.

**Note:** in this “vanilla” configuration, we do *not* install any of the OpenSearch plugins that Fess normally relies on.
As a result, Fess’s built-in dictionary management features will *not* be available under this setup.

## Usage

### Fess with OpenSearch:

```
$ docker compose -f compose.yaml -f compose-opensearch2.yaml up -d
```

### Stop Fess

```
$ docker compose -f compose.yaml -f compose-opensearch2.yaml down
```

### Remove Local Volumes

```
$ docker volume rm compose_search01_data 
```


