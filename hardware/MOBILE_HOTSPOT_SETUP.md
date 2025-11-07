# Mobile Hotspot Setup Guide for ESP8266

## 📱 Overview

This guide helps you connect all 3 ESP8266 boards to your mobile hotspot and configure them to work with the Flutter app.

## 🔧 Step 1: Setup Mobile Hotspot

1. **On your phone:**
   - Enable mobile hotspot
   - Note the SSID (network name) and password
   - Note the IP address range (usually 192.168.43.x for Android, 192.168.137.x for some phones)

2. **On your PC (running MQTT broker):**
   - Connect PC to your mobile hotspot
   - Find your PC's IP address:
     - **Windows**: Open Command Prompt, run `ipconfig`
     - **Linux/Mac**: Open Terminal, run `ifconfig`
   - Look for the IP address (usually 192.168.43.x or 192.168.137.x)
   - **Example**: If IP is `192.168.43.100`, use this as MQTT broker IP

## 🔧 Step 2: Configure ESP8266 Code

### For each ESP8266 file, update these 3 lines:

```cpp
// Line 13-14: Update WiFi credentials
const char* ssid = "YOUR_MOBILE_HOTSPOT_SSID";      // Your phone's hotspot name
const char* password = "YOUR_HOTSPOT_PASSWORD";     // Your phone's hotspot password

// Line 19: Update MQTT broker IP (your PC's IP on mobile hotspot)
const char* mqtt_broker = "192.168.43.100";        // Your PC's IP (from ipconfig)
```

### Example:
If your hotspot is named "MyPhone" with password "mypass123", and your PC's IP is 192.168.43.100:

```cpp
const char* ssid = "MyPhone";
const char* password = "mypass123";
const char* mqtt_broker = "192.168.43.100";
```

## 📋 MQTT Topic Structure

### ESP8266 #1 - Living Room & Common Areas
**Publishes:**
- `living_room/temperature` - Temperature in °C
- `living_room/humidity` - Humidity in %

**Subscribes:**
- `living_room/light` - Control living room light (ON/OFF)
- `kitchen/light` - Control kitchen light (ON/OFF)
- `bathroom/light` - Control bathroom light (ON/OFF)
- `living_room/fan` - Control fan (ON/OFF)

### ESP8266 #2 - Bedroom & Security (✅ Compatible with Flutter bedroom_mqtt_page)
**Publishes:**
- `bedroom/motion` - Motion detected (ON/OFF)
- `security/door/front` - Front door state (CLOSED/OPEN)
- `security/door/back` - Back door state (CLOSED/OPEN)
- `bedroom/buzzer` - Buzzer state (ON/OFF)

**Subscribes:**
- `bedroom/light` - Control bedroom light (ON/OFF) ✅
- `bedroom/fan` - Control fan (ON/OFF) ✅
- `bedroom/buzzer` - Control buzzer (ON/OFF) ✅
- `security/armed` - Arm/disarm security (ON/OFF)

**Note:** Flutter app's `bedroom_mqtt_page.dart` subscribes to `bedroom/temperature` and `bedroom/humidity`, but ESP8266 #2 doesn't have DHT22. If you need bedroom temperature, add DHT22 to ESP8266 #2 or use ESP8266 #1's data.

### ESP8266 #3 - Outdoor & Appliances
**Publishes:**
- `garden/light_level` - Ambient light level (0-1024, optional)

**Subscribes:**
- `garage/light` - Control garage light (ON/OFF)
- `garden/light` - Control garden light (ON/OFF)
- `car_charger/power` - Control car charger (ON/OFF)

## 🚀 Step 3: Upload Code to ESP8266

1. **ESP8266 #1**: Open `esp8266_01_living_room.ino`
   - Update WiFi credentials and MQTT broker IP
   - Upload to ESP8266 #1 board

2. **ESP8266 #2**: Open `esp8266_02_bedroom_security.ino`
   - Update WiFi credentials and MQTT broker IP
   - Upload to ESP8266 #2 board

3. **ESP8266 #3**: Open `esp8266_03_outdoor_appliances.ino`
   - Update WiFi credentials and MQTT broker IP
   - Upload to ESP8266 #3 board

## ✅ Step 4: Verify Connection

1. **Open Serial Monitor** (115200 baud) for each ESP8266
2. You should see:
   ```
   ✅ WiFi connected!
   IP Address: 192.168.43.xxx
   ✅ Connected to MQTT broker!
   ```

3. **Test from Flutter app:**
   - Open the bedroom MQTT page
   - Toggle light/fan/buzzer
   - Check Serial Monitor - you should see messages received

## 🔍 Troubleshooting

### ESP8266 can't connect to WiFi
- Check SSID and password are correct
- Ensure mobile hotspot is enabled
- Check if hotspot uses 2.4GHz (ESP8266 doesn't support 5GHz)
- Move ESP8266 closer to phone

### ESP8266 can't connect to MQTT broker
- Verify PC's IP address is correct
- Ensure MQTT broker is running on PC
- Check Windows Firewall allows port 1883
- Verify PC and ESP8266 are on same network (mobile hotspot)

### Flutter app can't connect
- Update `app_config.dart` in Flutter app:
  ```dart
  static const String homeMqttHost = '192.168.43.100';  // Your PC's IP
  static const Environment currentEnvironment = Environment.home;
  ```
- Ensure phone running Flutter app is on same hotspot

### Find PC's IP Address

**Windows:**
```cmd
ipconfig
```
Look for "Wireless LAN adapter Wi-Fi" or "Wireless LAN adapter WLAN" and find "IPv4 Address"

**Linux/Mac:**
```bash
ifconfig
```
Look for "wlan0" or "wlp" interface and find "inet" address

## 📱 Flutter App Configuration

Update `mobile_app_flutter/smart_home_app/lib/config/app_config.dart`:

```dart
// Mobile Hotspot Configuration
static const String homeMqttHost = '192.168.43.100';  // Your PC's IP on hotspot
static const int homeMqttPort = 1883;

static const Environment currentEnvironment = Environment.home; // Change to home
```

## 🎯 Quick Checklist

- [ ] Mobile hotspot enabled
- [ ] PC connected to mobile hotspot
- [ ] PC's IP address found (ipconfig/ifconfig)
- [ ] MQTT broker running on PC
- [ ] WiFi credentials updated in all 3 ESP8266 files
- [ ] MQTT broker IP updated in all 3 ESP8266 files
- [ ] Code uploaded to all 3 ESP8266 boards
- [ ] Serial Monitor shows successful connections
- [ ] Flutter app config updated with PC's IP
- [ ] Flutter app connected to same hotspot

## 🔐 Security Note

Mobile hotspots are less secure than home networks. For production:
- Use strong hotspot passwords
- Consider using MQTT authentication
- Use TLS/SSL for MQTT connections

