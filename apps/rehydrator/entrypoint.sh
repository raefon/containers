#!/usr/bin/env bash
set -euo pipefail

if [[ -f /scripts/umask.sh ]]; then
    # shellcheck disable=SC1091
    source /scripts/umask.sh
fi

# Support explicit command overrides (including dgoss CLI keepalive commands).
# Flags continue to launch Rehydrator through the normal configuration path.
if (( $# > 0 )) && [[ "$1" != -* ]]; then
    exec "$@"
fi

# Match application precedence: command-line role overrides REHYDRATOR_ROLE.
# Explicit --config arguments are forwarded last and override this default.
role="${REHYDRATOR_ROLE:-combined}"
arguments=("$@")
for ((index = 0; index < ${#arguments[@]}; index++)); do
    case "${arguments[index]}" in
        --role|-role)
            index=$((index + 1))
            role="${arguments[index]:-}"
            ;;
        --role=*|-role=*)
            role="${arguments[index]#*=}"
            ;;
        --config|-config)
            index=$((index + 1))
            ;;
        --) break ;;
        -*) ;;
        *) break ;;
    esac
done

case "$role" in
    gateway) default_config=/etc/rehydrator/config.yaml ;;
    *) default_config=/config/rehydrator.yaml ;;
esac

# No mount waits, directory creation or ownership changes here. The gateway
# must start independently, including when its configuration is read-only.
exec /usr/local/bin/rehydrator \
    --config "${REHYDRATOR_CONFIG:-$default_config}" \
    "$@"
