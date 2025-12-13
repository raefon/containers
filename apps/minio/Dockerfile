FROM public.ecr.aws/docker/library/alpine:3.23.0 AS build

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

WORKDIR /tmp/minio

# hadolint ignore=DL3018,DL3013
RUN apk add --no-cache \
        ca-certificates \
        git \
        bash \
    && \
    apk add --no-cache --virtual=.build-deps \
        build-base \
        go \
        musl-dev \
        gcc \
    && \
    git clone https://github.com/minio/minio.git . \
    && if [ -n "${VERSION}" ]; then \
        NUMBER_COMMITS_TO_REVERT=$(( $(git rev-list --count --first-parent HEAD) - $(echo "${VERSION}" | cut -d "." -f3) )); \
        git checkout "master~${NUMBER_COMMITS_TO_REVERT}"; \
    fi \
    && export GOPATH="/go" \
    && mkdir -p /tmp/out \
    && CGO_ENABLED=0 go build \
        -trimpath \
        -o /tmp/out/minio \
        -ldflags="-s -w -X github.com/minio/minio/cmd.Version=${VERSION:-dev}" \
        ./cmd/minio

FROM ghcr.io/raefon/alpine:rolling@sha256:1017ee8da45a7a13344f210eb4ec3cff73fd40522080fc757b0cacdb9f610d9c

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

COPY --from=build /tmp/out/minio /app/minio
RUN chmod 755 /app/minio

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1

ENV MINIO_ROOT_USER="minioadmin" \
    MINIO_ROOT_PASSWORD="minioadmin" \
    MINIO_OPTS="server /data" \
    JBOPS__SCRIPT_PATH="bin/minio" \
    APPNAME="minio"

USER kah
COPY ./apps/minio/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/minio/minio"
