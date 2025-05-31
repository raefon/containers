FROM public.ecr.aws/docker/library/alpine:3.22.0 AS build
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

FROM ghcr.io/raefon/alpine:rolling@sha256:fe1d7e2256371b8e923ab3063d1491d73500cf8575928cbd00d258babfad9817
COPY --from=build /tmp /app/overseerr
COPY ./apps/overseerr/entrypoint.sh /
RUN apk add --no-cache yarn
USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/sct/overseerr"
