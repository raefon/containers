#!/usr/bin/env bash
set -euo pipefail
# Credentials come from the pod environment, never from command-line arguments.
if [[ "${RECYCLARR_ENABLED:-true}" != true ]]; then
    echo "Recyclarr sync disabled"
    exit 0
fi
config="${RECYCLARR_CONFIG:-/etc/recyclarr/recyclarr.yml}"
export RECYCLARR_APP_DATA="${RECYCLARR_APP_DATA:-/config/recyclarr}"
if [[ ! -r "$config" || -z "${SONARR_API_KEY:-}" || -z "${RADARR_API_KEY:-}" ]]; then
    echo "Recyclarr needs its config and tenant Arr API-key environment variables" >&2
    exit 1
fi
mkdir -p "$RECYCLARR_APP_DATA"
exec 9>"$RECYCLARR_APP_DATA/sync.lock"
if ! flock -n 9; then
    echo "Recyclarr sync already running; skipping overlapping invocation"
    exit 0
fi
if [[ "$(recyclarr --version)" != v8.* ]]; then
    echo "Recyclarr 8 is required" >&2
    exit 1
fi
exec recyclarr sync --config "$config" --log info "$@"
