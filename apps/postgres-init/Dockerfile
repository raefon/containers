FROM ghcr.io/raefon/alpine:rolling@sha256:bbcf9df060c1f939d6867a0f45e6cc4098bbb9c758eb1477cd396a2b71a3aae6

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

#hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates postgresql15-client~"${VERSION}"

USER kah

COPY ./apps/postgres-init/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/postgres/postgres"
