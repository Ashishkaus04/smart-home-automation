/*
 * ESP8266 #3 - Energy Monitoring Controller
 * Based on Flutter App Screens: Energy
 * 
 * Controls:
 * - Energy Meter (PZEM-004T) - Current Usage, Cost, Monthly Usage
 * - Optional: Garage Light, Garden Light, Car Charger
 * 
 * MQTT Topics match Flutter app expectations
 */

#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <SoftwareSerial.h>

// WiFi Configuration - UPDATE THESE FOR YOUR MOBILE HOTSPOT
const char* ssid = "YOUR_MOBILE_HOTSPOT_SSID";
const char* password = "YOUR_HOTSPOT_PASSWORD";

// MQTT Configuration - UPDATE THIS TO YOUR PC'S IP ON MOBILE HOTSPOT
const char* mqtt_broker = "192.168.43.1";  // Change to your PC's IP
const int mqtt_port = 1883;
const char* client_id = "ESP8266_EnergyMonitoring";

// PZEM-004T Energy Meter (Serial communication)
// Connect PZEM-004T RX to ESP8266 D6 (GPIO 12)
// Connect PZEM-004T TX to ESP8266 D7 (GPIO 13)
#define PZEM_RX_PIN D6
#define PZEM_TX_PIN D7
SoftwareSerial pzemSerial(PZEM_RX_PIN, PZEM_TX_PIN);

// Optional: Relay Pins for outdoor devices
#define GARAGE_LIGHT_PIN D1
#define GARDEN_LIGHT_PIN D2
#define CAR_CHARGER_PIN D5

// Device states (optional)
bool garageLightState = false;
bool gardenLightState = false;
bool carChargerState = false;

// Energy data
float voltage = 0.0;
float current = 0.0;
float power = 0.0;        // Watts
float energy = 0.0;       // kWh (total energy consumed)
float cost = 0.0;         // Cost in ₹
float monthlyEnergy = 0.0; // Monthly kWh

// Energy cost per kWh (update based on your electricity rate)
const float COST_PER_KWH = 7.0;  // ₹7 per kWh (adjust as needed)

// MQTT Topics - Published (ESP8266 → Broker)
#define ENERGY_CONSUMPTION_TOPIC "energy/consumption"  // Current kWh
#define ENERGY_POWER_TOPIC "energy/power"              // Current power in W
#define ENERGY_COST_TOPIC "energy/cost"                // Current cost in ₹
#define ENERGY_MONTHLY_TOPIC "energy/monthly"          // Monthly kWh
#define ENERGY_VOLTAGE_TOPIC "energy/voltage"          // Voltage
#define ENERGY_CURRENT_TOPIC "energy/current"          // Current

// Optional topics
#define GARAGE_LIGHT_TOPIC "garage/light"
#define GARDEN_LIGHT_TOPIC "garden/light"
#define CAR_CHARGER_TOPIC "car_charger/power"

// MQTT Topics - Subscribed (Broker → ESP8266) - Optional
#define GARAGE_LIGHT_CONTROL_TOPIC "garage/light"
#define GARDEN_LIGHT_CONTROL_TOPIC "garden/light"
#define CAR_CHARGER_CONTROL_TOPIC "car_charger/power"

// Create instances
WiFiClient espClient;
PubSubClient client(espClient);

// Timing variables
unsigned long lastEnergyRead = 0;
unsigned long lastPublish = 0;
const unsigned long ENERGY_READ_INTERVAL = 2000;  // Read energy meter every 2 seconds
const unsigned long PUBLISH_INTERVAL = 5000;      // Publish every 5 seconds

// PZEM-004T command functions
void sendCommand(uint8_t cmd, uint8_t addr) {
  uint8_t data[] = {0xB4, cmd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  data[15] = calculateCRC(data, 15);
  pzemSerial.write(data, 16);
  delay(100);
}

uint8_t calculateCRC(uint8_t *data, uint8_t len) {
  uint16_t crc = 0;
  for (uint8_t i = 0; i < len; i++) {
    crc += data[i];
  }
  return (uint8_t)(crc & 0xFF);
}

bool readPZEMData() {
  // Request energy data from PZEM-004T
  sendCommand(0x04, 0x00);
  
  // Wait for response
  delay(200);
  
  if (pzemSerial.available() >= 25) {
    uint8_t buffer[25];
    pzemSerial.readBytes(buffer, 25);
    
    // Parse response (simplified - adjust based on PZEM-004T protocol)
    // Format: [Header][Command][Data...][CRC]
    if (buffer[0] == 0xA4 && buffer[1] == 0x04) {
      // Extract voltage (bytes 2-3)
      voltage = ((buffer[2] << 8) | buffer[3]) / 10.0;
      
      // Extract current (bytes 4-7)
      current = ((buffer[4] << 24) | (buffer[5] << 16) | (buffer[6] << 8) | buffer[7]) / 1000.0;
      
      // Extract power (bytes 8-11)
      power = ((buffer[8] << 24) | (buffer[9] << 16) | (buffer[10] << 8) | buffer[11]) / 10.0;
      
      // Extract energy (bytes 12-15)
      energy = ((buffer[12] << 24) | (buffer[13] << 16) | (buffer[14] << 8) | buffer[15]) / 1000.0;
      
      // Calculate cost
      cost = energy * COST_PER_KWH;
      
      // For monthly, you would need to track daily and sum
      // For now, use current energy as placeholder
      monthlyEnergy = energy;  // Replace with actual monthly tracking
      
      return true;
    }
  }
  return false;
}

void setup() {
  Serial.begin(115200);
  delay(100);
  
  Serial.println("\n\n====================================");
  Serial.println("⚡ ESP8266 #3 - Energy Monitoring");
  Serial.println("====================================\n");
  
  // Initialize PZEM-004T serial
  pzemSerial.begin(9600);
  Serial.println("✅ PZEM-004T initialized");
  
  // Initialize optional relay pins
  pinMode(GARAGE_LIGHT_PIN, OUTPUT);
  pinMode(GARDEN_LIGHT_PIN, OUTPUT);
  pinMode(CAR_CHARGER_PIN, OUTPUT);
  
  // Turn off all devices initially
  digitalWrite(GARAGE_LIGHT_PIN, HIGH);
  digitalWrite(GARDEN_LIGHT_PIN, HIGH);
  digitalWrite(CAR_CHARGER_PIN, HIGH);
  
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
  
  // Control optional devices
  if (topicStr == GARAGE_LIGHT_CONTROL_TOPIC) {
    garageLightState = state;
    digitalWrite(GARAGE_LIGHT_PIN, garageLightState ? LOW : HIGH);
    Serial.print("💡 Garage Light: ");
    Serial.println(garageLightState ? "ON" : "OFF");
  }
  else if (topicStr == GARDEN_LIGHT_CONTROL_TOPIC) {
    gardenLightState = state;
    digitalWrite(GARDEN_LIGHT_PIN, gardenLightState ? LOW : HIGH);
    Serial.print("💡 Garden Light: ");
    Serial.println(gardenLightState ? "ON" : "OFF");
  }
  else if (topicStr == CAR_CHARGER_CONTROL_TOPIC) {
    carChargerState = state;
    digitalWrite(CAR_CHARGER_PIN, carChargerState ? LOW : HIGH);
    Serial.print("🔌 Car Charger: ");
    Serial.println(carChargerState ? "ON" : "OFF");
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("🔄 Attempting MQTT connection... ");
    
    if (client.connect(client_id)) {
      Serial.println("✅ Connected!");
      
      Serial.println("📋 Subscribing to topics:");
      // Subscribe to optional control topics
      client.subscribe(GARAGE_LIGHT_CONTROL_TOPIC);
      client.subscribe(GARDEN_LIGHT_CONTROL_TOPIC);
      client.subscribe(CAR_CHARGER_CONTROL_TOPIC);
      Serial.println("  ✓ All topics subscribed");
    } else {
      Serial.print("❌ Failed, rc=");
      Serial.print(client.state());
      Serial.println(" - Retrying in 5 seconds...");
      delay(5000);
    }
  }
}

void publishEnergyData() {
  // Read energy data from PZEM-004T
  if (readPZEMData()) {
    // Publish current consumption (kWh)
    char energyStr[10];
    dtostrf(energy, 4, 2, energyStr);
    client.publish(ENERGY_CONSUMPTION_TOPIC, energyStr, false);
    Serial.print("📤 Energy Consumption: ");
    Serial.print(energyStr);
    Serial.println(" kWh");
    
    // Publish current power (W)
    char powerStr[10];
    dtostrf(power, 4, 1, powerStr);
    client.publish(ENERGY_POWER_TOPIC, powerStr, false);
    Serial.print("📤 Power: ");
    Serial.print(powerStr);
    Serial.println(" W");
    
    // Publish cost (₹)
    char costStr[10];
    dtostrf(cost, 4, 2, costStr);
    client.publish(ENERGY_COST_TOPIC, costStr, false);
    Serial.print("📤 Cost: ₹");
    Serial.println(costStr);
    
    // Publish monthly energy (kWh)
    char monthlyStr[10];
    dtostrf(monthlyEnergy, 4, 2, monthlyStr);
    client.publish(ENERGY_MONTHLY_TOPIC, monthlyStr, false);
    Serial.print("📤 Monthly Energy: ");
    Serial.print(monthlyStr);
    Serial.println(" kWh");
    
    // Optional: Publish voltage and current
    char voltageStr[10];
    dtostrf(voltage, 4, 1, voltageStr);
    client.publish(ENERGY_VOLTAGE_TOPIC, voltageStr, false);
    
    char currentStr[10];
    dtostrf(current, 4, 2, currentStr);
    client.publish(ENERGY_CURRENT_TOPIC, currentStr, false);
  } else {
    Serial.println("⚠️  Failed to read PZEM-004T data");
  }
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  
  unsigned long now = millis();
  
  // Read energy meter periodically
  if (now - lastEnergyRead >= ENERGY_READ_INTERVAL) {
    lastEnergyRead = now;
    
    // Publish energy data every interval
    if (now - lastPublish >= PUBLISH_INTERVAL) {
      lastPublish = now;
      
      if (client.connected()) {
        publishEnergyData();
      }
    }
  }
  
  delay(100);
}

