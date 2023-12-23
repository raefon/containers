#!/bin/bash

LOG_FILE=/config/qBittorrent/logs/torrent_unrar.log
TORRENT_DIR=$1
TR_TORRENT_NAME=$2

NOW=$(date +%Y-%m-%d\ %H:%M:%S)

SRC_DIR="${TORRENT_DIR}/${TR_TORRENT_NAME}"
DEST_DIR="${TORRENT_DIR}/${TR_TORRENT_NAME}"

cd $SRC_DIR

IFS=$'\n'

unset RAR_FILES i

for RAR_FILE in $( find "$SRC_DIR" -iname "*.rar" ); do

if [[ $RAR_FILE =~ .*part.*.rar ]]; then

  if [[ $RAR_FILE =~ .*part0*1.rar ]]; then

    RAR_FILES[i++]=$RAR_FILE

  fi

done

unset IFS

if [ ${#RAR_FILES} -gt 0 ]; then

for RAR_FILE in "${RAR_FILES[@]}"; do
  unrar x -inul "$RAR_FILE" "$DEST_DIR"
done
echo $NOW "Unrarred $TR_TORRENT_NAME" >> $LOG_FILE

fi

fi