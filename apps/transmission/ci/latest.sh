#!/usr/bin/env bash
user_agent="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.66 Safari/535.11"
version=$(curl -sX GET "https://repology.org/api/v1/projects/?search=transmission&inrepo=alpine_3_19" -H $user_agent | jq -r '.transmission | .[] | select((.repo == "alpine_3_19" and .binname == "transmission-daemon")) | .origversion')
version="${version%%_*}"
version="${version%%-*}"
printf "%s" "${version}"