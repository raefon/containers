FROM public.ecr.aws/docker/library/alpine:3.20.3 as build
ARG TARGETARCH
ARG VERSION
WORKDIR /tmp
ENV LDFLAGS="-static"
RUN \
    apk add --no-cache \
    	git \
    	curl \
    	tar \
    	gzip \
    	coreutils \
    	file \
    	autoconf \
    	automake \
    	libtool \
    	gettext \
    	gettext-dev \
    	make \
    	g++ \
    	texinfo \
    	py3-pip \
	&& git clone https://github.com/emcrisostomo/fswatch.git \
	&& cd fswatch \
	&& git checkout ${VERSION} \
    && ./autogen.sh --force \
    && ./configure \
    && make -j \
    && make install

FROM public.ecr.aws/docker/library/alpine:3.20.3
COPY --from=build /usr/local/bin/fswatch /usr/local/bin/fswatch

COPY ./apps/app-watcher/app-watcher.sh /usr/local/bin/app-watcher.sh
RUN apk add --no-cache bash libgcc libstdc++ curl openssl ca-certificates
RUN chmod +x /usr/local/bin/app-watcher.sh
RUN mkdir -p /app-watcher
CMD ["/usr/local/bin/app-watcher.sh"]