# ESP8266 Final Architecture - Based on Flutter App Screens

## 🎯 Complete Device Mapping

### ESP8266 #1 - Living Room & Appliances
**Location:** Living Room  
**Purpose:** Main living area devices, appliances, and climate control

**Devices:**
1. ✅ Living Room Light
2. ✅ Kitchen Light  
3. ✅ Bathroom Light
4. ✅ Living Room Fan
5. ✅ Smart TV
6. ✅ Music System
7. ✅ Coffee Maker
8. ✅ AC Control (ON/OFF)
9. ✅ DHT22 (Temperature/Humidity for Dashboard weather)
10. ✅ MQ135 (AQI for Dashboard)
11. ✅ Living Motion Sensor
12. ✅ Living Window Sensor

**GPIO Pins:**
```
D1  → Living Room Light Relay
D2  → Kitchen Light Relay
D5  → Bathroom Light Relay
D6  → Fan Relay
D7  → TV Relay
D8  → Music System Relay
D0  → Coffee Maker Relay
D3  → AC Power Relay
D4  → DHT22 DATA
A0  → MQ135 AO (Air Quality)
D9  → Living Motion Sensor (PIR) - Use RX pin (GPIO 3)
D10 → Living Window Sensor (Magnetic) - Use TX pin (GPIO 1) - ⚠️ Use carefully
```

**Note:** D9 (RX) and D10 (TX) are used for Serial, so use carefully or use other pins.

**Better Pin Allocation:**
```
D1  → Living Room Light
D2  → Kitchen Light
D5  → Bathroom Light
D6  → Fan
D7  → TV
D8  → Music
D0  → Coffee Maker
D3  → AC Power
D4  → DHT22 DATA
A0  → MQ135 AO
GPIO 16 (D0) → Living Motion (if available)
GPIO 14 (D5) → Already used, need alternative
```

**Revised Practical Allocation:**
```
D1  → Living Room Light
D2  → Kitchen Light
D5  → Bathroom Light
D6  → Fan
D7  → TV
D8  → Music
D4  → DHT22 DATA
A0  → MQ135 AO
D3  → Living Motion Sensor
D0  → Living Window Sensor
```

**For Coffee Maker & AC, use:**
- Option 1: Add 2 more relay channels (need 8-channel relay)
- Option 2: Move to ESP8266 #2 or #3
- Option 3: Use I2C GPIO expander

---

### ESP8266 #2 - Bedroom & Security
**Location:** Bedroom  
**Purpose:** Bedroom control and complete security system

**Devices:**
1. ✅ Bedroom Light
2. ✅ Bedroom Motion Sensor
3. ✅ Kitchen Motion Sensor
4. ✅ Front Door Sensor
5. ✅ Back Door Sensor
6. ✅ Living Window Sensor (if not on #1)
7. ✅ Bedroom Window Sensor
8. ✅ Kitchen Window Sensor
9. ✅ Smoke Sensor (MQ135 or MQ2)
10. ✅ LPG Sensor (MQ6 or use MQ135)
11. ✅ Security Buzzer
12. ✅ DHT22 (Bedroom Temperature/Humidity)

**GPIO Pins:**
```
D1  → Bedroom Light Relay
D2  → Buzzer Relay
D4  → DHT22 DATA (Bedroom)
D5  → Bedroom Motion Sensor (PIR)
D6  → Kitchen Motion Sensor (PIR)
D7  → Front Door Sensor (Magnetic)
D8  → Back Door Sensor (Magnetic)
D0  → Bedroom Window Sensor
D3  → Kitchen Window Sensor
A0  → Smoke Sensor (MQ135/MQ2) OR LPG Sensor (MQ6)
```

**Issue:** Only 1 analog input (A0) for 2 gas sensors
**Solution:** 
- Use MQ135 for both smoke and LPG (publish to both topics)
- OR use digital output sensors
- OR use I2C ADC expander

---

### ESP8266 #3 - Energy & Optional
**Location:** Garage/Outdoor  
**Purpose:** Energy monitoring and outdoor devices

**Devices:**
1. ✅ Energy Meter (PZEM-004T) - Serial communication
2. ⚠️ Garage Light (optional - not in Flutter screens)
3. ⚠️ Garden Light (optional - not in Flutter screens)
4. ⚠️ Car Charger (optional - not in Flutter screens)

**GPIO Pins:**
```
D6  → Energy Meter RX (Serial)
D7  → Energy Meter TX (Serial)
D1  → Garage Light Relay (optional)
D2  → Garden Light Relay (optional)
D5  → Car Charger Relay (optional)
```

---

## 📋 Complete MQTT Topic Mapping

### ESP8266 #1 Topics:

**Publishes:**
- `living_room/temperature`
- `living_room/humidity`
- `living_room/aqi` (from MQ135)
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

### ESP8266 #2 Topics:

**Publishes:**
- `bedroom/temperature`
- `bedroom/humidity`
- `bedroom/motion`
- `kitchen/motion`
- `security/door/front`
- `security/door/back`
- `security/window/bedroom`
- `security/window/kitchen`
- `security/smoke`
- `security/lpg`
- `security/buzzer`

**Subscribes:**
- `bedroom/light`
- `security/armed`
- `security/buzzer`

### ESP8266 #3 Topics:

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

## ⚠️ Practical Limitations & Solutions

### Issue 1: GPIO Pin Limitations
**Problem:** ESP8266 has ~11 usable GPIO pins, but we need more
**Solutions:**
1. Use I2C GPIO expander (MCP23017) for additional digital I/O
2. Use I2C ADC expander (ADS1115) for multiple analog sensors
3. Redistribute devices across boards
4. Use Serial communication for some devices

### Issue 2: Light Intensity Control
**Problem:** Flutter shows 0-100% intensity, but ESP8266 only has ON/OFF relays
**Solutions:**
1. Use PWM-capable relays
2. Use dimmer modules (TRIAC-based)
3. Use smart dimmer switches
4. Keep ON/OFF only (simpler, cheaper)

### Issue 3: AC Temperature Control
**Problem:** Flutter shows AC with temperature control (16-30°C)
**Solutions:**
1. Use IR blaster module (IRremote library)
2. Use smart AC controller
3. Use smart thermostat
4. Keep ON/OFF only (simpler)

### Issue 4: Multiple Analog Sensors
**Problem:** ESP8266 has only 1 analog input (A0)
**Solutions:**
1. Use I2C ADC expander (ADS1115)
2. Use digital output sensors (with threshold)
3. Use MQ135 for both smoke and LPG (publish to both topics)
4. Use multiplexer

---

## 🎯 Recommended Practical Setup

### Phase 1: Core Features (Start Here)

**ESP8266 #1:**
- 3 Lights (Living, Kitchen, Bathroom)
- Fan
- DHT22 (Temperature/Humidity)
- MQ135 (AQI)
- Living Motion
- Living Window

**ESP8266 #2:**
- Bedroom Light
- 2 Motion Sensors (Bedroom, Kitchen)
- 2 Door Sensors (Front, Back)
- 3 Window Sensors (Living, Bedroom, Kitchen)
- MQ135 (Smoke - use same sensor, publish to smoke topic)
- Buzzer
- DHT22 (Bedroom)

**ESP8266 #3:**
- Energy Meter (PZEM-004T)

### Phase 2: Add Appliances

Add to ESP8266 #1:
- TV, Music, Coffee Maker (need more relay channels)

### Phase 3: Add AC Control

Add to ESP8266 #1:
- AC Control (IR blaster or smart controller)

### Phase 4: Add LPG Sensor

Add to ESP8266 #2:
- MQ6 LPG Sensor (use I2C ADC expander or digital output)

---

## 📦 Final Component List

### ESP8266 #1:
- ESP8266 NodeMCU × 1
- 6-8 Channel Relay Module × 1
- DHT22 × 1
- MQ135 × 1
- PIR Motion Sensor × 1
- Magnetic Window Sensor × 1
- 10kΩ Resistor × 1

### ESP8266 #2:
- ESP8266 NodeMCU × 1
- 2-Channel Relay Module × 1
- DHT22 × 1
- MQ135 × 1 (for smoke)
- MQ6 × 1 (LPG) - OR use MQ135 for both
- PIR Motion Sensor × 2
- Magnetic Door Sensor × 2
- Magnetic Window Sensor × 3
- Active Buzzer × 1
- 10kΩ Resistor × 1
- I2C ADC Expander (optional, if using MQ6)

### ESP8266 #3:
- ESP8266 NodeMCU × 1
- PZEM-004T Energy Meter × 1
- 3-Channel Relay Module × 1 (optional)

---

This architecture matches what the Flutter app screens actually show!

