FROM ghcr.io/raefon/par2cmdline-turbo:1.3.0 as par2cmdline-turbo

FROM ghcr.io/raefon/alpine:rolling@sha256:2d470fad7bb189fd9e2744208204784aee7ab8912509afa1829aad9e13bca57c
ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1

ENV SABNZBD__PORT=8080

# Download source
RUN \
    curl -fsSL "https://github.com/sabnzbd/sabnzbd/releases/download/${VERSION}/SABnzbd-${VERSION}-src.tar.gz" \
        | tar xzf - -C /app --strip-components=1 \
    && \
    chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

# Install sabnzbd
RUN \
    # Keep py3-pip installed
    \
    apk add --no-cache \
        ca-certificates \
        python3 \
        py3-pip \
        p7zip \
    && \
    apk add --no-cache --virtual=.build-deps \
        build-base \
        libffi-dev \
        openssl-dev \
        musl-dev \
        cargo \
        python3-dev \
    && \
    pip install --break-system-packages --upgrade pip \
    && \
    pip install --break-system-packages --upgrade --requirement /app/requirements.txt \
    && apk del --purge .build-deps \
    && rm -rf \
        /root/.cache \
        /root/.cargo \
        /tmp/*

# Install par2cmdline-turbo
COPY --from=par2cmdline-turbo /usr/local/bin/par2 /usr/local/bin/par2
RUN ln -s /usr/local/bin/par2 /usr/local/bin/par2create \
    && ln -s /usr/local/bin/par2 /usr/local/bin/par2repair \
    && ln -s /usr/local/bin/par2 /usr/local/bin/par2verify

USER kah
COPY ./apps/sabnzbd/sabnzbd.ini /app/sabnzbd.ini
COPY ./apps/sabnzbd/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/sabnzbd/sabnzbd"
