#!/usr/bin/env bash
set -euo pipefail
# Credentials come from the pod environment, never from command-line arguments.
if [[ "${RECYCLARR_ENABLED:-true}" != true ]]; then
    echo "Recyclarr sync disabled"
    exit 0
fi
config="${RECYCLARR_CONFIG:-/etc/recyclarr/recyclarr.yml}"
export RECYCLARR_CONFIG_DIR="${RECYCLARR_CONFIG_DIR:-${RECYCLARR_APP_DATA:-/config/recyclarr}}"
unset RECYCLARR_APP_DATA
if [[ ! -r "$config" || -z "${SONARR_API_KEY:-}" || -z "${RADARR_API_KEY:-}" ]]; then
    echo "Recyclarr needs its config and tenant Arr API-key environment variables" >&2
    exit 1
fi
mkdir -p "$RECYCLARR_CONFIG_DIR"
exec 9>"$RECYCLARR_CONFIG_DIR/sync.lock"
if ! flock -n 9; then
    echo "Recyclarr sync already running; skipping overlapping invocation"
    exit 0
fi
if [[ "$(recyclarr --version)" != v8.* ]]; then
    echo "Recyclarr 8 is required" >&2
    exit 1
fi
# The scheduled first run also needs a recovery snapshot, even without provisioning.
python3 - "$RECYCLARR_CONFIG_DIR" <<'PYTHON'
import json, os, sys, urllib.request
path=os.path.join(sys.argv[1], 'before-managed-sync.json')
if not os.path.exists(path):
    snapshot={}
    for app,port in [('sonarr',8989),('radarr',7878)]:
        base=os.environ.get(app.upper()+'_URL',f'http://tenet-{app}:{port}').rstrip('/')
        snapshot[app]={}
        for resource in ['qualityprofile','customformat','qualitydefinition','config/naming']:
            request=urllib.request.Request(base+'/api/v3/'+resource,headers={'X-Api-Key':os.environ[app.upper()+'_API_KEY']})
            with urllib.request.urlopen(request,timeout=30) as response:
                snapshot[app][resource]=json.load(response)
    fd=os.open(path,os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600)
    with os.fdopen(fd,'w') as target: json.dump(snapshot,target)
    print('Saved initial Arr settings snapshot')
PYTHON
exec recyclarr sync --config "$config" --log info "$@"
