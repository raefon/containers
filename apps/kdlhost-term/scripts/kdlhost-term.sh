#!/usr/bin/env bash
set -ex

test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

if [[ ! -d "/config/kdlhost-term" ]]; then
    printf "Creating DIR: /config/kdlhost-term ...\n"
    mkdir -p /config/kdlhost-term
fi

if [[ ! -d "/config/kdlhost-term/.tmuxinator" ]]; then
    printf "Creating DIR: /config/kdlhost-term/.tmuxinator ...\n"
    mkdir -p /config/kdlhost-term/.tmuxinator
fi

if [[ ! -f "/config/kdlhost-term/crontab" ]]; then
    printf "Creating FILE: /config/kdlhost-term/crontab ...\n"
    cp -r /app/kdlhost-term/crontab /config/kdlhost-term
fi

if [[ ! -f "/config/kdlhost-term/.tmuxinator/kdlhost-terminal.yml" ]]; then
    printf "Creating FILE: /config/kdlhost-term/.tmuxinator/kdlhost-terminal.yml ...\n"
    cp -r /app/kdlhost-term/kdlhost-terminal.yml /config/kdlhost-term/.tmuxinator
fi

if [[ ! -f "/config/kdlhost-term/.tmux.conf" ]]; then
    printf "Creating FILE: /config/kdlhost-term/.tmux.conf ...\n"
    cp -r /app/kdlhost-term/tmux.conf /config/kdlhost-term/.tmux.conf
fi

if [[ ! -f "/config/kdlhost-term/.tmux.conf.local" ]]; then
    printf "Creating FILE: /config/kdlhost-term/.tmux.conf.local ...\n"
    cp -r /app/kdlhost-term/tmux.conf.local /config/kdlhost-term/.tmux.conf.local
fi
# Start lshell in the background
# readonly PATH=$HOME/programs

export HOME=/config/kdlhost-term
export PATH=$PATH:$HOME/.local/bin/

# Launch kdlhost-ttyd.sh
/usr/local/bin/kdlhost-ttyd.sh