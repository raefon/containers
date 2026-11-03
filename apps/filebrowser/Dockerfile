ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

FROM gtstef/filebrowser:${VERSION} AS upstream
FROM gtstef/ffmpeg:8.1.1-decode AS ffmpeg

FROM ghcr.io/raefon/alpine:rolling@sha256:c7120c0a2314b54dd0b82f781348d7add10835e7188b5187cfb44bcb46a5a7b0

EXPOSE 80

COPY --from=upstream /home/filebrowser/ /app/filebrowser/
COPY --from=ffmpeg [ "/ffmpeg", "/ffprobe", "/usr/local/bin/" ]

COPY ./apps/filebrowser/branding /branding/
COPY ./apps/filebrowser/scripts/* /usr/local/bin/
COPY ./apps/filebrowser/config.yaml /app/filebrowser/config.yaml
COPY ./apps/filebrowser/entrypoint.sh /entrypoint.sh
COPY ./apps/filebrowser/migrate_config.py /app/filebrowser/migrate_config.py
COPY ./apps/filebrowser/bootstrap_sidebar.py /app/filebrowser/bootstrap_sidebar.py

RUN apk add --no-cache mlocate ncdu tree curl python3 py3-yaml && \
    mkdir -p /config/filebrowser/data/tmp /srv /data /storage && \
    chmod 777 /srv && \
    chown -R kah:kah /app/filebrowser /config /srv /data /storage /branding && \
    chmod +x /entrypoint.sh \
        /app/filebrowser/filebrowser \
        /usr/local/bin/claim-plex-server.sh \
        /usr/local/bin/tenet

WORKDIR /app/filebrowser

USER kah

CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/gtsteffaniak/filebrowser"