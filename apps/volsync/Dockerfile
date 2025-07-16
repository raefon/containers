FROM ghcr.io/backube/volsync:v0.13.0 as volsync
FROM docker.io/rclone/rclone:1.70.2 as rclone
FROM docker.io/restic/restic:0.18.0 as restic

FROM public.ecr.aws/docker/library/alpine:3.22
ARG VERSION
ARG CHANNEL

RUN apk add --no-cache \
        acl \
        bash \
        ca-certificates \
        curl \
        tzdata

# Optionally fetch scripts as before
RUN curl -fsSL "https://github.com/backube/volsync/archive/refs/tags/v${VERSION}.tar.gz" \
        | tar xzf - -C /tmp --strip-components=1 \
    && mkdir -p /mover-rclone \
    && cp /tmp/mover-rclone/active.sh /mover-rclone/ \
    && chmod a+rx /mover-rclone/*.sh \
    && mkdir -p /mover-restic \
    && cp /tmp/mover-restic/entry.sh /mover-restic/ \
    && chmod a+rx /mover-restic/*.sh \
    && rm -rf /tmp/*

COPY --from=volsync /manager /manager
COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone
COPY --from=restic /usr/bin/restic /usr/local/bin/restic

ENTRYPOINT ["/bin/bash"]

LABEL org.opencontainers.image.source="https://github.com/backube/volsync"