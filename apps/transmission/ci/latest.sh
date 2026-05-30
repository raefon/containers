#!/usr/bin/env bash
set -euo pipefail

# Query Repology for the Alpine transmission-daemon package version and
# output the normalized upstream version string.
readonly USER_AGENT='User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.66 Safari/535.11'

version=$(curl -fsS -X GET \
    'https://repology.org/api/v1/projects/?search=transmission&inrepo=alpine_3_19' \
    -H "$USER_AGENT" | \
    jq -er '.transmission | .[] | select(.repo == "alpine_3_19" and .binname == "transmission-daemon") | .origversion')

# Strip any suffix after underscore or dash to keep only the base version.
version="${version%%[_-]*}"

printf "%s" "${version}"