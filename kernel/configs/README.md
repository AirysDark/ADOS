# ADOS Kernel Configurations

ADOS owns its kernel configuration fragments.

Configuration families:

```text
ados-common.config
ados-rpi3b-b0.config
```

The dedicated `rpi3b-b0` target is for the unusual Raspberry Pi 3 Model B PCB fitted with a BCM2837B0-class SoC. It intentionally starts from the Pi 3 Model B platform configuration rather than pretending the complete board is a Pi 3B+.

ADOS keeps ARM32 and ARM64 as separate userlands/build targets. Board revision, device tree and detected SoC information are retained separately so mixed/component-substitution boards can be diagnosed rather than being classified from one identifier.
