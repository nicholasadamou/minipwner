#!/bin/bash
# Install the packaged overlay on OpenWrt, or into an existing staging root.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
root=$(cd -- "${INSTALL_ROOT:-/}" && pwd -P)
if [[ $root == / && $EUID != 0 ]]; then
    printf 'Installing to / requires root.\n' >&2
    exit 1
fi
archive=OVERLAY/minipwner-overlay_2.0.0.tar
if [[ ! -f $archive ]]; then
    printf 'Missing overlay: %s\n' "$archive" >&2
    exit 1
fi
prefix=${root%/}
tar -xOf "$archive" minipwner.tar | tar -xf - -C "$root"
mkdir -p "$prefix/etc/init.d" "$prefix/etc/rc.d" "$prefix/etc/config" "$prefix/www"
tar -xOf "$archive" files/minimodes > "$prefix/etc/init.d/minimodes"
chmod 755 "$prefix/etc/init.d/minimodes"
ln -sf ../init.d/minimodes "$prefix/etc/rc.d/S99minimodes"
tar -xOf "$archive" files/minimodes.html > "$prefix/www/minimodes.html"
tar -xOf "$archive" files/firewall > "$prefix/etc/config/firewall"
tar -xOf "$archive" files/banner > "$prefix/etc/banner"
chmod 644 "$prefix/www/minimodes.html" "$prefix/etc/config/firewall" "$prefix/etc/banner"
printf 'The MiniPwner Overlay 2.0.0 has been applied.\n'
read -r -p 'Restart now? [y/N] ' answer || answer=n
if [[ $answer == y || $answer == Y ]]; then
    if [[ $root != / ]]; then
        printf 'Restart is unavailable for a staging root.\n' >&2
        exit 1
    fi
    shutdown -r now
fi
