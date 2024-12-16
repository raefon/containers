#!/usr/bin/env bash
set -ex

test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

if [[ ! -f "/config/kdlhost-term" ]]; then
    printf "Copying over default configuration ...\n"
    mkdir -p /config/kdlhost-term
    cp /app/kdlhost-term/crontab /config/kdlhost-term/crontab
fi
# Start lshell in the background
# readonly PATH=$HOME/programs

export HOME=/config/kdlhost-term
export PATH=$PATH:$HOME/.local/bin/

# Install PlexTraktSync
pipx install PlexTraktSync

# Launch kdlhost-ttyd.sh
/usr/local/bin/kdlhost-ttyd.sh