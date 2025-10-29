/*
 * Smart Home ESP8266 Controller
 * MQTT-based smart home automation with DHT sensor
 * Compatible with: College Network (10.217.139.106:1883)
 */

#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>

// WiFi Configuration
const char* ssid = "hotSpot123";           // Change to your WiFi SSID
const char* password = "pass123987";   // Change to your WiFi password

// MQTT Configuration
const char* mqtt_broker = "10.217.139.106";    // MQTT broker IP (College Network)
const int mqtt_port = 1883;
const char* client_id = "ESP8266_Bedroom";     // Unique client ID

// DHT Sensor Configuration
#define DHTPIN D4        // GPIO 4 (D4) for DHT sensor
#define DHTTYPE DHT22    // DHT22 sensor type
DHT dht(DHTPIN, DHTTYPE);

// Relay Pins (NodeMCU ESP8266 GPIO mapping)
#define LIGHT_PIN D1     // GPIO 5 (Light relay)
#define FAN_PIN D2       // GPIO 4 (Fan relay)
#define BUZZER_PIN D5    // GPIO 14 (Buzzer relay)

// Device states
bool lightState = false;
bool fanState = false;
bool buzzerState = false;

// MQTT Topics
#define TEMP_TOPIC "bedroom/temperature"
#define HUMIDITY_TOPIC "bedroom/humidity"
#define LIGHT_TOPIC "bedroom/light"
#define FAN_TOPIC "bedroom/fan"
#define BUZZER_TOPIC "bedroom/buzzer"

// Create instances
WiFiClient espClient;
PubSubClient client(espClient);

// Timing variables
unsigned long lastMsg = 0;
unsigned long lastTempRead = 0;
const unsigned long TEMP_READ_INTERVAL = 2000;  // Read temperature every 2 seconds
const unsigned long PUBLISH_INTERVAL = 5000;    // Publish every 5 seconds

void setup() {
  Serial.begin(115200);
  delay(100);
  
  Serial.println("\n\n====================================");
  Serial.println("🏠 Smart Home ESP8266 Starting...");
  Serial.println("====================================\n");
  
  // Initialize pins
  pinMode(LIGHT_PIN, OUTPUT);
  pinMode(FAN_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // Turn off all devices initially
  digitalWrite(LIGHT_PIN, HIGH);   // LOW = ON for common cathode relay
  digitalWrite(FAN_PIN, HIGH);
  digitalWrite(BUZZER_PIN, HIGH);
  
  // Initialize DHT sensor
  dht.begin();
  Serial.println("✅ DHT sensor initialized");
  
  // Connect to WiFi
  setup_wifi();
  
  // Setup MQTT
  client.setServer(mqtt_broker, mqtt_port);
  client.setCallback(callback);
  
  Serial.println("\n✅ Setup complete!");
  Serial.println("📡 Ready to connect to MQTT broker...\n");
}

void setup_wifi() {
  Serial.print("📶 Connecting to WiFi: ");
  Serial.println(ssid);
  
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi connected!");
    Serial.print("📍 IP Address: ");
    Serial.println(WiFi.localIP());
    Serial.print("📡 Signal Strength: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  } else {
    Serial.println("\n❌ WiFi connection failed!");
    Serial.println("⚠️  Check your WiFi credentials");
  }
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("\n📨 Message received on topic: ");
  Serial.print(topic);
  Serial.print(" -> ");
  
  // Convert payload to string
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.println(message);
  
  // Control devices based on topic
  if (String(topic) == LIGHT_TOPIC) {
    lightState = (message == "ON");
    digitalWrite(LIGHT_PIN, lightState ? LOW : HIGH);
    Serial.print("💡 Light ");
    Serial.println(lightState ? "ON" : "OFF");
  }
  else if (String(topic) == FAN_TOPIC) {
    fanState = (message == "ON");
    digitalWrite(FAN_PIN, fanState ? LOW : HIGH);
    Serial.print("🌀 Fan ");
    Serial.println(fanState ? "ON" : "OFF");
  }
  else if (String(topic) == BUZZER_TOPIC) {
    buzzerState = (message == "ON");
    digitalWrite(BUZZER_PIN, buzzerState ? LOW : HIGH);
    Serial.print("🔔 Buzzer ");
    Serial.println(buzzerState ? "ON" : "OFF");
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("🔄 Attempting MQTT connection... ");
    
    if (client.connect(client_id)) {
      Serial.println("✅ Connected!");
      
      // Subscribe to all control topics
      Serial.println("📋 Subscribing to topics:");
      client.subscribe(LIGHT_TOPIC);
      Serial.print("  ✓ ");
      Serial.println(LIGHT_TOPIC);
      
      client.subscribe(FAN_TOPIC);
      Serial.print("  ✓ ");
      Serial.println(FAN_TOPIC);
      
      client.subscribe(BUZZER_TOPIC);
      Serial.print("  ✓ ");
      Serial.println(BUZZER_TOPIC);
      
    } else {
      Serial.print("❌ Failed, rc=");
      Serial.print(client.state());
      Serial.println(" - Retrying in 5 seconds...");
      delay(5000);
    }
  }
}

float readTemperature() {
  float t = dht.readTemperature();
  if (isnan(t)) {
    Serial.println("⚠️  Failed to read temperature");
    return 0.0;
  }
  return t;
}

float readHumidity() {
  float h = dht.readHumidity();
  if (isnan(h)) {
    Serial.println("⚠️  Failed to read humidity");
    return 0.0;
  }
  return h;
}

void publishSensorData() {
  // Read temperature and humidity
  float temp = readTemperature();
  float humidity = readHumidity();
  
  // Publish temperature
  char tempStr[8];
  dtostrf(temp, 4, 1, tempStr);
  client.publish(TEMP_TOPIC, tempStr, false);
  Serial.print("📤 Published temperature: ");
  Serial.print(tempStr);
  Serial.println("°C");
  
  // Publish humidity
  char humStr[8];
  dtostrf(humidity, 4, 1, humStr);
  client.publish(HUMIDITY_TOPIC, humStr, false);
  Serial.print("📤 Published humidity: ");
  Serial.print(humStr);
  Serial.println("%");
}

void loop() {
  // Reconnect to MQTT if disconnected
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  
  // Read sensor data periodically
  unsigned long now = millis();
  if (now - lastTempRead >= TEMP_READ_INTERVAL) {
    lastTempRead = now;
    
    // Publish sensor data every interval
    if (now - lastMsg >= PUBLISH_INTERVAL) {
      lastMsg = now;
      
      if (client.connected()) {
        publishSensorData();
      }
    }
  }
  
  delay(100);
}

