#!/usr/bin/env bash
set -euo pipefail
[[ $EUID != 0 && -d /workspace && ! -w /workspace && ! -e /var/run/docker.sock ]]
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
cp -R src "$fixture/src"
mkdir "$fixture/mock" "$fixture/root"
export INSTALL_ROOT="$fixture/root" FIXTURE="$fixture"
cat > "$fixture/mock/dependencies" <<'MOCK'
mock_dependency() {
local command=$1
shift
case "$command" in
    tar) [[ $# == 4 && $1 == -xf && $2 == bin/minipwner.tar && $3 == -C && $4 == "$INSTALL_ROOT" ]] || return 98 ;;
    dirname) [[ $# == 2 && $1 == -- && $2 == "$FIXTURE/src/setup.sh" ]] || return 98 ;;
    mkdir) [[ $1 == -p ]] || return 98 ;;
    cp) [[ $# == 2 && $1 == bin/* && $2 == "$INSTALL_ROOT/"* ]] || return 98 ;;
    chmod) [[ $1 == 644 || $1 == 755 ]] || return 98 ;;
    ln) [[ $# == 3 && $1 == -sf && $2 == ../init.d/minimodes && $3 == "$INSTALL_ROOT/etc/rc.d/S99minimodes" ]] || return 98 ;;
    *) printf 'Denied command: %s\n' "$command" >> "$FIXTURE/denied"; exit 97 ;;
esac
if [[ $command == tar ]]; then
    /usr/bin/tar -tvf bin/minipwner.tar | /usr/bin/awk '$1 !~ /^[-d]/ {exit 1}' || return 98
    while IFS= read -r member; do
        resolved=$(/usr/bin/realpath -m "$INSTALL_ROOT/$member")
        [[ $resolved == "$INSTALL_ROOT/minipwner" || $resolved == "$INSTALL_ROOT/minipwner/"* ]] || exit 98
    done < <(/usr/bin/tar -tf bin/minipwner.tar)
fi
for argument in "$@"; do
    case "$argument" in --|-p|-sf|-xf|-C|644|755|../init.d/minimodes) continue ;; esac
    resolved=$(/usr/bin/realpath -m "$argument")
    [[ $resolved == "$FIXTURE/"* && $argument != *../* ]] || exit 98
done
[[ ${FAIL_COMMAND:-} != "$command" ]] || exit 42
[[ ${SKIP_COMMAND:-} != "$command" ]] || return 0
"/usr/bin/$command" "$@"
}
for command in dirname tar mkdir cp chmod ln sudo shutdown curl wget mount rm; do
    eval "$command() { mock_dependency $command \"\$@\"; }"
done
MOCK
run_installer() {
    printf '%s\n' "${1:-n}" | BASH_ENV="$fixture/mock/dependencies" PATH="$fixture/mock" /bin/bash "$fixture/src/setup.sh" > "$fixture/output" 2>&1
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
    cmp "src/bin/$file" "$INSTALL_ROOT/$installed"
    cmp "src/bin/$file" "$fixture/src/bin/$file"
    [[ $(stat -c %a "$INSTALL_ROOT/$installed") == "$mode" ]]
done
[[ $(readlink "$INSTALL_ROOT/etc/rc.d/S99minimodes") == ../init.d/minimodes ]]
[[ $(realpath "$INSTALL_ROOT/etc/rc.d/S99minimodes") == "$INSTALL_ROOT/etc/init.d/minimodes" ]]
tar -xf src/bin/minipwner.tar -C "$fixture"
diff -r "$fixture/minipwner" "$INSTALL_ROOT/minipwner"
[[ -f "$fixture/src/setup.sh" && -f "$fixture/src/bin/minipwner.tar" && ! -e "$fixture/denied" ]]
printf 'Installer success: real payload, content, modes, symlink, repeat installation and declined restart\n'
rm -rf "$INSTALL_ROOT"
mkdir "$INSTALL_ROOT"
if run_installer y; then exit 1; fi
grep -q 'Restart is unavailable' "$fixture/output"
[[ ! -e "$fixture/denied" ]]
rm -rf "$INSTALL_ROOT"
mkdir "$INSTALL_ROOT"
mv "$fixture/src/bin/minipwner.tar" "$fixture/payload.tar"
status=0
run_installer || status=$?
[[ $status == 1 ]]
[[ -z $(ls -A "$INSTALL_ROOT") ]]
grep -q 'payload' "$fixture/output"
mv "$fixture/payload.tar" "$fixture/src/bin/minipwner.tar"
export FAIL_COMMAND=cp
status=0
run_installer || status=$?
[[ $status == 42 ]]
[[ ! -e "$INSTALL_ROOT/etc/banner" && ! -e "$fixture/denied" ]]
if grep -q 'has been applied' "$fixture/output"; then exit 1; fi
printf 'Installer rejected real-root access, staging restart, missing payload and failed copy\n'
