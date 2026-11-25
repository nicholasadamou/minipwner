#!/bin/bash
# Install the packaged overlay on OpenWrt, or into an existing staging root.
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
installation_root=$(cd -- "${INSTALL_ROOT:-/}" && pwd -P)

if [[ $installation_root == / && $EUID != 0 ]]; then
    printf 'Installing to / requires root.\n' >&2
    exit 1
fi

overlay_archive=OVERLAY/minipwner-overlay_2.0.0.tar

if [[ ! -f $overlay_archive ]]; then
    printf 'Missing overlay: %s\n' "$overlay_archive" >&2
    exit 1
fi

# An empty prefix addresses /etc and /www without introducing double slashes.
destination_prefix=${installation_root%/}

# Stream the nested payload directly; the legacy setup script is never executed.
tar -xOf "$overlay_archive" minipwner.tar | tar -xf - -C "$installation_root"
mkdir -p \
    "$destination_prefix/etc/init.d" \
    "$destination_prefix/etc/rc.d" \
    "$destination_prefix/etc/config" \
    "$destination_prefix/www"

tar -xOf "$overlay_archive" files/minimodes > "$destination_prefix/etc/init.d/minimodes"
chmod 755 "$destination_prefix/etc/init.d/minimodes"
ln -sf ../init.d/minimodes "$destination_prefix/etc/rc.d/S99minimodes"

tar -xOf "$overlay_archive" files/minimodes.html > "$destination_prefix/www/minimodes.html"
tar -xOf "$overlay_archive" files/firewall > "$destination_prefix/etc/config/firewall"
tar -xOf "$overlay_archive" files/banner > "$destination_prefix/etc/banner"
chmod 644 \
    "$destination_prefix/www/minimodes.html" \
    "$destination_prefix/etc/config/firewall" \
    "$destination_prefix/etc/banner"

printf 'The MiniPwner Overlay 2.0.0 has been applied.\n'
read -r -p 'Restart now? [y/N] ' restart_answer || restart_answer=n

if [[ $restart_answer == y || $restart_answer == Y ]]; then
    if [[ $installation_root != / ]]; then
        printf 'Restart is unavailable for a staging root.\n' >&2
        exit 1
    fi

    shutdown -r now
fi
