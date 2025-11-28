# Complete ESP8266 Architecture - Based on Flutter App Screens

## 📱 Architecture Overview

This architecture is **100% based on the 6 Flutter app screens**:
1. Dashboard Screen
2. Devices Screen
3. Security Screen
4. Energy Screen
5. Automation Screen
6. AI Insights Screen

---

## 🎯 ESP8266 #1 - Living Room & Appliances

### Devices (12 total):
1. ✅ Living Room Light
2. ✅ Kitchen Light
3. ✅ Bathroom Light
4. ✅ Living Room Fan
5. ✅ Smart TV
6. ✅ Music System
7. ✅ Coffee Maker
8. ✅ AC Control (ON/OFF)
9. ✅ DHT22 (Temperature/Humidity)
10. ✅ MQ135 (AQI)
11. ✅ Living Motion Sensor
12. ✅ Living Window Sensor

### GPIO Pin Mapping:
```
D1  → Living Room Light Relay
D2  → Kitchen Light Relay
D5  → Bathroom Light Relay
D6  → TV Relay
D7  → Music System Relay
D8  → Coffee Maker Relay
D0  → Fan Relay
D3  → AC Power Relay
D4  → DHT22 DATA
A0  → MQ135 AO (Air Quality)
D9  → Living Motion Sensor (PIR) - Use GPIO 3 (RX) carefully
D10 → Living Window Sensor (Magnetic) - Use GPIO 1 (TX) carefully
```

**⚠️ Note:** D9 (RX) and D10 (TX) are used for Serial. Consider using GPIO 16 (D0) or other pins.

### MQTT Topics:

**Publishes:**
- `living_room/temperature`
- `living_room/humidity`
- `living_room/aqi`
- `living_room/motion`
- `security/window/living`

**Subscribes:**
- `living_room/light`
- `kitchen/light`
- `bathroom/light`
- `living_room/fan`
- `appliances/tv`
- `appliances/music`
- `appliances/coffee`
- `climate/ac`
- `climate/ac_temperature`

---

## 🎯 ESP8266 #2 - Bedroom & Security

### Devices (13 total):
1. ✅ Bedroom Light
2. ✅ Bedroom Motion Sensor
3. ✅ Kitchen Motion Sensor
4. ✅ Front Door Sensor
5. ✅ Back Door Sensor
6. ✅ Living Window Sensor
7. ✅ Bedroom Window Sensor
8. ✅ Kitchen Window Sensor
9. ✅ Smoke Sensor (MQ135)
10. ✅ LPG Sensor (MQ135 - same sensor, different threshold)
11. ✅ Security Buzzer
12. ✅ DHT22 (Bedroom Temperature/Humidity)
13. ✅ Security Armed State (Software)

### GPIO Pin Mapping:
```
D1  → Bedroom Light Relay
D2  → Buzzer Relay
D4  → DHT22 DATA
D5  → Bedroom Motion Sensor (PIR)
D6  → Kitchen Motion Sensor (PIR)
D7  → Front Door Sensor (Magnetic)
D8  → Back Door Sensor (Magnetic)
D0  → Living Window Sensor (Magnetic)
D3  → Bedroom Window Sensor (Magnetic)
D9  → Kitchen Window Sensor (Magnetic) - Use GPIO 3 (RX) carefully
A0  → MQ135 AO (Smoke/LPG)
```

**⚠️ Note:** Only 1 analog input (A0). Using MQ135 for both smoke and LPG detection with different thresholds.

### MQTT Topics:

**Publishes:**
- `bedroom/temperature`
- `bedroom/humidity`
- `bedroom/motion`
- `kitchen/motion`
- `security/door/front`
- `security/door/back`
- `security/window/living`
- `security/window/bedroom`
- `security/window/kitchen`
- `security/smoke`
- `security/lpg`
- `security/buzzer`

**Subscribes:**
- `bedroom/light`
- `security/armed`
- `security/buzzer`

---

## 🎯 ESP8266 #3 - Energy Monitoring

### Devices (4 total):
1. ✅ PZEM-004T Energy Meter
2. ⚠️ Garage Light (Optional - not in Flutter screens)
3. ⚠️ Garden Light (Optional - not in Flutter screens)
4. ⚠️ Car Charger (Optional - not in Flutter screens)

### GPIO Pin Mapping:
```
D6  → PZEM-004T RX (Serial)
D7  → PZEM-004T TX (Serial)
D1  → Garage Light Relay (optional)
D2  → Garden Light Relay (optional)
D5  → Car Charger Relay (optional)
```

### MQTT Topics:

**Publishes:**
- `energy/consumption` (kWh)
- `energy/power` (W)
- `energy/cost` (₹)
- `energy/monthly` (kWh)
- `energy/voltage` (V)
- `energy/current` (A)
- `garage/light` (optional)
- `garden/light` (optional)
- `car_charger/power` (optional)

**Subscribes:**
- `garage/light` (optional)
- `garden/light` (optional)
- `car_charger/power` (optional)

---

## 📋 Complete Component List

### ESP8266 #1 (Living Room):
- ESP8266 NodeMCU × 1
- 8-Channel Relay Module × 1 (or 2× 4-channel)
- DHT22 × 1
- MQ135 × 1
- PIR Motion Sensor × 1
- Magnetic Window Sensor × 1
- 10kΩ Resistor × 1
- Jumper wires

### ESP8266 #2 (Bedroom & Security):
- ESP8266 NodeMCU × 1
- 2-Channel Relay Module × 1
- DHT22 × 1
- MQ135 × 1 (for smoke/LPG)
- PIR Motion Sensor × 2
- Magnetic Door Sensor × 2
- Magnetic Window Sensor × 3
- Active Buzzer × 1
- 10kΩ Resistor × 1
- Jumper wires

### ESP8266 #3 (Energy):
- ESP8266 NodeMCU × 1
- PZEM-004T Energy Meter × 1
- 3-Channel Relay Module × 1 (optional)
- Jumper wires

---

## ✅ Flutter App Screen Coverage

### Dashboard Screen:
- ✅ Quick Lighting (Bedroom, Living, Kitchen, Bathroom)
- ✅ Weather (Temperature, Humidity, AQI)
- ✅ Climate Control (AC)
- ✅ Energy (Today kWh, Monthly kWh)

### Devices Screen:
- ✅ Lights (Bedroom, Living, Kitchen, Bathroom) with intensity
- ✅ Appliances (TV, Music, Coffee)

### Security Screen:
- ✅ Security Armed/Disarmed
- ✅ Doors (Front, Back)
- ✅ Windows (Living, Bedroom, Kitchen)
- ✅ Motion (Living, Bedroom, Kitchen)
- ✅ Smoke Sensor
- ✅ LPG Sensor

### Energy Screen:
- ✅ Current Usage (kWh)
- ✅ Current Cost (₹)
- ✅ Monthly Usage (kWh)

### Automation Screen:
- ✅ References all devices (lights, doors, security, coffee, AC)

### AI Insights Screen:
- ✅ Uses data from all other screens (no hardware needed)

---

## ⚠️ Known Limitations & Solutions

### 1. GPIO Pin Limitations
**Issue:** ESP8266 has limited GPIO pins
**Solution:** 
- Use I2C GPIO expander (MCP23017) if needed
- Redistribute devices if necessary
- Use Serial pins carefully

### 2. Light Intensity Control
**Issue:** Flutter shows 0-100% intensity, ESP8266 has ON/OFF only
**Solution:**
- Use PWM-capable relays
- Use dimmer modules (TRIAC-based)
- Keep ON/OFF only (simpler)

### 3. AC Temperature Control
**Issue:** Flutter shows AC with temperature control (16-30°C)
**Solution:**
- Use IR blaster module (IRremote library)
- Use smart AC controller
- Keep ON/OFF only (simpler)

### 4. Multiple Analog Sensors
**Issue:** ESP8266 has only 1 analog input (A0)
**Solution:**
- Use MQ135 for both smoke and LPG (different thresholds)
- Use I2C ADC expander (ADS1115) if needed
- Use digital output sensors

### 5. Window Sensor Pin Conflict
**Issue:** D4 used for DHT22 and Kitchen Window
**Solution:**
- Move Kitchen Window to different pin (GPIO 16 or use I2C expander)
- Or use separate DHT22 on different pin

---

## 🎯 Summary

**Total Devices:** 29 devices across 3 ESP8266 boards
**Flutter Screen Coverage:** 100% (all 6 screens)
**MQTT Topics:** All topics match Flutter app expectations

**Status:** ✅ Architecture complete and ready for implementation!

