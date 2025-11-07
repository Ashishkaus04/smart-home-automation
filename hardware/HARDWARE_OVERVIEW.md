# Smart Home Hardware Overview

## 🏠 System Architecture

This smart home automation system uses **3 ESP8266 NodeMCU boards** to distribute automation functions across different areas of the home.

---

## 📊 Board Distribution

### ESP8266 #1 - Living Room & Common Areas
**Location**: Living Room  
**File**: `hardware/arduino_code/esp8266_01_living_room.ino`

**Functions:**
- ✅ Living Room Light Control
- ✅ Kitchen Light Control
- ✅ Bathroom Light Control
- ✅ Fan Control
- ✅ Temperature & Humidity Monitoring (DHT22)

**Components:**
- 1x DHT22 Sensor
- 4-Channel Relay Module
- 1x 10kΩ Resistor

**GPIO Pins Used:**
- D1 (GPIO 5) - Living Room Light
- D2 (GPIO 4) - Kitchen Light
- D4 (GPIO 4) - DHT22 Sensor
- D5 (GPIO 14) - Bathroom Light
- D6 (GPIO 12) - Fan

---

### ESP8266 #2 - Bedroom & Security
**Location**: Bedroom  
**File**: `hardware/arduino_code/esp8266_02_bedroom_security.ino`

**Functions:**
- ✅ Bedroom Light Control
- ✅ Motion Detection (PIR Sensor)
- ✅ Door/Window Sensors (Magnetic)
- ✅ Security Alarm (Buzzer)
- ✅ Security System Arming/Disarming

**Components:**
- 1-3x PIR Motion Sensors (HC-SR501)
- 2-3x Magnetic Door/Window Sensors
- 2-Channel Relay Module
- 1x Active Buzzer (5V)

**GPIO Pins Used:**
- D1 (GPIO 5) - Bedroom Light
- D2 (GPIO 4) - Buzzer Control
- D5 (GPIO 14) - Motion Sensor Input
- D6 (GPIO 12) - Front Door Sensor
- D7 (GPIO 13) - Back Door Sensor

---

### ESP8266 #3 - Outdoor & Appliances
**Location**: Garage/Outdoor  
**File**: `hardware/arduino_code/esp8266_03_outdoor_appliances.ino`

**Functions:**
- ✅ Garage Light Control
- ✅ Garden Light Control
- ✅ Car Charger Control
- ✅ Ambient Light Sensing (LDR, optional)
- ✅ Automatic Garden Light (based on ambient light)

**Components:**
- 3-Channel Relay Module
- 1x LDR (Light Dependent Resistor, optional)
- 1x 10kΩ Resistor (for LDR)

**GPIO Pins Used:**
- D1 (GPIO 5) - Garage Light
- D2 (GPIO 4) - Garden Light
- D5 (GPIO 14) - Car Charger
- A0 - LDR Analog Input (optional)

---

## 🔌 MQTT Topic Structure

All boards communicate via MQTT using the following topic structure:

### Published Topics (ESP8266 → Broker)

**ESP8266 #1:**
- `home/sensors/temperature` - Temperature (°C)
- `home/sensors/humidity` - Humidity (%)
- `home/lights/living_room/state` - Living room light state
- `home/lights/kitchen/state` - Kitchen light state
- `home/lights/bathroom/state` - Bathroom light state
- `home/appliances/fan/state` - Fan state

**ESP8266 #2:**
- `home/security/motion_sensors/living/state` - Motion detected
- `home/security/doors/front/state` - Front door state
- `home/security/doors/back/state` - Back door state
- `home/security/alarm/state` - Alarm state
- `home/lights/bedroom/state` - Bedroom light state
- `home/security/armed/state` - Security armed state

**ESP8266 #3:**
- `home/lights/garage/state` - Garage light state
- `home/lights/garden/state` - Garden light state
- `home/appliances/car_charger/state` - Car charger state
- `home/sensors/light_level` - Ambient light level (0-1024)

### Subscribed Topics (Broker → ESP8266)

**ESP8266 #1:**
- `home/lights/living_room/set` - Control living room light
- `home/lights/kitchen/set` - Control kitchen light
- `home/lights/bathroom/set` - Control bathroom light
- `home/appliances/fan/set` - Control fan

**ESP8266 #2:**
- `home/lights/bedroom/set` - Control bedroom light
- `home/security/armed/set` - Arm/disarm security
- `home/security/buzzer/set` - Control buzzer

**ESP8266 #3:**
- `home/lights/garage/set` - Control garage light
- `home/lights/garden/set` - Control garden light
- `home/appliances/car_charger/set` - Control car charger

---

## 📋 Component Requirements Summary

### Required Components (Total)

| Component | Quantity | Used By |
|-----------|----------|---------|
| ESP8266 NodeMCU | 3 | All boards |
| DHT22 Sensor | 1 | ESP8266 #1 |
| PIR Motion Sensor | 1-3 | ESP8266 #2 |
| Magnetic Door Sensor | 2-3 | ESP8266 #2 |
| 2-Channel Relay Module | 1 | ESP8266 #2 |
| 3-Channel Relay Module | 1 | ESP8266 #3 |
| 4-Channel Relay Module | 1 | ESP8266 #1 |
| Active Buzzer (5V) | 1 | ESP8266 #2 |
| LDR | 1 | ESP8266 #3 (optional) |
| 10kΩ Resistor | 2 | ESP8266 #1, #3 |
| Jumper Wires | 50+ | All boards |
| USB Cables | 3 | All boards |

---

## 🔧 Power Requirements

| Board | Max Current | Power Supply Recommendation |
|-------|-------------|----------------------------|
| ESP8266 #1 | ~500mA | 1A USB or 5V adapter |
| ESP8266 #2 | ~400mA | 1A USB or 5V adapter |
| ESP8266 #3 | ~400mA | 1A USB or 5V adapter |

**Note:** Use quality USB power supplies or external 5V adapters for stable operation, especially when relays are active.

---

## 📚 Documentation

- **[ESP8266_MULTI_BOARD_SETUP.md](./ESP8266_MULTI_BOARD_SETUP.md)** - Complete setup guide with wiring diagrams
- **[ESP8266_SETUP_GUIDE.md](./ESP8266_SETUP_GUIDE.md)** - Single board setup (legacy)

---

## 🚀 Quick Start

1. **Hardware Setup**: Follow [ESP8266_MULTI_BOARD_SETUP.md](./ESP8266_MULTI_BOARD_SETUP.md) for wiring
2. **Software Setup**: 
   - Install Arduino IDE with ESP8266 support
   - Install required libraries (PubSubClient, DHT, etc.)
   - Update WiFi credentials in each .ino file
3. **Upload Code**: Upload each .ino file to its corresponding ESP8266 board
4. **Testing**: Use Serial Monitor to verify connections
5. **Integration**: Connect to MQTT broker and test from web dashboard

---

## 🔐 Security Considerations

1. **Network**: Use secure WiFi (WPA2/WPA3)
2. **MQTT**: Enable authentication on MQTT broker
3. **Physical**: Secure ESP8266 boards in appropriate locations
4. **Updates**: Keep firmware updated
5. **Isolation**: Consider IoT VLAN for network isolation

---

## 📞 Troubleshooting

See [ESP8266_MULTI_BOARD_SETUP.md](./ESP8266_MULTI_BOARD_SETUP.md) for detailed troubleshooting guide.

Common issues:
- WiFi connection problems
- MQTT broker connectivity
- Sensor readings
- Relay polarity (Active LOW vs Active HIGH)

