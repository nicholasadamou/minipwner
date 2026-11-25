#!/usr/bin/env bash
set -euo pipefail
workspace="$(mktemp -d)"
failure_log="$(mktemp)"
trap 'rm -rf "$workspace" "$failure_log"' EXIT
cp -R src test package.json bun.lock .markdownlint-cli2.jsonc .pre-commit-config.yaml .dockerignore .gitignore .flox "$workspace/"
ln -s /workspace/node_modules "$workspace/node_modules"
cd "$workspace"
expect_failure() {
    if bash test/check.sh > "$failure_log" 2>&1; then
        printf 'Expected rejection: %s\n' "$1" >&2
        exit 1
    fi
    grep -q "$2" "$failure_log"
    printf 'Rejected %s\n' "$1"
}
printf '#!/usr/bin/env bash\nif\n' > src/new.sh
expect_failure 'new source shell syntax' 'syntax error'
printf "#!/usr/bin/env bash\necho \$HOME\n" > src/new.sh
expect_failure 'new source ShellCheck violation' 'SC2086'
rm src/new.sh
printf 'if\n' >> test/main.sh
expect_failure 'invalid shell syntax' 'syntax error'
cp /workspace/test/main.sh test/main.sh
printf "echo \$HOME\n" >> test/main.sh
expect_failure 'ShellCheck violation' 'SC2086'
cp /workspace/test/main.sh test/main.sh
for ((line=0; line<251; line++)); do printf '# budget fixture\n'; done > extra.conf
expect_failure 'new file exceeding LOC budget' 'LOC budget exceeded'
rm extra.conf
printf '# Fixture\n\n### Skipped heading\n' > fixture.md
expect_failure 'invalid Markdown' 'MD001'
cat > fixture.md <<'MARKDOWN'
# Fixture

```mermaid
flowchart LR
  A --> [
```
MARKDOWN
expect_failure 'invalid Mermaid' 'Parse error'
