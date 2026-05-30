FROM node:22-alpine AS build
ARG TARGETARCH
ARG VERSION
WORKDIR /tmp
RUN \
    apk add --no-cache \
        build-base \
        curl \
        pnpm \
        python3 \
    && \
    curl -fsSL "https://github.com/seerr-team/seerr/archive/v${VERSION}.tar.gz" \
        | tar xzf - -C /tmp --strip-components 1 \
    && \
    export NODE_OPTIONS=--max_old_space_size=2048 \
    && \
    CYPRESS_INSTALL_BINARY=0 pnpm install \
    && \
    pnpm build \
    && \
    pnpm cache delete

FROM ghcr.io/raefon/alpine:rolling@sha256:f0a6485d2c1b259aef8714f4f0d53641cc906b391220ed73e9ebdb940d39bbad
COPY --from=build /tmp /app/seerr
COPY ./apps/seerr/entrypoint.sh /

RUN curl -fsSL https://raw.githubusercontent.com/mklement0/n-install/stable/bin/n-install | N_PREFIX=/usr/local bash -s 22 \
    && corepack enable pnpm

USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/seerr-team/seerr"