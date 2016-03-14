docker-fess
=====

Usage
-----

* build image from Dockerfile

```
$ docker build -t fess .
```

* run fess image

```
$ docker run -d -p 127.0.0.1:8080:8080 fess
```

* check the container id

```
$ docker ps
```

* execute bash in running container

```
$ docker exec -it CONTAINER_ID /bin/bash
```

* stop container

```
$ docker stop CONTAINER_ID
```

* open http://127.0.0.1:8080 from the host os
