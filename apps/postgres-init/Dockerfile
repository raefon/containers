FROM ghcr.io/raefon/alpine:rolling@sha256:671c05af9ead52f63b42139fa13f400e8f22d7fb581bb7577ab0a0ee51a0a960

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

#hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates postgresql15-client~"${VERSION}"

USER kah

COPY ./apps/postgres-init/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/postgres/postgres"
