#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

# Ensure data dir exists and permissions are sane (MinIO expects non-root, but template uses user 'kah')
mkdir -p /data
chown -R kah:kah /data || true

exec \
    /app/minio \
        ${MINIO_OPTS:-server /data} \
        "$@"
