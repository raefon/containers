#!/usr/bin/env bash
set -euo pipefail

# Fetch the latest MinIO RELEASE tag from GitHub
latest_tag=$(git ls-remote --tags https://github.com/minio/minio.git | \
             awk '{print $2}' | \
             grep -E 'refs/tags/RELEASE\.[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-[0-9]{2}Z$' | \
             sed 's|refs/tags/||' | \
             sort -r | \
             head -n1)

# Print it, fallback to "dev" if no release found
echo "${latest_tag:-dev}"
