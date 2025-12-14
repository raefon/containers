FROM public.ecr.aws/docker/library/alpine:3.23.0 AS build

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

WORKDIR /tmp/minio

# Install build tools and dependencies
RUN apk add --no-cache \
        ca-certificates \
        git \
        bash \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        go \
        musl-dev \
        gcc \
    && rm -rf /var/cache/apk/*

# Determine version if not set
RUN if [ -z "${VERSION:-}" ]; then \
        VERSION=$(git ls-remote --tags https://github.com/minio/minio.git | \
            awk '{print $2}' | \
            grep -E 'refs/tags/RELEASE\.[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-[0-9]{2}Z$' | \
            sed 's|refs/tags/||' | \
            sort -r | \
            head -n1) && \
        echo "Building latest MinIO release: ${VERSION}"; \
    fi

# Clone MinIO repo and checkout requested version
RUN git clone --quiet https://github.com/minio/minio.git . \
    && git fetch --tags --quiet \
    && if [ -n "${VERSION}" ]; then \
        git checkout "${VERSION}"; \
    fi

# Build MinIO binary
RUN export GOPATH="/go" \
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

# Copy MinIO binary
COPY --from=build /tmp/out/minio /app/minio
RUN chmod 755 /app/minio

# Set environment variables
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
