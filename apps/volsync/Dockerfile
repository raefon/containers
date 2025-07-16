ARG VERSION
FROM golang:1.24-alpine as builder
ARG VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""
WORKDIR /src

# Install build dependencies
RUN apk add --no-cache git upx

# Download source code for the specified version
RUN git clone --branch ${VERSION} --depth 1 https://github.com/backube/volsync.git .

# Build the binary
RUN CGO_ENABLED=0 \
    GOOS=${TARGETOS:-linux} \
    GOARCH=${TARGETARCH:-amd64} \
    go build -ldflags "-X=main.volsyncVersion=${VERSION}" -o /go/bin/volsync ./cmd/volsync

# Optionally compress the binary
RUN upx /go/bin/volsync

FROM docker.io/rclone/rclone:1.70.2 as rclone
FROM docker.io/restic/restic:0.18.0 as restic

FROM public.ecr.aws/docker/library/alpine:3.22
ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

RUN \
    apk add --no-cache \
        acl \
        bash \
        ca-certificates \
        curl \
        tzdata \
    && \
    curl -fsSL "https://github.com/backube/volsync/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xzf - -C /tmp --strip-components=1 \
    && mkdir -p /mover-rclone \
        && cp /tmp/mover-rclone/active.sh /mover-rclone/ \
        && chmod a+rx /mover-rclone/*.sh \
    && mkdir -p /mover-restic \
        && cp /tmp/mover-restic/entry.sh /mover-restic/ \
        && chmod a+rx /mover-restic/*.sh \
    && rm -rf /tmp/*

COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone
COPY --from=restic /usr/bin/restic /usr/local/bin/restic
COPY --from=builder /go/bin/volsync /manager

ENTRYPOINT ["/bin/bash"]

LABEL org.opencontainers.image.source="https://github.com/backube/volsync"
