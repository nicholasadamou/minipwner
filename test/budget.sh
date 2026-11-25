#!/usr/bin/env bash
set -euo pipefail
# Exclude documentation, assets, generated state and the existing router payload.
lines=0
while IFS= read -r -d '' file; do
    count=$(awk 'NF { count++ } END { print count+0 }' "$file")
    lines=$((lines + count))
done < <(find . \( -path ./.git -o -path ./node_modules -o -path ./docs \
    -o -path ./assets -o -path ./FIRMWARE -o -path ./OVERLAY \
    -o -path ./LICENSES -o -path ./.flox/run -o -path ./.flox/cache \
    -o -path ./.flox/lib -o -path ./.flox/log \) -prune -o -type f \
    ! -name '*.md' ! -name '*.lock' ! -name LICENSE ! -name NOTICE \
    ! -path ./banner.png ! -path ./src/bin/banner \
    ! -path ./src/bin/firewall ! -path ./src/bin/minimodes \
    ! -path ./src/bin/minimodes.html ! -path ./src/bin/minipwner.tar -print0)
printf 'Verification/config budget: %s/350 nonblank lines\n' "$lines"
if (( lines > 350 )); then
    printf 'Verification/config LOC budget exceeded\n' >&2
    exit 1
fi
