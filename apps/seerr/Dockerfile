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
    pnpm cache clean

FROM ghcr.io/raefon/alpine:rolling@sha256:c7120c0a2314b54dd0b82f781348d7add10835e7188b5187cfb44bcb46a5a7b0
COPY --from=build /tmp /app/seerr
COPY ./apps/seerr/entrypoint.sh /
RUN apk add --no-cache pnpm
USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/seerr-team/seerr"