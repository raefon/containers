FROM ghcr.io/raefon/ubuntu:jammy-20250619@sha256:c0920da5d01b64a38440d72babae54cf9f6861ba15bad04d529ba8aead19cf23

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
        software-properties-common \
    && \
    add-apt-repository universe \
    && \
    curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | gpg --dearmor | tee /usr/share/keyrings/jellyfin.gpg >/dev/null \
    && \
    echo deb [arch=${ARCH} signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu jammy main > /etc/apt/sources.list.d/jellyfin.list \
    && \
    apt-get -qq update \
    && \
    apt-get install -y --no-install-recommends \
        jellyfin=${VERSION}+ubu2204 mesa-va-drivers \
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