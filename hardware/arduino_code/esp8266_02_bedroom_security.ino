/*
 * ESP8266 #2 - Bedroom & Security Controller
 * Based on Flutter App Screens: Security, Dashboard (Bedroom)
 * 
 * Controls:
 * - Bedroom Light
 * - Security: Armed/Disarmed, Buzzer
 * - Motion Sensors: Bedroom, Kitchen
 * - Door Sensors: Front, Back
 * - Window Sensors: Living, Bedroom, Kitchen
 * - Gas Sensors: Smoke (MQ135), LPG (MQ6 or MQ135)
 * - Bedroom Environment: DHT22 (Temperature/Humidity)
 * 
 * MQTT Topics match Flutter app expectations
 */

#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>

// WiFi Configuration - UPDATE THESE FOR YOUR MOBILE HOTSPOT
const char* ssid = "hotSpot123";
const char* password = "pass123987";

// MQTT Configuration - UPDATE THIS TO YOUR PC'S IP ON MOBILE HOTSPOT
const char* mqtt_broker = "10.231.104.106";  // Change to your PC's IP
const int mqtt_port = 1883;
const char* client_id = "ESP8266_BedroomSecurity";

// Relay Pins
//#define BEDROOM_LIGHT_PIN D1
#define BUZZER_PIN D2

// Motion Sensor Pins (PIR)
#define PIR1_PIN D5  // PIR sensor #1
#define PIR2_PIN D6  // PIR sensor #2

// Door Sensor Pins (Magnetic - LOW when closed)
#define FRONT_DOOR_PIN D7
#define BACK_DOOR_PIN D8

// Window Sensor Pins (Magnetic - LOW when closed)
#define LIVING_WINDOW_PIN D0
#define BEDROOM_WINDOW_PIN D3
#define KITCHEN_WINDOW_PIN D4  // Note: D4 is also used for DHT22, need to choose

// // DHT22 (Bedroom environment)
// #define DHTPIN D4  // GPIO 4
// #define DHTTYPE DHT22
// DHT dht(DHTPIN, DHTTYPE);

// Gas Sensors (Analog)
#define MQ135_PIN A0  // Smoke sensor (or use for both smoke and LPG)
// Note: ESP8266 has only 1 analog input. Options:
// 1. Use MQ135 for both smoke and LPG (publish to both topics)
// 2. Use I2C ADC expander for MQ6 LPG sensor
// 3. Use digital output sensors

// Device states
bool bedroomLightState = false;
bool buzzerState = false;
bool securityArmed = false;

// Motion sensor states
bool pir1MotionDetected = false;
bool pir2MotionDetected = false;
bool lastPir1State = false;
bool lastPir2State = false;

// Door sensor states
bool frontDoorClosed = true;
bool backDoorClosed = true;
bool lastFrontDoorState = true;
bool lastBackDoorState = true;

// Window sensor states
bool livingWindowClosed = true;
bool bedroomWindowClosed = true;
bool kitchenWindowClosed = true;
bool lastLivingWindowState = true;
bool lastBedroomWindowState = true;
bool lastKitchenWindowState = true;

// MQTT Topics - Published (ESP8266 → Broker)
#define BEDROOM_TEMP_TOPIC "bedroom/temperature"
#define BEDROOM_HUMIDITY_TOPIC "bedroom/humidity"
#define PIR1_MOTION_TOPIC "security/motion/pir1"
#define PIR2_MOTION_TOPIC "security/motion/pir2"
#define FRONT_DOOR_TOPIC "security/door/front"
#define BACK_DOOR_TOPIC "security/door/back"
#define LIVING_WINDOW_TOPIC "security/window/living"
#define BEDROOM_WINDOW_TOPIC "security/window/bedroom"
#define KITCHEN_WINDOW_TOPIC "security/window/kitchen"
#define SMOKE_TOPIC "security/smoke"
#define LPG_TOPIC "security/lpg"
#define BUZZER_STATE_TOPIC "security/buzzer"

// MQTT Topics - Subscribed (Broker → ESP8266)
//#define BEDROOM_LIGHT_TOPIC "bedroom/light"
#define SECURITY_ARMED_TOPIC "security/armed"
#define BUZZER_CONTROL_TOPIC "security/buzzer"

// Create instances
WiFiClient espClient;
PubSubClient client(espClient);

// Timing variables
unsigned long lastSensorCheck = 0;
unsigned long lastPublish = 0;
unsigned long lastEnvRead = 0;
const unsigned long SENSOR_CHECK_INTERVAL = 500;   // Check sensors every 500ms
const unsigned long PUBLISH_INTERVAL = 2000;       // Publish every 2 seconds
const unsigned long ENV_READ_INTERVAL = 5000;      // Read DHT22/MQ135 every 5 seconds

void setup() {
  Serial.begin(115200);
  delay(100);
  
  Serial.println("\n\n====================================");
  Serial.println("🏠 ESP8266 #2 - Bedroom & Security");
  Serial.println("====================================\n");
  
  // Initialize output pins
 // pinMode(BEDROOM_LIGHT_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  // Initialize input pins
  pinMode(PIR1_PIN, INPUT);
  pinMode(PIR2_PIN, INPUT);
  pinMode(FRONT_DOOR_PIN, INPUT_PULLUP);
  pinMode(BACK_DOOR_PIN, INPUT_PULLUP);
  pinMode(LIVING_WINDOW_PIN, INPUT_PULLUP);
  pinMode(BEDROOM_WINDOW_PIN, INPUT_PULLUP);
  pinMode(KITCHEN_WINDOW_PIN, INPUT_PULLUP);
  
  // Turn off all devices initially (Active LOW relay)
 // digitalWrite(BEDROOM_LIGHT_PIN, HIGH);
  digitalWrite(BUZZER_PIN, HIGH);
  
  // Read initial sensor states
  lastPir1State = digitalRead(PIR1_PIN) == HIGH;
  lastPir2State = digitalRead(PIR2_PIN) == HIGH;
  lastFrontDoorState = digitalRead(FRONT_DOOR_PIN) == LOW;  // Closed = LOW
  lastBackDoorState = digitalRead(BACK_DOOR_PIN) == LOW;
  lastLivingWindowState = digitalRead(LIVING_WINDOW_PIN) == LOW;
  lastBedroomWindowState = digitalRead(BEDROOM_WINDOW_PIN) == LOW;
  lastKitchenWindowState = digitalRead(KITCHEN_WINDOW_PIN) == LOW;
  
  // Initialize DHT22
  dht.begin();
  Serial.println("✅ DHT22 initialized (Bedroom)");
  Serial.println("✅ MQ135 initialized (Smoke/LPG)");
  Serial.println("✅ All sensors initialized");
  
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
  } else {
    Serial.println("\n❌ WiFi connection failed!");
  }
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("\n📨 Message received: ");
  Serial.print(topic);
  Serial.print(" -> ");
  
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.println(message);
  
  String topicStr = String(topic);
  bool state = (message == "ON" || message == "1" || message == "true");
  
  // Control bedroom light
  // if (topicStr == BEDROOM_LIGHT_TOPIC) {
  //   bedroomLightState = state;
  //   digitalWrite(BEDROOM_LIGHT_PIN, bedroomLightState ? LOW : HIGH);
  //   Serial.print("💡 Bedroom Light: ");
  //   Serial.println(bedroomLightState ? "ON" : "OFF");
  // }
  // Security armed state
  else if (topicStr == SECURITY_ARMED_TOPIC) {
    securityArmed = state;
    Serial.print("🔒 Security System: ");
    Serial.println(securityArmed ? "ARMED" : "DISARMED");
    
    // If disarming, turn off buzzer
    if (!securityArmed) {
      buzzerState = false;
      digitalWrite(BUZZER_PIN, HIGH);
    }
  }
  // Buzzer control
  else if (topicStr == BUZZER_CONTROL_TOPIC) {
    buzzerState = state;
    digitalWrite(BUZZER_PIN, buzzerState ? LOW : HIGH);
    Serial.print("🔔 Buzzer: ");
    Serial.println(buzzerState ? "ON" : "OFF");
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("🔄 Attempting MQTT connection... ");
    
    if (client.connect(client_id)) {
      Serial.println("✅ Connected!");
      
      Serial.println("📋 Subscribing to topics:");
      //client.subscribe(BEDROOM_LIGHT_TOPIC);
      client.subscribe(SECURITY_ARMED_TOPIC);
      client.subscribe(BUZZER_CONTROL_TOPIC);
      Serial.println("  ✓ All topics subscribed");
    } else {
      Serial.print("❌ Failed, rc=");
      Serial.print(client.state());
      Serial.println(" - Retrying in 5 seconds...");
      delay(5000);
    }
  }
}

void checkSensors() {
  // Read motion sensors
  bool currentPir1Motion = digitalRead(PIR1_PIN) == HIGH;
  bool currentPir2Motion = digitalRead(PIR2_PIN) == HIGH;
  
  // Publish motion changes
  if (currentPir1Motion != lastPir1State) {
    pir1MotionDetected = currentPir1Motion;
    lastPir1State = currentPir1Motion;
    client.publish(PIR1_MOTION_TOPIC, pir1MotionDetected ? "DETECTED" : "CLEAR", true);
    Serial.print("🚨 PIR #1 Motion: ");
    Serial.println(pir1MotionDetected ? "DETECTED" : "CLEAR");
    
    // Trigger alarm if armed
    if (pir1MotionDetected && securityArmed) {
      triggerAlarm();
    }
  }
  
  if (currentPir2Motion != lastPir2State) {
    pir2MotionDetected = currentPir2Motion;
    lastPir2State = currentPir2Motion;
    client.publish(PIR2_MOTION_TOPIC, pir2MotionDetected ? "DETECTED" : "CLEAR", true);
    Serial.print("🚨 PIR #2 Motion: ");
    Serial.println(pir2MotionDetected ? "DETECTED" : "CLEAR");
    
    if (pir2MotionDetected && securityArmed) {
      triggerAlarm();
    }
  }
  
  // Read door sensors
  bool currentFrontDoor = digitalRead(FRONT_DOOR_PIN) == LOW;  // Closed = LOW
  bool currentBackDoor = digitalRead(BACK_DOOR_PIN) == LOW;
  
  if (currentFrontDoor != lastFrontDoorState) {
    frontDoorClosed = currentFrontDoor;
    lastFrontDoorState = currentFrontDoor;
    client.publish(FRONT_DOOR_TOPIC, frontDoorClosed ? "LOCKED" : "UNLOCKED", false);
    Serial.print("🚪 Front Door: ");
    Serial.println(frontDoorClosed ? "LOCKED" : "UNLOCKED");
    
    if (!frontDoorClosed && securityArmed) {
      triggerAlarm();
    }
  }
  
  if (currentBackDoor != lastBackDoorState) {
    backDoorClosed = currentBackDoor;
    lastBackDoorState = currentBackDoor;
    client.publish(BACK_DOOR_TOPIC, backDoorClosed ? "LOCKED" : "UNLOCKED", false);
    Serial.print("🚪 Back Door: ");
    Serial.println(backDoorClosed ? "LOCKED" : "UNLOCKED");
    
    if (!backDoorClosed && securityArmed) {
      triggerAlarm();
    }
  }
  
  // Read window sensors
  bool currentLivingWindow = digitalRead(LIVING_WINDOW_PIN) == LOW;  // Closed = LOW
  bool currentBedroomWindow = digitalRead(BEDROOM_WINDOW_PIN) == LOW;
  bool currentKitchenWindow = digitalRead(KITCHEN_WINDOW_PIN) == LOW;
  
  if (currentLivingWindow != lastLivingWindowState) {
    livingWindowClosed = currentLivingWindow;
    lastLivingWindowState = currentLivingWindow;
    client.publish(LIVING_WINDOW_TOPIC, livingWindowClosed ? "CLOSED" : "OPEN", false);
    Serial.print("🪟 Living Window: ");
    Serial.println(livingWindowClosed ? "CLOSED" : "OPEN");
  }
  
  if (currentBedroomWindow != lastBedroomWindowState) {
    bedroomWindowClosed = currentBedroomWindow;
    lastBedroomWindowState = currentBedroomWindow;
    client.publish(BEDROOM_WINDOW_TOPIC, bedroomWindowClosed ? "CLOSED" : "OPEN", false);
    Serial.print("🪟 Bedroom Window: ");
    Serial.println(bedroomWindowClosed ? "CLOSED" : "OPEN");
  }
  
  if (currentKitchenWindow != lastKitchenWindowState) {
    kitchenWindowClosed = currentKitchenWindow;
    lastKitchenWindowState = currentKitchenWindow;
    client.publish(KITCHEN_WINDOW_TOPIC, kitchenWindowClosed ? "CLOSED" : "OPEN", false);
    Serial.print("🪟 Kitchen Window: ");
    Serial.println(kitchenWindowClosed ? "CLOSED" : "OPEN");
  }
}

void triggerAlarm() {
  if (!buzzerState) {
    buzzerState = true;
    digitalWrite(BUZZER_PIN, LOW);
    client.publish(BUZZER_STATE_TOPIC, "ON", false);
    Serial.println("🚨 ALARM TRIGGERED!");
  }
}

void readAndPublishEnvironment() {
  // Read DHT22
  float t = dht.readTemperature();
  float h = dht.readHumidity();
  
  if (!isnan(t)) {
    char tStr[8];
    dtostrf(t, 4, 1, tStr);
    client.publish(BEDROOM_TEMP_TOPIC, tStr, false);
    Serial.print("📤 Bedroom Temp: ");
    Serial.print(tStr);
    Serial.println("°C");
  }
  
  if (!isnan(h)) {
    char hStr[8];
    dtostrf(h, 4, 1, hStr);
    client.publish(BEDROOM_HUMIDITY_TOPIC, hStr, false);
    Serial.print("📤 Bedroom Humidity: ");
    Serial.print(hStr);
    Serial.println("%");
  }
  
  // Read MQ135 (use for both smoke and LPG)
  int gasValue = analogRead(MQ135_PIN);
  
  // Smoke detection (threshold ~600, adjust based on calibration)
  const int SMOKE_THRESHOLD = 600;
  const char* smokeState = (gasValue >= SMOKE_THRESHOLD) ? "ALERT" : "NORMAL";
  client.publish(SMOKE_TOPIC, smokeState, false);
  
  // LPG detection (threshold ~500, adjust based on calibration)
  // Note: Using same sensor for both. For better accuracy, use separate MQ6 for LPG
  const int LPG_THRESHOLD = 500;
  const char* lpgState = (gasValue >= LPG_THRESHOLD) ? "ALERT" : "NORMAL";
  client.publish(LPG_TOPIC, lpgState, false);
  
  if (gasValue >= SMOKE_THRESHOLD || gasValue >= LPG_THRESHOLD) {
    Serial.print("🚨 Gas Alert! Value: ");
    Serial.println(gasValue);
    if (securityArmed) {
      triggerAlarm();
    }
  }
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  
  unsigned long now = millis();
  
  // Check sensors frequently
  if (now - lastSensorCheck >= SENSOR_CHECK_INTERVAL) {
    lastSensorCheck = now;
    checkSensors();
  }
  
  // Publish sensor states periodically
  if (now - lastPublish >= PUBLISH_INTERVAL) {
    lastPublish = now;
    if (client.connected()) {
      // Publish current states
      client.publish(PIR1_MOTION_TOPIC, pir1MotionDetected ? "DETECTED" : "CLEAR", true);
      client.publish(PIR2_MOTION_TOPIC, pir2MotionDetected ? "DETECTED" : "CLEAR", true);
      client.publish(FRONT_DOOR_TOPIC, frontDoorClosed ? "LOCKED" : "UNLOCKED", false);
      client.publish(BACK_DOOR_TOPIC, backDoorClosed ? "LOCKED" : "UNLOCKED", false);
      client.publish(LIVING_WINDOW_TOPIC, livingWindowClosed ? "CLOSED" : "OPEN", false);
      client.publish(BEDROOM_WINDOW_TOPIC, bedroomWindowClosed ? "CLOSED" : "OPEN", false);
      client.publish(KITCHEN_WINDOW_TOPIC, kitchenWindowClosed ? "CLOSED" : "OPEN", false);
    }
  }
  
  // Read and publish environment periodically
  if (now - lastEnvRead >= ENV_READ_INTERVAL) {
    lastEnvRead = now;
    if (client.connected()) {
      readAndPublishEnvironment();
    }
  }
  
  delay(50);
}
