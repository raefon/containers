ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/raefon/alpine:rolling@sha256:00e5d3fac8180f2418c3fc243afecf5afb5dd2784e101c8af5de8795dd2766e1

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