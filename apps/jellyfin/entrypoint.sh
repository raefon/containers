#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

#shellcheck disable=SC2155
export HOME="/config" \
    JELLYFIN_DATA_DIR="/config/jellyfin/data" \
    JELLYFIN_CONFIG_DIR="/config/jellyfin" \
    JELLYFIN_LOG_DIR="/config/jellyfin/log" \
    JELLYFIN_CACHE_DIR="/config/jellyfin/cache" \
    JELLYFIN_WEB_DIR="/usr/share/jellyfin/web"

if [[ -z "${FFMPEG_PATH}" ]] || [[ ! -f "${FFMPEG_PATH}" ]]; then
    FFMPEG_PATH=/usr/lib/jellyfin-ffmpeg/ffmpeg
fi

#shellcheck disable=SC2086
exec \
    /usr/bin/jellyfin \
        --ffmpeg="${FFMPEG_PATH}" \
        "$@"
