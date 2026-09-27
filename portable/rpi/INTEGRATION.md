# ADOS OS integration

The root `portable/` directory is the **source of truth** for the ADOS Portable subsystem.

Every ADOS image build automatically copies the complete current `portable/` tree into:

```text
/usr/share/ados/portable/
```

This means changes to protocol documentation, Arduino firmware, Pi-side code, configuration, and future portable assets are captured by the next OS build without manually duplicating them elsewhere.

## Runtime installation

During the Buildroot post-build stage ADOS also consumes runtime assets from `portable/rpi/`:

- `portable.conf` if present, otherwise `portable.conf.example` -> `/etc/ados/portable.conf`
- `ados-portabled`, when present -> `/usr/bin/ados-portabled`
- `rootfs-overlay/`, when present -> merged into the ADOS root filesystem

The standard ADOS image provides `/usr/bin/ados-portable` and `/etc/init.d/S45ados-portable`.

The Git commit used for the portable snapshot is recorded in `/usr/share/ados/portable-build-commit`.

GitHub Actions watches `portable/**`, so any committed portable change triggers fresh ADOS image builds.

The existing `ados-portabled.service` remains reference material for a future systemd configuration. Current ADOS uses Buildroot/SysV init.
