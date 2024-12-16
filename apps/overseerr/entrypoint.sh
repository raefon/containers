#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

#shellcheck disable=SC2155
export HOME="/config/overseerr" \
    CONFIG_DIRECTORY="/config/overseerr"

if [[ ! -f "/config/overseerr" ]]; then
    printf "Copying over default configuration ...\n"
    mkdir -p /config/overseerr
fi

# Change to the /app/overseerr directory
cd /app/overseerr || exit 1

#shellcheck disable=SC2086
exec /usr/bin/yarn start