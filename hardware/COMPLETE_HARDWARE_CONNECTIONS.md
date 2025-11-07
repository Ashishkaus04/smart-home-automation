# Complete Hardware Connection Guide - All 3 ESP8266 Boards

## 📋 Overview

This guide shows **exactly** what to connect to each ESP8266 board, organized by board.

---

## 🔌 ESP8266 #1 - Living Room & Common Areas

### 📦 Components Needed:
- 1x ESP8266 NodeMCU
- 1x DHT22 Temperature & Humidity Sensor
- 1x 4-Channel Relay Module (5V)
- 1x 10kΩ Resistor
- 10-15x Jumper Wires
- 1x USB Cable

### 🔌 Pin Connections:

```
┌─────────────────────────────────────────────────────────┐
│ ESP8266 #1 - Living Room & Common Areas                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ POWER & GROUND:                                         │
│   5V   ────────────────────────────────────────────────┐│
│   3V3  ───────────────────────────────────────────────┐││
│   GND  ───────────────────────────────────────────────┐│││
│                                                         │││
│ DHT22 SENSOR:                                          │││
│   DHT22 VCC  ────────────→ 3V3                        │││
│   DHT22 GND  ────────────→ GND                        │││
│   DHT22 DATA ────────────→ D4 (GPIO 4)                │││
│   10kΩ Resistor ─────────→ Between DATA and VCC       │││
│                                                         │││
│ 4-CHANNEL RELAY MODULE:                                │││
│   Relay VCC  ────────────→ 5V                         │││
│   Relay GND  ────────────→ GND                        │││
│   Relay 1 IN ────────────→ D1 (GPIO 5)  [Living Room] │││
│   Relay 2 IN ────────────→ D2 (GPIO 4)  [Kitchen]     │││
│   Relay 3 IN ────────────→ D5 (GPIO 14) [Bathroom]    │││
│   Relay 4 IN ────────────→ D6 (GPIO 12) [Fan]         │││
│                                                         │││
│ RELAY OUTPUTS (Connect your devices):                  │││
│   Relay 1 COM/NO ────────→ Living Room Light          │││
│   Relay 2 COM/NO ────────→ Kitchen Light              │││
│   Relay 3 COM/NO ────────→ Bathroom Light             │││
│   Relay 4 COM/NO ────────→ Fan                        │││
│                                                         │││
└─────────────────────────────────────────────────────────┘││
                                                           ││
                                                           ││
                                                           ││
```

### 📍 Detailed Pin Mapping:

| ESP8266 Pin | GPIO | Component | Connection |
|-------------|------|-----------|------------|
| **3V3** | - | DHT22 VCC | Direct |
| **GND** | - | DHT22 GND, Relay GND | Common Ground |
| **D4** | GPIO 4 | DHT22 DATA | With 10kΩ pull-up to 3V3 |
| **5V** | - | Relay Module VCC | Direct |
| **D1** | GPIO 5 | Relay 1 IN (Living Room Light) | Direct |
| **D2** | GPIO 4 | Relay 2 IN (Kitchen Light) | Direct |
| **D5** | GPIO 14 | Relay 3 IN (Bathroom Light) | Direct |
| **D6** | GPIO 12 | Relay 4 IN (Fan) | Direct |

### 🔧 Relay Module Wiring:

```
4-Channel Relay Module
┌──────────────────────┐
│  VCC ────────── 5V   │
│  GND ────────── GND  │
│  IN1 ────────── D1   │ → Living Room Light
│  IN2 ────────── D2   │ → Kitchen Light
│  IN3 ────────── D5   │ → Bathroom Light
│  IN4 ────────── D6   │ → Fan
└──────────────────────┘
```

### 📊 MQTT Topics (ESP8266 #1):
- **Publishes**: `living_room/temperature`, `living_room/humidity`
- **Subscribes**: `living_room/light`, `kitchen/light`, `bathroom/light`, `living_room/fan`

---

## 🔌 ESP8266 #2 - Bedroom & Security

### 📦 Components Needed:
- 1x ESP8266 NodeMCU
- 1x DHT22 Temperature & Humidity Sensor
- 1x MQ135 Gas/Smoke Sensor Module
- 1x PIR Motion Sensor (HC-SR501)
- 2x Magnetic Door/Window Sensors
- 1x 2-Channel Relay Module (5V)
- 1x Active Buzzer (5V)
- 1x 10kΩ Resistor (for DHT22)
- 15-20x Jumper Wires
- 1x USB Cable

### 🔌 Pin Connections:

```
┌─────────────────────────────────────────────────────────┐
│ ESP8266 #2 - Bedroom & Security                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ POWER & GROUND:                                         │
│   5V   ────────────────────────────────────────────────┐│
│   3V3  ───────────────────────────────────────────────┐││
│   GND  ───────────────────────────────────────────────┐│││
│                                                         │││
│ DHT22 SENSOR (Bedroom Environment):                    │││
│   DHT22 VCC  ────────────→ 3V3                        │││
│   DHT22 GND  ────────────→ GND                        │││
│   DHT22 DATA ────────────→ D4 (GPIO 4)                │││
│   10kΩ Resistor ─────────→ Between DATA and VCC       │││
│                                                         │││
│ MQ135 GAS/SMOKE SENSOR:                                │││
│   MQ135 VCC  ────────────→ 5V                         │││
│   MQ135 GND  ────────────→ GND                        │││
│   MQ135 AO   ────────────→ A0 (Analog Input)          │││
│   ⚠️  NOTE: If AO > 3.3V, use voltage divider!        │││
│                                                         │││
│ PIR MOTION SENSOR:                                     │││
│   PIR VCC  ──────────────→ 5V                         │││
│   PIR GND  ──────────────→ GND                        │││
│   PIR OUT  ──────────────→ D5 (GPIO 14)               │││
│                                                         │││
│ MAGNETIC DOOR SENSORS:                                 │││
│   Front Door:                                          │││
│     VCC  ────────────────→ 3V3                        │││
│     GND  ────────────────→ GND                        │││
│     DO   ────────────────→ D6 (GPIO 12)               │││
│                                                         │││
│   Back Door:                                           │││
│     VCC  ────────────────→ 3V3                        │││
│     GND  ────────────────→ GND                        │││
│     DO   ────────────────→ D7 (GPIO 13)               │││
│                                                         │││
│ 2-CHANNEL RELAY MODULE:                                │││
│   Relay VCC  ────────────→ 5V                         │││
│   Relay GND  ────────────→ GND                        │││
│   Relay 1 IN ────────────→ D1 (GPIO 5)  [Bedroom Light]│││
│   Relay 2 IN ────────────→ D2 (GPIO 4)  [Buzzer]      │││
│                                                         │││
│ ACTIVE BUZZER:                                         │││
│   Buzzer + ──────────────→ Relay 2 COM                │││
│   Buzzer - ──────────────→ GND                        │││
│   Relay 2 NO ────────────→ 5V                         │││
│   (When relay activates, buzzer completes circuit)     │││
│                                                         │││
└─────────────────────────────────────────────────────────┘││
                                                           ││
                                                           ││
```

### 📍 Detailed Pin Mapping:

| ESP8266 Pin | GPIO | Component | Connection |
|-------------|------|-----------|------------|
| **3V3** | - | DHT22 VCC, Door Sensors VCC | Direct |
| **5V** | - | MQ135 VCC, PIR VCC, Relay VCC | Direct |
| **GND** | - | All GND pins | Common Ground |
| **A0** | ADC | MQ135 AO (Analog Output) | Direct (check voltage!) |
| **D1** | GPIO 5 | Relay 1 IN (Bedroom Light) | Direct |
| **D2** | GPIO 4 | Relay 2 IN (Buzzer Control) | Direct |
| **D4** | GPIO 4 | DHT22 DATA | With 10kΩ pull-up to 3V3 |
| **D5** | GPIO 14 | PIR Motion Sensor OUT | Direct |
| **D6** | GPIO 12 | Front Door Sensor DO | Direct |
| **D7** | GPIO 13 | Back Door Sensor DO | Direct |

### ⚠️ MQ135 Voltage Divider (If Needed):

If your MQ135 module outputs 0-5V on AO, you need a voltage divider:

```
MQ135 AO ────┬─── 10kΩ ──── A0 (ESP8266)
             │
             └─── 10kΩ ──── GND
```

This divides the voltage by 2 (0-2.5V max), safe for ESP8266.

### 🔔 Buzzer Circuit:

```
When Relay 2 is OFF: Buzzer circuit is open (silent)
When Relay 2 is ON: 5V → Relay NO → Buzzer + → Buzzer - → GND (buzzer sounds)

Relay 2:
  COM ──────────────→ Buzzer +
  NO  ──────────────→ 5V
  NC  ──────────────→ (Not used)
  GND ──────────────→ GND
```

### 📊 MQTT Topics (ESP8266 #2):
- **Publishes**: 
  - `bedroom/temperature`, `bedroom/humidity`
  - `bedroom/motion`, `bedroom/buzzer`
  - `security/door/front`, `security/door/back`
  - `bedroom/air_quality`, `security/smoke`
- **Subscribes**: 
  - `bedroom/light`, `bedroom/buzzer`, `security/armed`

---

## 🔌 ESP8266 #3 - Outdoor & Appliances

### 📦 Components Needed:
- 1x ESP8266 NodeMCU
- 1x 3-Channel Relay Module (5V)
- 1x LDR (Light Dependent Resistor) - Optional
- 1x 10kΩ Resistor (for LDR, if used)
- 10-15x Jumper Wires
- 1x USB Cable

### 🔌 Pin Connections:

```
┌─────────────────────────────────────────────────────────┐
│ ESP8266 #3 - Outdoor & Appliances                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ POWER & GROUND:                                         │
│   5V   ────────────────────────────────────────────────┐│
│   3V3  ───────────────────────────────────────────────┐││
│   GND  ───────────────────────────────────────────────┐│││
│                                                         │││
│ 3-CHANNEL RELAY MODULE:                                │││
│   Relay VCC  ────────────→ 5V                         │││
│   Relay GND  ────────────→ GND                        │││
│   Relay 1 IN ────────────→ D1 (GPIO 5)  [Garage]      │││
│   Relay 2 IN ────────────→ D2 (GPIO 4)  [Garden]      │││
│   Relay 3 IN ────────────→ D5 (GPIO 14) [Car Charger] │││
│                                                         │││
│ LDR (Optional - for automatic garden light):           │││
│   LDR Circuit:                                         │││
│     3V3 ──── LDR ──── A0 ──── 10kΩ ──── GND          │││
│                                                         │││
│ RELAY OUTPUTS (Connect your devices):                  │││
│   Relay 1 COM/NO ────────→ Garage Light               │││
│   Relay 2 COM/NO ────────→ Garden Light               │││
│   Relay 3 COM/NO ────────→ Car Charger                │││
│                                                         │││
└─────────────────────────────────────────────────────────┘││
                                                           ││
                                                           ││
```

### 📍 Detailed Pin Mapping:

| ESP8266 Pin | GPIO | Component | Connection |
|-------------|------|-----------|------------|
| **5V** | - | Relay Module VCC | Direct |
| **3V3** | - | LDR (via voltage divider) | Direct |
| **GND** | - | Relay GND, LDR GND | Common Ground |
| **A0** | ADC | LDR (via voltage divider) | Optional |
| **D1** | GPIO 5 | Relay 1 IN (Garage Light) | Direct |
| **D2** | GPIO 4 | Relay 2 IN (Garden Light) | Direct |
| **D5** | GPIO 14 | Relay 3 IN (Car Charger) | Direct |

### 🌞 LDR Voltage Divider Circuit (Optional):

```
      3V3
       │
       │
    ┌──┴──┐
    │ LDR │
    └──┬──┘
       │
       ├──────→ A0 (ESP8266)
       │
    ┌──┴──┐
    │10kΩ │
    └──┬──┘
       │
      GND

Higher light = Higher voltage at A0
Lower light = Lower voltage at A0
```

### 📊 MQTT Topics (ESP8266 #3):
- **Publishes**: `garden/light_level` (optional)
- **Subscribes**: `garage/light`, `garden/light`, `car_charger/power`

---

## 📦 Complete Component Shopping List

### ESP8266 Boards:
- [ ] ESP8266 NodeMCU × 3

### Sensors:
- [ ] DHT22 Temperature & Humidity Sensor × 2 (1 for ESP8266 #1, 1 for ESP8266 #2)
- [ ] MQ135 Gas/Smoke Sensor Module × 1 (ESP8266 #2)
- [ ] PIR Motion Sensor (HC-SR501) × 1-3 (ESP8266 #2 - minimum 1, add more for living/kitchen)
- [ ] Magnetic Door/Window Sensors × 2-5 (ESP8266 #2 - 2 doors, optional 3 windows)
- [ ] LDR (Light Dependent Resistor) × 1 (ESP8266 #3 - optional)

### Relays:
- [ ] 4-Channel Relay Module (5V) × 1 (ESP8266 #1)
- [ ] 2-Channel Relay Module (5V) × 1 (ESP8266 #2)
- [ ] 3-Channel Relay Module (5V) × 1 (ESP8266 #3)

### Outputs:
- [ ] Active Buzzer (5V) × 1 (ESP8266 #2)

### Resistors:
- [ ] 10kΩ Resistor × 2-3 (1 for each DHT22, 1 for LDR if used)
- [ ] 10kΩ Resistor × 2 (for MQ135 voltage divider if needed)

### Power & Cables:
- [ ] USB Cable (Micro USB) × 3
- [ ] Jumper Wires (Male-to-Male) × 50+
- [ ] Breadboard (optional, for testing) × 1-3
- [ ] 5V Power Supply (1A minimum per board) × 3 (or good USB chargers)

### Devices to Control (Your Actual Home Devices):
- [ ] Living Room Light
- [ ] Kitchen Light
- [ ] Bathroom Light
- [ ] Bedroom Light
- [ ] Garage Light
- [ ] Garden Light
- [ ] Fan
- [ ] Car Charger (or any appliance)

---

## 🔌 Complete Wiring Summary Table

### ESP8266 #1 (Living Room):
| Pin | Component | Details |
|-----|-----------|---------|
| 3V3 | DHT22 VCC | Direct |
| GND | DHT22 GND, Relay GND | Common |
| D4 | DHT22 DATA | With 10kΩ pull-up |
| 5V | Relay VCC | Direct |
| D1 | Relay 1 IN | Living Room Light |
| D2 | Relay 2 IN | Kitchen Light |
| D5 | Relay 3 IN | Bathroom Light |
| D6 | Relay 4 IN | Fan |

### ESP8266 #2 (Bedroom & Security):
| Pin | Component | Details |
|-----|-----------|---------|
| 3V3 | DHT22 VCC, Door Sensors VCC | Direct |
| 5V | MQ135 VCC, PIR VCC, Relay VCC, Buzzer | Direct |
| GND | All GND | Common |
| A0 | MQ135 AO | Analog (check voltage!) |
| D1 | Relay 1 IN | Bedroom Light |
| D2 | Relay 2 IN | Buzzer Control |
| D4 | DHT22 DATA | With 10kΩ pull-up |
| D5 | PIR OUT | Motion Sensor |
| D6 | Front Door DO | Digital Input |
| D7 | Back Door DO | Digital Input |

### ESP8266 #3 (Outdoor):
| Pin | Component | Details |
|-----|-----------|---------|
| 5V | Relay VCC | Direct |
| 3V3 | LDR (via divider) | Optional |
| GND | Relay GND, LDR GND | Common |
| A0 | LDR | Optional (via voltage divider) |
| D1 | Relay 1 IN | Garage Light |
| D2 | Relay 2 IN | Garden Light |
| D5 | Relay 3 IN | Car Charger |

---

## ⚡ Power Requirements

| Board | Components | Max Current | Recommendation |
|-------|-----------|-------------|----------------|
| ESP8266 #1 | 4 relays + DHT22 | ~500mA | 1A USB charger |
| ESP8266 #2 | 2 relays + DHT22 + MQ135 + PIR + Buzzer | ~600mA | 1A USB charger |
| ESP8266 #3 | 3 relays + LDR | ~400mA | 1A USB charger |

**Total System**: ~1.5A when all devices active

---

## 🚨 Important Notes

1. **Relay Polarity**: Code assumes Active LOW relays. If your relay is Active HIGH, change `LOW` to `HIGH` in code.

2. **MQ135 Voltage**: ESP8266 A0 can only handle 0-3.3V. If MQ135 outputs 0-5V, use voltage divider.

3. **Ground Connections**: Always connect all GND pins together (common ground).

4. **Power**: Use quality USB cables and 1A+ power supplies. Poor power causes ESP8266 resets.

5. **WiFi Range**: Keep ESP8266 boards within WiFi range of your mobile hotspot.

6. **Testing**: Test each board individually before connecting all devices.

---

## ✅ Testing Checklist

After wiring each board:

- [ ] ESP8266 #1: DHT22 reads temperature/humidity
- [ ] ESP8266 #1: All 4 relays switch correctly
- [ ] ESP8266 #2: DHT22 reads bedroom temperature/humidity
- [ ] ESP8266 #2: MQ135 reads air quality (check Serial Monitor)
- [ ] ESP8266 #2: PIR detects motion
- [ ] ESP8266 #2: Door sensors detect open/close
- [ ] ESP8266 #2: Buzzer sounds when relay activated
- [ ] ESP8266 #3: All 3 relays switch correctly
- [ ] ESP8266 #3: LDR reads light level (if installed)
- [ ] All boards connect to WiFi
- [ ] All boards connect to MQTT broker
- [ ] Test from Flutter app

---

## 📸 Visual Reference

For detailed circuit diagrams, see:
- `ESP8266_MULTI_BOARD_SETUP.md` - Detailed setup guide
- `MOBILE_HOTSPOT_SETUP.md` - Network configuration

---

## 🆘 Troubleshooting

### ESP8266 won't connect to WiFi
- Check SSID and password
- Ensure 2.4GHz WiFi (not 5GHz)
- Check mobile hotspot is enabled

### Sensors not reading
- Check wiring connections
- Verify power supply (3V3/5V)
- Check pull-up resistors (DHT22)
- For MQ135, verify voltage divider if needed

### Relays not switching
- Check relay module power (5V)
- Verify relay polarity (Active LOW vs HIGH)
- Test relay with multimeter

### MQTT not connecting
- Verify PC's IP address on mobile hotspot
- Check MQTT broker is running
- Ensure firewall allows port 1883
- Verify ESP8266 and PC on same network

