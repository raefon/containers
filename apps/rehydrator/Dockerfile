FROM docker.io/library/alpine:3.23 AS build
ARG TARGETARCH
ARG VERSION
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    GOARM=${TARGETVARIANT} \
    GOPATH=/go
ENV PATH $GOPATH/bin:$PATH
#hadolint ignore=DL3018
WORKDIR /tmp
RUN \
    apk add --no-cache \
        go \
        curl \
        tar \
        gzip \
    && \
    curl -fsSL "https://github.com/raefon/rehydrator/archive/v${VERSION}.tar.gz" \
        | tar xzf - -C /tmp --strip-components 1 \
    && \
	go mod download \
	&& \
	go build -o /tmp/rehydrator

FROM ghcr.io/raefon/alpine:rolling@sha256:f0a6485d2c1b259aef8714f4f0d53641cc906b391220ed73e9ebdb940d39bbad
COPY --from=build /tmp/rehydrator /usr/local/bin/rehydrator
COPY ./apps/rehydrator/entrypoint.sh /

USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/raefon/rehydrator"