#!/bin/bash

LOG="/config/qBittorrent/logs/torrent_unrar.log"
TR_TORRENT_NAME="$1"
TR_TORRENT_DIR="$2"
UNRAR_STAGING="/data/unrar_staging"

# check if log file exists
[ ! test -f "${LOG}" ] && touch ${LOG}

# check if unrar_staging exists
[ ! -d "${UNRAR_STAGING}" ] && mkdir -p ${UNRAR_STAGING}

# The script could use more tesing, but it works well for my needs
function extract_rar() {
  isRar=$(ls | grep *.rar)
  if [ -n "$isRar" ]; then
    # Handle an edge case with some distributors
    isPart01="$(ls *.rar | egrep -i 'part01.rar|part1.rar')"
    if [ -n "$isPart01" ]; then
      isRar=$isPart01
    fi
    toUnrar="$(pwd)/$isRar"
    # we need to move to new location so sonarr doesn't try to mv before its done
    # also, unrar doesn't support changing the filename on extracting, makes sense a little bit
    pushd ${UNRAR_STAGING}
    fileName="$(unrar e -y $toUnrar | egrep "^\.\.\..*OK" | awk '{ print $2 }')"
    # put it back so sonarr can now find it
    mv $fileName $(dirname $toUnrar)
    popd
  fi
}

echo "Starting  - $(date)" >> $LOG
echo "${TR_TORRENT_NAME}" >> $LOG

cd "$TR_TORRENT_DIR"

if [ -d "$TR_TORRENT_NAME" ]; then
  cd "$TR_TORRENT_NAME"
  #handle multiple episode packs, like those that contain a whole season, or just a single episode
  for rar in $(find . -name '*.rar' -exec dirname {} \; | sort -u);
  do
    pushd $rar
    extract_rar
    popd
  done
fi