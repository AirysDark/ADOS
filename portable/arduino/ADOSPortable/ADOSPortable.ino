#include <Arduino.h>
#include <WiFi.h>
#include <BLEDevice.h>
#include <BLEScan.h>
#include "NV3047_Driver.h"

// ADOS Portable client skeleton.
// Baseline: ESP32-S3 / Arduino-ESP32 2.0.17.
// Display/touch remain owned by the existing NV3047 libraries.

static const char *ADOS_SERVICE_UUID = "30470000-ad05-4000-8000-000000000001";

NV3047 hw;
NV3047_Driver panel;

enum class LinkState {
  BLE_SCANNING,
  BLE_CONNECTING,
  WIFI_CONNECTING,
  SESSION_ACTIVE
};

static LinkState state = LinkState::BLE_SCANNING;
static BLEScan *scanner = nullptr;

static void startBleScan() {
  state = LinkState::BLE_SCANNING;
  scanner->setActiveScan(true);
  scanner->setInterval(100);
  scanner->setWindow(80);
  // Short repeated scans keep the main loop responsive and make discovery persistent.
  scanner->start(2, false);
}

static void serviceDiscovery() {
  // TODO: inspect scan results for ADOS_SERVICE_UUID, authenticate/bond,
  // connect to the provisioning GATT service and obtain ephemeral Wi-Fi
  // credentials + APDP session token.
  if (!scanner->isScanning()) {
    scanner->clearResults();
    startBleScan();
  }
}

static void serviceSession() {
  // TODO: maintain Wi-Fi/APDP session, receive display updates and send touch.
  // On loss: disconnect Wi-Fi, discard ephemeral credentials and return to BLE scan.
  if (WiFi.status() != WL_CONNECTED) {
    WiFi.disconnect(true);
    startBleScan();
  }
}

void setup() {
  Serial.begin(115200);
  panel.begin(&hw);
  panel.setBrightness(80);

  BLEDevice::init("NV3047-ADOS-Portable");
  scanner = BLEDevice::getScan();
  startBleScan();
}

void loop() {
  switch (state) {
    case LinkState::BLE_SCANNING:
      serviceDiscovery();
      break;
    case LinkState::BLE_CONNECTING:
    case LinkState::WIFI_CONNECTING:
      // Provisioning state machine is implemented next.
      break;
    case LinkState::SESSION_ACTIVE:
      serviceSession();
      break;
  }
  delay(5);
}
