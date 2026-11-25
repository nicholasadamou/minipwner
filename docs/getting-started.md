# Getting started

MiniPwner targets a TP-Link TL-MR3040 router running legacy OpenWrt Barrier Breaker, with USB storage for additional packages. Keep a recovery method and backups available before modifying the device. Run installer commands only on the intended router and use the device only on networks you are authorized to assess.

## Prepare the router

Follow the existing [MR3040 configuration guide](https://github.com/nicholasadamou/minipwner/wiki/Configuring-a-TP-Link-MR3040-into-a-MiniPwner) for device preparation, firmware and storage. The repository includes historical firmware in `FIRMWARE/` and a packaged overlay in `OVERLAY/`; confirm compatibility with your exact hardware revision before using them.

## Review the distribution before installing

The historical `OVERLAY/minipwner-overlay_2.0.0.tar` contains `setup.sh`, `minipwner.tar` and a `files/` directory at its archive root. On the intended router, inspect and extract it into a temporary directory, then review its included setup script before running it from that extracted directory. The packaged script uses CRLF line endings; account for those during review. It modifies router files, init scripts, the firewall and web interface. This distribution has not been runtime-tested by local CI.

The supported source installer is `src/setup.sh`, with its real bundled payload at `src/bin/minipwner.tar`. It requires Bash and standard `tar`, `mkdir`, `cp`, `chmod`, `ln` and `dirname` commands. These basic operations are available as [BusyBox applets](https://busybox.net/downloads/BusyBox.html); enabled applets still depend on your firmware build. It no longer downloads external shell utilities or requests sudo. Run it as root only on the intended router after reviewing the files:

```sh
bash src/setup.sh
```

For staging, set `INSTALL_ROOT` to an existing directory. The installer extracts the payload and copies supporting files beneath that root, preserves the source distribution and creates a relative startup symlink. It stops on missing payloads or failed commands; installation is not transactional and may leave partial files. Repeating installation refreshes the files and replaces the startup symlink. Decline the restart prompt for staging; an affirmative answer is rejected outside the real root. Actual router reboot behavior requires a compatible `shutdown` command and is not exercised by CI.

The firmware and packaged overlay are historical artifacts. The packaged script remains unchanged and is separate from the supported source installer. Passing staged integration tests does not establish firmware compatibility or hardware behavior.

```mermaid
flowchart LR
  Hardware[Confirm router revision] --> Prepare[Prepare firmware and USB storage]
  Prepare --> Review[Review installer and overlay]
  Review --> Install[Install on router]
  Install --> Check[Check access and MiniModes]
```

## Check the device

Confirm wired and wireless access, storage mounts and MiniModes selection after installation. Verify the configured SSH or VPN route in your own test network before relying on remote access. The tools and packages described by the historical project depend on the installed OpenWrt image; treat availability as device-specific.

For repository checks on your workstation, use [local development](development.md).
