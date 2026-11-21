#!/usr/bin/env bash
set -euo pipefail
sha256sum apps/openvpn-client/Dockerfile apps/openvpn-client/openvpn.sh | sha256sum | cut -c1-12
