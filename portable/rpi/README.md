# ADOS Raspberry Pi portable-display side

The Pi-side runtime is `ados-portabled` plus `ados-portable-gatt`.

## Implemented connection layer
- starts automatically when installed by ADOS;
- continuously advertises the ADOS Portable BLE service through BlueZ;
- supplies a headless BlueZ bonding agent for the NV3047;
- generates random per-daemon-session Wi-Fi SSID, WPA2 PSK and APDP token;
- exposes provisioning only through an encrypted BLE GATT characteristic;
- creates `ados0` as a virtual AP interface over the configured parent radio;
- keeps the normal `wlan0` station interface separate;
- aligns the AP channel to the parent Wi-Fi channel when one is active;
- runs the private network at 10.77.0.1/30;
- restarts BLE advertising automatically if the GATT helper exits.

The NV3047 remains connected to BLE after Wi-Fi comes up. BLE is the discovery/control/recovery plane; Wi-Fi is the display/input data plane.

## Runtime requirements
- BlueZ
- hostapd
- iw
- iproute2
- Python 3
- python3-dbus-next

## Files
- `ados-portabled` - session/AP supervisor
- `ados-portable-gatt` - BlueZ GATT advertisement, provisioning and pairing agent
- `portable.conf.example` - portable runtime configuration
- `ados-portabled.service` - systemd reference configuration
- `INTEGRATION.md` - OS-owned integration contract; portable code does not modify the OS build

## Raspberry Pi radio constraint
Pi 3/3B/3B+/4 concurrency is one physical Wi-Fi radio with virtual interfaces, not two independent radios. Concurrent STA+AP operation can therefore be firmware/channel constrained. The portable daemon fails explicitly if `ados0` cannot be created instead of silently taking over normal `wlan0`.

Hardware validation on each supported Pi model is still required.
