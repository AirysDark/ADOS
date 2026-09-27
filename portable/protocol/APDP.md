# APDP - ADOS Portable Display Protocol

Status: design baseline.

APDP separates discovery/control from high-bandwidth transport.

## BLE plane
BLE is always available for discovery/reconnection on ADOS. The NV3047 scans whenever it has no valid session.

BLE carries:
- protocol version/capabilities;
- host/device identity;
- pairing/bonding;
- Wi-Fi session provisioning;
- random session token;
- link status and recovery control.

Do not transmit reusable Wi-Fi credentials before an authenticated encrypted BLE relationship exists.

## Wi-Fi plane
The private Wi-Fi link carries:
- terminal/UI commands;
- dirty framebuffer regions where required;
- touch/input events;
- status/telemetry;
- heartbeats.

Initial network:
- ADOS: 10.77.0.1
- NV3047: 10.77.0.2
- APDP TCP: 3047

## Display capabilities
NV3047 advertises:
- width: 480
- height: 272
- pixel format: RGB565
- touch range: X 0..479, Y 0..271
- PSRAM capability
- APDP protocol version

A raw RGB565 frame is 261120 bytes, so APDP should prefer UI/terminal commands and dirty regions rather than continuous full-frame transmission.

## Recovery
Loss of Wi-Fi does not unpair the devices. The NV3047 returns to BLE discovery; ADOS continues advertising and can provision a new ephemeral Wi-Fi session.

## Security
A hidden SSID is only a convenience/privacy feature, not a security boundary. Each session should use a randomly generated Wi-Fi PSK and independent APDP session token. Long-term trust is established through BLE bonding/authentication.
