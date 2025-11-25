/*
 * ESP8266 #1 - Living Room & Appliances Controller
 * Based on Flutter App Screens: Dashboard, Devices
 * 
 * Hardware:
 * - 4-Relay Module for Lights (IN1-D1, IN2-D2, IN3-D5, IN4-D6)
 * - Separate relays for Appliances and Climate
 * 
 * Controls:
 * - Lights: Living Room, Kitchen, Bathroom (on 4-relay module)
 * - Appliances: TV, Music System, Coffee Maker
 * - Climate: Fan, AC
 * - Sensors: DHT22 (Temperature/Humidity), MQ135 (AQI)
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
 const char* client_id = "ESP8266_LivingRoom";
 
 // DHT22 Sensor (Temperature/Humidity for Dashboard weather)
 #define DHTPIN D4
 #define DHTTYPE DHT22
 DHT dht(DHTPIN, DHTTYPE);
 
 // MQ135 Air Quality Sensor (for Dashboard AQI)
 #define MQ135_PIN A0
 
// 4-Relay Module for Lights (Active LOW)
// Relay Module Pin Mapping:
//   Relay 1 (IN1) -> D1 -> Living Room Light
//   Relay 2 (IN2) -> D2 -> Kitchen Light
//   Relay 3 (IN3) -> D5 -> Bathroom Light
//   Relay 4 (IN4) -> D6 -> (Reserved for future light or 4th light)
#define LIVING_ROOM_LIGHT_PIN D1  // Relay Module IN1
#define KITCHEN_LIGHT_PIN D2      // Relay Module IN2
#define BATHROOM_LIGHT_PIN D5     // Relay Module IN3
#define BEDROOM_LIGHT_PIN D6            // Relay Module IN4 (optional 4th light)

// Relay Pins - Appliances (separate from 4-relay module)
#define TV_PIN D7
#define MUSIC_PIN D8
#define COFFEE_PIN D0

// Relay Pins - Climate
#define FAN_PIN D3
#define AC_PIN D4
 
 // Optional: Security sensors on ESP #1 are DISABLED to avoid using RX/TX (GPIO 3/1) which breaks Serial
 // If needed later, move these sensors to ESP8266 #2 (Security) or reassign to safe GPIOs
 #define ENABLE_SECURITY_SENSORS 0
 #if ENABLE_SECURITY_SENSORS
 #define LIVING_MOTION_PIN D9   // GPIO 3 (RX) - NOT RECOMMENDED
 #define LIVING_WINDOW_PIN D10  // GPIO 1 (TX) - NOT RECOMMENDED
 #endif
 
 // Device states
 bool livingRoomLightState = false;
 bool kitchenLightState = false;
 bool bathroomLightState = false;
 bool bedroomLightState = false;
 bool tvState = false;
 bool musicState = false;
 bool coffeeState = false;
 bool fanState = false;
 bool acState = false;
 bool lastMotionState = false;
 bool lastWindowState = false;
 
 // MQTT Topics - Published (ESP8266 → Broker)
 #define TEMP_TOPIC "living_room/temperature"
 #define HUMIDITY_TOPIC "living_room/humidity"
 #define AQI_TOPIC "living_room/aqi"
 #define MOTION_TOPIC "living_room/motion"
 #define WINDOW_TOPIC "security/window/living"
 #define SMOKE_TOPIC "security/smoke"
 #define LPG_TOPIC "security/lpg"
 
 // MQTT Topics - Subscribed (Broker → ESP8266)
 #define LIVING_ROOM_LIGHT_TOPIC "living_room/light"
 #define KITCHEN_LIGHT_TOPIC "kitchen/light"
 #define BATHROOM_LIGHT_TOPIC "bathroom/light"
 #define BEDROOM_LIGHT_TOPIC "bedroom/light"
 #define TV_TOPIC "appliances/tv"
 #define MUSIC_TOPIC "appliances/music"
 #define COFFEE_TOPIC "appliances/coffee"
 #define FAN_TOPIC "living_room/fan"
 #define AC_TOPIC "climate/ac"
 #define AC_TEMP_TOPIC "climate/ac_temperature"
 
 
 // Create instances
 WiFiClient espClient;
 PubSubClient client(espClient);
 
 // Timing variables
 unsigned long lastMsg = 0;
 unsigned long lastSensorRead = 0;
 const unsigned long SENSOR_READ_INTERVAL = 2000;  // Read sensors every 2 seconds
 const unsigned long PUBLISH_INTERVAL = 5000;      // Publish every 5 seconds
 
 void setup() {
   Serial.begin(115200);
   delay(100);
   
  Serial.println("\n\n====================================");
  Serial.println("🏠 ESP8266 #1 - Living Room Controller");
  Serial.println("====================================\n");
  Serial.println("🔌 4-Relay Module Configuration:");
  Serial.println("   Relay 1 (IN1-D1) -> Living Room Light");
  Serial.println("   Relay 2 (IN2-D2) -> Kitchen Light");
  Serial.println("   Relay 3 (IN3-D5) -> Bathroom Light");
  Serial.println("   Relay 4 (IN4-D6) -> Reserved/Optional\n");
  
  // Initialize 4-Relay Module pins for lights (Active LOW relay)
  pinMode(LIVING_ROOM_LIGHT_PIN, OUTPUT);  // Relay Module IN1
  pinMode(KITCHEN_LIGHT_PIN, OUTPUT);      // Relay Module IN2
  pinMode(BATHROOM_LIGHT_PIN, OUTPUT);     // Relay Module IN3
  pinMode(BEDROOM_LIGHT_PIN, OUTPUT);            // Relay Module IN4 (optional)
  
  // Initialize appliance and climate relay pins
  pinMode(TV_PIN, OUTPUT);
  pinMode(MUSIC_PIN, OUTPUT);
  pinMode(COFFEE_PIN, OUTPUT);
  pinMode(FAN_PIN, OUTPUT);
  pinMode(AC_PIN, OUTPUT);
  
  // Turn off all devices initially (Active LOW: HIGH = OFF, LOW = ON)
  digitalWrite(LIVING_ROOM_LIGHT_PIN, HIGH);
  digitalWrite(KITCHEN_LIGHT_PIN, HIGH);
  digitalWrite(BATHROOM_LIGHT_PIN, HIGH);
  digitalWrite(BEDROOM_LIGHT_PIN, HIGH);
  digitalWrite(TV_PIN, HIGH);
  digitalWrite(MUSIC_PIN, HIGH);
  digitalWrite(COFFEE_PIN, HIGH);
  digitalWrite(FAN_PIN, HIGH);
  digitalWrite(AC_PIN, HIGH);
   
   // Security sensors disabled on this board to keep Serial working
   // Re-enable only if moved to safe pins
   
   // Initialize DHT sensor
   dht.begin();
   Serial.println("✅ DHT22 sensor initialized");
   Serial.println("✅ MQ135 sensor initialized");
   
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
   
   // Control devices
   if (topicStr == LIVING_ROOM_LIGHT_TOPIC) {
     livingRoomLightState = state;
     digitalWrite(LIVING_ROOM_LIGHT_PIN, livingRoomLightState ? LOW : HIGH);
     Serial.print("💡 Living Room Light: ");
     Serial.println(livingRoomLightState ? "ON" : "OFF");
   }
   else if (topicStr == KITCHEN_LIGHT_TOPIC) {
     kitchenLightState = state;
     digitalWrite(KITCHEN_LIGHT_PIN, kitchenLightState ? LOW : HIGH);
     Serial.print("💡 Kitchen Light: ");
     Serial.println(kitchenLightState ? "ON" : "OFF");
   }
   else if (topicStr == BATHROOM_LIGHT_TOPIC) {
     bathroomLightState = state;
     digitalWrite(BATHROOM_LIGHT_PIN, bathroomLightState ? LOW : HIGH);
     Serial.print("💡 Bathroom Light: ");
     Serial.println(bathroomLightState ? "ON" : "OFF");
   }
   else if (topicStr == BEDROOM_LIGHT_TOPIC) {
    bedroomLightState = state;
    digitalWrite(BEDROOM_LIGHT_PIN, bedroomLightState ? LOW : HIGH);
    Serial.print("💡 Bedroom Light: ");
    Serial.println(bedroomLightState ? "ON" : "OFF");
  }
   else if (topicStr == TV_TOPIC) {
     tvState = state;
     digitalWrite(TV_PIN, tvState ? LOW : HIGH);
     Serial.print("📺 TV: ");
     Serial.println(tvState ? "ON" : "OFF");
   }
   else if (topicStr == MUSIC_TOPIC) {
     musicState = state;
     digitalWrite(MUSIC_PIN, musicState ? LOW : HIGH);
     Serial.print("🎵 Music System: ");
     Serial.println(musicState ? "ON" : "OFF");
   }
   else if (topicStr == COFFEE_TOPIC) {
     coffeeState = state;
     digitalWrite(COFFEE_PIN, coffeeState ? LOW : HIGH);
     Serial.print("☕ Coffee Maker: ");
     Serial.println(coffeeState ? "ON" : "OFF");
   }
   else if (topicStr == FAN_TOPIC) {
     fanState = state;
     digitalWrite(FAN_PIN, fanState ? LOW : HIGH);
     Serial.print("🌀 Fan: ");
     Serial.println(fanState ? "ON" : "OFF");
   }
   else if (topicStr == AC_TOPIC) {
     acState = state;
     digitalWrite(AC_PIN, acState ? LOW : HIGH);
     Serial.print("❄️ AC: ");
     Serial.println(acState ? "ON" : "OFF");
   }
   // Note: AC temperature control would need IR blaster or smart AC controller
   // For now, just ON/OFF control
 }
 
 void reconnect() {
   while (!client.connected()) {
     Serial.print("🔄 Attempting MQTT connection... ");
     
     if (client.connect(client_id)) {
       Serial.println("✅ Connected!");
       
       // Subscribe to all control topics
       Serial.println("📋 Subscribing to topics:");
       client.subscribe(LIVING_ROOM_LIGHT_TOPIC);
       client.subscribe(KITCHEN_LIGHT_TOPIC);
       client.subscribe(BATHROOM_LIGHT_TOPIC);
       client.subscribe(BEDROOM_LIGHT_TOPIC);
       client.subscribe(TV_TOPIC);
       client.subscribe(MUSIC_TOPIC);
       client.subscribe(COFFEE_TOPIC);
       client.subscribe(FAN_TOPIC);
       client.subscribe(AC_TOPIC);
       
       Serial.println("  ✓ All topics subscribed");
     } else {
       Serial.print("❌ Failed, rc=");
       Serial.print(client.state());
       Serial.println(" - Retrying in 5 seconds...");
       delay(5000);
     }
   }
 }
 
 void publishSensorData() {
   // Read DHT22
   float temp = dht.readTemperature();
   float humidity = dht.readHumidity();
   
   // Read MQ135 (AQI)
   int aqiValue = analogRead(MQ135_PIN);
   
   // Security sensors disabled
   
   // Publish temperature
   char tempStr[8];
   if (!isnan(temp)) {
     dtostrf(temp, 4, 1, tempStr);
     client.publish(TEMP_TOPIC, tempStr, true); // retain latest temperature
     Serial.print("📤 Temperature: ");
     Serial.print(tempStr);
     Serial.println("°C");
   } else {
     strcpy(tempStr, "0.0");
     Serial.println("⚠️  DHT read failed (temperature)");
   }
   
   // Publish humidity
   char humStr[8];
   if (!isnan(humidity)) {
     dtostrf(humidity, 4, 1, humStr);
     client.publish(HUMIDITY_TOPIC, humStr, true); // retain latest humidity
     Serial.print("📤 Humidity: ");
     Serial.print(humStr);
     Serial.println("%");
   } else {
     strcpy(humStr, "0.0");
     Serial.println("⚠️  DHT read failed (humidity)");
   }
   
   // Publish AQI
  // Publish AQI (base value)
 char aqiStr[6];
 sprintf(aqiStr, "%d", aqiValue);
 client.publish(AQI_TOPIC, aqiStr, true);
 Serial.print("📤 AQI: ");
 Serial.println(aqiStr);
 
 // Estimate smoke and LPG levels (0–100 scale)
 int smokeLevel = map(aqiValue, 100, 900, 0, 100);
 int lpgLevel   = map(aqiValue, 100, 900, 0, 100);
 
 // Clamp values
 smokeLevel = constrain(smokeLevel, 0, 100);
 lpgLevel   = constrain(lpgLevel, 0, 100);
 
 // Publish Smoke
 char smokeStr[8];
 sprintf(smokeStr, "%d", smokeLevel);
 client.publish(SMOKE_TOPIC, smokeStr, true);
 Serial.print("🔥 Smoke Level: ");
 Serial.println(smokeStr);
 
 // Publish LPG
 char lpgStr[8];
 sprintf(lpgStr, "%d", lpgLevel);
 client.publish(LPG_TOPIC, lpgStr, true);
 Serial.print("⛽ LPG Level: ");
 Serial.println(lpgStr);
 
 // Hazard detection (optional alerts)
 if (smokeLevel > 60) {
   client.publish(SMOKE_TOPIC, "ALERT");
 }
 if (lpgLevel > 60) {
   client.publish(LPG_TOPIC, "ALERT");
 }
 
 
   // One-line summary for easy monitoring
   Serial.print("ENV → T: ");
   Serial.print(tempStr);
   Serial.print("°C, H: ");
   Serial.print(humStr);
   Serial.print("%, AQI: ");
   Serial.println(aqiStr);
   
   // Motion/window publishing disabled on this board
 }
 
 void loop() {
   if (!client.connected()) {
     reconnect();
   }
   client.loop();
   
   unsigned long now = millis();
   
   // Read sensors periodically
   if (now - lastSensorRead >= SENSOR_READ_INTERVAL) {
     lastSensorRead = now;
     
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
 