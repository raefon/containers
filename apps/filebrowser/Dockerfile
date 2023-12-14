ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

FROM filebrowser/filebrowser:${VERSION} as upstream

FROM ghcr.io/raefon/alpine:rolling@sha256:db7f44955327ee02177b821ab653659cc46f54d35ef4e92365678f994025c16f

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
				/usr/local/bin/claim-plex-server.sh

USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/filebrowser/filebrowser"