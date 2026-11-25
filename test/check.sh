#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
while IFS= read -r -d '' script; do
    bash -n "$script"
    shellcheck "$script"
done < <(find . \( -path ./.git -o -path ./node_modules -o -path ./.flox \
    -o -path ./FIRMWARE -o -path ./OVERLAY \) -prune -o -type f -name '*.sh' -print0)
sh -n src/bin/minimodes
bash test/budget.sh
bun node_modules/markdownlint-cli2/markdownlint-cli2-bin.mjs
rendered="$(mktemp -d)"
trap 'rm -rf "$rendered"' EXIT
while IFS= read -r -d '' document; do
    mkdir -p "$rendered/$(dirname "$document")"
    bun node_modules/@mermaid-js/mermaid-cli/src/cli.js -i "$document" \
        -o "$rendered/$document" -p test/puppeteer.json
done < <(find . -path ./node_modules -prune -o -path ./.flox -prune -o -name '*.md' -print0)
