ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

FROM filebrowser/filebrowser:${VERSION} AS upstream

FROM ghcr.io/raefon/alpine:rolling@sha256:c7120c0a2314b54dd0b82f781348d7add10835e7188b5187cfb44bcb46a5a7b0

EXPOSE 80

# Use this so that dgoss works
ENV FB_DATABASE=/tmp/filebrowser.db

COPY --from=upstream /bin/filebrowser /filebrowser
COPY ./apps/filebrowser/branding /branding/
COPY ./apps/filebrowser/scripts/* /usr/local/bin/
COPY ./apps/filebrowser/settings.json /app/filebrowser/settings.json
COPY ./apps/filebrowser/entrypoint.sh /entrypoint.sh

RUN apk add --no-cache mlocate ncdu tree curl &&\
	chmod 777 /srv &&\
	chmod +x /entrypoint.sh \ 
				/usr/local/bin/claim-plex-server.sh \
				/usr/local/bin/tenet

USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/filebrowser/filebrowser"