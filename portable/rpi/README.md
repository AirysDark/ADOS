# ADOS Raspberry Pi portable-display side

The Pi-side daemon is `ados-portabled`.

## Required behaviour
- start automatically at boot;
- keep the ADOS Portable BLE service discoverable/available continuously;
- accept authenticated NV3047 pairing and reconnection;
- provision an ephemeral private Wi-Fi session;
- maintain BLE as the low-bandwidth control/recovery path while Wi-Fi carries display/input traffic;
- automatically recreate a failed session;
- never require a desktop environment.

## Raspberry Pi targets
ADOS targets Pi 3/3B/3B+/4. Wi-Fi concurrency must be treated as a board/firmware capability, not assumed to be two independent radios. AP+STA virtual interfaces share one physical radio and may have channel/concurrency constraints.

The daemon should therefore expose a transport backend so ADOS can support:
- concurrent normal Wi-Fi + private display AP where supported;
- dedicated display AP when normal networking is Ethernet;
- future USB or other transports without changing APDP.

## Proposed installation
- /usr/bin/ados-portabled
- /etc/ados/portable.conf
- /var/lib/ados/portable/
- ados-portabled.service

See ados-portabled.service and portable.conf.example.
