ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

FROM filebrowser/filebrowser:${VERSION} as upstream

FROM ghcr.io/raefon/alpine:rolling@sha256:db0977fb009059a8ad17e3592fc9fd68f9621d84f75b7dfca11691e68ba35e5c

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