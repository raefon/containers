FROM public.ecr.aws/docker/library/alpine:3.21.0 AS build
ARG TARGETARCH
ARG VERSION
WORKDIR /tmp
RUN \
    apk add --no-cache \
        build-base \
        curl \
        yarn \
        python3 \
    && \
    curl -fsSL "https://github.com/sct/overseerr/archive/v${VERSION}.tar.gz" \
        | tar xzf - -C /tmp --strip-components 1 \
    && \
    export NODE_OPTIONS=--max_old_space_size=2048 \
    && \
    CYPRESS_INSTALL_BINARY=0 yarn --frozen-lockfile --network-timeout 1000000 \
    && \
    yarn build \
    && \
    yarn install --production --ignore-scripts --prefer-offline \
    && \
    yarn cache clean

FROM ghcr.io/raefon/alpine:rolling@sha256:34fc6966b3f623df9b3f8a8755bd63ddee41c4ac42b68971e790550b2974245c
COPY --from=build /tmp /app/overseerr
RUN apk add --no-cache yarn
USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/sct/overseerr"
