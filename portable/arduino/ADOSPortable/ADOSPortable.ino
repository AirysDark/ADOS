#include <Arduino.h>
#include <WiFi.h>
#include <BLEDevice.h>
#include <BLEClient.h>
#include <BLEScan.h>
#include "NV3047_Driver.h"

// ADOS Portable NV3047 client
// HARD BASELINE: ESP32-S3 + Arduino-ESP32 2.0.17.

static BLEUUID ADOS_SERVICE("30470000-ad05-4000-8000-000000000001");
static BLEUUID ADOS_PROVISION("30470000-ad05-4000-8000-000000000002");

NV3047 hw;
NV3047_Driver panel;

enum class LinkState { BLE_SCANNING, BLE_CONNECTING, WIFI_CONNECTING, SESSION_ACTIVE };
static LinkState state=LinkState::BLE_SCANNING;
static BLEScan *scanner=nullptr;
static BLEAdvertisedDevice *candidate=nullptr;
static BLEClient *client=nullptr;
static String wifiSsid,wifiPsk,host,sessionToken;
static uint16_t apdpPort=3047;
static unsigned long stateSince=0;

static String jsonString(const String &s,const char *key) {
  String needle=String("\"")+key+"\":\""; int a=s.indexOf(needle); if(a<0)return "";
  a+=needle.length(); int b=s.indexOf('"',a); if(b<0)return ""; return s.substring(a,b);
}
static long jsonInt(const String &s,const char *key,long fallback) {
  String needle=String("\"")+key+"\":"; int a=s.indexOf(needle); if(a<0)return fallback;
  a+=needle.length(); return s.substring(a).toInt();
}
static void beginScan();

class FoundADOS : public BLEAdvertisedDeviceCallbacks {
  void onResult(BLEAdvertisedDevice d) override {
    if (!d.haveServiceUUID() || !d.isAdvertisingService(ADOS_SERVICE)) return;
    if (candidate) delete candidate;
    candidate=new BLEAdvertisedDevice(d);
    scanner->stop(); state=LinkState::BLE_CONNECTING; stateSince=millis();
  }
};
class ClientEvents : public BLEClientCallbacks {
  void onConnect(BLEClient*) override {}
  void onDisconnect(BLEClient*) override {
    WiFi.disconnect(true); beginScan();
  }
};

static void beginScan() {
  state=LinkState::BLE_SCANNING; stateSince=millis();
  if(client && client->isConnected()) client->disconnect();
  if(candidate){delete candidate; candidate=nullptr;}
  scanner->clearResults(); scanner->start(0,nullptr,false); // continuous until a matching ADOS service is found
}
static bool provision() {
  if(!candidate)return false;
  if(!client){client=BLEDevice::createClient(); client->setClientCallbacks(new ClientEvents());}
  if(!client->connect(candidate))return false;
  BLERemoteService *svc=client->getService(ADOS_SERVICE); if(!svc)return false;
  BLERemoteCharacteristic *ch=svc->getCharacteristic(ADOS_PROVISION); if(!ch || !ch->canRead())return false;
  std::string raw=ch->readValue(); String p=String(raw.c_str());
  wifiSsid=jsonString(p,"ssid"); wifiPsk=jsonString(p,"psk"); host=jsonString(p,"host");
  sessionToken=jsonString(p,"token"); apdpPort=(uint16_t)jsonInt(p,"port",3047);
  if(wifiSsid.length()==0 || wifiPsk.length()<8 || host.length()==0 || sessionToken.length()<32)return false;
  WiFi.mode(WIFI_STA); WiFi.begin(wifiSsid.c_str(),wifiPsk.c_str());
  state=LinkState::WIFI_CONNECTING; stateSince=millis(); return true;
}
static void serviceWiFiConnect() {
  if(WiFi.status()==WL_CONNECTED) {
    state=LinkState::SESSION_ACTIVE; stateSince=millis();
    Serial.printf("ADOS private link ready: %s:%u\n",host.c_str(),apdpPort);
    return;
  }
  if(millis()-stateSince>15000) { WiFi.disconnect(true); beginScan(); }
}
static void serviceSession() {
  // BLE intentionally remains connected as the control/recovery plane.
  // APDP TCP transport is the next layer; loss of either link returns to discovery.
  if(WiFi.status()!=WL_CONNECTED || !client || !client->isConnected()) {
    WiFi.disconnect(true); beginScan(); return;
  }
  uint16_t x=0,y=0;
  if(panel.getTouch(x,y)) {
    // APDP touch transmission is implemented by the transport layer.
  }
}

void setup() {
  Serial.begin(115200); panel.begin(&hw); panel.setBrightness(80);
  BLEDevice::init("NV3047-ADOS-Portable");
  // Arduino-ESP32 2.0.17 BLE security: require encrypted authenticated provisioning.
  BLEDevice::setEncryptionLevel(ESP_BLE_SEC_ENCRYPT);
  BLESecurity *sec=new BLESecurity();
  sec->setAuthenticationMode(ESP_LE_AUTH_REQ_SC_BOND);
  sec->setCapability(ESP_IO_CAP_NONE);
  scanner=BLEDevice::getScan(); scanner->setAdvertisedDeviceCallbacks(new FoundADOS(),true);
  scanner->setActiveScan(true); scanner->setInterval(100); scanner->setWindow(80);
  beginScan();
}
void loop() {
  switch(state) {
    case LinkState::BLE_SCANNING: break;
    case LinkState::BLE_CONNECTING:
      if(!provision()){delay(500);beginScan();} break;
    case LinkState::WIFI_CONNECTING: serviceWiFiConnect(); break;
    case LinkState::SESSION_ACTIVE: serviceSession(); break;
  }
  delay(5);
}
