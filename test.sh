#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID == 0 || ! -d /workspace || -w /workspace || -e /var/run/docker.sock ]]; then
    printf 'Run the restricted Docker check in docs/development.md.\n' >&2
    exit 1
fi

shellcheck install.sh test.sh

overlay_archive=OVERLAY/minipwner-overlay_2.0.0.tar
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/project/OVERLAY" "$fixture/root" "$fixture/mock" "$fixture/expected"
cp install.sh "$fixture/project/"
cp "$overlay_archive" "$fixture/project/$overlay_archive"

export FIXTURE="$fixture" INSTALL_ROOT="$fixture/root"

# Reject links and paths outside the expected payload before extracting test data.
tar -xOf "$overlay_archive" minipwner.tar > "$fixture/payload.tar"
tar -tvf "$fixture/payload.tar" | awk '$1 !~ /^[-d]/ {exit 1}'
while IFS= read -r member; do
    resolved_member=$(realpath -m "$fixture/expected/$member")
    [[ $resolved_member == "$fixture/expected/minipwner" || $resolved_member == "$fixture/expected/minipwner/"* ]]
done < <(tar -tf "$fixture/payload.tar")

tar -xf "$fixture/payload.tar" -C "$fixture/expected"
tar -xOf "$overlay_archive" files/minimodes > "$fixture/minimodes"
sh -n "$fixture/minimodes"

# The installer receives only these approved commands, with no PATH fallback.
cat > "$fixture/mock/dependencies" << 'MOCK'
mock_dependency() {
    local command=$1 argument
    shift

    case "$command" in
        dirname)
            [[ $# == 2 && $1 == -- && $2 == "$FIXTURE/project/install.sh" ]] || return 98
            ;;
        tar)
            if [[ $# == 3 && $1 == -xOf && $2 == OVERLAY/minipwner-overlay_2.0.0.tar ]]; then
                case "$3" in
                    minipwner.tar | files/minimodes | files/minimodes.html | files/firewall | files/banner) ;;
                    *) return 98 ;;
                esac
            else
                [[ $# == 4 && $1 == -xf && $2 == - && $3 == -C && $4 == "$INSTALL_ROOT" ]] || return 98
            fi
            /usr/bin/tar "$@"
            return
            ;;
        mkdir)
            [[ $1 == -p ]] || return 98
            ;;
        chmod)
            [[ $1 == 644 || $1 == 755 ]] || return 98
            ;;
        ln)
            [[ $# == 3 && $1 == -sf && $2 == ../init.d/minimodes && $3 == "$INSTALL_ROOT/etc/rc.d/S99minimodes" ]] || return 98
            ;;
        *)
            printf 'Denied command: %s\n' "$command" >> "$FIXTURE/denied"
            return 97
            ;;
    esac

    for argument; do
        case "$argument" in
            -- | -p | -sf | 644 | 755 | ../init.d/minimodes) continue ;;
        esac
        [[ $(/usr/bin/realpath -m "$argument") == "$FIXTURE/"* && $argument != *../* ]] || return 98
    done

    [[ ${FAIL_COMMAND:-} != "$command" ]] || return 42
    "/usr/bin/$command" "$@"
}

for command in dirname tar mkdir chmod ln sudo shutdown curl wget mount rm; do
    eval "$command() { mock_dependency $command \"\$@\"; }"
done
MOCK

run_installer() {
    printf '%s\n' "${1:-n}" |
        BASH_ENV="$fixture/mock/dependencies" PATH="$fixture/mock" \
            /bin/bash "$fixture/project/install.sh" > "$fixture/output" 2>&1
}

# Default installation must refuse the real root when running unprivileged.
if (
    unset INSTALL_ROOT
    run_installer
); then
    exit 1
fi
grep -q 'requires root' "$fixture/output"

run_installer || {
    cat "$fixture/output" >&2
    exit 1
}
run_installer || {
    cat "$fixture/output" >&2
    exit 1
}

for file in banner firewall minimodes minimodes.html; do
    case "$file" in
        banner)
            installed_path=etc/banner
            expected_mode=644
            ;;
        firewall)
            installed_path=etc/config/firewall
            expected_mode=644
            ;;
        minimodes)
            installed_path=etc/init.d/minimodes
            expected_mode=755
            ;;
        minimodes.html)
            installed_path=www/minimodes.html
            expected_mode=644
            ;;
    esac
    cmp <(tar -xOf "$overlay_archive" "files/$file") "$INSTALL_ROOT/$installed_path"
    [[ $(stat -c %a "$INSTALL_ROOT/$installed_path") == "$expected_mode" ]]
done

diff -r "$fixture/expected/minipwner" "$INSTALL_ROOT/minipwner"
[[ $(readlink "$INSTALL_ROOT/etc/rc.d/S99minimodes") == ../init.d/minimodes ]]
[[ $(realpath "$INSTALL_ROOT/etc/rc.d/S99minimodes") == "$INSTALL_ROOT/etc/init.d/minimodes" ]]
cmp "$overlay_archive" "$fixture/project/$overlay_archive"
[[ ! -e "$fixture/denied" ]]

# A staged installation must never reboot the host.
if run_installer y; then
    exit 1
fi
grep -q 'Restart is unavailable' "$fixture/output"

# A missing package must fail before writing any files.
rm -rf "$INSTALL_ROOT"
mkdir "$INSTALL_ROOT"
mv "$fixture/project/$overlay_archive" "$fixture/missing-overlay.tar"
if run_installer; then
    exit 1
fi
[[ -z $(ls -A "$INSTALL_ROOT") ]]
grep -q 'Missing overlay' "$fixture/output"
mv "$fixture/missing-overlay.tar" "$fixture/project/$overlay_archive"

# A failed dependency must stop installation before the success message.
if FAIL_COMMAND='chmod' run_installer; then
    exit 1
fi
if grep -q 'has been applied' "$fixture/output"; then
    exit 1
fi
[[ ! -e "$fixture/denied" ]]

printf 'Installer passed: packaged overlay, files, modes, links, reruns, and failure handling.\n'
