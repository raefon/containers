ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/raefon/alpine:rolling@sha256:671c05af9ead52f63b42139fa13f400e8f22d7fb581bb7577ab0a0ee51a0a960

COPY --from=upstream /bin/syncthing /bin/syncthing

EXPOSE 8384 22000/tcp 22000/udp 21027/udp

ENV STGUIADDRESS=0.0.0.0:8384

#COPY ./apps/syncthing/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/syncthing/entrypoint.sh /entrypoint.sh

RUN chown -R root:root /app \
	&& chmod -R 755 /app \
	&& chmod +x /entrypoint.sh

USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/syncthing/syncthing"