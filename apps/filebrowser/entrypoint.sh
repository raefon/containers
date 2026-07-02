#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

APP_DIR="/app/filebrowser"
WEB_DIR="${APP_DIR}/http/dist"
CONFIG_DIR="/config/filebrowser"
CONFIG_FILE="${CONFIG_DIR}/config.yaml"
DEFAULT_CONFIG="${APP_DIR}/config.yaml"
FILEBROWSER="${APP_DIR}/filebrowser"

mkdir -p "${CONFIG_DIR}/data/tmp" /srv

if [[ ! -f "${CONFIG_FILE}" ]]; then
    printf "Copying over default configuration ...\n"
    cp "${DEFAULT_CONFIG}" "${CONFIG_FILE}"

    cd "${WEB_DIR}"
    "${FILEBROWSER}" set -u bogus,bogus -a -c "${CONFIG_FILE}"
fi

data="/srv/data"
if [[ ! -e "${data}" ]]; then
    printf "Creating data symlink ...\n"
    ln -s /data "${data}"
fi

config="/srv/config"
if [[ ! -e "${config}" ]]; then
    printf "Creating config symlink ...\n"
    ln -s /config "${config}"
fi

cd "${WEB_DIR}"

# shellcheck disable=SC2086
exec \
    "${FILEBROWSER}" \
    -c "${CONFIG_FILE}" \
    "$@"