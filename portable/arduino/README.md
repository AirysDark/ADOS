# NV3047 Arduino client

Target: Elecrow CrowPanel DIS06043H / ESP32-S3.

## Required baseline
- NV3047-Core
- Arduino-ESP32 **2.0.17**
- NV3047_drivers
- NV3047_memorymanager
- NV3047_UI
- QSPI PSRAM

Do not migrate this client to Arduino-ESP32 3.x without a separate hardware validation branch.

## Responsibilities
- scan continuously for the ADOS Portable BLE service while disconnected;
- connect only to an authenticated/trusted ADOS host;
- receive private Wi-Fi session provisioning over BLE;
- join the ADOS private Wi-Fi network;
- maintain the APDP Wi-Fi session;
- render received UI/display data through the existing NV3047 stack;
- send calibrated XPT2046 touch events back to ADOS;
- automatically recover from BLE or Wi-Fi loss.

The firmware skeleton is in ADOSPortable/ADOSPortable.ino.
