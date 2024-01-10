#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"
test -f "/scripts/vpn.sh" && source "/scripts/vpn.sh"

downloadsPath="/data/Downloads"

if [[ -z "$QBITTORRENT__USE_PROFILE" ]]; then
    configFolder="/config"
    export HOME="${configFolder}"
    export XDG_CONFIG_HOME="${configFolder}"
    export XDG_DATA_HOME="${configFolder}"
    qbtConfigFile="${configFolder}/qBittorrent/qBittorrent.conf"
    qbtLogFile="${configFolder}/qBittorrent/logs/qbittorrent.log"
    PROFILE_ARGS=""
else
    profilePath="/config"
    qbtConfigFile="${profilePath}/qBittorrent/config/qBittorrent.conf"
    qbtLogFile="${profilePath}/qBittorrent/data/logs/qbittorrent.log"
    PROFILE_ARGS="--profile=\"${profilePath}\""
fi

if [[ ! -f "$qbtConfigFile" ]]; then
    mkdir -p "$(dirname $qbtConfigFile)"
    cat << EOF > "$qbtConfigFile"
[AutoRun]
enabled=true
program=/scripts/torrent_unrar.sh \"%N\" \"%R\"
[BitTorrent]
Session\DefaultSavePath=$downloadsPath
Session\Port=$QBITTORRENT__BT_PORT
Session\MaxConnections=250
Session\MaxConnectionsPerTorrent=50
Session\MaxUploads=10
Session\MaxUploadsPerTorrent=2
Session\Port=6881
Session\TempPath=$downloadsPath/incomplete
Session\TempPathEnabled=true
Session\MaxActiveTorrents=-1
Session\MaxActiveUploads=-1
[Preferences]
WebUI\HostHeaderValidation=false
WebUI\UseUPnP=false
WebUI\LocalHostAuth=false
WebUI\AuthSubnetWhitelist=10.0.0.0/8
WebUI\AuthSubnetWhitelistEnabled=true
[LegalNotice]
Accepted=true
EOF
fi

python3 /scripts/config.py --output "$qbtConfigFile"

if [[ ! -f "$qbtLogFile" ]]; then
    mkdir -p "$(dirname $qbtLogFile)"
    ln -sf /proc/self/fd/1 "$qbtLogFile"
fi

#shellcheck disable=SC2086,SC2090
exec \
    /app/qbittorrent-nox \
        ${PROFILE_ARGS} \
        --webui-port="${QBITTORRENT__PORT:-8080}" \
        "$@"
