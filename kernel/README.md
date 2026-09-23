# ADOS Kernel

ADOS uses a custom-built Linux kernel for its Raspberry Pi targets.

## Policy

- Kernel source is selected explicitly by the ADOS build.
- ADOS maintains its own kernel configurations.
- ADOS-specific source changes are maintained as patches.
- ARM32 and ARM64 configurations are kept distinct.
- Board-specific differences are isolated where required.
- Kernel local version is `-ados`.
- Kernel, modules and device trees are built reproducibly with the OS image.

## Targets

- Raspberry Pi 3 Model B — ARM32 / ARM64
- Raspberry Pi 3 Model B+ — ARM32 / ARM64
- Raspberry Pi 3 silicon/component variants — detected from board revision/device tree
- Raspberry Pi 4 Model B — ARM32 / ARM64

Do not assume a board model solely from the SoC package. ADOS hardware detection uses firmware/device-tree and revision information.
