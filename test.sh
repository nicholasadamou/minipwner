#!/usr/bin/env bash
set -euo pipefail
if [[ $EUID == 0 || ! -d /workspace || -w /workspace || -e /var/run/docker.sock ]]; then
    printf 'Run the restricted Docker check in docs/development.md.\n' >&2
    exit 1
fi
shellcheck install.sh test.sh
archive=OVERLAY/minipwner-overlay_2.0.0.tar
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/project/OVERLAY" "$fixture/root" "$fixture/mock" "$fixture/expected"
cp install.sh "$fixture/project/"
cp "$archive" "$fixture/project/$archive"
export FIXTURE="$fixture" INSTALL_ROOT="$fixture/root"
tar -xOf "$archive" minipwner.tar > "$fixture/payload.tar"
tar -tvf "$fixture/payload.tar" | awk '$1 !~ /^[-d]/ {exit 1}'
while IFS= read -r member; do
    resolved=$(realpath -m "$fixture/expected/$member")
    [[ $resolved == "$fixture/expected/minipwner" || $resolved == "$fixture/expected/minipwner/"* ]]
done < <(tar -tf "$fixture/payload.tar")
tar -xf "$fixture/payload.tar" -C "$fixture/expected"
tar -xOf "$archive" files/minimodes > "$fixture/minimodes"
sh -n "$fixture/minimodes"
cat > "$fixture/mock/dependencies" <<'MOCK'
mock_dependency() {
    local command=$1 argument
    shift
    case "$command" in
        dirname) [[ $# == 2 && $1 == -- && $2 == "$FIXTURE/project/install.sh" ]] || return 98 ;;
        tar)
            if [[ $# == 3 && $1 == -xOf && $2 == OVERLAY/minipwner-overlay_2.0.0.tar ]]; then
                case "$3" in minipwner.tar|files/minimodes|files/minimodes.html|files/firewall|files/banner) ;; *) return 98 ;; esac
            else
                [[ $# == 4 && $1 == -xf && $2 == - && $3 == -C && $4 == "$INSTALL_ROOT" ]] || return 98
            fi
            /usr/bin/tar "$@"; return ;;
        mkdir) [[ $1 == -p ]] || return 98 ;;
        chmod) [[ $1 == 644 || $1 == 755 ]] || return 98 ;;
        ln) [[ $# == 3 && $1 == -sf && $2 == ../init.d/minimodes && $3 == "$INSTALL_ROOT/etc/rc.d/S99minimodes" ]] || return 98 ;;
        *) printf 'Denied command: %s\n' "$command" >> "$FIXTURE/denied"; return 97 ;;
    esac
    for argument; do
        case "$argument" in --|-p|-sf|644|755|../init.d/minimodes) continue ;; esac
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
    printf '%s\n' "${1:-n}" | BASH_ENV="$fixture/mock/dependencies" PATH="$fixture/mock" /bin/bash "$fixture/project/install.sh" > "$fixture/output" 2>&1
}
if (unset INSTALL_ROOT; run_installer); then exit 1; fi
grep -q 'requires root' "$fixture/output"
run_installer || { cat "$fixture/output" >&2; exit 1; }
run_installer || { cat "$fixture/output" >&2; exit 1; }
for file in banner firewall minimodes minimodes.html; do
    case "$file" in
        banner) installed=etc/banner; mode=644 ;;
        firewall) installed=etc/config/firewall; mode=644 ;;
        minimodes) installed=etc/init.d/minimodes; mode=755 ;;
        minimodes.html) installed=www/minimodes.html; mode=644 ;;
    esac
    cmp <(tar -xOf "$archive" "files/$file") "$INSTALL_ROOT/$installed"
    [[ $(stat -c %a "$INSTALL_ROOT/$installed") == "$mode" ]]
done
diff -r "$fixture/expected/minipwner" "$INSTALL_ROOT/minipwner"
[[ $(readlink "$INSTALL_ROOT/etc/rc.d/S99minimodes") == ../init.d/minimodes ]]
[[ $(realpath "$INSTALL_ROOT/etc/rc.d/S99minimodes") == "$INSTALL_ROOT/etc/init.d/minimodes" ]]
cmp "$archive" "$fixture/project/$archive"
[[ ! -e "$fixture/denied" ]]
if run_installer y; then exit 1; fi
grep -q 'Restart is unavailable' "$fixture/output"
rm -rf "$INSTALL_ROOT"
mkdir "$INSTALL_ROOT"
mv "$fixture/project/$archive" "$fixture/missing-overlay.tar"
if run_installer; then exit 1; fi
[[ -z $(ls -A "$INSTALL_ROOT") ]]
grep -q 'Missing overlay' "$fixture/output"
mv "$fixture/missing-overlay.tar" "$fixture/project/$archive"
if FAIL_COMMAND='chmod' run_installer; then exit 1; fi
if grep -q 'has been applied' "$fixture/output"; then exit 1; fi
[[ ! -e "$fixture/denied" ]]
printf 'Installer passed: packaged overlay, files, modes, links, reruns, and failure handling.\n'
