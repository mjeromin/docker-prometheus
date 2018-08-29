# docker-prometheus
Docker image for [Prometheus](https://prometheus.io) built from source. It is based on the official [prometheus/prometheus](https://github.com/prometheus/prometheus) Dockerfile.

- `mjeromin/prometheus`: [![](https://images.microbadger.com/badges/version/mjeromin/prometheus:v2.3.2-alpine3.8.svg)](https://microbadger.com/images/mjeromin/prometheus:v2.3.2-alpine3.8 "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/mjeromin/prometheus:v2.3.2-alpine3.8.svg)](https://microbadger.com/images/mjeromin/prometheus:v2.3.2-alpine3.8 "Get your own image badge on microbadger.com")

## Usage
You can build a docker image with
```
docker image build -f Dockerfile -t mjeromin/prometheus .
```

This will pull the prometheus source code from github and `make build` inside an Alpine/Go environment. The final artifacts are copied into an Alpine base image.

The docker build accepts a some optional build arguments, including
* `GIT_REPO`: the prometheus source code git repository (default: [github.com/prometheus/prometheus.git](https://github.com/prometheus/prometheus.git))
* `GIT_TAG`: the git tag (default: v2.3.2)

## Running the docker image
You can launch a Prometheus container with
```
$ docker container run --name prometheus -d -p 127.0.0.1:9090:9090 mjeromin/prometheus
```

Prometheus will now be reachable at http://localhost:9090/.

You can override the example configuration with your own via volume mapping. For example:
```
$ docker container run --name prometheus -d -p 127.0.0.1:9090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml:ro mjeromin/prometheus
```

This is assuming /tmp/prometheus.yml is where you are storing your local configuration. Alternatively, you can avoid volume mapping and bake the configuration into downstream images
```
FROM mjeromin/prometheus

COPY /tmp/prometheus.yml /etc/prometheus/prometheus.yml
```
