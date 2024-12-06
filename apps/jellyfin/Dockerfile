FROM ghcr.io/raefon/ubuntu:jammy-20240911.1@sha256:dc4223b98c447a43344aebfdada1c38b066ea0196cfb76e99a132a4f48cec39c

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# hadolint ignore=DL3008,DL3015,SC2039,SC2086
RUN \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') \
            export ARCH='amd64'; \
        ;; \
        'linux/arm64') \
            export ARCH='arm64'; \
        ;; \
    esac \
    && \
    apt-get -qq update \
    && \
    apt-get -qq install -y \
        ca-certificates \
        libusb-dev \
        uuid-runtime \
        xmlstarlet \
        libfontconfig1 \
        libbluray2 \
        libelf1t64 \
        libgmp10 \
        libgnutls30t64 \
        libllvm17t64 \
        libmp3lame0 \
        libopenmpt0t64 \
        libopus0 \
        libpciaccess0 \
        libstdc++6 \
        libtheora0 \
        libvorbis0a \
        libvorbisenc2 \
        libvpx9 \
        libwebp7 \
        libwebpmux3 \
        libx11-xcb1 \
        libx264-164 \
        libx265-199 \
        libxcb-dri2-0 \
        libxcb-dri3-0 \
        libxcb-present0 \
        libxcb-randr0 \
        libxcb-shm0 \
        libxcb-sync1 \
        libxcb-xfixes0 \
        libxcb1 \
        libxshmfence1 \
        libzstd1 \
        libzvbi0t64 \
        ocl-icd-libopencl1 \
        libopencl1 \
        ocl-icd-libopencl1 \
        libopencl-1.2-1 \
    && \
    curl -fsSL -o /tmp/jellyfin.deb \
        "https://repo.jellyfin.org/files/server/ubuntu/latest-stable/amd64/jellyfin-server_10.10.3+ubu2404_amd64.deb" \
    && \
    curl -fsSL -o /tmp/jellyfin-web.deb \
        "https://repo.jellyfin.org/files/server/ubuntu/latest-stable/amd64/jellyfin-web_10.10.3+ubu2404_all.deb" \
    && \
    curl -fsSL -o /tmp/jellyfin-ffmpeg.deb \
        "https://repo.jellyfin.org/files/ffmpeg/ubuntu/latest-7.x/amd64/jellyfin-ffmpeg7_7.0.2-7-noble_amd64.deb" \
    && \
    dpkg -i --force-confold /tmp/jellyfin.deb /tmp/jellyfin-web.deb /tmp/jellyfin-ffmpeg.deb \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/ \
    && chown -R root:root /app \
    && printf "umask %d\n" "${UMASK}" >> /etc/bash.bashrc

USER kah
COPY ./apps/jellyfin/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
