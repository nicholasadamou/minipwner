#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

for script in src/setup.sh test/main.sh test/verify.sh; do
    bash -n "$script"
done
sh -n src/bin/minimodes

# Preserve the installer's existing ShellCheck exclusions for legacy code.
shellcheck --exclude=SC1090,SC1091,SC2033,SC2129,SC2155,SC2164,SC2200 src/setup.sh
shellcheck test/main.sh test/verify.sh

printf 'MiniPwner verification passed (shell syntax and ShellCheck).\n'
