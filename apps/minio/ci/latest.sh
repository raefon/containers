#!/usr/bin/env bash
set -euo pipefail

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

git clone --quiet https://github.com/minio/minio.git "${TMPDIR}"
pushd "${TMPDIR}" > /dev/null

version=$(git rev-list --count --first-parent HEAD)

popd > /dev/null
printf "1.0.%d" "${version}"
