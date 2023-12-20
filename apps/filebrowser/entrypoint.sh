#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

if [[ ! -f "/config/filebrowser/settings.json" ]]; then
    printf "Copying over default configuration ...\n"
    mkdir -p /config/filebrowser
    cp /app/filebrowser/settings.json /config/filebrowser/settings.json
fi

if [[ ! -f "/config/filebrowser/filebrowser.db" ]]; then
    printf "Generating default database ...\n"
    /filebrowser config init --disable-preview-resize \
        --disable-thumbnails \
        --disable-type-detection-by-header \
        --branding.name="filebrowser, by KDLHOST " \
        --branding.files=/branding \
        --branding.disableExternal \
        --auth.method=noauth \
        --lockPassword \
        --database /config/filebrowser/filebrowser.db \
        --cache-dir /tmp \
        --port 80
    # allow commands
    /filebrowser config set --database /config/filebrowser/filebrowser.db --commands zip,unzip,rar,unrar,ls,pwd,cd,mv,cp,ln,find,echo,grep,cat,touch,tar,gzip,rm,tree,du,mlocate,updatedb,locate,tenet
    # add bogus user
    /filebrowser users add 1 bogus --database /config/filebrowser/filebrowser.db
fi

data=/srv/data
if [ ! \( -e "${data}" \) ]
then
     echo "%ERROR: data symlink does not exist!" >&2
     ln -s /data $data
fi

config=/srv/config
if [ ! \( -e "${config}" \) ]
then
     echo "%ERROR: config symlink does not exist!" >&2
     ln -s /config $config
fi

#shellcheck disable=SC2086
exec \
    /filebrowser \
    --config /config/filebrowser/settings.json \
    --database /config/filebrowser/filebrowser.db \
    "$@"