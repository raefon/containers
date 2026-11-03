#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

APP_DIR="/app/filebrowser"
CONFIG_DIR="/config/filebrowser"
CONFIG_FILE="${CONFIG_DIR}/config.yaml"
DEFAULT_CONFIG="${APP_DIR}/config.yaml"
FILEBROWSER="${APP_DIR}/filebrowser"

mkdir -p "${CONFIG_DIR}/data/tmp" /storage

if [[ ! -f "${CONFIG_FILE}" ]]; then
    printf "Copying over default configuration ...\n"
    cp "${DEFAULT_CONFIG}" "${CONFIG_FILE}"
fi

python3 "${APP_DIR}/migrate_config.py" "${CONFIG_FILE}"

# Only unlink the two legacy aliases; never remove target directories or custom links.
if [[ -L /srv/data && "$(readlink /srv/data)" == /data ]]; then
    unlink /srv/data
fi
if [[ -L /srv/config && "$(readlink /srv/config)" == /config ]]; then
    unlink /srv/config
fi

cd "${APP_DIR}"

exec \
    "${FILEBROWSER}" \
    -c "${CONFIG_FILE}" \
    "$@"