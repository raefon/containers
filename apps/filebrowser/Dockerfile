ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

FROM filebrowser/filebrowser:${VERSION} as upstream

FROM ghcr.io/raefon/alpine:rolling@sha256:9f414960d5cee8f2b9c17f8e510aa88c8d95345365d1dbf4af670b7079dbe20d

EXPOSE 80

# Use this so that dgoss works
ENV FB_DATABASE=/tmp/filebrowser.db

COPY --from=upstream /filebrowser /filebrowser
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