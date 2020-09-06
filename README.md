Docker for Fess
=====

See [https://hub.docker.com/r/codelibs/fess/](https://hub.docker.com/r/codelibs/fess/).

## Docker Images

-   [`latest`, `13`, `13.9`, `13.9.x` (*13.9/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.9/Dockerfile)
-   [`13.8`, `13.8.x` (*13.8/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.8/Dockerfile)
-   [`13.7`, `13.7.x` (*13.7/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.7/Dockerfile)
-   [`13.6`, `13.6.x` (*13.6/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.6/Dockerfile)
-   [`13.5`, `13.5.x` (*13.5/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.5/Dockerfile)
-   [`13.4`, `13.4.x` (*13.4/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.4/Dockerfile)
-   [`13.3`, `13.3.x` (*13.3/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.3/Dockerfile)
-   [`13.2`, `13.2.x` (*13.2/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.2/Dockerfile)
-   [`13.1`, `13.1.x` (*13.1/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.1/Dockerfile)
-   [`13.0`, `13.0.x` (*13.0/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/13.0/Dockerfile)
-   [`12.7`, `12.7.x` (*12.7/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/12.7/Dockerfile)
-   [`12.6`, `12.6.x` (*12.6/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/12.6/Dockerfile)
-   [`12.5`, `12.5.x` (*12.5/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/12.5/Dockerfile)
-   [`12.4`, `12.4.x` (*12.4/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/12.4/Dockerfile)
-   [`12.3`, `12.3.x` (*12.3/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/12.3/Dockerfile)
-   [`12.2`, `12.2.x` (*12.2/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/12.2/Dockerfile)
-   [`12.1`, `12.1.x` (*12.1/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/12.1/Dockerfile)
-   [`12.0`, `12.0.x` (*12.1/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/12.0/Dockerfile)
-   [`11`, `11.4`, `11.4.x` (*11.4/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/11.4/Dockerfile)
-   [`11.3`, `11.3.x` (*11.3/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/11.3/Dockerfile)
-   [`11.2`, `11.2.x` (*11.2/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/11.2/Dockerfile)
-   [`11.1`, `11.1.x` (*11.1/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/11.1/Dockerfile)
-   [`11.0`, `11.0.x` (*11.0/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/11.0/Dockerfile)
-   [`10`, `10.3`, `10.3.x` (*10.3/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/10.3/Dockerfile)
-   [`10.2`, `10.2.x` (*10.2/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/10.2/Dockerfile)
-   [`10.1`, `10.1.x` (*10.1/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/10.1/Dockerfile)
-   [`10.0`, `10.0.x` (*10.0/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/10.0/Dockerfile)
-   [`snapshot` (*snapshot/Dockerfile*)](https://github.com/codelibs/docker-fess/blob/master/snapshot/Dockerfile)

## What is Fess?

Fess is very powerful and easily deployable Enterprise Search Server. You can install and run Fess quickly on any platforms, which have Java runtime environment. Fess is provided under Apache license.

Fess is Elasticsearch-based search server, but knowledge/experience about Elasticsearch is NOT needed because of All-in-One Enterprise Search Server. Fess provides Administration GUI to configure the system on your browser. Fess also contains a crawler, which can crawl documents on Web/File System/DB and support many file formats, such as MS Office, pdf and zip.

For more info, access [Fess official documentation](http://fess.codelibs.org/).

## Getting Started

### Run Fess

You can access http://localhost:8080 from the host OS with:

```console
$ docker run -d -p 8080:8080 --name fess ghcr.io/codelibs/fess:latest
```

### Run Fess with Elasticsearch Cluster and Kibana

See [docker-compose.yml](https://github.com/codelibs/docker-fess/blob/master/compose/docker-compose.yml).

### Run Fess with Your Data/Config

To save data and config for Fess/Elasticsearch, use -v option for mount host directory:

```console
$ mkdir -p ./data/fess/config data/es/data
$ sudo chown -R 1001:1001 ./data/fess
$ sudo chown -R 1000:1000 ./data/es
$ docker run -d -p 8080:8080 --name fess \
    -v $PWD/data/fess/config:/opt/fess \
    -v $PWD/data/es/data:/var/lib/elasticsearch ghcr.io/codelibs/fess:latest
```

You can put fess\_config.properties to fess/config directory.

### Set ES\_JAVA\_OPTS

To set ES\_JAVA\_OPTS, use -e option:

```console
$ docker run -e 'ES_JAVA_OPTS="-Xms2g -Xmx2g"' -d -p 8080:8080 ghcr.io/codelibs/fess:latest
```

## Kernel settings

Elasticsearch needs to set vm.max\_map\_count to  at least 262144. See [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-prod-prerequisites).

## Build

### Fess

To build docker images, run as below:

```console
$ docker build --rm -t codelibs/fess:<tag name> ./<version_dir>/
```

### Elasticsearch

```console
$ docker build --rm --build-arg ES_TYPE=elasticsearch -t codelibs/fess-elasticsearch:<tag name> ./elasticsearch/<version_dir>/
$ docker build --rm --build-arg ES_TYPE=elasticsearch-oss -t codelibs/fess-elasticsearch-oss:<tag name> ./elasticsearch/<version_dir>/
```

## License

[Apache License 2.0](LICENSE)
