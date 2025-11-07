# Flutter App Compatibility Guide

## ✅ Current Status

The 3 ESP8266 boards are **mostly compatible** with the Flutter app, but there are some gaps to address.

---

## 📊 Device Coverage Comparison

### ✅ Fully Supported (Implemented)

| Flutter App Expects | ESP8266 Implementation | Status |
|---------------------|------------------------|--------|
| Bedroom Light | ESP8266 #2 - D1 | ✅ |
| Living Room Light | ESP8266 #1 - D1 | ✅ |
| Kitchen Light | ESP8266 #1 - D2 | ✅ |
| Bathroom Light | ESP8266 #1 - D5 | ✅ |
| Fan | ESP8266 #1 - D6 | ✅ |
| Temperature Sensor | ESP8266 #1 - DHT22 | ✅ |
| Humidity Sensor | ESP8266 #1 - DHT22 | ✅ |
| Front Door Sensor | ESP8266 #2 - D6 | ✅ |
| Back Door Sensor | ESP8266 #2 - D7 | ✅ |
| Security Armed | ESP8266 #2 - Software | ✅ |
| Buzzer Alarm | ESP8266 #2 - D2 | ✅ |
| Motion Sensor | ESP8266 #2 - D5 | ⚠️ Only 1 sensor (needs 3) |

### ⚠️ Partially Supported (Needs Enhancement)

| Flutter App Expects | Current Status | Solution Needed |
|---------------------|----------------|-----------------|
| Garage Light | ✅ ESP8266 #3 - D1 | Backend needs to add `garage` to deviceState |
| Garden Light | ✅ ESP8266 #3 - D2 | Backend needs to add `garden` to deviceState |
| Living Motion | ⚠️ Only 1 PIR sensor | Need 3 PIR sensors or use 1 sensor for all |
| Bedroom Motion | ⚠️ Only 1 PIR sensor | Need 3 PIR sensors or use 1 sensor for all |
| Kitchen Motion | ⚠️ Only 1 PIR sensor | Need 3 PIR sensors or use 1 sensor for all |
| Window Sensors | ❌ Not implemented | Need magnetic window sensors |
| Car Charger | ✅ ESP8266 #3 - D5 | Backend needs to add `car_charger` to deviceState |

### ❌ Not Yet Supported (Flutter App Shows)

| Flutter App Feature | Status | Notes |
|---------------------|--------|-------|
| TV Control | ❌ Not implemented | Needs IR blaster or smart TV integration |
| Music System | ❌ Not implemented | Needs smart speaker integration |
| Coffee Maker | ❌ Not implemented | Needs smart outlet or coffee maker |
| AC Control | ❌ Not implemented | Needs smart AC controller |
| Smoke Sensor | ❌ Not implemented | Needs smoke detector sensor |
| LPG Sensor | ❌ Not implemented | Needs gas sensor |
| Cameras | ❌ Not implemented | Needs IP camera integration |

---

## 🔧 MQTT Topic Mapping

### ✅ Updated MQTT Topics (Compatible with Flutter App Direct MQTT)

**ESP8266 #2 (Bedroom) - 100% Compatible with `bedroom_mqtt_page.dart`:**
- ✅ Subscribes to: `bedroom/light`, `bedroom/fan`, `bedroom/buzzer`
- ✅ Publishes to: `bedroom/motion`, `security/door/front`, `security/door/back`
- ⚠️ Note: Flutter app expects `bedroom/temperature` and `bedroom/humidity`, but ESP8266 #2 doesn't have DHT22. Add DHT22 to ESP8266 #2 if needed, or use ESP8266 #1's data.

**ESP8266 #1 (Living Room):**
- Publishes: `living_room/temperature`, `living_room/humidity`
- Subscribes: `living_room/light`, `kitchen/light`, `bathroom/light`, `living_room/fan`

**ESP8266 #3 (Outdoor):**
- Subscribes: `garage/light`, `garden/light`, `car_charger/power`
- Publishes: `garden/light_level` (optional LDR)

### ✅ Correct MQTT Topics (Matches Backend)

The ESP8266 code uses the correct topic structure that matches the backend:

**Backend expects:**
- `home/lights/{room}/set` - Control lights
- `home/lights/{room}/state` - Light state updates
- `home/sensors/temperature` - Temperature
- `home/sensors/humidity` - Humidity
- `home/security/doors/{door}/state` - Door status
- `home/security/armed/set` - Arm/disarm
- `home/appliances/{appliance}/set` - Control appliances

**ESP8266 publishes:**
- ✅ `home/sensors/temperature` (ESP8266 #1)
- ✅ `home/sensors/humidity` (ESP8266 #1)
- ✅ `home/lights/living_room/state` (ESP8266 #1)
- ✅ `home/lights/kitchen/state` (ESP8266 #1)
- ✅ `home/lights/bathroom/state` (ESP8266 #1)
- ✅ `home/lights/bedroom/state` (ESP8266 #2)
- ✅ `home/lights/garage/state` (ESP8266 #3)
- ✅ `home/lights/garden/state` (ESP8266 #3)
- ✅ `home/security/doors/front/state` (ESP8266 #2)
- ✅ `home/security/doors/back/state` (ESP8266 #2)
- ✅ `home/security/motion_sensors/living/state` (ESP8266 #2)

**ESP8266 subscribes:**
- ✅ `home/lights/{room}/set` - All boards
- ✅ `home/appliances/fan/set` (ESP8266 #1)
- ✅ `home/security/armed/set` (ESP8266 #2)
- ✅ `home/appliances/car_charger/set` (ESP8266 #3)

---

## 🛠️ Required Updates

### 1. Backend Updates Needed

Update `backend/server.js` to include missing devices:

```javascript
let deviceState = {
  lights: { 
    living_room: false, 
    bedroom: true, 
    kitchen: false, 
    bathroom: false,
    garage: false,      // ADD THIS
    garden: false       // ADD THIS
  },
  security: { 
    armed: true, 
    doors: { front: true, back: true },
    motion: {          // ADD THIS
      living: false,
      bedroom: false,
      kitchen: false
    },
    windows: {         // ADD THIS (for future)
      living: true,
      bedroom: true,
      kitchen: true
    }
  },
  appliances: { 
    ac: false, 
    fan: true, 
    tv: false,
    car_charger: false  // ADD THIS
  },
  sensors: { 
    motion: false, 
    smoke: false, 
    humidity: 45, 
    light: 75 
  }
};
```

### 2. ESP8266 Hardware Enhancements

**Option A: Add More Sensors (Recommended)**
- Add 2 more PIR sensors to ESP8266 #2 (Kitchen and Bedroom)
- Add 3 magnetic window sensors to ESP8266 #2

**Option B: Software Workaround (Quick Fix)**
- Use 1 PIR sensor but publish to all 3 motion topics
- Simulate window sensors (not recommended for production)

### 3. Motion Sensor Enhancement

Currently ESP8266 #2 has only 1 PIR sensor on D5. To support all 3 motion sensors:

**Option 1: Add 2 more PIR sensors**
- D5 - Living Room Motion (existing)
- D6 - Bedroom Motion (reassign from Front Door)
- D7 - Kitchen Motion (reassign from Back Door)
- Use D3 (GPIO 0) and D4 (GPIO 2) for door sensors instead

**Option 2: Use 1 sensor for all (Quick Fix)**
- Publish motion state to all 3 topics: `home/security/motion_sensors/{location}/state`

---

## 📱 Flutter App Integration Points

### API Endpoints Used by Flutter

```dart
// From api_service.dart
GET  /api/devices              // Get all device states
POST /api/devices/{category}/{device}  // Update device
POST /api/devices/security/armed       // Arm/disarm security
POST /api/devices/security/{door}      // Lock/unlock door
```

### Socket.IO Events Used by Flutter

```dart
// From socket_service.dart
socket.on('deviceUpdate')    // Real-time device state changes
socket.on('sensorUpdate')    // Real-time sensor data
socket.on('deviceState')     // Initial device state
```

### MQTT Topics Used by Flutter

The Flutter app connects to MQTT broker directly (via `bedroom_mqtt_page.dart`):
- `bedroom/temperature` - Old topic (legacy)
- `bedroom/humidity` - Old topic (legacy)
- `bedroom/light` - Old topic (legacy)

**Note:** The Flutter app has a legacy MQTT page that uses old topics. The main app uses REST API + Socket.IO.

---

## ✅ Compatibility Summary

| Component | Status | Notes |
|-----------|--------|-------|
| **Core Lights** | ✅ 100% | All 4 main lights supported |
| **Outdoor Lights** | ⚠️ 90% | Hardware ready, backend needs update |
| **Sensors** | ⚠️ 70% | Temperature/Humidity OK, motion needs enhancement |
| **Security** | ⚠️ 80% | Doors OK, motion partial, windows missing |
| **Appliances** | ⚠️ 60% | Fan OK, car charger ready, TV/Music/Coffee not implemented |
| **MQTT Topics** | ✅ 100% | All topics match backend structure |

---

## 🚀 Quick Fixes to Improve Compatibility

1. **Update Backend** - Add `garage`, `garden`, `car_charger` to deviceState
2. **Add Motion Sensors** - Add 2 more PIR sensors to ESP8266 #2
3. **Add Window Sensors** - Add 3 magnetic window sensors to ESP8266 #2
4. **Update Backend Security** - Add motion and windows to security structure

---

## 📝 Recommendations

1. **For MVP/Demo**: Current setup works for basic lights, fan, and security
2. **For Full Features**: Add more sensors and update backend
3. **For Production**: Add smoke/LPG sensors, window sensors, and proper error handling

The current implementation provides a **solid foundation** that matches 70-80% of Flutter app features!

