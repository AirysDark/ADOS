# ADOS

**ADOS** is a custom, terminal-first Linux operating system for Raspberry Pi hardware.

ADOS deliberately has no desktop environment, X11 or Wayland user session. HDMI output is a text console. Remote administration is provided through SSH.

## Hardware and architecture targets

| Board | ARM32 | ARM64 |
|---|---|---|
| Raspberry Pi 3 Model B | Yes | Yes |
| Raspberry Pi Frankenstein (Pi 3B PCB + BCM2837B0-generation SoC) | Yes | Yes |
| Raspberry Pi 3 Model B+ | Yes | Yes |
| Raspberry Pi 3 silicon/component variants | Yes | Yes |
| Raspberry Pi 4 Model B | Yes | Yes |

ARM32 and ARM64 are first-class targets with separate userlands.

## ADOS kernel

ADOS builds and maintains its own Raspberry Pi Linux kernel configuration and ADOS patch set. Kernel source is the ADOS-owned `AirysDark/linux` repository. The current build tracks the `rpi-6.12.y` line and is pinned to commit `43c132e8863c3bff3647033b6a7d2bf87b15501c` for reproducibility.

The kernel strategy is:

1. Track a suitable Raspberry Pi/Linux kernel source.
2. Apply ADOS-owned patches.
3. Apply board/architecture-specific ADOS kernel configurations.
4. Build the kernel, modules and DTBs as part of the ADOS image build.
5. Identify ADOS kernels with an ADOS local version suffix.

The project does not intend to rewrite Linux from scratch. ADOS owns the configuration, integration and patches while retaining the mature Linux/Raspberry Pi hardware foundation.

## Core goals

- One universal user-facing USB installer with automatic hardware detection
- Reproducible per-target build artifacts
- Custom ADOS kernel build
- Terminal-only userspace
- Raspberry Pi 3B, 3B+, Frankenstein and Pi 4 support
- Runtime hardware/revision identification
- ARMv7 32-bit and AArch64 64-bit builds
- ADOS root filesystem, startup and services
- HDMI text console and UART serial console
- Ethernet, Wi-Fi, Bluetooth and SSH
- USB and storage
- GPIO, SPI, I2C and UART
- ADOS command-line administration tools
- Automated GitHub Actions builds

## Universal USB installer

The user-facing installation path is a single `ADOS-Installer.img.xz` image written to USB. On boot it detects Raspberry Pi 3B, Raspberry Pi 3B+, Raspberry Pi Frankenstein, or Raspberry Pi 4 hardware, then retrieves and verifies the matching prebuilt ADOS release components. See `installer/README.md` for the detection and installation contract.

The per-board ARM32/ARM64 targets below remain the engineering/CI matrix and are not intended to require users to choose among eight installer images.

## Build targets

```text
ados_rpi3_32
ados_rpi3_64
ados_rpi3b_b0_32
ados_rpi3b_b0_64
ados_rpi3bplus_32
ados_rpi3bplus_64
ados_rpi4_32
ados_rpi4_64
```

Expected artifacts:

```text
ADOS-RPi3-arm32.img.xz
ADOS-RPi3-arm64.img.xz
ADOS-rpi3b-b0-32.img.xz
ADOS-rpi3b-b0-64.img.xz
ADOS-RPi3BPlus-arm32.img.xz
ADOS-RPi3BPlus-arm64.img.xz
ADOS-RPi4-arm32.img.xz
ADOS-RPi4-arm64.img.xz
```

## Repository layout

```text
ADOS/
├── configs/
├── board/
│   └── raspberrypi/
│       ├── common/
│       ├── rpi3/
│       ├── rpi3bplus/
│       └── rpi4/
├── kernel/
│   ├── configs/
│   └── patches/
├── system/
│   ├── init/
│   ├── hardware/
│   ├── network/
│   └── services/
├── cli/
├── packages/
├── installer/              # universal USB installer and release manifest tooling
├── portable/               # canonical ADOS Portable subsystem source
├── scripts/
└── .github/workflows/
```

## ADOS Portable

`portable/` is the canonical source of truth for the ADOS Portable subsystem. It targets the NV3047/CrowPanel ESP32-S3 as a portable ADOS touchscreen/terminal. Bluetooth is used for discovery, bonding, provisioning, recovery and control; a private Wi-Fi link is used for higher-bandwidth display/input traffic. The ADOS image consumes the Portable runtime from this directory rather than maintaining a duplicate implementation elsewhere in the OS tree.

Current OS integration includes BlueZ, hostapd, `iw`, `iproute2`, Python 3, `dbus-next`, the Portable daemon/GATT helper, ADOS networking ownership, and boot-time service integration. APDP display/input transport and physical end-to-end hardware validation remain development work.

## Build and release integrity

ADOS uses Buildroot as build machinery while ADOS owns its root filesystem, startup/services, configuration, CLI, kernel configuration and patches. Kernel source is pinned to an immutable commit. Generated image artifacts are SHA-256 verified by CI. The universal installer release manifest is designed to carry per-artifact SHA-256 digests and exact kernel provenance.

## Roadmap

### Phase 1 — Bootable terminal base
Build system, cross-toolchain, ADOS kernel, boot files, minimal root filesystem, HDMI/serial console and hardware detection.

### Phase 2 — Hardware and networking
USB, storage, Ethernet, Wi-Fi, Bluetooth, GPIO, SPI, I2C, UART and SSH.

### Phase 3 — ADOS system layer
ADOS startup, services, logging, configuration and command-line administration.

### Phase 4 — Update/package infrastructure
Kernel/system update tooling and ADOS package infrastructure.

### Phase 5 — Universal USB installer and releases
Build `ADOS-Installer.img.xz`, automatic 3B/3B+/Frankenstein/4 detection, release manifests, verified component downloads, automated ARM32/ARM64 builds, checksums, boot testing and release artifacts.

## Current development status

ADOS is in active development and is not yet declared hardware-verified or release-ready. The eight-target CI matrix is currently validating the pinned custom-kernel build path after removing Buildroot's forced upstream-archive hash requirement for the custom Git kernel. GitHub Actions run #52 is still in progress, so no successful bootable image is claimed yet.

The current workstreams are:

- complete and validate all eight ARM32/ARM64 engineering builds;
- build the universal USB installer around the four physical hardware profiles;
- generate release manifests automatically from verified CI artifacts;
- complete ADOS Portable APDP transport and hardware validation;
- perform physical boot, networking, Bluetooth, Portable and installer testing on supported Raspberry Pi hardware.
