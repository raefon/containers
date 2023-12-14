FROM ghcr.io/raefon/alpine:raefon@sha256:00e5d3fac8180f2418c3fc243afecf5afb5dd2784e101c8af5de8795dd2766e1

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    SONARR__INSTANCE_NAME="Sonarr" \
    SONARR__BRANCH="${CHANNEL}" \
    SONARR__PORT="8989" \
    SONARR__ANALYTICS_ENABLED="False"

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
    curl -fsSL "https://download.sonarr.tv/v4/${SONARR__BRANCH}/${VERSION}/Sonarr.${SONARR__BRANCH}.${VERSION}.linux-musl-${ARCH}.tar.gz" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && \
    rm -rf \
        /app/bin/Sonarr.Update \
    && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[raefon](https://github.com/raefon)\n" "${SONARR__BRANCH}" "${VERSION}" > /app/package_info \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

USER kah

COPY ./apps/sonarr/${SONARR__BRANCH}/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/sonarr/${SONARR__BRANCH}/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.title="${SONARR__INSTANCE_NAME} (${SONARR__BRANCH})"
