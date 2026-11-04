#!/usr/bin/env bash
set -euo pipefail

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
# Migrate only the stock commented defaults; preserve explicit user overrides.
python3 - "/config/kdlhost-term/.tmux.conf.local" <<'PYTHON'
from pathlib import Path
import sys
path = Path(sys.argv[1])
original = path.read_text()
updated = original.replace("\n#set -g history-limit 10000\n", "\nset -g history-limit 20000\n")
updated = updated.replace("\n#set -g mouse on\n", "\nset -g mouse on\n")
if updated != original:
    path.write_text(updated)
PYTHON

# Start lshell in the background
# readonly PATH=$HOME/programs

export HOME=/config/kdlhost-term
export PATH=$PATH:$HOME/.local/bin/

# Preserve user jobs; add exactly one managed Recyclarr job without editing their file.
managed="$HOME/.managed-crontab"
grep -v '# managed-recyclarr' "$HOME/crontab" > "$managed" || true
if [[ "${RECYCLARR_ENABLED:-false}" == true ]]; then
    # A stable tenant identifier staggers daily work across tenants.
    minute=$(printf '%s' "${RECYCLARR_INSTANCE:-tenant}" | cksum | awk '{print $1 % 60}')
    schedule="${RECYCLARR_CRON:-$minute 5 * * *}"
    if [[ "$schedule" == *$'\n'* ]]; then echo "Invalid Recyclarr schedule" >&2; exit 1; fi
    # Existing explicit user jobs take precedence, avoiding duplicate scheduled syncs.
    if ! grep -Ev '^\s*(#|$)' "$managed" | grep -q 'recyclarr'; then
        printf '%s /usr/local/bin/recyclarr-sync.sh # managed-recyclarr\n' "$schedule" >> "$managed"
    fi
fi
cron_pid=""
if grep -Ev '^[[:space:]]*(#|$)' "$managed" | grep -q .; then
    supercronic -test "$managed"
    supercronic "$managed" &
    cron_pid=$!
fi
/usr/local/bin/kdlhost-ttyd.sh &
terminal_pid=$!
cleanup() { kill "$cron_pid" "$terminal_pid" 2>/dev/null || true; wait "$cron_pid" "$terminal_pid" 2>/dev/null || true; }
trap cleanup EXIT
trap 'exit 0' TERM INT
if [[ -n "$cron_pid" ]]; then wait -n "$cron_pid" "$terminal_pid"; else wait "$terminal_pid"; fi
