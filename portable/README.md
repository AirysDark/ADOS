# ADOS Portable Display

## SOURCE OF TRUTH / CHAT HANDOFF

**`ADOS/portable/` is the canonical source of truth for the entire ADOS Portable subsystem.**

Portable development owns this directory. Do not duplicate portable source under `board/`, `system/`, `packages/` or another OS directory, and do not modify the ADOS OS build system from portable work.

The ADOS OS/build work is maintained separately and already consumes changes from `portable/`. Every committed portable change is intended to flow into later ADOS images automatically. See `rpi/INTEGRATION.md` for the integration contract.

If continuing this work in another chat: **work inside `portable/` only unless the user explicitly changes that boundary.**

## Goal

Turn the NV3047 / Elecrow CrowPanel 4.3-inch ESP32-S3 device into the dedicated wireless portable touchscreen/terminal for ADOS Raspberry Pi systems.

Bluetooth is the always-available discovery, bonding, provisioning and recovery/control plane. A private Wi-Fi connection is created for higher-bandwidth display/input transport.

## Hardware and software baseline

### NV3047 portable device
- Elecrow CrowPanel 4.3-inch / DIS06043H class hardware
- ESP32-S3
- NV3047 RGB display, 480 x 272 RGB565
- XPT2046 SPI touch
- touch coordinates calibrated by `NV3047_drivers` to X 0..479 / Y 0..271
- QSPI PSRAM
- 6 MHz display pixel clock in the existing driver stack
- **Arduino-ESP32 2.0.17 is the required baseline**
- ESP-IDF generation: 4.4.7-based Arduino SDK

Do **not** casually migrate this project to Arduino-ESP32 3.x. Any migration requires separate hardware validation.

Existing stack:

```text
NV3047-Core
    ↓
NV3047_drivers
    ↓
NV3047_memorymanager
    ↓
NV3047_UI
    ↓
ADOS Portable firmware
```

Reuse these projects rather than reimplementing their low-level display/touch/memory functionality.

### ADOS host
Targets Raspberry Pi 3/3B/3B+, the special Pi 3B hardware using the Pi 3B+ CPU/GPU variant, and Raspberry Pi 4. ADOS is terminal-first/headless; portable must not require a desktop environment.

## Connection architecture

```text
NV3047 ESP32-S3                         ADOS Raspberry Pi
       │                                      │
       │──── continuous BLE scan ────────────>│
       │<── ADOS Portable advertisement ─────│
       │──── connect / bond ─────────────────>│
       │<── encrypted provisioning ──────────│
       │     SSID / WPA2 PSK / channel        │
       │     host / APDP port                 │
       │     session ID / session token       │
       │~~~~ private Wi-Fi connection ~~~~~~~>│
       │<====== APDP display/terminal =========│
       │======= APDP touch/input =============>│
       │──── BLE remains connected ──────────>│
```

Bluetooth does **not** stop after Wi-Fi connects. ADOS remains available for discovery/reconnection and the active NV3047 keeps BLE as its control/recovery plane. If either link fails, the NV3047 returns to discovery/recovery.

## Implemented so far

### Raspberry Pi
`portable/rpi/ados-portabled`:
- generates random per-session display SSID, WPA2 PSK and APDP session credentials;
- creates private virtual AP interface `ados0`;
- keeps normal `wlan0` separate;
- attempts to align the AP channel with the active parent Wi-Fi channel;
- configures ADOS as `10.77.0.1/30`;
- starts hostapd;
- supervises/restarts the BLE GATT helper.

`portable/rpi/ados-portable-gatt`:
- BlueZ GATT peripheral;
- continuous ADOS Portable advertisement;
- headless BlueZ bonding agent;
- encrypted-read provisioning characteristic;
- status characteristic;
- remains registered while Wi-Fi is active.

Expected runtime dependencies: BlueZ, hostapd, iw, iproute2, Python 3 and python3-dbus-next.

### NV3047 / ESP32-S3
`portable/arduino/ADOSPortable/ADOSPortable.ino`:
- Arduino-ESP32 2.0.17 baseline;
- initializes the existing NV3047 driver;
- continuously scans for the ADOS service UUID;
- connects to the ADOS GATT server;
- requests bonded/encrypted BLE operation;
- reads Wi-Fi/APDP provisioning;
- joins the private Wi-Fi;
- keeps BLE connected while Wi-Fi is active;
- returns to scanning after Bluetooth or Wi-Fi failure;
- has the touch polling point ready for APDP transmission.

## BLE identifiers

```text
Service:      30470000-ad05-4000-8000-000000000001
Provisioning: 30470000-ad05-4000-8000-000000000002
Status:       30470000-ad05-4000-8000-000000000003
```

Provisioning supplies protocol version, SSID, PSK, channel, ADOS address, APDP port, session ID and session token.

## Private Wi-Fi

```text
parent Wi-Fi: wlan0
private AP:   ados0
ADOS:         10.77.0.1/30
APDP TCP:     3047
SSID prefix:  _ADOS-DISP-
security:     WPA2-PSK + independent APDP session authentication
```

A Pi exposes virtual Wi-Fi interfaces over one physical radio, not two independent radios. Concurrent STA+AP operation therefore has firmware/channel constraints. The daemon deliberately fails if `ados0` cannot be created instead of silently taking over normal `wlan0`. A hidden SSID is not a security mechanism.

## APDP

APDP means ADOS Portable Display Protocol. BLE handles discovery/control/provisioning; Wi-Fi carries APDP.

The 480 x 272 RGB565 framebuffer is 261,120 bytes per complete frame, so prefer terminal/UI commands, cell/region deltas and dirty framebuffer regions instead of blindly streaming full frames. See `protocol/APDP.md`.

## Directory

```text
portable/
├── README.md
├── arduino/
│   ├── README.md
│   └── ADOSPortable/
│       └── ADOSPortable.ino
├── protocol/
│   └── APDP.md
└── rpi/
    ├── INTEGRATION.md
    ├── README.md
    ├── ados-portabled
    ├── ados-portable-gatt
    ├── ados-portabled.service
    └── portable.conf.example
```

## Still to implement

1. APDP TCP server on Raspberry Pi.
2. APDP TCP client on ESP32-S3.
3. Authenticate APDP using the BLE-provisioned token.
4. HELLO/capability negotiation.
5. Heartbeat, sequencing, timeout and reconnection.
6. Terminal/UI rendering through NV3047_UI, NV3047_memorymanager and NV3047_drivers.
7. Touch down/move/up transmission back to ADOS.
8. Terminal-oriented updates and dirty regions.
9. Performance/latency statistics.
10. Portable CI including an Arduino-ESP32 **2.0.17** compile check.
11. Physical BLE/GATT, bonding, STA+AP and end-to-end validation on supported hardware.

## Validation status

**Do not describe the connection stack as hardware-verified yet.** Repository implementation exists, but exact BlueZ behavior, bonding, concurrent hostapd operation, Arduino compilation against the exact NV3047 libraries, and end-to-end Pi/CrowPanel operation still require real hardware/build validation.

When a test fails, fix the implementation under `portable/`; do not work around it by modifying unrelated ADOS OS source.

## Rules for future chats

1. `portable/` is the source of truth.
2. Portable work does not own the OS build.
3. ESP32-S3 stays on Arduino-ESP32 2.0.17.
4. ADOS Bluetooth discovery remains continuously available.
5. BLE handles discovery/provisioning/recovery.
6. Private Wi-Fi handles high-bandwidth portable traffic.
7. BLE remains available after Wi-Fi connects.
8. Reuse the existing NV3047 Core/driver/memory/UI projects.
9. Do not silently destroy normal Pi networking to create the display link.
10. Require hardware validation before claiming on-device success.
