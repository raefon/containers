FROM public.ecr.aws/docker/library/alpine:3.23.0 AS build

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

WORKDIR /tmp/minio

# Install build tools
RUN apk add --no-cache \
        ca-certificates \
        git \
        bash \
    && apk add --no-cache --virtual=.build-deps \
        build-base \
        go \
        musl-dev \
        gcc

# Clone MinIO and checkout the requested version
RUN git clone https://github.com/minio/minio.git . \
    && if [ -n "${VERSION}" ]; then \
        git fetch --tags; \
        git rev-parse -q --verify "refs/tags/RELEASE.${VERSION}" || (echo "Version ${VERSION} not found" && exit 1); \
        git checkout "RELEASE.${VERSION}"; \
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

# Copy the built binary
COPY --from=build /tmp/out/minio /app/minio
RUN chmod 755 /app/minio

# Environment
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    MINIO_ROOT_USER="minioadmin" \
    MINIO_ROOT_PASSWORD="minioadmin" \
    MINIO_OPTS="server /data" \
    JBOPS__SCRIPT_PATH="bin/minio" \
    APPNAME="minio"

# Use non-root user
USER kah

# Entrypoint
COPY ./apps/minio/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]

# Metadata
LABEL org.opencontainers.image.source="https://github.com/minio/minio"
