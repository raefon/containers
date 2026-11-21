#!/bin/sh
set -eu

# Accept the common boolean spelling while preserving dperson's optional port form.
case "${FIREWALL-}" in
  on|true|yes|1) FIREWALL=""; export FIREWALL ;;
esac

exec /usr/bin/openvpn.sh "$@"
