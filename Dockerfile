FROM golang:1.10.3-alpine3.8 as build

RUN set -x \
    && apk add --no-cache --virtual .build-deps \
        make \
        git

ARG BUILD_ROOT="/usr/local/src/prometheus"
# beware of hardcoded build paths, ie. $GOPATH/src/github.com/prometheus/prometheus
ARG HARDCODED_BUILD_ROOT="$GOPATH/src/github.com/prometheus"
ARG GIT_REPO="https://github.com/prometheus/prometheus.git"
ARG GIT_TAG="v2.3.2"

RUN set -x \
    && mkdir -p $BUILD_ROOT && mkdir -p $HARDCODED_BUILD_ROOT \
    && cd $BUILD_ROOT && git clone -b $GIT_TAG $GIT_REPO prometheus \
    && ln -s ${BUILD_ROOT}/prometheus ${HARDCODED_BUILD_ROOT}/prometheus \
    && cd prometheus && make build \
    # tiny smoke test to ensure our built binary runs
    && ./prometheus --version

FROM alpine:3.8

LABEL maintainer="Mark Jeromin <mark.jeromin@sysfrog.net>"
LABEL version="2.3.2"

ARG BUILD_ROOT="/usr/local/src/prometheus"

# to be clear, we are indeed copying from source path /usr/local/src/prometheus/prometheus/prometheus
COPY --from=build $BUILD_ROOT/prometheus/prometheus /bin/prometheus
COPY --from=build $BUILD_ROOT/prometheus/promtool /bin/promtool
COPY --from=build $BUILD_ROOT/prometheus/documentation/examples/prometheus.yml /etc/prometheus/prometheus.yml
COPY --from=build $BUILD_ROOT/prometheus/console_libraries/ /usr/share/prometheus/console_libraries/
COPY --from=build $BUILD_ROOT/prometheus/consoles/ /usr/share/prometheus/consoles/

# The instructions below this line should stay consistent with
# the official prometheus Dockerfile (https://github.com/prometheus/prometheus)
RUN ln -s /usr/share/prometheus/console_libraries/ /usr/share/prometheus/consoles/ /etc/prometheus/
RUN mkdir -p /prometheus \
    && chown -R nobody:nogroup /etc/prometheus /prometheus

USER       nobody
EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]
