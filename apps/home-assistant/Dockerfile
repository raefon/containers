FROM ghcr.io/raefon/alpine:rolling@sha256:9f414960d5cee8f2b9c17f8e510aa88c8d95345365d1dbf4af670b7079dbe20d

# https://github.com/linuxserver/docker-homeassistant
# https://github.com/home-assistant/docker
# https://github.com/home-assistant/docker-base
# https://github.com/pypa/pip/issues/10788

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    ALPINE_WHEELS="https://wheel-index.linuxserver.io/alpine-3.18/" \
    HOMEASSISTANT_WHEELS="https://wheel-index.linuxserver.io/homeassistant-3.18/" \
    PYTHONPATH="${PYTHONPATH}:/pip-packages" \
    HOME="/config"

WORKDIR /tmp

#hadolint ignore=DL3018
RUN \
    apk add --no-cache \
        bluez \
        bluez-deprecated \
        bluez-libs \
        ca-certificates \
        cups-libs \
        eudev-libs \
        ffmpeg \
        git \
        libcap \
        libjpeg-turbo \
        libstdc++ \
        libxslt \
        mariadb-connector-c \
        mariadb-connector-c-dev \
        openssh-client \
        openssl \
        postgresql-libs \
        py3-pip \
        python3 \
        socat \
        tiff

#hadolint ignore=DL3018,DL3013,DL3059
RUN \
    apk add --no-cache --virtual=.build-deps \
        autoconf \
        build-base \
        cargo \
        cmake \
        cups-dev \
        eudev-dev \
        ffmpeg-dev \
        glib-dev \
        jpeg-dev \
        libffi-dev \
        libxml2-dev \
        libxslt-dev \
        postgresql-dev \
        python3-dev \
        unixodbc-dev

#hadolint ignore=DL3018,DL3013,DL3059
RUN \
    pip install --break-system-packages --upgrade \
        cython \
        pip \
        pyparsing \
        setuptools \
        wheel

#hadolint ignore=DL3018,DL3013,DL3059,DL4006
RUN \
    curl -fsSL "https://github.com/home-assistant/core/archive/${VERSION}.tar.gz" \
        | tar xzf - -C /tmp --strip-components=1 \
    && \
    mkdir -p /pip-packages \
    && \
    pip install \
        --break-system-packages \
        --upgrade \
        --target /pip-packages \
        distlib \
    && \
    NUMPY_VERSION=$(grep "numpy" requirements_all.txt) \
    && \
    pip install --break-system-packages --find-links "${ALPINE_WHEELS}" --find-links "${HOMEASSISTANT_WHEELS}" \
        "${NUMPY_VERSION}" \
    && \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') \
            export ARCH='amd64'; \
        ;; \
        'linux/arm64') \
            export ARCH='aarch64'; \
        ;; \
    esac \
    && \
    HOME_ASSISTANT_BASE=$(curl -fsSL "https://raw.githubusercontent.com/home-assistant/core/${VERSION}/build.yaml" | grep "${ARCH}: " | cut -d ":" -f3) \
    && \
    pip install --break-system-packages --no-index --only-binary=:all: --find-links "${ALPINE_WHEELS}" --find-links "${HOMEASSISTANT_WHEELS}" \
        --requirement "https://raw.githubusercontent.com/home-assistant/docker/${HOME_ASSISTANT_BASE}/requirements.txt" \
    && \
    pip install --break-system-packages --find-links "${ALPINE_WHEELS}" --find-links "${HOMEASSISTANT_WHEELS}" \
        --requirement requirements_all.txt \
    && \
    pip install --break-system-packages --only-binary=:all: --find-links "${ALPINE_WHEELS}" --find-links "${HOMEASSISTANT_WHEELS}" \
        homeassistant=="${VERSION}" \
    && \
    pip install --break-system-packages --find-links "${ALPINE_WHEELS}" --find-links "${HOMEASSISTANT_WHEELS}" \
        pycups PySwitchbot \
    && \
    apk del --purge .build-deps \
    && \
    rm -rf \
        /root/.cache \
        /root/.cargo \
        /tmp/*

WORKDIR /app
USER kah
COPY ./apps/home-assistant/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/home-assistant/core"
