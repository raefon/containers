#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

#shellcheck disable=SC2086
exec \
    /bin/syncthing \
    --home /config/syncthing \
    --no-default-folder \
    "$@"