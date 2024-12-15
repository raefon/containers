#!/usr/bin/env bash
set -ex

test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

if [[ ! -f "/config/kdlhost-term" ]]; then
    printf "Copying over default configuration ...\n"
    mkdir -p /config/kdlhost-term
    cp /app/kdlhost-term/crontab /config/kdlhost-term/crontab
fi

# Launch kdlhost-ttyd.sh
/usr/local/bin/kdlhost-ttyd.sh