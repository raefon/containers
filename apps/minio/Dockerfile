FROM public.ecr.aws/docker/library/alpine:3.23.0 AS build

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

WORKDIR /tmp/minio

# Install build dependencies
RUN apk add --no-cache \
        ca-certificates \
        git \
        bash \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        go \
        musl-dev \
        gcc

# Clone MinIO and checkout specific VERSION
RUN git clone --quiet https://github.com/minio/minio.git . \
    &&  git checkout "${VERSION}"

# Build MinIO binary
RUN export GOPATH="/go" \
    && CGO_ENABLED=0 go build \
        -trimpath \
        -ldflags="-s -w -X github.com/minio/minio/cmd.Version=${VERSION}"

FROM ghcr.io/raefon/alpine:rolling@sha256:1017ee8da45a7a13344f210eb4ec3cff73fd40522080fc757b0cacdb9f610d9c

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

COPY --from=build /tmp/minio/minio /app/minio
COPY ./apps/minio/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /app/minio

USER kah
CMD ["/entrypoint.sh"]
