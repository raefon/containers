# Force using 3.10
FROM ghcr.io/raefon/alpine:rolling@sha256:671c05af9ead52f63b42139fa13f400e8f22d7fb581bb7577ab0a0ee51a0a960

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

RUN \
    curl -fsSL -o /tmp/app.zip "https://github.com/morpheus65535/bazarr/releases/download/v${VERSION}/bazarr.zip" \
    && unzip -q /tmp/app.zip -d /app \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

#hadolint ignore=DL3018,DL3013
RUN \
    apk add --no-cache ca-certificates mediainfo ffmpeg python3 py3-lxml py3-numpy py3-gevent py3-cryptography py3-setuptools py3-pillow py3-psycopg2 \
    && \
    apk add --no-cache --virtual .build-deps py3-pip python3-dev gcc musl-dev \
    && \
    pip install --upgrade pip \
    && \
    pip install --upgrade \
      "webrtcvad-wheels>=2.0.10" \
    && apk del --purge .build-deps \
    && rm -rf \
        /root/.cache \
        /root/.cargo \
        /tmp/*

USER kah
COPY ./apps/bazarr/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/morpheus65535/bazarr"
