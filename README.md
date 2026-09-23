# ADOS

**ADOS** is a custom Linux-based operating system for Raspberry Pi hardware.

## Initial hardware targets

| Board | ARM32 | ARM64 |
|---|---|---|
| Raspberry Pi 3 Model B | Yes | Yes |
| Raspberry Pi 3 Model B+ | Yes | Yes |
| Raspberry Pi 3 silicon/component variants | Yes | Yes |
| Raspberry Pi 4 Model B | Yes | Yes |

ARM32 and ARM64 are first-class targets and use separate userlands.

## Project goals

- Reproducible bootable SD-card images
- Raspberry Pi 3/3B+/4 support
- Runtime hardware identification
- 32-bit ARMv7 and 64-bit AArch64 builds
- Linux kernel and Raspberry Pi hardware support
- ADOS-owned root filesystem, startup, services and configuration
- Ethernet, Wi-Fi, Bluetooth, USB and HDMI support
- GPIO, SPI, I2C and UART support
- Future ADOS graphical desktop and applications
- Automated GitHub Actions image builds

## Planned build targets

```text
ados_rpi3_32
ados_rpi3_64
ados_rpi3bplus_32
ados_rpi3bplus_64
ados_rpi4_32
ados_rpi4_64
```

Expected release artifacts:

```text
ADOS-RPi3-arm32.img.xz
ADOS-RPi3-arm64.img.xz
ADOS-RPi3BPlus-arm32.img.xz
ADOS-RPi3BPlus-arm64.img.xz
ADOS-RPi4-arm32.img.xz
ADOS-RPi4-arm64.img.xz
```

## Development roadmap

### Phase 1 — Bootable base
Build system, kernel, boot files, root filesystem, serial console and hardware detection.

### Phase 2 — Hardware and networking
USB, storage, Ethernet, Wi-Fi, Bluetooth, GPIO, SPI, I2C and UART.

### Phase 3 — ADOS system layer
ADOS init/startup integration, system services, configuration, updater and package/application infrastructure.

### Phase 4 — Graphics
Display stack, compositor/windowing foundation and input.

### Phase 5 — ADOS desktop
Desktop shell, launcher, taskbar, notifications, settings and file manager.

### Phase 6 — Applications and releases
Core ADOS applications, installer/update system, release images and automated testing.

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
├── system/
│   ├── init/
│   ├── hardware/
│   ├── network/
│   └── services/
├── packages/
├── desktop/
├── apps/
├── scripts/
└── .github/workflows/
```

## Status

Early development. The first objective is a minimal bootable ADOS image before adding the graphical desktop.
