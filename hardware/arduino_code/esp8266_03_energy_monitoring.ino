/*
 * ESP8266 #3 - Energy Monitoring Controller
 * Based on Flutter App Screens: Energy
 * 
 * Hardware:
 * - ACS712 Current Sensor (5A/20A/30A variant)
 * - Optional: Balcony Light, Front Door Light, Back Door Light, Window Light
 * 
 * Controls:
 * - Current Measurement (ACS712)
 * - Power Calculation (Voltage × Current)
 * - Energy Calculation (Power × Time)
 * - Cost Calculation
 * - MQTT-controlled perimeter lighting relays
 * 
 * MQTT Topics match Flutter app expectations
 */

 #include <ESP8266WiFi.h>
 #include <PubSubClient.h>
 
 // WiFi Configuration - UPDATE THESE FOR YOUR MOBILE HOTSPOT
 const char* ssid = "";
 const char* password = "";
 
 // MQTT Configuration - UPDATE THIS TO YOUR PC'S IP ON MOBILE HOTSPOT
 const char* mqtt_broker = "";  // Change to your PC's IP
 const int mqtt_port = 1883;
 const char* client_id = "ESP8266_EnergyMonitoring";
 
 // ACS712 Current Sensor Configuration
 // Choose your sensor variant:
 //   ACS712-5A:  use ACS712_SENSITIVITY = 185 (mV/A)
 //   ACS712-20A: use ACS712_SENSITIVITY = 100 (mV/A)
 //   ACS712-30A: use ACS712_SENSITIVITY = 66 (mV/A)
 #define ACS712_PIN A0              // Analog pin for ACS712 output
 #define ACS712_SENSITIVITY 100     // 100 mV/A for 20A variant (adjust for your sensor)
 #define ACS712_VCC 3.3             // ESP8266 ADC reference voltage (3.3V)
 #define ACS712_QUIESCENT_VOLTAGE 1.65  // VCC/2 (midpoint when no current)
 #define AC_VOLTAGE 220.0           // AC Mains voltage (adjust for your region: 110V or 220V)
 
 // Number of samples for averaging (for noise reduction)
 #define SAMPLES 100
 
 // Optional: Relay pins for perimeter lighting
 #define BALCONY_LIGHT_PIN D1
 #define FRONT_DOOR_LIGHT_PIN D2
 #define BACK_DOOR_LIGHT_PIN D5
 #define WINDOW_LIGHT_PIN D6
 // Appliance indicators
 #define SMART_TV_LED_PIN D7
 #define TV_COFFEE_BUZZER_PIN D8
 #define MUSIC_BUZZER_PIN D0
 
 // Device states
 bool balconyLightState = false;
 bool frontDoorLightState = false;
 bool backDoorLightState = false;
 bool windowLightState = false;
bool smartTvState = false;
bool musicSystemState = false;
bool coffeeMakerState = false;
bool tvCoffeeBuzzerState = false;
bool musicBuzzerState = false;
String selectedSong = "Happy Birthday";
bool isPlayingSong = false;
bool shouldStopSong = false;
unsigned long songStartTime = 0;
int currentSongNote = 0;
String currentPlayingSong = "";
 
 // Energy data
 float voltage = AC_VOLTAGE;       // AC Mains voltage (assumed constant)
 float current = 0.0;              // Current in Amperes (from ACS712)
 float power = 0.0;                // Power in Watts (Voltage × Current)
 float energy = 0.0;               // Total energy consumed in kWh
 float cost = 0.0;                 // Cost in ₹
 float monthlyEnergy = 0.0;        // Monthly kWh
 unsigned long lastEnergyUpdate = 0;  // For energy integration
 
 // Energy cost per kWh (update based on your electricity rate)
 const float COST_PER_KWH = 7.0;  // ₹7 per kWh (adjust as needed)
 
 // MQTT Topics - Published (ESP8266 → Broker)
 #define ENERGY_CONSUMPTION_TOPIC "energy/consumption"  // Current kWh
 #define ENERGY_POWER_TOPIC "energy/power"              // Current power in W
 #define ENERGY_COST_TOPIC "energy/cost"                // Current cost in ₹
 #define ENERGY_MONTHLY_TOPIC "energy/monthly"          // Monthly kWh
 #define ENERGY_VOLTAGE_TOPIC "energy/voltage"          // Voltage
 #define ENERGY_CURRENT_TOPIC "energy/current"          // Current
 
 // Optional topics for smart lighting perimeter
 #define BALCONY_LIGHT_TOPIC "lights/balcony"
 #define FRONT_DOOR_LIGHT_TOPIC "lights/front_door"
 #define BACK_DOOR_LIGHT_TOPIC "lights/back_door"
 #define WINDOW_LIGHT_TOPIC "lights/window"
// Appliance topics for Devices screen
#define SMART_TV_TOPIC "appliances/tv"
#define MUSIC_SYSTEM_TOPIC "appliances/music"
#define COFFEE_MAKER_TOPIC "appliances/coffee"
#define MUSIC_SONG_TOPIC "appliances/music/song"
 
 // Create instances
 WiFiClient espClient;
 PubSubClient client(espClient);
 
 // Timing variables
 unsigned long lastEnergyRead = 0;
 unsigned long lastPublish = 0;
 const unsigned long ENERGY_READ_INTERVAL = 1000;  // Read ACS712 every 1 second
 const unsigned long PUBLISH_INTERVAL = 5000;      // Publish every 5 seconds
 
 // Helper functions for publishing light states
 void publishLightState(const char* topic, bool state) {
   if (!client.connected()) return;
   client.publish(topic, state ? "ON" : "OFF", true);
 }
 
 void publishAllLightStates() {
   publishLightState(BALCONY_LIGHT_TOPIC, balconyLightState);
   publishLightState(FRONT_DOOR_LIGHT_TOPIC, frontDoorLightState);
   publishLightState(BACK_DOOR_LIGHT_TOPIC, backDoorLightState);
   publishLightState(WINDOW_LIGHT_TOPIC, windowLightState);
 }
 
 void publishApplianceState(const char* topic, bool state) {
   if (!client.connected()) return;
   client.publish(topic, state ? "ON" : "OFF", true);
 }
 
 void publishAllApplianceStates() {
   publishApplianceState(SMART_TV_TOPIC, smartTvState);
   publishApplianceState(MUSIC_SYSTEM_TOPIC, musicSystemState);
   publishApplianceState(COFFEE_MAKER_TOPIC, coffeeMakerState);
 }
 
// Simple blocking tone for compatibility (not used in current implementation, kept for reference)
void playToneBlocking(int frequency, int duration) {
  if (frequency == 0) {
    digitalWrite(MUSIC_BUZZER_PIN, LOW);
    delay(duration);
    return;
  }
  
  int period = 1000000 / frequency;
  int halfPeriod = period / 2;
  int cycles = (duration * 1000) / period;
  
  for (int i = 0; i < cycles; i++) {
    digitalWrite(MUSIC_BUZZER_PIN, HIGH);
    delayMicroseconds(halfPeriod);
    digitalWrite(MUSIC_BUZZER_PIN, LOW);
    delayMicroseconds(halfPeriod);
  }
}

// Structure to hold song notes
struct SongNote {
  int frequency;
  int duration;
};

// Song data arrays
SongNote songHappyBirthday[] = {
  {264, 250}, {264, 125}, {297, 500}, {264, 500}, {352, 500}, {330, 1000},
  {264, 250}, {264, 125}, {297, 500}, {264, 500}, {396, 500}, {352, 1000},
  {264, 250}, {264, 125}, {523, 500}, {440, 500}, {352, 500}, {330, 500}, {297, 1000}
};
const int songHappyBirthdayLen = sizeof(songHappyBirthday) / sizeof(SongNote);

SongNote songJingleBells[] = {
  {330, 200}, {330, 200}, {330, 400}, {330, 200}, {330, 200}, {330, 400},
  {330, 200}, {392, 200}, {262, 300}, {294, 200}, {330, 800},
  {349, 200}, {349, 200}, {349, 200}, {349, 200}, {349, 200},
  {330, 200}, {330, 200}, {330, 200}, {294, 200}, {294, 200}, {330, 200},
  {294, 400}, {392, 400}
};
const int songJingleBellsLen = sizeof(songJingleBells) / sizeof(SongNote);

SongNote songTwinkle[] = {
  {262, 400}, {262, 400}, {392, 400}, {392, 400}, {440, 400}, {440, 400}, {392, 800},
  {349, 400}, {349, 400}, {330, 400}, {330, 400}, {294, 400}, {294, 400}, {262, 800}
};
const int songTwinkleLen = sizeof(songTwinkle) / sizeof(SongNote);

SongNote songMario[] = {
  {659, 125}, {659, 125}, {0, 125}, {659, 125}, {0, 125}, {523, 125}, {659, 250}, {784, 250},
  {0, 250}, {392, 250}, {0, 250}, {523, 125}, {0, 125}, {392, 250}, {0, 250},
  {330, 250}, {0, 250}, {440, 125}, {494, 125}, {466, 125}, {440, 250}
};
const int songMarioLen = sizeof(songMario) / sizeof(SongNote);

SongNote songStarWars[] = {
  {440, 500}, {440, 500}, {440, 500}, {349, 350}, {523, 150}, {440, 500},
  {349, 350}, {523, 150}, {440, 1000}, {659, 500}, {659, 500}, {659, 500},
  {698, 350}, {523, 150}, {415, 500}, {349, 350}, {523, 150}, {440, 1000}
};
const int songStarWarsLen = sizeof(songStarWars) / sizeof(SongNote);

SongNote songBeepBeep[] = {
  {440, 200}, {0, 100}, {523, 200}, {0, 200},
  {440, 200}, {0, 100}, {523, 200}, {0, 200},
  {440, 200}, {0, 100}, {523, 200}, {0, 200}
};
const int songBeepBeepLen = sizeof(songBeepBeep) / sizeof(SongNote);

// Non-blocking song playback
void updateSongPlayback() {
  if (!musicSystemState || !isPlayingSong || shouldStopSong) {
    if (shouldStopSong) {
      isPlayingSong = false;
      shouldStopSong = false;
      currentSongNote = 0;
      currentPlayingSong = "";
      noTone(MUSIC_BUZZER_PIN);
    }
    return;
  }
  
  // Get song data
  SongNote* songData = nullptr;
  int songLen = 0;
  
  if (currentPlayingSong == "Happy Birthday") {
    songData = songHappyBirthday;
    songLen = songHappyBirthdayLen;
  } else if (currentPlayingSong == "Jingle Bells") {
    songData = songJingleBells;
    songLen = songJingleBellsLen;
  } else if (currentPlayingSong == "Twinkle Twinkle") {
    songData = songTwinkle;
    songLen = songTwinkleLen;
  } else if (currentPlayingSong == "Mario Theme") {
    songData = songMario;
    songLen = songMarioLen;
  } else if (currentPlayingSong == "Star Wars") {
    songData = songStarWars;
    songLen = songStarWarsLen;
  } else if (currentPlayingSong == "Beep Beep") {
    songData = songBeepBeep;
    songLen = songBeepBeepLen;
  } else {
    // Unknown song, stop
    Serial.print("🎵 ERROR: Unknown song in playback: ");
    Serial.println(currentPlayingSong);
    isPlayingSong = false;
    currentSongNote = 0;
    currentPlayingSong = "";
    return;
  }
  
  // Debug: Print current note info
  static int lastDebugNote = -1;
  if (currentSongNote != lastDebugNote) {
    Serial.print("🎵 Note ");
    Serial.print(currentSongNote);
    Serial.print("/");
    Serial.print(songLen);
    Serial.print(" - Freq: ");
    Serial.print(songData[currentSongNote].frequency);
    Serial.print("Hz, Duration: ");
    Serial.print(songData[currentSongNote].duration);
    Serial.println("ms");
    lastDebugNote = currentSongNote;
  }
  
  if (currentSongNote >= songLen) {
    // Song finished
    isPlayingSong = false;
    currentSongNote = 0;
    currentPlayingSong = "";
    noTone(MUSIC_BUZZER_PIN);
    Serial.println("🎵 Song finished");
    return;
  }
  
  // Calculate elapsed time since song started
  unsigned long elapsed = millis() - songStartTime;
  
  // Calculate cumulative duration up to current note
  unsigned long noteStartTime = 0;
  for (int i = 0; i < currentSongNote; i++) {
    noteStartTime += songData[i].duration;
  }
  
  unsigned long noteEndTime = noteStartTime + songData[currentSongNote].duration;
  
  // Play current note
  if (elapsed >= noteStartTime && elapsed < noteEndTime) {
    int freq = songData[currentSongNote].frequency;
    static int lastFreq = -1;
    static unsigned long lastNoteStart = 0;
    
    // Only start tone if frequency changed or it's a new note
    if (freq != lastFreq || noteStartTime != lastNoteStart) {
      if (freq == 0) {
        noTone(MUSIC_BUZZER_PIN);
      } else {
        tone(MUSIC_BUZZER_PIN, freq);
      }
      lastFreq = freq;
      lastNoteStart = noteStartTime;
    }
  } else if (elapsed >= noteEndTime) {
    // Move to next note
    currentSongNote++;
    if (currentSongNote >= songLen) {
      // Song finished
      isPlayingSong = false;
      currentSongNote = 0;
      currentPlayingSong = "";
      noTone(MUSIC_BUZZER_PIN);
      Serial.println("🎵 Song finished");
    }
  }
}

// Start playing a song (non-blocking)
void playSong(String songName) {
  // Trim and normalize song name
  songName.trim();
  
  // Stop current song if playing
  if (isPlayingSong) {
    shouldStopSong = true;
    // Don't use delay() - let updateSongPlayback() handle it
  }
  
  if (!musicSystemState) return;
  
  // Check if song name matches
  bool songFound = false;
  if (songName == "Happy Birthday" || songName.indexOf("Happy Birthday") >= 0) {
    currentPlayingSong = "Happy Birthday";
    songFound = true;
  } else if (songName == "Jingle Bells" || songName.indexOf("Jingle Bells") >= 0) {
    currentPlayingSong = "Jingle Bells";
    songFound = true;
  } else if (songName == "Twinkle Twinkle" || songName.indexOf("Twinkle") >= 0) {
    currentPlayingSong = "Twinkle Twinkle";
    songFound = true;
  } else if (songName == "Mario Theme" || songName.indexOf("Mario") >= 0) {
    currentPlayingSong = "Mario Theme";
    songFound = true;
  } else if (songName == "Star Wars" || songName.indexOf("Star Wars") >= 0) {
    currentPlayingSong = "Star Wars";
    songFound = true;
  } else if (songName == "Beep Beep" || songName.indexOf("Beep") >= 0) {
    currentPlayingSong = "Beep Beep";
    songFound = true;
  }
  
  if (!songFound) {
    Serial.print("🎵 Unknown song: ");
    Serial.println(songName);
    return;
  }
  
  isPlayingSong = true;
  shouldStopSong = false;
  currentSongNote = 0;
  songStartTime = millis();
  
  Serial.print("🎵 Playing song: ");
  Serial.println(currentPlayingSong);
  Serial.print("🎵 Song found: ");
  Serial.println(songFound ? "YES" : "NO");
  // Song playback is now handled by updateSongPlayback() in the main loop
}

void updateApplianceOutputs() {
  // Only update LED if state actually changed to prevent blinking
  static bool lastSmartTvState = false;
  if (smartTvState != lastSmartTvState) {
    digitalWrite(SMART_TV_LED_PIN, smartTvState ? HIGH : LOW);
    lastSmartTvState = smartTvState;
  }

  // Shared buzzer for Smart TV + Coffee Maker
  bool newBuzzerState = (smartTvState || coffeeMakerState);
  if (tvCoffeeBuzzerState != newBuzzerState) {
    tvCoffeeBuzzerState = newBuzzerState;
    digitalWrite(TV_COFFEE_BUZZER_PIN, tvCoffeeBuzzerState ? HIGH : LOW);
  }

  // Music System buzzer is controlled by updateSongPlayback() in main loop
}
 
 // ACS712 Current Reading Function
 float readACS712() {
   // Read multiple samples and average for noise reduction
   float sum = 0;
   int minADC = 1024, maxADC = 0;
   
   for (int i = 0; i < SAMPLES; i++) {
     int adcValue = analogRead(ACS712_PIN);
     float voltage = (adcValue / 1024.0) * ACS712_VCC;  // Convert ADC to voltage
     sum += voltage;
     if (adcValue < minADC) minADC = adcValue;
     if (adcValue > maxADC) maxADC = adcValue;
     delay(2);  // Small delay between samples
   }
   
   float avgVoltage = sum / SAMPLES;
   
   // Calculate current: (voltage - quiescent) / sensitivity
   // For AC current, we need RMS value, but for simplicity, we'll use peak-to-peak
   float voltageOffset = avgVoltage - ACS712_QUIESCENT_VOLTAGE;
   float currentRMS = abs(voltageOffset) / (ACS712_SENSITIVITY / 1000.0);  // Convert mV/A to V/A
   
   // Serial output for debugging (only print occasionally to avoid spam)
   static unsigned long lastDebugPrint = 0;
   if (millis() - lastDebugPrint > 10000) {  // Print every 10 seconds
     Serial.print("🔍 ACS712 Debug - ADC: ");
     Serial.print(minADC);
     Serial.print("-");
     Serial.print(maxADC);
     Serial.print(", Voltage: ");
     Serial.print(avgVoltage, 3);
     Serial.print("V, Offset: ");
     Serial.print(voltageOffset, 3);
     Serial.print("V, Current: ");
     Serial.print(currentRMS, 3);
     Serial.println("A");
     lastDebugPrint = millis();
   }
   
   return currentRMS;
 }
 
 // Read current from ACS712 and calculate power
 void readCurrentAndPower() {
   // Read current from ACS712
   current = readACS712();
   
   // Calculate power (P = V × I for AC)
   power = voltage * current;
   
   // Print to serial monitor periodically
   static unsigned long lastReadPrint = 0;
   if (millis() - lastReadPrint > 2000) {  // Print every 2 seconds
     Serial.print("📊 Reading - Current: ");
     Serial.print(current, 3);
     Serial.print(" A, Power: ");
     Serial.print(power, 1);
     Serial.println(" W");
     lastReadPrint = millis();
   }
 }
 
 // Calculate energy increment (integrate power over time)
 void updateEnergyData() {
   unsigned long now = millis();
   if (lastEnergyUpdate > 0) {
     float timeHours = (now - lastEnergyUpdate) / 3600000.0;  // Convert ms to hours
     float energyIncrement = power * timeHours / 1000.0;  // Convert W to kW, then to kWh
     energy += energyIncrement;
     
     // Calculate cost
     cost = energy * COST_PER_KWH;
     
     // For monthly energy, you would reset at start of month
     // For now, use total energy as monthly (you can add EEPROM storage for persistence)
     monthlyEnergy = energy;
     
     // Print energy increment to serial (only if significant)
     static unsigned long lastEnergyPrint = 0;
     if (millis() - lastEnergyPrint > 5000 && energyIncrement > 0.0001) {  // Print every 5 seconds if increment > 0.0001 kWh
       Serial.print("⚡ Energy Update - Increment: ");
       Serial.print(energyIncrement, 6);
       Serial.print(" kWh, Total: ");
       Serial.print(energy, 4);
       Serial.print(" kWh, Cost: ₹");
       Serial.println(cost, 2);
       lastEnergyPrint = millis();
     }
   }
   lastEnergyUpdate = now;
 }
 
 void setup() {
   Serial.begin(115200);
   delay(100);
   
   Serial.println("\n\n====================================");
   Serial.println("⚡ ESP8266 #3 - Energy Monitoring");
   Serial.println("====================================\n");
   
   // Initialize ACS712 sensor pin
   pinMode(ACS712_PIN, INPUT);
   Serial.println("✅ ACS712 Current Sensor initialized");
   Serial.print("   Sensitivity: ");
   Serial.print(ACS712_SENSITIVITY);
   Serial.println(" mV/A");
   Serial.print("   AC Voltage: ");
   Serial.print(AC_VOLTAGE);
   Serial.println("V");
   
   // Initialize optional relay pins
   pinMode(BALCONY_LIGHT_PIN, OUTPUT);
   pinMode(FRONT_DOOR_LIGHT_PIN, OUTPUT);
   pinMode(BACK_DOOR_LIGHT_PIN, OUTPUT);
   pinMode(WINDOW_LIGHT_PIN, OUTPUT);
   pinMode(SMART_TV_LED_PIN, OUTPUT);
   pinMode(TV_COFFEE_BUZZER_PIN, OUTPUT);
   pinMode(MUSIC_BUZZER_PIN, OUTPUT);
   
   // Turn off all devices initially (active LOW relays)
   digitalWrite(BALCONY_LIGHT_PIN, HIGH);
   digitalWrite(FRONT_DOOR_LIGHT_PIN, HIGH);
   digitalWrite(BACK_DOOR_LIGHT_PIN, HIGH);
   digitalWrite(WINDOW_LIGHT_PIN, HIGH);
   updateApplianceOutputs();
   
   // Initialize energy tracking
   lastEnergyUpdate = millis();
   
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
   
   // Control optional devices - only update and publish if state actually changed
   if (topicStr == BALCONY_LIGHT_TOPIC) {
     if (balconyLightState != state) {
       balconyLightState = state;
       digitalWrite(BALCONY_LIGHT_PIN, balconyLightState ? LOW : HIGH);
       Serial.print("💡 Balcony Light: ");
       Serial.println(balconyLightState ? "ON" : "OFF");
       publishLightState(BALCONY_LIGHT_TOPIC, balconyLightState);
     }
   }
   else if (topicStr == FRONT_DOOR_LIGHT_TOPIC) {
     if (frontDoorLightState != state) {
       frontDoorLightState = state;
       digitalWrite(FRONT_DOOR_LIGHT_PIN, frontDoorLightState ? LOW : HIGH);
       Serial.print("💡 Front Door Light: ");
       Serial.println(frontDoorLightState ? "ON" : "OFF");
       publishLightState(FRONT_DOOR_LIGHT_TOPIC, frontDoorLightState);
     }
   }
   else if (topicStr == BACK_DOOR_LIGHT_TOPIC) {
     if (backDoorLightState != state) {
       backDoorLightState = state;
       digitalWrite(BACK_DOOR_LIGHT_PIN, backDoorLightState ? LOW : HIGH);
       Serial.print("💡 Back Door Light: ");
       Serial.println(backDoorLightState ? "ON" : "OFF");
       publishLightState(BACK_DOOR_LIGHT_TOPIC, backDoorLightState);
     }
   }
   else if (topicStr == WINDOW_LIGHT_TOPIC) {
     if (windowLightState != state) {
       windowLightState = state;
       digitalWrite(WINDOW_LIGHT_PIN, windowLightState ? LOW : HIGH);
       Serial.print("💡 Window Light: ");
       Serial.println(windowLightState ? "ON" : "OFF");
       publishLightState(WINDOW_LIGHT_TOPIC, windowLightState);
     }
   }
  else if (topicStr == SMART_TV_TOPIC) {
    if (smartTvState != state) {
      smartTvState = state;
      updateApplianceOutputs();
      Serial.print("📺 Smart TV (LED + Buzzer): ");
      Serial.println(smartTvState ? "ON" : "OFF");
      // Only publish state if it actually changed to prevent feedback loop
      publishApplianceState(SMART_TV_TOPIC, smartTvState);
    }
  }
  else if (topicStr == MUSIC_SYSTEM_TOPIC) {
    if (musicSystemState != state) {
      musicSystemState = state;
      if (musicSystemState) {
        // Music system turned on - play selected song
        playSong(selectedSong);
      } else {
        // Music system turned off - stop song
        shouldStopSong = true;
        isPlayingSong = false;
        noTone(MUSIC_BUZZER_PIN);
      }
      Serial.print("🎵 Music System (Buzzer): ");
      Serial.println(musicSystemState ? "ON" : "OFF");
      publishApplianceState(MUSIC_SYSTEM_TOPIC, musicSystemState);
    }
  }
  else if (topicStr == COFFEE_MAKER_TOPIC) {
    if (coffeeMakerState != state) {
      coffeeMakerState = state;
      updateApplianceOutputs();
      Serial.print("☕ Coffee Maker (Buzzer): ");
      Serial.println(coffeeMakerState ? "ON" : "OFF");
      publishApplianceState(COFFEE_MAKER_TOPIC, coffeeMakerState);
    }
  }
  else if (topicStr == MUSIC_SONG_TOPIC) {
    // Handle song selection - trim and normalize
    String newSong = message;
    newSong.trim();
    
    // Only update if song actually changed
    if (newSong != selectedSong && newSong.length() > 0) {
      selectedSong = newSong;
      Serial.print("🎵 Song selected: ");
      Serial.println(selectedSong);
      
      // If music system is on, play the new song (will interrupt current song)
      if (musicSystemState) {
        playSong(selectedSong);
      }
    }
  }
}
 
 void reconnect() {
   while (!client.connected()) {
     Serial.print("🔄 Attempting MQTT connection... ");
     
     if (client.connect(client_id)) {
       Serial.println("✅ Connected!");
       
       Serial.println("📋 Subscribing to topics:");
       // Subscribe to perimeter lighting control topics
       client.subscribe(BALCONY_LIGHT_TOPIC);
       client.subscribe(FRONT_DOOR_LIGHT_TOPIC);
       client.subscribe(BACK_DOOR_LIGHT_TOPIC);
       client.subscribe(WINDOW_LIGHT_TOPIC);
       Serial.println("  ✓ Lighting topics subscribed");
       publishAllLightStates();
      // Subscribe to appliance control topics
      client.subscribe(SMART_TV_TOPIC);
      client.subscribe(MUSIC_SYSTEM_TOPIC);
      client.subscribe(COFFEE_MAKER_TOPIC);
      client.subscribe(MUSIC_SONG_TOPIC);
      Serial.println("  ✓ Appliance topics subscribed");
      publishAllApplianceStates();
     } else {
       Serial.print("❌ Failed, rc=");
       Serial.print(client.state());
       Serial.println(" - Retrying in 5 seconds...");
       delay(5000);
     }
   }
 }
 
 void publishEnergyData() {
   // Read fresh current and power values
   readCurrentAndPower();
   
   Serial.println("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
   Serial.println("📡 Publishing Energy Data to MQTT");
   Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
   
   // Publish voltage (assumed constant)
   char voltageStr[10];
   dtostrf(voltage, 4, 1, voltageStr);
   client.publish(ENERGY_VOLTAGE_TOPIC, voltageStr, true);
   Serial.print("📤 Voltage: ");
   Serial.print(voltageStr);
   Serial.println(" V");
   
   // Publish current (A)
   char currentStr[10];
   dtostrf(current, 4, 2, currentStr);
   client.publish(ENERGY_CURRENT_TOPIC, currentStr, true);
   Serial.print("📤 Current: ");
   Serial.print(currentStr);
   Serial.println(" A");
   
   // Publish current power (W)
   char powerStr[10];
   dtostrf(power, 4, 1, powerStr);
   client.publish(ENERGY_POWER_TOPIC, powerStr, true);  // Retain for immediate display
   Serial.print("📤 Power: ");
   Serial.print(powerStr);
   Serial.println(" W");
   
   // Publish current consumption (kWh)
   char energyStr[10];
   dtostrf(energy, 4, 3, energyStr);
   client.publish(ENERGY_CONSUMPTION_TOPIC, energyStr, true);  // Retain for immediate display
   Serial.print("📤 Energy Consumption: ");
   Serial.print(energyStr);
   Serial.println(" kWh");
   
   // Publish monthly energy (kWh)
   char monthlyStr[10];
   dtostrf(monthlyEnergy, 4, 3, monthlyStr);
   client.publish(ENERGY_MONTHLY_TOPIC, monthlyStr, true);  // Retain for immediate display
   Serial.print("📤 Monthly Energy: ");
   Serial.print(monthlyStr);
   Serial.println(" kWh");
   
   // Publish cost (₹)
   char costStr[10];
   dtostrf(cost, 4, 2, costStr);
   client.publish(ENERGY_COST_TOPIC, costStr, true);  // Retain for immediate display
   Serial.print("📤 Cost: ₹");
   Serial.println(costStr);
   
   // One-line summary
   Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
   Serial.print("⚡ Summary → V: ");
   Serial.print(voltageStr);
   Serial.print("V | I: ");
   Serial.print(currentStr);
   Serial.print("A | P: ");
   Serial.print(powerStr);
   Serial.print("W | E: ");
   Serial.print(energyStr);
   Serial.print("kWh | Cost: ₹");
   Serial.print(costStr);
   Serial.println();
   Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
 }
 
void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  
  unsigned long now = millis();
  
  // Update non-blocking song playback
  updateSongPlayback();
  
  // Read current and update energy data continuously (for accurate integration)
  readCurrentAndPower();
  updateEnergyData();
   
   // Print periodic status to serial (every 10 seconds)
   static unsigned long lastStatusPrint = 0;
   if (now - lastStatusPrint >= 10000) {
     Serial.println("────────────────────────────────────────");
     Serial.println("📊 Real-time Energy Status");
     Serial.println("────────────────────────────────────────");
     Serial.print("   Voltage: ");
     Serial.print(voltage, 1);
     Serial.println(" V");
     Serial.print("   Current: ");
     Serial.print(current, 3);
     Serial.println(" A");
     Serial.print("   Power: ");
     Serial.print(power, 1);
     Serial.println(" W");
     Serial.print("   Total Energy: ");
     Serial.print(energy, 4);
     Serial.println(" kWh");
     Serial.print("   Total Cost: ₹");
     Serial.println(cost, 2);
     Serial.print("   Monthly Energy: ");
     Serial.print(monthlyEnergy, 4);
     Serial.println(" kWh");
     Serial.println("────────────────────────────────────────\n");
     lastStatusPrint = now;
   }
   
   // Publish energy data periodically
   if (now - lastPublish >= PUBLISH_INTERVAL) {
     lastPublish = now;
     
     if (client.connected()) {
       publishEnergyData();
     } else {
       Serial.println("⚠️  MQTT not connected - skipping publish");
     }
   }
   
   delay(50);  // Small delay for stability
 }
 
 