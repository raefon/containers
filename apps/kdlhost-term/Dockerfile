FROM ghcr.io/raefon/alpine:rolling@sha256:1017ee8da45a7a13344f210eb4ec3cff73fd40522080fc757b0cacdb9f610d9c
ARG TARGETARCH
ARG VERSION

COPY ./apps/kdlhost-term/scripts/* /usr/local/bin/
#COPY ./scripts/* /usr/local/bin/
COPY ./apps/kdlhost-term/app/* /app/kdlhost-term/
#COPY ./app/* /app/kdlhost-term/
RUN apk add --no-cache shadow bash fish curl openssl ca-certificates py3-pip pipx py3-virtualenv nano tmux ruby ruby-dev build-base musl-dev python3-dev linux-headers git \
	&& pipx ensurepath \
	&& gem install tmuxinator

# add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd

# add supercronic
ADD --chmod=755 https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-amd64 /usr/local/bin/supercronic

# add kubectl
ADD --chmod=755 https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl /usr/local/bin/kubectl

# add Recyclarr
RUN wget "https://github.com/recyclarr/recyclarr/releases/latest/download/recyclarr-linux-x64.tar.xz" -O - | sudo tar xJ --overwrite -C /usr/local/bin

# add PlexTraktSync
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin PIPX_MAN_DIR=/usr/local/share/man pipx install PlexTraktSync

# add Kometa(PlexMetaManager)
RUN git clone https://github.com/Kometa-Team/Kometa /app/kometa \
	&& pip install -r /app/kometa/requirements.txt --break-system-packages --ignore-installed

# restrict user with rbash
RUN ln -s /bin/bash /bin/rbash \
	&& chsh -s /bin/rbash kah

# cleanup
RUN apk del ruby-dev build-base musl-dev python3-dev linux-headers \
	&& rm -rf /var/cache/apk/*

EXPOSE 3001

RUN chmod +x /usr/local/bin/*.sh
USER kah
CMD ["/usr/local/bin/kdlhost-term.sh"]