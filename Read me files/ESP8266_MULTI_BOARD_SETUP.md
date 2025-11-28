# ESP8266 Multi-Board Smart Home Setup Guide

## 📋 Overview

This project uses **3 ESP8266 NodeMCU boards** to distribute smart home automation functions:

- **ESP8266 #1**: Living Room & Common Areas (Lights, Fan, DHT22 Sensor)
- **ESP8266 #2**: Bedroom & Security (Light, Motion Sensors, Door Sensors, Buzzer)
- **ESP8266 #3**: Outdoor & Appliances (Garage Light, Garden Light, Car Charger)

---

## 🔧 Hardware Components Required

### For ESP8266 #1 (Living Room & Common Areas):
1. **ESP8266 NodeMCU** × 1
2. **DHT22 Temperature & Humidity Sensor** × 1
3. **4-Channel Relay Module** (5V) × 1
4. **10kΩ Resistor** × 1 (for DHT22)
5. **Jumper Wires** × 10-15
6. **USB Cable** × 1

### For ESP8266 #2 (Bedroom & Security):
1. **ESP8266 NodeMCU** × 1
2. **PIR Motion Sensor** (HC-SR501) × 1-3
3. **Magnetic Door/Window Sensor** × 2-3
4. **2-Channel Relay Module** (5V) × 1
5. **Buzzer** (5V active buzzer) × 1
6. **Jumper Wires** × 15-20
7. **USB Cable** × 1

### For ESP8266 #3 (Outdoor & Appliances):
1. **ESP8266 NodeMCU** × 1
3. **3-Channel Relay Module** (5V) × 1
4. **LDR (Light Dependent Resistor)** × 1 (optional, for garden light automation)
5. **10kΩ Resistor** × 1 (for LDR, if used)
6. **Jumper Wires** × 10-15
7. **USB Cable** × 1

---

## 🔌 ESP8266 #1 - Living Room & Common Areas

### Pin Connections

#### DHT22 Sensor
```
DHT22 VCC   → 3V3 (ESP8266)
DHT22 GND   → GND (ESP8266)
DHT22 DATA  → D4 (GPIO 4)
10kΩ Resistor between DATA and VCC (pull-up)
```

#### 4-Channel Relay Module
```
Relay Module VCC  → 5V (ESP8266)
Relay Module GND  → GND (ESP8266)

Relay 1 (Living Room Light) → D1 (GPIO 5)
Relay 2 (Kitchen Light)     → D2 (GPIO 4)
Relay 3 (Bathroom Light)    → D5 (GPIO 14)
Relay 4 (Fan)               → D6 (GPIO 12)
```

### Circuit Diagram
```
ESP8266 NodeMCU #1
┌─────────────────────────────┐
│ 3V3 ── VCC DHT22            │
│ GND ── GND DHT22            │
│ D4  ── DATA DHT22 (10kΩ)    │
│                             │
│ 5V  ── VCC Relay Module     │
│ GND ── GND Relay Module     │
│                             │
│ D1  ── Relay 1 IN (Living)  │
│ D2  ── Relay 2 IN (Kitchen) │
│ D5  ── Relay 3 IN (Bathroom)│
│ D6  ── Relay 4 IN (Fan)     │
└─────────────────────────────┘
```

### MQTT Topics
**Published:**
- `home/sensors/temperature` - Temperature in °C
- `home/sensors/humidity` - Humidity in %

**Subscribed:**
- `home/lights/living_room/set` - Control living room light (ON/OFF)
- `home/lights/kitchen/set` - Control kitchen light (ON/OFF)
- `home/lights/bathroom/set` - Control bathroom light (ON/OFF)
- `home/appliances/fan/set` - Control fan (ON/OFF)

---

## 🔌 ESP8266 #2 - Bedroom & Security

### Pin Connections

#### PIR Motion Sensor (HC-SR501)
```
PIR VCC  → 5V (ESP8266)
PIR GND  → GND (ESP8266)
PIR OUT  → D5 (GPIO 14)
```

**Note:** Adjust sensitivity and delay on the PIR sensor board itself using the potentiometers.

#### Magnetic Door Sensors
```
Front Door Sensor:
  VCC → 3V3 (ESP8266)
  GND → GND (ESP8266)
  DO  → D6 (GPIO 12)

Back Door Sensor:
  VCC → 3V3 (ESP8266)
  GND → GND (ESP8266)
  DO  → D7 (GPIO 13)
```

**Note:** Magnetic sensors output LOW when closed (magnet near sensor), HIGH when open.

#### 2-Channel Relay Module
```
Relay Module VCC  → 5V (ESP8266)
Relay Module GND  → GND (ESP8266)

Relay 1 (Bedroom Light) → D1 (GPIO 5)
Relay 2 (Buzzer)        → D2 (GPIO 4)
```

#### Buzzer (5V Active Buzzer)
```
Buzzer + → Relay 2 COM (Common)
Buzzer - → GND
Relay 2 NO (Normally Open) → 5V
```
**Note:** When relay is activated, buzzer circuit completes.

### Circuit Diagram
```
ESP8266 NodeMCU #2
┌─────────────────────────────┐
│ 5V  ── VCC PIR Sensor       │
│ GND ── GND PIR Sensor       │
│ D5  ── OUT PIR Sensor       │
│                             │
│ 3V3 ── VCC Door Sensor 1    │
│ GND ── GND Door Sensor 1    │
│ D6  ── DO Door Sensor 1     │
│                             │
│ 3V3 ── VCC Door Sensor 2    │
│ GND ── GND Door Sensor 2    │
│ D7  ── DO Door Sensor 2     │
│                             │
│ 5V  ── VCC Relay Module     │
│ GND ── GND Relay Module     │
│                             │
│ D1  ── Relay 1 IN (Bedroom) │
│ D2  ── Relay 2 IN (Buzzer)  │
│                             │
│ Relay 2: COM → Buzzer+      │
│          NO  → 5V           │
│          GND → GND          │
└─────────────────────────────┘
```

### MQTT Topics
**Published:**
- `home/security/motion_sensors/living/state` - Motion detected (ON/OFF)
- `home/security/doors/front/state` - Front door state (LOCKED/UNLOCKED)
- `home/security/doors/back/state` - Back door state (LOCKED/UNLOCKED)
- `home/security/alarm/state` - Alarm/buzzer state (ON/OFF)

**Subscribed:**
- `home/lights/bedroom/set` - Control bedroom light (ON/OFF)
- `home/security/armed/set` - Arm/disarm security (ON/OFF)
- `home/security/buzzer/set` - Control buzzer directly (ON/OFF)

---

## 🔌 ESP8266 #3 - Outdoor & Appliances

### Pin Connections

#### 3-Channel Relay Module
```
Relay Module VCC  → 5V (ESP8266)
Relay Module GND  → GND (ESP8266)

Relay 1 (Garage Light) → D1 (GPIO 5)
Relay 2 (Garden Light) → D2 (GPIO 4)
Relay 3 (Car Charger)  → D5 (GPIO 14)
```

#### LDR (Light Dependent Resistor) - Optional
```
LDR Circuit:
  ┌─── A0 (ESP8266) ────┐
  │                     │
  LDR             10kΩ Resistor
  │                     │
  └─── 3V3 ─────────────┘
  
LDR one leg → A0 (ESP8266)
LDR other leg → 3V3
10kΩ Resistor: one leg → A0, other leg → GND
```

**Note:** This creates a voltage divider. Higher light = higher voltage reading.

### Circuit Diagram
```
ESP8266 NodeMCU #3
┌─────────────────────────────┐
│ 5V  ── VCC Relay Module     │
│ GND ── GND Relay Module     │
│                             │
│ D1  ── Relay 1 IN (Garage)  │
│ D2  ── Relay 2 IN (Garden)  │
│ D5  ── Relay 3 IN (Car)     │
│                             │
│ A0  ── LDR (Optional)       │
│      (with 10kΩ pull-down)  │
└─────────────────────────────┘
```

### MQTT Topics
**Published:**
- `home/lights/garage/state` - Garage light state (ON/OFF)
- `home/lights/garden/state` - Garden light state (ON/OFF)
- `home/appliances/car_charger/state` - Car charger state (ON/OFF)
- `home/sensors/light_level` - Ambient light level (0-1024, optional)

**Subscribed:**
- `home/lights/garage/set` - Control garage light (ON/OFF)
- `home/lights/garden/set` - Control garden light (ON/OFF)
- `home/appliances/car_charger/set` - Control car charger (ON/OFF)

---

## 💻 Software Setup

### 1. Install Arduino IDE with ESP8266 Support

1. Install [Arduino IDE](https://www.arduino.cc/en/software)
2. Add ESP8266 board support:
   - Go to `File → Preferences`
   - Add this URL to "Additional Board Manager URLs":
     ```
     http://arduino.esp8266.com/stable/package_esp8266com_index.json
     ```
   - Go to `Tools → Board → Boards Manager`
   - Search "ESP8266" and install
   - Select: `Tools → Board → NodeMCU 1.0 (ESP-12E Module)`

### 2. Install Required Libraries

Go to `Sketch → Include Library → Manage Libraries` and install:
- **ESP8266WiFi** (already included)
- **PubSubClient** by Nick O'Leary
- **DHT sensor library** by Adafruit (for ESP8266 #1)
- **Adafruit Unified Sensor** (dependency for DHT library)

### 3. Configure WiFi & MQTT

For each ESP8266 file, update these lines:

```cpp
// WiFi Configuration
const char* ssid = "YOUR_WIFI_SSID";           // Change this
const char* password = "YOUR_WIFI_PASSWORD";   // Change this

// MQTT Configuration
const char* mqtt_broker = "10.217.139.106";    // MQTT broker IP
const int mqtt_port = 1883;
```

### 4. Upload Code to Each ESP8266

1. **ESP8266 #1**: Open `esp8266_01_living_room.ino` and upload
2. **ESP8266 #2**: Open `esp8266_02_bedroom_security.ino` and upload
3. **ESP8266 #3**: Open `esp8266_03_outdoor_appliances.ino` and upload

**Important:** Upload each file to its corresponding ESP8266 board. Make sure to:
- Select the correct **COM Port** for each board
- Connect only one board at a time (or use different COM ports)
- Verify the upload completes successfully

---

## ✅ Testing Each Board

### Testing ESP8266 #1 (Living Room)
1. Open Serial Monitor (115200 baud)
2. You should see:
   ```
   ✅ WiFi connected!
   ✅ Connected to MQTT broker!
   📤 Published temperature: 23.5°C
   📤 Published humidity: 45.0%
   ```
3. Test lights by publishing to MQTT topics:
   - `home/lights/living_room/set` → `ON`
   - `home/lights/kitchen/set` → `ON`
   - `home/appliances/fan/set` → `ON`

### Testing ESP8266 #2 (Bedroom & Security)
1. Open Serial Monitor (115200 baud)
2. Check motion sensor: Wave hand in front of PIR sensor
3. Check door sensors: Open/close doors and watch serial output
4. Test security: Publish `home/security/armed/set` → `ON`, then trigger motion/door

### Testing ESP8266 #3 (Outdoor & Appliances)
1. Open Serial Monitor (115200 baud)
2. Test lights by publishing to MQTT topics:
   - `home/lights/garage/set` → `ON`
   - `home/lights/garden/set` → `ON`
   - `home/appliances/car_charger/set` → `ON`
3. If LDR is connected, check ambient light readings

---

## 🔄 Relay Polarity Note

**Important:** The code assumes **Active LOW** relays (common cathode). 

If your relay module is **Active HIGH** (common anode), change all relay control lines:

**From:**
```cpp
digitalWrite(PIN, state ? LOW : HIGH);
```

**To:**
```cpp
digitalWrite(PIN, state ? HIGH : LOW);
```

---

## 🚨 Troubleshooting

### WiFi Not Connecting
- Check SSID and password (2.4GHz only, ESP8266 doesn't support 5GHz)
- Move closer to router
- Check router settings (MAC filtering, etc.)

### MQTT Not Connecting
- Verify MQTT broker is running on `10.217.139.106:1883`
- Ensure all ESP8266 boards are on the same network as the broker
- Check firewall settings
- Verify broker allows anonymous connections (or add authentication)

### Sensors Not Working

**DHT22:**
- Verify 10kΩ pull-up resistor between DATA and VCC
- Check connections (VCC, GND, DATA)
- Try different DHT sensor (DHT11 also works)

**PIR Motion Sensor:**
- Adjust sensitivity and delay potentiometers on the sensor board
- Wait 30-60 seconds after power-on for sensor to stabilize
- Check if sensor LED lights up when motion detected

**Door Sensors:**
- Test with magnet: sensor should output LOW when magnet is near
- Check wiring (VCC, GND, DO)
- Verify pull-up resistor if sensor doesn't have built-in pull-up

**LDR:**
- Verify voltage divider circuit (LDR + 10kΩ resistor)
- Check connections (A0, 3V3, GND)
- Test with multimeter: voltage should change with light

### Relays Not Working
- Check relay module power (5V)
- Verify relay connections (IN, VCC, GND)
- Test relay polarity (Active LOW vs Active HIGH)
- Check if relay module has jumper for LOW/HIGH trigger

---

## 📊 Power Requirements

- **ESP8266 NodeMCU**: ~200mA (can draw up to 500mA during WiFi transmission)
- **Relay Module**: ~70mA per relay (when active)
- **DHT22**: ~2.5mA
- **PIR Sensor**: ~65mA
- **Magnetic Sensor**: ~1mA
- **LDR**: ~0.1mA

**Total per board:**
- ESP8266 #1: ~500mA (with all relays active)
- ESP8266 #2: ~400mA (with relays active)
- ESP8266 #3: ~400mA (with relays active)

**Recommendation:** Use quality USB power supplies (1A minimum) or external 5V power supply for relay modules.

---

## 🔐 Security Considerations

1. **Change default WiFi credentials** in code
2. **Use MQTT authentication** in production (username/password)
3. **Use TLS/SSL** for MQTT in production environments
4. **Physical security**: Keep ESP8266 boards in secure locations
5. **Network security**: Isolate IoT devices on separate VLAN if possible

---

## 📞 Support

If you encounter issues:
1. Check Serial Monitor output for error messages
2. Verify all connections match the diagrams
3. Test components individually (relays, sensors)
4. Check MQTT broker logs
5. Verify WiFi signal strength (RSSI > -70 dBm recommended)

---

## 🎯 Next Steps

After hardware setup:
1. Verify all 3 ESP8266 boards connect to MQTT broker
2. Test all devices from the web dashboard
3. Configure automation rules in the backend
4. Set up mobile app connections
5. Configure security system arming/disarming schedules

