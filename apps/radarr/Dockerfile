FROM ghcr.io/raefon/alpine:rolling@sha256:671c05af9ead52f63b42139fa13f400e8f22d7fb581bb7577ab0a0ee51a0a960

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    RADARR__INSTANCE_NAME="Radarr" \
    RADARR__BRANCH="${CHANNEL}" \
    RADARR__PORT="7878" \
    RADARR__ANALYTICS_ENABLED="False"

#hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates icu-libs libintl sqlite-libs xmlstarlet
#hadolint ignore=DL3059
RUN \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') export ARCH='x64' ;; \
        'linux/arm64') export ARCH='arm64' ;; \
    esac \
    && \
    mkdir -p /app/bin \
    && \
    curl -fsSL "https://radarr.servarr.com/v1/update/${RADARR__BRANCH}/updatefile?version=${VERSION}&os=linuxmusl&runtime=netcore&arch=${ARCH}" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && \
    rm -rf \
        /app/bin/Radarr.Update \
    && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[raefon](https://github.com/raefon)\n" "${RADARR__BRANCH}" "${VERSION}" > /app/package_info \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

USER kah

COPY ./apps/radarr/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/radarr/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Radarr/Radarr"
