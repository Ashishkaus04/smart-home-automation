# ESP8266 Smart Home Setup Guide

## 📋 Hardware Components Required

1. **ESP8266 NodeMCU** (or any ESP8266-based board)
2. **DHT22 Temperature & Humidity Sensor**
3. **3-channel Relay Module** (5V)
4. **Jumper Wires**
5. **USB Cable** (for programming)

## 🔌 Pin Connections

### DHT22 Sensor
```
DHT22 VCC   → 3V3 (ESP8266)
DHT22 GND   → GND (ESP8266)
DHT22 DATA  → D4 (GPIO 4)
DHT22 10kΩ Resistor between DATA and VCC
```

### 3-Channel Relay Module
```
Relay 1 (Light)  → D1 (GPIO 5)
Relay 2 (Fan)    → D2 (GPIO 4)
Relay 3 (Buzzer) → D5 (GPIO 14)
```

**Note:** The code uses **Active LOW** relays (common cathode). If your relay is Active HIGH, change `LOW` to `HIGH` in the code.

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
- **DHT sensor library** by Adafruit
- **Adafruit Unified Sensor** (dependency for DHT library)

### 3. Configure the Code

Open `hardware/arduino_code/smart_home.ino` and update:

```cpp
// Line 10-11: Update with your WiFi credentials
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
```

### 4. Upload to ESP8266

1. Connect ESP8266 via USB
2. Select correct **COM Port**: `Tools → Port → COM?`
3. Upload the code: `Sketch → Upload`

## 🔧 Testing the Setup

1. Open **Serial Monitor** (Tools → Serial Monitor)
2. Set baud rate to **115200**
3. You should see:
   ```
   WiFi connected!
   IP Address: 192.168.x.x
   Connected to MQTT broker!
   Subscribed to topics
   Published temperature: 23.5°C
   Published humidity: 45.0%
   ```

## 🏠 Circuit Diagram

```
ESP8266 NodeMCU
┌─────────────────────┐
│ 3V3 ── VCC DHT22    │
│ GND ── GND DHT22    │
│ D4  ── DATA DHT22   │
│                     │
│ D1  ── Relay 1 IN   │ (Light)
│ D2  ── Relay 2 IN   │ (Fan)
│ D5  ── Relay 3 IN   │ (Buzzer)
│                     │
│ GND ── Relay GND    │
│ VIN ── Relay VCC    │ (Use 5V)
└─────────────────────┘
```

## 📱 MQTT Topics

The ESP8266 publishes/subscribes to these topics:

### Published (ESP8266 → Broker):
- `bedroom/temperature` - Current temperature (°C)
- `bedroom/humidity` - Current humidity (%)

### Subscribed (Broker → ESP8266):
- `bedroom/light` - Control light: `"ON"` or `"OFF"`
- `bedroom/fan` - Control fan: `"ON"` or `"OFF"`
- `bedroom/buzzer` - Control buzzer: `"ON"` or `"OFF"`

## 🚨 Troubleshooting

### WiFi Not Connecting
- Check SSID and password
- Ensure 2.4GHz WiFi (ESP8266 doesn't support 5GHz)
- Move closer to router

### MQTT Not Connecting
- Verify MQTT broker is running
- Check IP address: `10.217.139.106` for college network
- Ensure ESP8266 and broker are on same network
- Check firewall settings

### Sensor Not Reading
- Verify DHT22 connections
- Add 4.7kΩ or 10kΩ pull-up resistor
- Try different DHT sensor (DHT11 works too)

### Relays Not Working
- Check relay connections
- Some relays are Active HIGH - change `LOW` to `HIGH` in code
- Verify relay module is powered (5V)

## 🔄 Calibration

To adjust publishing interval, modify in code:

```cpp
const unsigned long TEMP_READ_INTERVAL = 2000;  // Read every 2s
const unsigned long PUBLISH_INTERVAL = 5000;   // Publish every 5s
```

## 📞 Support

If ESP8266 continuously restarts:
1. Check power supply (use good USB cable)
2. Add delay(100) in critical sections
3. Reduce WiFi transmit power:
   ```cpp
   WiFi.setTxPower(WIFI_POWER_11dBm);
   ```

