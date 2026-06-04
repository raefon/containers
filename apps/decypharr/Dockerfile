# Stage 1: Download decypharr binary
FROM alpine:latest AS decypharr-builder

ARG VERSION

RUN apk add --no-cache curl tar && \
    case "$(apk --print-arch)" in \
        x86_64) ARCH=linux-64 ;; \
        aarch64) ARCH=linux-arm-64 ;; \
        *) echo "Unsupported architecture" && exit 1 ;; \
    esac && \
    curl -L "https://github.com/sirrobot01/decypharr/releases/download/v${VERSION}/decypharr-${VERSION}-${ARCH}.tar.gz" \
    -o /tmp/decypharr.tar.gz && \
    tar -xzf /tmp/decypharr.tar.gz -C /tmp && \
    mv /tmp/decypharr /decypharr && \
    chmod +x /decypharr && \
    rm /tmp/decypharr.tar.gz

# Stage 2: Download ffprobe
FROM alpine:latest AS ffprobe-builder

RUN apk add --no-cache curl unzip && \
    case "$(apk --print-arch)" in \
        x86_64) ARCH=linux-64 ;; \
        aarch64) ARCH=linux-arm-64 ;; \
        *) echo "Unsupported architecture" && exit 1 ;; \
    esac && \
    curl -L "https://github.com/ffbinaries/ffbinaries-prebuilt/releases/download/v6.1/ffprobe-6.1-${ARCH}.zip" \
    -o /tmp/ffprobe.zip && \
    unzip /tmp/ffprobe.zip -d /tmp && \
    mv /tmp/ffprobe /ffprobe && \
    chmod +x /ffprobe

# Stage 3: Download rclone
FROM alpine:latest AS rclone-builder

RUN apk add --no-cache curl unzip && \
    case "$(apk --print-arch)" in \
        x86_64) ARCH=amd64 ;; \
        aarch64) ARCH=arm64 ;; \
        armv7l|armv7) ARCH=arm ;; \
        *) echo "Unsupported architecture" && exit 1 ;; \
    esac && \
    curl -L "https://downloads.rclone.org/rclone-current-linux-${ARCH}.zip" -o /tmp/rclone.zip && \
    unzip /tmp/rclone.zip -d /tmp && \
    cp /tmp/rclone-*/rclone /rclone && \
    chmod +x /rclone

# Final stage
FROM ghcr.io/raefon/ubuntu:rolling@sha256:dc6d82871992bda7c93f6c0a51eeca0388a9c95898e703d666a3b7db4a3e6837

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    fuse3 \
    ca-certificates \
    curl \
    unzip \
    tzdata && \
    rm -rf /var/lib/apt/lists/* && \
    echo "user_allow_other" >> /etc/fuse.conf

# Copy binaries from build stages
COPY --from=decypharr-builder /decypharr /usr/local/bin/decypharr
COPY --from=ffprobe-builder /ffprobe /usr/local/bin/ffprobe
COPY --from=rclone-builder /rclone /usr/local/bin/rclone

# # Create app directory
# RUN mkdir -p /app && \
#     chown -R root:root /app && \
#     chmod -R 755 /app

# Copy entrypoint script
COPY ./apps/decypharr/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER kah
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/sirrobot01/decypharr"
LABEL version="${VERSION}-${CHANNEL}"
LABEL org.opencontainers.image.title="decypharr"