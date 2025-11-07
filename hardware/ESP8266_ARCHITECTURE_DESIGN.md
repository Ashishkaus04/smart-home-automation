# ESP8266 Architecture Design - Based on Flutter App Screens

## 🎯 Design Philosophy

**Distribute devices across 3 ESP8266 boards based on:**
1. Physical location (room-based grouping)
2. Function type (security, climate, appliances)
3. GPIO pin availability
4. Power requirements

---

## 📐 ESP8266 #1 - Living Room & Common Areas

### Location: Living Room

### Devices Assigned:
1. **Living Room Light** (ON/OFF + Intensity)
2. **Kitchen Light** (ON/OFF + Intensity)
3. **Bathroom Light** (ON/OFF + Intensity)
4. **Living Room Fan** (ON/OFF)
5. **AC Control** (ON/OFF + Temperature)
6. **Smart TV** (ON/OFF)
7. **Music System** (ON/OFF)
8. **Coffee Maker** (ON/OFF)
9. **Temperature Sensor** (DHT22)
10. **Humidity Sensor** (DHT22)
11. **AQI Sensor** (for weather display)
12. **Living Motion Sensor** (PIR)
13. **Living Window Sensor** (Magnetic)

### GPIO Pin Allocation:
```
D1  → Living Room Light Relay
D2  → Kitchen Light Relay
D5  → Bathroom Light Relay
D6  → Fan Relay
D7  → AC Power Relay
D8  → TV Relay
D4  → DHT22 (Temperature/Humidity)
A0  → AQI Sensor (or use MQ135)
D3  → Living Motion Sensor (PIR)
D0  → Living Window Sensor (Magnetic)
```

**Note:** Need 8-channel relay module or multiple relay modules

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
- `climate/ac`
- `climate/ac_temperature`
- `appliances/tv`
- `appliances/music`
- `appliances/coffee`

---

## 📐 ESP8266 #2 - Bedroom & Security

### Location: Bedroom

### Devices Assigned:
1. **Bedroom Light** (ON/OFF + Intensity)
2. **Bedroom Motion Sensor** (PIR)
3. **Kitchen Motion Sensor** (PIR)
4. **Front Door Sensor** (Magnetic)
5. **Back Door Sensor** (Magnetic)
6. **Bedroom Window Sensor** (Magnetic)
7. **Kitchen Window Sensor** (Magnetic)
8. **Smoke Sensor** (MQ135 or MQ2)
9. **LPG Sensor** (MQ6 or use MQ135)
10. **Security Armed Toggle** (Software)
11. **Buzzer/Alarm** (Active Buzzer)
12. **Bedroom Temperature** (DHT22 - optional, for bedroom climate)
13. **Bedroom Humidity** (DHT22 - optional)

### GPIO Pin Allocation:
```
D1  → Bedroom Light Relay
D2  → Buzzer Relay
D4  → DHT22 (Bedroom Temperature/Humidity) - Optional
D5  → Bedroom Motion Sensor (PIR)
D6  → Kitchen Motion Sensor (PIR)
D7  → Front Door Sensor (Magnetic)
D8  → Back Door Sensor (Magnetic)
D0  → Bedroom Window Sensor (Magnetic)
D3  → Kitchen Window Sensor (Magnetic)
A0  → Smoke Sensor (MQ135/MQ2)
```

**Note:** May need analog multiplexer if using multiple analog sensors

### MQTT Topics:
**Publishes:**
- `bedroom/motion`
- `kitchen/motion`
- `security/door/front`
- `security/door/back`
- `security/window/bedroom`
- `security/window/kitchen`
- `security/smoke`
- `security/lpg`
- `bedroom/temperature` (optional)
- `bedroom/humidity` (optional)

**Subscribes:**
- `bedroom/light`
- `security/armed`
- `security/buzzer`

---

## 📐 ESP8266 #3 - Outdoor & Energy

### Location: Garage/Outdoor

### Devices Assigned:
1. **Garage Light** (ON/OFF) - Optional, not in Flutter screens
2. **Garden Light** (ON/OFF) - Optional, not in Flutter screens
3. **Car Charger** (ON/OFF) - Optional, not in Flutter screens
4. **Energy Meter** (PZEM-004T) - For Energy Screen
5. **LDR** (Optional - for garden light automation)

### GPIO Pin Allocation:
```
D1  → Garage Light Relay (optional)
D2  → Garden Light Relay (optional)
D5  → Car Charger Relay (optional)
D6  → Energy Meter RX (Serial)
D7  → Energy Meter TX (Serial)
A0  → LDR (optional)
```

### MQTT Topics:
**Publishes:**
- `energy/consumption` (kWh)
- `energy/power` (W)
- `energy/cost` (₹)
- `garage/light` (optional)
- `garden/light` (optional)
- `car_charger/power` (optional)

**Subscribes:**
- `garage/light` (optional)
- `garden/light` (optional)
- `car_charger/power` (optional)

---

## ⚠️ Issues with Current Design

### Problem 1: Too Many Devices for ESP8266 #1
**Current:** 13 devices on ESP8266 #1
**Issue:** ESP8266 has limited GPIO pins (only ~11 usable)
**Solution:** Redistribute or use I2C/SPI expanders

### Problem 2: Light Intensity Control
**Flutter App:** Shows intensity slider (0-100%)
**Current ESP8266:** Only ON/OFF relays
**Solution:** Use PWM-capable relays or dimmer modules

### Problem 3: AC Temperature Control
**Flutter App:** AC with temperature control (16-30°C)
**Current ESP8266:** Only ON/OFF relay
**Solution:** Use IR blaster or smart AC controller

### Problem 4: Multiple Analog Sensors
**ESP8266 #2:** Needs Smoke + LPG sensors
**Issue:** ESP8266 has only 1 analog input (A0)
**Solution:** Use I2C ADC expander or digital output sensors

---

## 🔧 Revised Architecture (Practical)

### ESP8266 #1 - Living Room & Appliances
**Focus:** Main living area devices

**Devices:**
1. Living Room Light
2. Kitchen Light
3. Bathroom Light
4. Living Room Fan
5. Smart TV
6. Music System
7. Coffee Maker
8. DHT22 (Temperature/Humidity)
9. MQ135 (AQI/Smoke - can serve dual purpose)
10. Living Motion Sensor
11. Living Window Sensor

**Relays Needed:** 7-channel relay module
**Sensors:** DHT22, MQ135, PIR, Magnetic sensor

### ESP8266 #2 - Bedroom & Security
**Focus:** Security and bedroom

**Devices:**
1. Bedroom Light
2. Bedroom Motion Sensor
3. Kitchen Motion Sensor
4. Front Door Sensor
5. Back Door Sensor
6. Bedroom Window Sensor
7. Kitchen Window Sensor
8. Smoke Sensor (MQ135 - already on #1, or add MQ2)
9. LPG Sensor (MQ6 or use MQ135 for both)
10. Security Buzzer
11. DHT22 (Bedroom Temperature/Humidity)

**Relays Needed:** 1-channel (bedroom light) + Buzzer
**Sensors:** 2x PIR, 4x Magnetic, 1-2x Gas sensors, DHT22

### ESP8266 #3 - Energy & Optional
**Focus:** Energy monitoring

**Devices:**
1. Energy Meter (PZEM-004T)
2. Garage Light (optional)
3. Garden Light (optional)
4. Car Charger (optional)

**Relays Needed:** 3-channel (optional devices)
**Sensors:** Energy meter (Serial communication)

---

## 📋 Revised Component List

### ESP8266 #1 (Living Room):
- ESP8266 NodeMCU × 1
- 7-Channel Relay Module × 1 (or 2x 4-channel)
- DHT22 × 1
- MQ135 × 1 (for AQI/Smoke)
- PIR Motion Sensor × 1
- Magnetic Window Sensor × 1
- 10kΩ Resistor × 1

### ESP8266 #2 (Bedroom & Security):
- ESP8266 NodeMCU × 1
- 2-Channel Relay Module × 1
- DHT22 × 1
- MQ135 × 1 (or MQ2 for smoke)
- MQ6 × 1 (LPG) - OR use MQ135 for both
- PIR Motion Sensor × 2
- Magnetic Door Sensor × 2
- Magnetic Window Sensor × 2
- Active Buzzer × 1
- 10kΩ Resistor × 1
- I2C ADC Expander (optional, if need multiple analog sensors)

### ESP8266 #3 (Energy):
- ESP8266 NodeMCU × 1
- PZEM-004T Energy Meter × 1
- 3-Channel Relay Module × 1 (optional)
- LDR × 1 (optional)
- 10kΩ Resistor × 1 (if using LDR)

---

## 🎯 Final Recommendation

**For MVP (Minimum Viable Product):**

**ESP8266 #1:**
- 4 Lights (Living, Kitchen, Bathroom, Bedroom - move bedroom here)
- 3 Appliances (TV, Music, Coffee)
- Fan
- DHT22
- MQ135 (AQI)
- Living Motion
- Living Window

**ESP8266 #2:**
- Bedroom Light (move from #1)
- 2 Motion Sensors (Bedroom, Kitchen)
- 2 Door Sensors (Front, Back)
- 3 Window Sensors (Living, Bedroom, Kitchen)
- MQ135 (Smoke - use same sensor for both AQI and smoke)
- Buzzer
- DHT22 (Bedroom)

**ESP8266 #3:**
- Energy Meter (PZEM-004T)
- Optional: Garage, Garden, Car Charger

This balances the load better and uses available GPIO pins efficiently.

