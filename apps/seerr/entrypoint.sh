#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

#shellcheck disable=SC2155
export HOME="/config/seerr" \
    CONFIG_DIRECTORY="/config/seerr" \
    NODE_ENV="production"

if [[ ! -f "/config/seerr" ]]; then
    printf "Copying over default configuration ...\n"
    mkdir -p /config/seerr
fi

# Change to the /app/seerr directory
cd /app/seerr || exit 1

#shellcheck disable=SC2086
exec /usr/local/bin/node dist/index.js