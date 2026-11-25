# Getting started

MiniPwner targets a TP-Link TL-MR3040 router running legacy OpenWrt Barrier Breaker, with USB storage for additional packages. Keep a recovery method and backups available before modifying the device. Run installer commands only on the intended router and use the device only on networks you are authorized to assess.

## Prepare the router

Follow the existing [MR3040 configuration guide](https://github.com/nicholasadamou/minipwner/wiki/Configuring-a-TP-Link-MR3040-into-a-MiniPwner) for device preparation, firmware and storage. The repository includes historical firmware in `FIRMWARE/` and a packaged overlay in `OVERLAY/`; confirm compatibility with your exact hardware revision before using them.

## Review the distribution before installing

The historical `OVERLAY/minipwner-overlay_2.0.0.tar` contains `setup.sh`, `minipwner.tar` and a `files/` directory at its archive root. On the intended router, inspect and extract it into a temporary directory, then review its included setup script before running it from that extracted directory. The packaged script uses CRLF line endings; account for those during review. It modifies router files, init scripts, the firewall and web interface. This distribution has not been runtime-tested by local CI.

The source checkout is a separate development snapshot. `src/setup.sh` expects `minipwner.tar` beside itself, while the checked-in payload is actually under `src/bin/`. It also calls an external helper before loading its remote utilities. Running the source installer directly is therefore not a verified installation path. Resolve and validate those legacy assumptions on compatible hardware before using it; local checks deliberately do not execute it.

The firmware, overlay and remote dependencies are historical artifacts. No current firmware compatibility or successful installation is implied by a passing repository check.

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
