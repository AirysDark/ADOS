# ADOS OS integration

The portable display subsystem is part of the ADOS root filesystem.

Installed paths:
- `/etc/ados/portable.conf`
- `/usr/bin/ados-portable`
- `/usr/bin/ados-portabled` (daemon implementation)
- `/etc/init.d/S45ados-portable`
- `/var/lib/ados/portable/`

ADOS currently uses Buildroot/SysV-style init, so `ados-portabled.service` remains reference material for a future systemd configuration. The active ADOS image starts the portable subsystem through `S45ados-portable`.

The daemon must implement APDP, continuous BLE discovery/control, authenticated provisioning, Wi-Fi session creation/recovery, and terminal/touch transport without requiring a desktop.
