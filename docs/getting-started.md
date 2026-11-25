# Getting started

MiniPwner targets a TP-Link TL-MR3040 running legacy OpenWrt Barrier Breaker.
Use it only on networks you are authorized to assess. Keep backups and a recovery
method before modifying the router.

## Prepare the router

Follow the [MR3040 configuration guide](https://github.com/nicholasadamou/minipwner/wiki/Configuring-a-TP-Link-MR3040-into-a-MiniPwner)
for firmware and USB storage preparation. The existing firmware image is kept
in `FIRMWARE/`; confirm compatibility with your exact hardware revision.

## Review and install

`install.sh` uses the single package in
`OVERLAY/minipwner-overlay_2.0.0.tar`. Its filesystem payload, MiniModes,
firewall configuration, banner, and web interface are installed from that package.
The historical setup script inside the archive is not executed.

The installer requires Bash and the standard `tar`, `mkdir`, `chmod`, `ln`, and
`dirname` commands. Enabled utilities vary between OpenWrt builds. Review the
installer and package, then run as root only on the intended router:

```sh
bash install.sh
```

The installer preserves the package, refreshes installed files, creates a relative
startup symlink, and asks before restarting. Failed commands stop installation;
partial files may remain. For staging, set `INSTALL_ROOT` to an existing directory
and decline the restart prompt. Restart requests are rejected for staging roots.

```mermaid
flowchart LR
    Hardware[Confirm router revision] --> Prepare[Prepare firmware and USB storage]
    Prepare --> Review[Review installer and package]
    Review --> Install[Install on router]
    Install --> Check[Check access and MiniModes]
```

## Check the device

Confirm wired and wireless access, storage mounts, and MiniModes selection.
Verify SSH or VPN access in your own test network. Package availability, firmware
compatibility, and real device behavior require hardware testing.

For workstation checks, use [local verification](development.md).
