# ADOS Universal USB Installer

## Purpose

ADOS will ship one user-facing installer image, `ADOS-Installer.img.xz`, designed to boot from USB and install the correct ADOS system for the detected Raspberry Pi.

The eight ARM32/ARM64 board builds remain the engineering and CI validation matrix. Users should not need to choose among those build targets.

## Supported physical hardware identities

| ADOS hardware ID | Physical board | SoC expectation | Board assumptions |
|---|---|---|---|
| `rpi3b` | Raspberry Pi 3 Model B | BCM2837 | Pi 3B |
| `rpi3-frankenstein` | Raspberry Pi 3 Model B PCB with BCM2837B0-generation SoC | BCM2837B0 | Pi 3B, not Pi 3B+ |
| `rpi3bplus` | Raspberry Pi 3 Model B+ | BCM2837B0 | Pi 3B+ |
| `rpi4` | Raspberry Pi 4 Model B | BCM2711 | Pi 4 |

The Frankenstein profile is deliberately separate. A BCM2837B0 must not by itself cause the installer to classify a Pi 3B PCB as a Pi 3B+.

## Installer implementation

`ados-detect-hardware` is the canonical non-destructive detector. It emits key/value diagnostics and exits non-zero for unsupported or ambiguous hardware. `ADOS_SOC_REVISION` is available as an explicit diagnostic/test override until the installer has a hardware-verified BCM2837B0 revision source on the Frankenstein board.

`release-manifest.example.json` defines manifest schema `ados.release-manifest.v1`. Null artifact entries are intentionally non-installable placeholders until CI publishes verified artifacts.

`targets.map` records the authoritative mapping from the eight engineering targets to the four physical installer profiles and ARM architecture. `generate-release-manifest.py` consumes all eight compressed image artifacts, computes their SHA-256 digests and sizes, and refuses to emit a complete release manifest if any required target is missing.

## Detection contract

Hardware selection must use multiple signals where available:

1. Device-tree model and compatible strings.
2. Raspberry Pi board revision information.
3. SoC identity/revision.
4. Cross-check board identity against SoC identity.

Expected classification:

```text
Pi 3B board + BCM2837    -> rpi3b
Pi 3B board + BCM2837B0  -> rpi3-frankenstein
Pi 3B+ board + BCM2837B0 -> rpi3bplus
Pi 4 board + BCM2711     -> rpi4
```

Ambiguous or unsupported hardware must stop installation and show the detected identifiers. It must not guess a target.

## Architecture policy

Pi 3, Pi 3B+, Frankenstein and Pi 4 are maintained as ARM32 and ARM64 CI targets. The installer should default to ARM64 on supported hardware while allowing an explicit ARM32 selection.

## Installation flow

1. Boot the ADOS installer from USB.
2. Detect board, revision and SoC.
3. Select the ADOS hardware profile.
4. Bring up networking.
5. Fetch the ADOS release manifest.
6. Select the matching architecture and hardware artifacts.
7. Verify hashes/signatures before use.
8. Select and validate the destination drive.
9. Install boot files, kernel, DTBs/overlays, modules, root filesystem and ADOS packages.
10. Record the installed ADOS release, hardware profile and exact kernel revision.
11. Reboot into the installed ADOS system.

The installer must never overwrite the USB device it is currently running from.

## Release model

GitHub Actions builds and tests the per-target components. A release manifest maps the four physical hardware profiles and architecture choice to immutable, hash-verified artifacts.

The kernel remains sourced from `AirysDark/linux` at the exact commit pinned by ADOS. Installation downloads prebuilt release components; it does not compile Linux on the Raspberry Pi.

## USB boot constraints

USB boot capability must be checked/documented per supported board. Raspberry Pi 3 Model B systems that are not already configured for USB mass-storage boot may require a one-time boot configuration step before the universal USB installer can start. The installer project must not assume factory-state Pi 3B boards can all boot USB directly.

## Safety requirements

- Never install to the live installer device.
- Require an explicit destination selection/confirmation before destructive writes.
- Reject artifacts whose digest/signature does not match the release manifest.
- Refuse unsupported or ambiguous hardware rather than selecting the closest profile.
- Preserve the distinction between the Pi 3B+ and Frankenstein profiles.
- Record enough installation metadata to reproduce the installed system.
