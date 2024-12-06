#!/usr/bin/env bash
channel=$1

if [[ "${channel}" == "stable" ]]; then
    version=$(curl -sX GET https://repo.jellyfin.org/ubuntu/dists/jammy/main/binary-amd64/Packages |grep -A 7 -m 1 'Package: jellyfin-server' | awk -F ': ' '/Version/{print $2;exit}');
fi

version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
