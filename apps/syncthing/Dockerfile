ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/raefon/alpine:rolling@sha256:fe1d7e2256371b8e923ab3063d1491d73500cf8575928cbd00d258babfad9817

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