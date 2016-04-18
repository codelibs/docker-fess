docker-fess
=====

Usage
-----

* build image from Dockerfile

```
$ docker build --rm -t fess-img .
```

* create container from image

```
$ docker create -p 8080:8080 --name fess fess-img
```

* start fess container

```
$ docker start fess
```

You can access http://127.0.0.1:8080 from the host os!

* execute bash in running container

```
$ docker exec -it fess /bin/bash
```

* show container IP address

```
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' fess
```

* stop container

```
$ docker stop fess
```

