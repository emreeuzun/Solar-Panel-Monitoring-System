#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <PubSubClient.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);

// UART2 pinleri
#define RXD2 16
#define TXD2 17

// LoRa Modülü için M0-M1 pinleri
#define M0  5
#define M1  18

// WiFi ve ThingSpeak bilgileri
const char* ssid = "Galaxy A21sE088";
const char* password = "antalya12345";
const char* thingSpeakURL = "http://api.thingspeak.com/update?api_key=DCA93XKSSTY3LEJX";

// MQTT bilgileri
const char* mqtt_server = "broker.hivemq.com";
const int mqtt_port = 1883;
const char* mqtt_topic = "panel/veri";

// MQTT Client tanımı
WiFiClient espClient;
PubSubClient client(espClient);

// Zamanlayıcı
unsigned long lastMsg = 0;
const long interval = 2000; // 2 saniyede bir veri gönderimi

typedef struct {
  float cur;
  float temp;
  float nem;
  float volt;
} DataPacket;

DataPacket receivedData;

// Fonksiyonlar
void setup_wifi();
void reconnect();
void sendToThingSpeak(DataPacket data);
void sendToMQTT(DataPacket data);
void clearSerialBuffer();

void setup() {
  pinMode(M0, OUTPUT);
  pinMode(M1, OUTPUT);
  digitalWrite(M0, LOW);
  digitalWrite(M1, LOW);

  Serial.begin(9600);
  Serial2.begin(9600, SERIAL_8N1, RXD2, TXD2);
  lcd.begin();
  lcd.display();

  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);

  receivedData = {0.0, 0.0, 0.0, 0.0};
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  if (Serial2.available() >= sizeof(DataPacket) + 2) {
    uint8_t startByte;
    Serial2.readBytes(&startByte, 1);
    if (startByte != 0xAA) {
      clearSerialBuffer();
      return;
    }

    uint8_t rawData[sizeof(DataPacket)];
    Serial2.readBytes(rawData, sizeof(DataPacket));

    uint8_t endByte;
    Serial2.readBytes(&endByte, 1);
    if (endByte != 0xBB) {
      clearSerialBuffer();
      return;
    }

    Serial.print("Start: 0x"); Serial.println(startByte, HEX);

    for (int i = 0; i < sizeof(DataPacket); i++) {
    Serial.print("0x");
    if (rawData[i] < 0x10) Serial.print("0");
    Serial.print(rawData[i], HEX);
    Serial.print(" ");
    }
    Serial.print("End: 0x"); Serial.println(endByte, HEX);

    memcpy(&receivedData, rawData, sizeof(DataPacket));

    //if (receivedData.cur < -1000 || receivedData.cur > 1000) receivedData.cur = 0;
    if (receivedData.nem < 0 || receivedData.nem > 100) receivedData.nem = 0;



Serial.println();

    // LCD'ye yazdır
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("A: "); lcd.print(receivedData.cur, 2);
    lcd.print(" T: "); lcd.print(receivedData.temp, 2);
    lcd.setCursor(0, 1);
    lcd.print("N: "); lcd.print(receivedData.nem, 2);
    lcd.print(" V:"); lcd.print(receivedData.volt, 2);

    // MQTT ve ThingSpeak gönderimi
    sendToThingSpeak(receivedData);
    sendToMQTT(receivedData);
  }

  delay(interval);
}

void setup_wifi() {
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi bağlandı!");
  Serial.print("IP adresi: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("MQTT bağlantısı kuruluyor...");
    String clientId = "ESP32Client-";
    clientId += String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("Bağlandı.");
    } else {
      Serial.print("Başarısız. Hata kodu: ");
      Serial.println(client.state());
      delay(2000);
    }
  }
}

void sendToThingSpeak(DataPacket data) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String url = String(thingSpeakURL) +
                 "&field1=" + String(data.temp, 2) +
                 "&field2=" + String(data.nem, 2) +
                 "&field3=" + String(data.volt, 2) +
                 "&field4=" + String(data.cur, 2);
    http.begin(url);
    http.GET();
    http.end();
  }
}

void sendToMQTT(DataPacket data) {
  String payload = "{";
  payload += "\"sicaklik\":" + String(data.temp, 1) + ",";
  payload += "\"nem\":" + String(data.nem, 1) + ",";
  payload += "\"voltaj\":" + String(data.volt, 1) + ",";
  payload += "\"akim\":" + String(data.cur, 2);
  payload += "}";
  client.publish(mqtt_topic, payload.c_str());
}

void clearSerialBuffer() {
  while (Serial2.available()) {
    Serial2.read();
  }
}
