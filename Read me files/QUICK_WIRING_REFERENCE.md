# Quick Wiring Reference - Pin-by-Pin Guide

## 🎯 ESP8266 #1 - Living Room & Common Areas

```
ESP8266 #1 Pinout:
┌─────────────────────┐
│ 3V3 ──→ DHT22 VCC   │
│ GND ──→ DHT22 GND   │
│      ──→ Relay GND  │
│ D4  ──→ DHT22 DATA  │ (10kΩ to 3V3)
│ 5V  ──→ Relay VCC   │
│ D1  ──→ Relay 1 IN  │ → Living Room Light
│ D2  ──→ Relay 2 IN  │ → Kitchen Light
│ D5  ──→ Relay 3 IN  │ → Bathroom Light
│ D6  ──→ Relay 4 IN  │ → Fan
└─────────────────────┘
```

**Components:**
- DHT22 × 1
- 4-Channel Relay × 1
- 10kΩ Resistor × 1

---

## 🎯 ESP8266 #2 - Bedroom & Security

```
ESP8266 #2 Pinout:
┌─────────────────────┐
│ 3V3 ──→ DHT22 VCC   │
│      ──→ Door VCC   │
│ 5V  ──→ MQ135 VCC   │
│      ──→ PIR VCC    │
│      ──→ Relay VCC  │
│ GND ──→ All GND     │
│ A0  ──→ MQ135 AO    │ (check voltage!)
│ D1  ──→ Relay 1 IN  │ → Bedroom Light
│ D2  ──→ Relay 2 IN  │ → Buzzer Control
│ D4  ──→ DHT22 DATA  │ (10kΩ to 3V3)
│ D5  ──→ PIR OUT     │
│ D6  ──→ Front Door  │
│ D7  ──→ Back Door   │
└─────────────────────┘

Buzzer Circuit:
Relay 2 COM ──→ Buzzer +
Relay 2 NO  ──→ 5V
Buzzer -     ──→ GND
```

**Components:**
- DHT22 × 1
- MQ135 × 1
- PIR Motion × 1
- Magnetic Door Sensors × 2
- 2-Channel Relay × 1
- Buzzer × 1
- 10kΩ Resistor × 1

---

## 🎯 ESP8266 #3 - Outdoor & Appliances

```
ESP8266 #3 Pinout:
┌─────────────────────┐
│ 5V  ──→ Relay VCC   │
│ 3V3 ──→ LDR (opt)   │
│ GND ──→ Relay GND   │
│      ──→ LDR GND    │
│ A0  ──→ LDR (opt)   │ (via voltage divider)
│ D1  ──→ Relay 1 IN  │ → Garage Light
│ D2  ──→ Relay 2 IN  │ → Garden Light
│ D5  ──→ Relay 3 IN  │ → Car Charger
└─────────────────────┘

LDR Circuit (Optional):
3V3 ── LDR ── A0 ── 10kΩ ── GND
```

**Components:**
- 3-Channel Relay × 1
- LDR × 1 (optional)
- 10kΩ Resistor × 1 (if using LDR)

---

## 📊 Component Count Summary

| Component | Quantity | Used By |
|-----------|----------|---------|
| ESP8266 NodeMCU | 3 | All boards |
| DHT22 | 2 | ESP8266 #1, #2 |
| MQ135 | 1 | ESP8266 #2 |
| PIR Motion | 1 | ESP8266 #2 |
| Door Sensors | 2 | ESP8266 #2 |
| 4-Ch Relay | 1 | ESP8266 #1 |
| 2-Ch Relay | 1 | ESP8266 #2 |
| 3-Ch Relay | 1 | ESP8266 #3 |
| Buzzer | 1 | ESP8266 #2 |
| LDR | 1 | ESP8266 #3 (opt) |
| 10kΩ Resistor | 2-3 | Multiple |
| USB Cable | 3 | All boards |
| Jumper Wires | 50+ | All boards |

---

## ⚡ Power Connections Quick Reference

### ESP8266 #1:
- 5V → Relay Module VCC
- 3V3 → DHT22 VCC
- GND → Common ground

### ESP8266 #2:
- 5V → MQ135 VCC, PIR VCC, Relay VCC
- 3V3 → DHT22 VCC, Door Sensors VCC
- GND → Common ground (all components)

### ESP8266 #3:
- 5V → Relay Module VCC
- 3V3 → LDR (if used)
- GND → Common ground

---

## 🔍 Pin Conflict Check

### ESP8266 #1:
- ✅ D4 (DHT22) - OK
- ✅ D1, D2, D5, D6 (Relays) - OK
- No conflicts

### ESP8266 #2:
- ✅ D4 (DHT22) - OK
- ✅ D5 (PIR) - OK
- ✅ D6, D7 (Doors) - OK
- ✅ D1, D2 (Relays) - OK
- ✅ A0 (MQ135) - OK
- No conflicts

### ESP8266 #3:
- ✅ D1, D2, D5 (Relays) - OK
- ✅ A0 (LDR) - OK (optional)
- No conflicts

---

## 📝 Quick Setup Steps

1. **Wire ESP8266 #1** (Living Room)
   - Connect DHT22 (D4, 3V3, GND)
   - Connect 4-channel relay (D1, D2, D5, D6, 5V, GND)
   - Upload `esp8266_01_living_room.ino`

2. **Wire ESP8266 #2** (Bedroom & Security)
   - Connect DHT22 (D4, 3V3, GND)
   - Connect MQ135 (A0, 5V, GND)
   - Connect PIR (D5, 5V, GND)
   - Connect door sensors (D6, D7, 3V3, GND)
   - Connect 2-channel relay (D1, D2, 5V, GND)
   - Connect buzzer to relay 2
   - Upload `esp8266_02_bedroom_security.ino`

3. **Wire ESP8266 #3** (Outdoor)
   - Connect 3-channel relay (D1, D2, D5, 5V, GND)
   - Connect LDR (A0, 3V3, GND) - optional
   - Upload `esp8266_03_outdoor_appliances.ino`

4. **Configure WiFi & MQTT**
   - Update SSID/password in all 3 files
   - Update MQTT broker IP in all 3 files
   - Re-upload if needed

5. **Test**
   - Open Serial Monitor (115200 baud)
   - Verify WiFi connection
   - Verify MQTT connection
   - Test from Flutter app

---

## 🎯 MQTT Topic Quick Reference

### ESP8266 #1 Publishes:
- `living_room/temperature`
- `living_room/humidity`

### ESP8266 #1 Subscribes:
- `living_room/light`
- `kitchen/light`
- `bathroom/light`
- `living_room/fan`

### ESP8266 #2 Publishes:
- `bedroom/temperature`
- `bedroom/humidity`
- `bedroom/motion`
- `bedroom/buzzer`
- `security/door/front`
- `security/door/back`
- `bedroom/air_quality`
- `security/smoke`

### ESP8266 #2 Subscribes:
- `bedroom/light`
- `bedroom/buzzer`
- `security/armed`

### ESP8266 #3 Publishes:
- `garden/light_level` (optional)

### ESP8266 #3 Subscribes:
- `garage/light`
- `garden/light`
- `car_charger/power`

---

This is your complete wiring reference! Use this alongside the detailed guide for exact connections.

