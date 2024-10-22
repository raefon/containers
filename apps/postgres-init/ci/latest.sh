#!/usr/bin/env bash
version=$(curl -sX GET "https://pkgs.alpinelinux.org/packages?name=postgresql15-client&branch=v3.18&arch" | sed -n 's/.*<strong class="hint--right hint--rounded text-success" aria-label="Package up-to-date">\([^<]*\)<.*/\1/p' | sed 's/\\//g' | head -n 1)
version="${version%%_*}"
version="${version%%-*}"
printf "%s" "${version}"