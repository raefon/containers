FROM docker.io/library/alpine:3.23 AS build

ARG TARGETOS=linux
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOPATH=/go

ENV PATH="${GOPATH}/bin:${PATH}"

WORKDIR /src/rehydrator

# hadolint ignore=DL3018
RUN apk add --no-cache \
      go \
      curl \
      tar \
      gzip

RUN curl -fsSL "https://github.com/raefon/rehydrator/archive/v${VERSION}.tar.gz" \
      | tar xzf - -C /src/rehydrator --strip-components 1

RUN go mod download

RUN set -eux; \
    GOARM_VALUE=""; \
    if [ "${TARGETARCH}" = "arm" ]; then \
      GOARM_VALUE="$(echo "${TARGETVARIANT}" | sed 's/^v//')"; \
    fi; \
    GOOS="${TARGETOS}" \
    GOARCH="${TARGETARCH}" \
    GOARM="${GOARM_VALUE}" \
    go build \
      -trimpath \
      -ldflags="-s -w" \
      -o /tmp/rehydrator \
      ./cmd/rehydrator

FROM ghcr.io/raefon/alpine:rolling@sha256:f0a6485d2c1b259aef8714f4f0d53641cc906b391220ed73e9ebdb940d39bbad

COPY --from=build /tmp/rehydrator /usr/local/bin/rehydrator
COPY ./apps/rehydrator/entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/rehydrator /entrypoint.sh

USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/raefon/rehydrator"