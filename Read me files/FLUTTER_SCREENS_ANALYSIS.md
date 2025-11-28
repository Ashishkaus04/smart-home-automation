# Flutter App Screens - Complete Device Requirements

## 📱 Screen-by-Screen Analysis

### 1. Dashboard Screen
**Devices Needed:**
- ✅ Lights: Bedroom, Living, Kitchen, Bathroom (ON/OFF)
- ✅ Weather: Temperature, Humidity, AQI
- ✅ Climate: AC (ON/OFF, Temperature 16-30°C)
- ⚠️ Energy: Today kWh, Monthly kWh (display only - needs energy meter)

### 2. Devices Screen
**Devices Needed:**
- ✅ Lights: Bedroom, Living Room, Kitchen, Bathroom (ON/OFF + Intensity 0-100%)
- ✅ Appliances: Smart TV, Music System, Coffee Maker (ON/OFF)

### 3. Security Screen
**Devices Needed:**
- ✅ Security: Armed/Disarmed toggle
- ⚠️ Cameras: Front, Back (status only - no ESP8266 control)
- ✅ Doors: Front, Back (Locked/Unlocked)
- ✅ Windows: Living, Bedroom, Kitchen (Closed/Open)
- ✅ Motion: Living, Bedroom, Kitchen (Detected/Clear)
- ✅ Sensors: Smoke, LPG (ALERT/Normal)

### 4. Energy Screen
**Devices Needed:**
- ⚠️ Energy Meter: Current Usage (kWh), Cost (₹), Monthly usage
- ⚠️ Charts: Today, Week, Month (calculated from energy data)

### 5. Automation Screen
**Devices Referenced:**
- Lights (all rooms)
- Doors (lock/unlock)
- Security (arm/disarm)
- Coffee Maker
- AC

### 6. AI Insights Screen
**Devices Needed:**
- ⚠️ None (analytics only, uses data from other screens)

---

## 📊 Complete Device List from All Screens

### Lights (4 total)
1. Bedroom Light (ON/OFF + Intensity 0-100%)
2. Living Room Light (ON/OFF + Intensity 0-100%)
3. Kitchen Light (ON/OFF + Intensity 0-100%)
4. Bathroom Light (ON/OFF + Intensity 0-100%)

### Appliances (3 total)
1. Smart TV (ON/OFF)
2. Music System (ON/OFF)
3. Coffee Maker (ON/OFF)

### Climate Control (1 total)
1. AC (ON/OFF + Temperature 16-30°C)

### Security - Doors (2 total)
1. Front Door (Locked/Unlocked)
2. Back Door (Locked/Unlocked)

### Security - Windows (3 total)
1. Living Window (Closed/Open)
2. Bedroom Window (Closed/Open)
3. Kitchen Window (Closed/Open)

### Security - Motion Sensors (3 total)
1. Living Motion (Detected/Clear)
2. Bedroom Motion (Detected/Clear)
3. Kitchen Motion (Detected/Clear)

### Security - Other Sensors (2 total)
1. Smoke Sensor (ALERT/Normal)
2. LPG Sensor (ALERT/Normal)

### Security - System (1 total)
1. Security Armed/Disarmed (ON/OFF)

### Sensors - Environment (3 total)
1. Temperature (for Weather/AQI)
2. Humidity (for Weather)
3. AQI (Air Quality Index)

### Energy (1 total - Optional)
1. Energy Meter (kWh, Cost)

### Other (1 total)
1. Buzzer/Alarm (for security alerts)

---

## 🎯 Total Hardware Requirements

**Must Have:**
- 4 Lights (with intensity control ideally)
- 3 Appliances (TV, Music, Coffee)
- 1 AC (with temperature control)
- 2 Doors
- 3 Windows
- 3 Motion Sensors
- 2 Gas Sensors (Smoke, LPG)
- 1 Security System (armed toggle)
- 1 Buzzer
- Temperature & Humidity sensors
- AQI sensor

**Optional:**
- Energy Meter
- Cameras (ESP8266 can't handle video)

---

## 📋 Summary by Category

| Category | Count | Priority |
|----------|-------|----------|
| Lights | 4 | ✅ Must Have |
| Appliances | 3 | ✅ Must Have |
| AC | 1 | ✅ Must Have |
| Doors | 2 | ✅ Must Have |
| Windows | 3 | ✅ Must Have |
| Motion Sensors | 3 | ✅ Must Have |
| Gas Sensors | 2 | ✅ Must Have |
| Security System | 1 | ✅ Must Have |
| Buzzer | 1 | ✅ Must Have |
| Temperature/Humidity | 2 | ✅ Must Have |
| AQI Sensor | 1 | ✅ Must Have |
| Energy Meter | 1 | ⚠️ Optional |
| Cameras | 2 | ❌ Not ESP8266 |

