Docker for Fess
=====

See [Docker Images](https://github.com/codelibs/docker-fess/pkgs/container/fess/versions).

## What is Fess?

Fess is very powerful and easily deployable Enterprise Search Server. You can install and run Fess quickly on any platforms, which have Java runtime environment. Fess is provided under Apache license.

Fess is Elasticsearch-based search server, but knowledge/experience about Elasticsearch is NOT needed because of All-in-One Enterprise Search Server. Fess provides Administration GUI to configure the system on your browser. Fess also contains a crawler, which can crawl documents on Web/File System/DB and support many file formats, such as MS Office, pdf and zip.

For more info, access [Fess official documentation](http://fess.codelibs.org/).

## Getting Started

### Kernel settings

Elasticsearch needs to set vm.max\_map\_count to  at least 262144. See [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-prod-prerequisites).

### Run Fess

You can access http://localhost:8080 from the host OS with:

```console
$ git clone https://github.com/codelibs/docker-fess.git
$ cd docker-fess/compose
$ docker-compose -f docker-compose.yml -f docker-compose.standalone.yml up -d
```

### Run Fess with Elasticsearch Cluster and Kibana

See [docker-compose.yml](https://github.com/codelibs/docker-fess/blob/master/compose/docker-compose.yml).


## Build

### Fess

To build docker images, run as below:

```console
$ docker build --rm -t ghcr.io/codelibs/fess:<tag name> ./fess/<version_dir>/
```

### Elasticsearch

```console
$ docker build --rm -t ghcr.io/codelibs/fess-elasticsearch:<tag name> ./elasticsearch/<version_dir>/
```

### OpenSearch

```console
$ docker build --rm -t ghcr.io/codelibs/fess-opensearch:<tag name> ./opensearch/<version_dir>/
```

## License

[Apache License 2.0](LICENSE)
