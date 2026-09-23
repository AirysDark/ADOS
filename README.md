# ADOS

**ADOS** is a custom, terminal-first Linux operating system for Raspberry Pi hardware.

ADOS deliberately has no desktop environment, X11 or Wayland user session. HDMI output is a text console. Remote administration is provided through SSH.

## Hardware and architecture targets

| Board | ARM32 | ARM64 |
|---|---|---|
| Raspberry Pi 3 Model B | Yes | Yes |
| Raspberry Pi 3 Model B + BCM2837B0 SoC | Yes | Yes |
| Raspberry Pi 3 Model B+ | Yes | Yes |
| Raspberry Pi 3 silicon/component variants | Yes | Yes |
| Raspberry Pi 4 Model B | Yes | Yes |

ARM32 and ARM64 are first-class targets with separate userlands.

## ADOS kernel

ADOS builds and maintains its own Raspberry Pi Linux kernel configuration and ADOS patch set.

The kernel strategy is:

1. Track a suitable Raspberry Pi/Linux kernel source.
2. Apply ADOS-owned patches.
3. Apply board/architecture-specific ADOS kernel configurations.
4. Build the kernel, modules and DTBs as part of the ADOS image build.
5. Identify ADOS kernels with an ADOS local version suffix.

The project does not intend to rewrite Linux from scratch. ADOS owns the configuration, integration and patches while retaining the mature Linux/Raspberry Pi hardware foundation.

## Core goals

- Reproducible bootable SD-card images
- Custom ADOS kernel build
- Terminal-only userspace
- Raspberry Pi 3/3B+/4 support
- Runtime hardware/revision identification
- ARMv7 32-bit and AArch64 64-bit builds
- ADOS root filesystem, startup and services
- HDMI text console and UART serial console
- Ethernet, Wi-Fi, Bluetooth and SSH
- USB and storage
- GPIO, SPI, I2C and UART
- ADOS command-line administration tools
- Automated GitHub Actions builds

## Planned targets

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
├── scripts/
└── .github/workflows/
```

## Roadmap

### Phase 1 — Bootable terminal base
Build system, cross-toolchain, ADOS kernel, boot files, minimal root filesystem, HDMI/serial console and hardware detection.

### Phase 2 — Hardware and networking
USB, storage, Ethernet, Wi-Fi, Bluetooth, GPIO, SPI, I2C, UART and SSH.

### Phase 3 — ADOS system layer
ADOS startup, services, logging, configuration and command-line administration.

### Phase 4 — Update/package infrastructure
Kernel/system update tooling and ADOS package infrastructure.

### Phase 5 — Releases and testing
Automated ARM32/ARM64 images, checksums, boot testing and release artifacts.

## Status

Early development. The immediate objective is a minimal bootable ADOS terminal image using an ADOS-built kernel.
