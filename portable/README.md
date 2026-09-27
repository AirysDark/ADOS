# ADOS Portable Display

ADOS Portable turns the NV3047 / Elecrow CrowPanel 4.3-inch ESP32-S3 device into a wireless portable touchscreen for ADOS.

## Hardware baseline
- ESP32-S3
- NV3047 480x272 RGB565 display
- XPT2046 touch, calibrated to 0..479 x 0..271 by NV3047_drivers
- QSPI PSRAM
- Arduino-ESP32 **2.0.17** / ESP-IDF 4.4.7 generation
- Existing stack: NV3047-Core -> NV3047_drivers -> NV3047_memorymanager -> NV3047_UI

## Connection architecture
1. ADOS continuously advertises the ADOS Portable BLE service.
2. NV3047 continuously scans while disconnected.
3. Devices pair/bond and authenticate.
4. ADOS creates/provisions a private Wi-Fi display session.
5. Wi-Fi credentials and a session token are delivered over the encrypted BLE control channel.
6. NV3047 joins the private Wi-Fi link.
7. Display, terminal and touch traffic moves over Wi-Fi.
8. BLE remains available as the discovery/control/recovery path.
9. If Wi-Fi drops, the portable device returns to discovery/reconnect automatically.

The Wi-Fi SSID may be non-broadcast, but security must not depend on a hidden SSID. Use a strong random PSK plus application session authentication.

See rpi/README.md, arduino/README.md and protocol/APDP.md.
