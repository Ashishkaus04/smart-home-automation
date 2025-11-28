# Backend MQTT Bridge Requirements

## 🔄 How Flutter App Connects to ESP8266

The Flutter app **does NOT connect directly to MQTT**. Instead:

```
Flutter App → REST API → Backend Server → MQTT Broker → ESP8266
ESP8266 → MQTT Broker → Backend Server → Socket.IO → Flutter App
```

## 📋 Required Backend MQTT Topic Mappings

The backend (`backend/server.js`) must translate between REST API and MQTT topics.

### 1. Lights Control (Flutter → ESP8266)

**Flutter REST API:**
```
POST /api/devices/lights/bedroom
POST /api/devices/lights/living_room
POST /api/devices/lights/kitchen
POST /api/devices/lights/bathroom
```

**Backend must publish to MQTT:**
- `bedroom/light` → ESP8266 #2
- `living_room/light` → ESP8266 #1
- `kitchen/light` → ESP8266 #1
- `bathroom/light` → ESP8266 #1

### 2. Security Control (Flutter → ESP8266)

**Flutter REST API:**
```
POST /api/devices/security/armed
POST /api/devices/security/front  (door lock)
POST /api/devices/security/back   (door lock)
```

**Backend must publish to MQTT:**
- `security/armed` → ESP8266 #2
- `security/door/front/set` → ESP8266 #2 (if door locks are controllable)
- `security/door/back/set` → ESP8266 #2

### 3. Sensor Data (ESP8266 → Flutter)

**ESP8266 publishes to MQTT:**
- `bedroom/temperature` → Backend → Socket.IO → Flutter
- `bedroom/humidity` → Backend → Socket.IO → Flutter
- `living_room/temperature` → Backend → Socket.IO → Flutter
- `living_room/humidity` → Backend → Socket.IO → Flutter
- `bedroom/motion` → Backend → Socket.IO → Flutter
- `security/door/front` → Backend → Socket.IO → Flutter
- `security/door/back` → Backend → Socket.IO → Flutter
- `security/smoke` → Backend → Socket.IO → Flutter
- `bedroom/air_quality` → Backend → Socket.IO → Flutter

**Backend must:**
1. Subscribe to these MQTT topics
2. Update `deviceState` object
3. Emit Socket.IO events to Flutter app

## 🔧 Current Backend Status

Check `backend/server.js` to ensure it:
1. ✅ Subscribes to ESP8266 MQTT topics
2. ✅ Publishes MQTT commands when Flutter makes REST API calls
3. ✅ Emits Socket.IO events when MQTT messages received

## ⚠️ Topic Mismatches to Fix

### Issue 1: Light Topics
**Current ESP8266 topics:**
- `bedroom/light`
- `living_room/light`
- `kitchen/light`
- `bathroom/light`

**Backend expects (from server.js):**
- `home/lights/bedroom/set`
- `home/lights/living_room/set`
- etc.

**Solution:** Either:
- Update ESP8266 code to use `home/lights/{room}/set` format
- OR update backend to translate `home/lights/{room}/set` → `{room}/light`

### Issue 2: Security Topics
**Current ESP8266 topics:**
- `security/armed`
- `security/door/front`
- `security/door/back`

**Backend expects:**
- `home/security/armed/set`
- `home/security/doors/front/state`

**Solution:** Update backend to handle both topic formats or standardize on one.

## 📝 Recommended Backend Updates

Update `backend/server.js` to handle these MQTT topics:

```javascript
// Subscribe to ESP8266 topics
mqttClient.subscribe([
  'bedroom/temperature',
  'bedroom/humidity',
  'living_room/temperature',
  'living_room/humidity',
  'bedroom/motion',
  'security/door/front',
  'security/door/back',
  'security/smoke',
  'bedroom/air_quality',
  // ... etc
]);

// When Flutter calls REST API, publish to ESP8266
app.post('/api/devices/lights/:room', (req, res) => {
  const { room } = req.params;
  const { state } = req.body;
  
  // Publish to ESP8266
  mqttClient.publish(`${room}/light`, state ? 'ON' : 'OFF');
  
  // Update deviceState
  deviceState.lights[room] = state;
  
  // Emit to Flutter
  io.emit('deviceUpdate', { category: 'lights', device: room, state });
  
  res.json({ success: true });
});
```

## ✅ Testing Checklist

- [ ] Backend subscribes to all ESP8266 MQTT topics
- [ ] Backend publishes MQTT when Flutter makes REST API calls
- [ ] Backend emits Socket.IO events when MQTT messages received
- [ ] Flutter app receives real-time updates via Socket.IO
- [ ] All topic names match between backend and ESP8266

