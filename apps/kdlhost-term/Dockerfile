FROM ghcr.io/raefon/alpine:rolling@sha256:34fc6966b3f623df9b3f8a8755bd63ddee41c4ac42b68971e790550b2974245c
ARG TARGETARCH
ARG VERSION

COPY ./apps/kdlhost-term/scripts/* /usr/local/bin/
COPY ./apps/kdlhost-term/restricted.tmux.conf ./apps/kdlhost-term/crontab /app/kdlhost-term/
RUN apk add --no-cache shadow bash fish curl openssl ca-certificates pipx py3-virtualenv nano tmux \
	&& pipx ensurepath

# add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd

# add superconic
ADD --chmod=755 https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-amd64 /usr/local/bin/supercronic

# restrict user with rbash
RUN chsh -s /bin/rbash kah

# add PlexTraktSync
RUN pipx install PlexTraktSync

EXPOSE 3001

RUN chmod +x /usr/local/bin/*.sh
USER kah
CMD ["/usr/local/bin/kdlhost-term.sh"]