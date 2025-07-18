FROM ghcr.io/raefon/ubuntu:jammy-20250619@sha256:c0920da5d01b64a38440d72babae54cf9f6861ba15bad04d529ba8aead19cf23

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    SONARR__INSTANCE_NAME="Sonarr" \
    SONARR__BRANCH="${CHANNEL}" \
    SONARR__PORT="8989" \
    SONARR__ANALYTICS_ENABLED="False"

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
    apt-get -qq update \
    && apt-get -qq install -y gnupg \
    && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official.list \
    && apt-get -qq update \
    && \
    apt-get -qq install -y \
        ca-certificates \
        mono-complete \
        ca-certificates-mono \
        libmediainfo0v5 \
        xmlstarlet \
    && \
    mkdir -p /app/bin \
    && \
    curl -fsSL "https://download.sonarr.tv/v3/${SONARR__BRANCH}/${VERSION}/Sonarr.${SONARR__BRANCH}.${VERSION}.linux.tar.gz" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[raefon](https://github.com/raefon)\n" "${SONARR__BRANCH}" "${VERSION}" > /app/package_info \
    && \
    gpgconf --kill all \
    && apt-get remove -y gnupg \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && \
    rm -rf \
        /app/bin/Sonarr.Update \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/ \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && printf "umask %d\n" "${UMASK}" >> /etc/bash.bashrc

USER kah

COPY ./apps/sonarr/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/sonarr/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Sonarr/Sonarr"
