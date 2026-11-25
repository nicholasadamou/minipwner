#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
bash test/check.sh
bash test/failures.sh
printf 'MiniPwner verification passed.\n'
