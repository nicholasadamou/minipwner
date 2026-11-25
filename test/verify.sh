#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

docker build --file "$repository_root/test/Dockerfile" \
    --tag minipwner-verify "$repository_root"
docker run --rm --network none --read-only --cap-drop ALL \
    --security-opt no-new-privileges minipwner-verify
