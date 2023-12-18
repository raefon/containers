FROM public.ecr.aws/docker/library/alpine:3.19.0 as build
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

FROM public.ecr.aws/docker/library/alpine:3.19.0
COPY --from=build /usr/local/bin/fswatch /usr/local/bin/fswatch

COPY scripts/* /usr/local/bin
RUN chmod +x /usr/local/bin/*
CMD ["/usr/local/bin/app-watcher.sh"]