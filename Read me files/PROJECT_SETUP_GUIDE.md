# 🏠 Smart Home Automation - Complete Setup Guide

A comprehensive IoT-based smart home system with Flutter mobile app, ESP8266 hardware controllers, and MQTT communication.

---

## 📋 Table of Contents

1. [System Overview](#-system-overview)
2. [Hardware Requirements](#-hardware-requirements)
3. [Software Requirements](#-software-requirements)
4. [Hardware Setup](#-hardware-setup)
5. [Software Installation](#-software-installation)
6. [Configuration](#-configuration)
7. [Running the Project](#-running-the-project)
8. [Testing & Verification](#-testing--verification)
9. [Troubleshooting](#-troubleshooting)

---

## 🏗️ System Overview

### Architecture
- **Flutter Mobile App**: Android/iOS control interface
- **MQTT Broker**: Message communication hub
- **3 ESP8266 Boards**: Distributed IoT controllers
- **TensorFlow Lite**: AI/ML energy predictions

### Features
- ✅ **Device Control**: Lights, appliances, climate control
- ✅ **Security System**: Motion sensors, door/window monitoring, servo door control
- ✅ **Energy Monitoring**: Real-time consumption with AI predictions
- ✅ **Automation**: Rule-based smart home automation
- ✅ **Real-time Updates**: MQTT-based instant synchronization

---

## 🔧 Hardware Requirements

### ESP8266 Controllers (3 boards total)

#### ESP8266 #1 - Living Room & Common Areas
| Component | Quantity | Purpose |
|-----------|----------|---------|
| ESP8266 NodeMCU | 1 | Main controller |
| DHT22 Sensor | 1 | Temperature/Humidity |
| MQ135 Sensor | 1 | Air Quality (AQI) |
| 4-Channel Relay Module | 1 | Light control |
| 10kΩ Resistor | 1 | DHT22 pull-up |
| Jumper Wires | 15+ | Connections |
| USB Cable | 1 | Power/Programming |

#### ESP8266 #2 - Bedroom & Security  
| Component | Quantity | Purpose |
|-----------|----------|---------|
| ESP8266 NodeMCU | 1 | Security controller |
| PIR Motion Sensors | 2 | Motion detection |
| Magnetic Door Sensors | 2 | Door monitoring |
| Magnetic Window Sensors | 3 | Window monitoring |
| SG90 Servo Motor | 1 | Front door control |
| Active Buzzer (5V) | 1 | Security alarm |
| 2-Channel Relay Module | 1 | Device control |
| Jumper Wires | 20+ | Connections |
| USB Cable | 1 | Power/Programming |

#### ESP8266 #3 - Energy Monitoring & Appliances
| Component | Quantity | Purpose |
|-----------|----------|---------|
| ESP8266 NodeMCU | 1 | Energy/appliance controller |
| LED (any color) | 1 | Smart TV indicator |
| Buzzer (5V) | 2 | Music system & coffee maker |
| 3-Channel Relay Module | 1 | Appliance control |
| Jumper Wires | 15+ | Connections |
| USB Cable | 1 | Power/Programming |

### Additional Hardware
- **Breadboards** (3x) or **PCB boards** for permanent installation
- **Power Supplies**: 5V/1A adapters for each ESP8266 (or USB power)
- **Resistors**: 220Ω for LEDs, 10kΩ for sensors

---

## 💻 Software Requirements

### Development Environment

#### 1. Arduino IDE
- **Version**: 1.8.19 or newer / Arduino IDE 2.x
- **Purpose**: ESP8266 programming
- **Download**: [arduino.cc](https://www.arduino.cc/en/software)

#### 2. Flutter SDK
- **Version**: 3.9.2 or newer
- **Purpose**: Mobile app development
- **Download**: [flutter.dev](https://flutter.dev/docs/get-started/install)

#### 3. Android Studio / VS Code
- **Purpose**: Flutter development IDE
- **Android Studio**: [developer.android.com](https://developer.android.com/studio)
- **VS Code**: [code.visualstudio.com](https://code.visualstudio.com/)

#### 4. MQTT Broker
- **Options**: 
  - **Mosquitto** (Recommended): [mosquitto.org](https://mosquitto.org/download/)
  - **HiveMQ** (Cloud): [hivemq.com](https://www.hivemq.com/)
  - **EMQX** (Local/Cloud): [emqx.io](https://www.emqx.io/)

### Arduino Libraries (Install via Library Manager)

| Library | Version | Purpose | Author |
|---------|---------|---------|---------|
| ESP8266WiFi | Built-in | WiFi connectivity | ESP8266 Community |
| PubSubClient | 2.8+ | MQTT communication | Nick O'Leary |
| DHT sensor library | 1.4.4+ | Temperature/Humidity | Adafruit |
| Adafruit Unified Sensor | 1.1.9+ | Sensor abstraction | Adafruit |
| Servo | Built-in | Servo motor control | Arduino |

### Flutter Dependencies (from pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  mqtt_client: ^10.2.0          # MQTT communication
  provider: ^6.1.2              # State management
  http: ^1.2.2                  # HTTP requests
  socket_io_client: ^2.0.3      # WebSocket communication
  tflite_flutter: ^0.11.0       # TensorFlow Lite
  path_provider: ^2.1.2         # File system access
  shared_preferences: ^2.2.2    # Local storage
  cupertino_icons: ^1.0.8       # iOS-style icons

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0         # Code linting

# Android-specific dependency (in android/app/build.gradle.kts)
dependencies:
  implementation("org.tensorflow:tensorflow-lite-select-tf-ops:2.14.0")
```

---

## 🔌 Hardware Setup

### ESP8266 #1 - Living Room Controller

#### Pin Connections
```
DHT22 Sensor:
  VCC  → 3.3V
  GND  → GND  
  DATA → D4 (GPIO 2)
  10kΩ resistor between DATA and VCC

MQ135 Air Quality Sensor:
  VCC → 3.3V
  GND → GND
  AO  → A0 (Analog input)

4-Channel Relay Module:
  VCC → 5V (or 3.3V)
  GND → GND
  IN1 → D1 (Living Room Light)
  IN2 → D2 (Kitchen Light)  
  IN3 → D5 (Bathroom Light)
  IN4 → D6 (Reserved/Fan)
```

### ESP8266 #2 - Security Controller

#### Pin Connections
```
PIR Motion Sensors (x2):
  PIR1: VCC→5V, GND→GND, OUT→D5
  PIR2: VCC→5V, GND→GND, OUT→D6

Magnetic Door Sensors:
  Front Door: Signal→D7, GND→GND
  Back Door:  Signal→D8, GND→GND

Magnetic Window Sensors:
  Living:  Signal→D0, GND→GND
  Bedroom: Signal→D3, GND→GND  
  Kitchen: Signal→D4, GND→GND

SG90 Servo Motor:
  Red (VCC)    → 5V or 3.3V
  Brown (GND)  → GND
  Orange (PWM) → D1

Active Buzzer:
  Positive → D2
  Negative → GND
```

### ESP8266 #3 - Energy & Appliances

#### Pin Connections
```
Smart TV LED:
  Anode  → D7 (via 220Ω resistor)
  Cathode → GND

TV/Coffee Buzzer:
  Positive → D8
  Negative → GND

Music System Buzzer:
  Positive → D4  
  Negative → GND
```

---

## 🛠️ Software Installation

### Step 1: Install Arduino IDE

1. **Download** Arduino IDE from [arduino.cc](https://www.arduino.cc/en/software)
2. **Install** following platform-specific instructions
3. **Add ESP8266 Board Support**:
   - Open `File → Preferences`
   - Add to "Additional Board Manager URLs":
     ```
     http://arduino.esp8266.com/stable/package_esp8266com_index.json
     ```
   - Go to `Tools → Board → Boards Manager`
   - Search "ESP8266" and install "esp8266 by ESP8266 Community"
   - Select `Tools → Board → NodeMCU 1.0 (ESP-12E Module)`

### Step 2: Install Arduino Libraries

Open `Sketch → Include Library → Manage Libraries` and install:

1. **PubSubClient** by Nick O'Leary (for MQTT)
2. **DHT sensor library** by Adafruit  
3. **Adafruit Unified Sensor** (dependency)
4. **Servo** (usually pre-installed)

### Step 3: Install Flutter

#### Windows:
```powershell
# Download Flutter SDK
# Extract to C:\flutter
# Add C:\flutter\bin to PATH
flutter doctor
```

#### macOS:
```bash
# Using Homebrew
brew install flutter
flutter doctor
```

#### Linux:
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz
tar xf flutter_linux_3.19.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

### Step 4: Install MQTT Broker

#### Option A: Mosquitto (Local)
```bash
# Windows (using Chocolatey)
choco install mosquitto

# macOS
brew install mosquitto
brew services start mosquitto

# Ubuntu/Debian
sudo apt update
sudo apt install mosquitto mosquitto-clients
sudo systemctl start mosquitto
sudo systemctl enable mosquitto
```

#### Option B: Online MQTT Broker
Use public brokers for testing:
- `broker.hivemq.com:1883`
- `test.mosquitto.org:1883`

---

## ⚙️ Configuration

### Step 1: Configure WiFi & MQTT in ESP8266 Code

Edit these files and update WiFi/MQTT settings:

#### `hardware/arduino_code/esp8266_01_living_room.ino`
```cpp
// WiFi Configuration
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// MQTT Configuration  
const char* mqtt_broker = "YOUR_PC_IP_ADDRESS";  // e.g., "192.168.1.100"
const int mqtt_port = 1883;
```

#### `hardware/arduino_code/esp8266_02_bedroom_security.ino`
```cpp
// Same WiFi & MQTT settings as above
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* mqtt_broker = "YOUR_PC_IP_ADDRESS";
```

#### `hardware/arduino_code/esp8266_03_energy_monitoring.ino`
```cpp
// Same WiFi & MQTT settings as above
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* mqtt_broker = "YOUR_PC_IP_ADDRESS";
```

### Step 2: Configure Flutter App

#### `mobile_app_flutter/smart_home_app/lib/config/app_config.dart`
```dart
class AppConfig {
  static const String mqttHost = 'YOUR_PC_IP_ADDRESS';  // Same as ESP8266
  static const int mqttPort = 1883;
  static const String apiBaseUrl = 'http://YOUR_PC_IP_ADDRESS:3000';
}
```

### Step 3: Find Your PC's IP Address

#### Windows:
```cmd
ipconfig
# Look for "IPv4 Address" under your active network adapter
```

#### macOS/Linux:
```bash
ifconfig
# Look for "inet" address under your active interface
```

---

## 🚀 Running the Project

### Step 1: Start MQTT Broker

#### Local Mosquitto:
```bash
# Windows
net start mosquitto

# macOS/Linux  
sudo systemctl start mosquitto
# or
mosquitto -v
```

#### Verify MQTT is running:
```bash
# Test publish/subscribe
mosquitto_pub -h localhost -t test/topic -m "Hello MQTT"
mosquitto_sub -h localhost -t test/topic
```

### Step 2: Upload ESP8266 Code

1. **Connect ESP8266 #1** via USB
2. **Select correct COM port** in `Tools → Port`
3. **Open** `hardware/arduino_code/esp8266_01_living_room.ino`
4. **Upload** code (`Ctrl+U`)
5. **Repeat** for ESP8266 #2 and #3 with their respective files

**Important**: Upload each `.ino` file to its corresponding ESP8266 board!

### Step 3: Run Flutter App

```bash
# Navigate to Flutter project
cd mobile_app_flutter/smart_home_app

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Or build APK for installation
flutter build apk --release
```

### Step 4: Verify Connections

#### Check ESP8266 Serial Output:
```
✅ WiFi connected! IP: 192.168.1.101
✅ Connected to MQTT broker!
📤 Published temperature: 23.5°C
📤 Published humidity: 45.0%
```

#### Test MQTT Communication:
```bash
# Subscribe to all topics
mosquitto_sub -h YOUR_PC_IP -t "#" -v

# Test device control
mosquitto_pub -h YOUR_PC_IP -t "home/lights/living_room/set" -m "ON"
```

---

## ✅ Testing & Verification

### 1. Hardware Testing

#### ESP8266 #1 (Living Room):
- [ ] DHT22 publishes temperature/humidity every 30 seconds
- [ ] MQ135 publishes air quality readings
- [ ] Lights respond to MQTT commands
- [ ] Serial monitor shows successful connections

#### ESP8266 #2 (Security):
- [ ] PIR sensors detect motion
- [ ] Door/window sensors report open/closed states
- [ ] Servo motor responds to open/close commands
- [ ] Buzzer activates during alarm

#### ESP8266 #3 (Energy):
- [ ] Smart TV LED responds to commands
- [ ] Music system plays selected songs
- [ ] Coffee maker buzzer activates

### 2. Flutter App Testing

- [ ] **Dashboard**: Shows real-time sensor data
- [ ] **Devices**: Controls lights and appliances
- [ ] **Security**: Arms/disarms system, shows sensor states
- [ ] **Energy**: Displays consumption chart
- [ ] **Automation**: Creates and executes rules

### 3. Integration Testing

- [ ] MQTT messages flow between app and ESP8266s
- [ ] Real-time updates appear instantly
- [ ] Automation rules trigger correctly
- [ ] Energy predictions display properly

---

## 🔧 Troubleshooting

### Common Issues

#### ESP8266 Won't Connect to WiFi
```cpp
// Check Serial Monitor for error messages
// Verify SSID and password are correct
// Ensure WiFi is 2.4GHz (ESP8266 doesn't support 5GHz)
```

#### MQTT Connection Failed
```bash
# Check if broker is running
netstat -an | grep 1883

# Test broker connectivity
mosquitto_pub -h YOUR_IP -t test -m "hello"
```

#### Flutter Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# For Android TensorFlow issues
cd android
./gradlew clean
cd ..
flutter run
```

#### Servo Motor Not Moving
```cpp
// Check power supply (servo needs adequate current)
// Verify wiring: Red→5V, Brown→GND, Orange→D1
// Test with simple servo sweep code first
```

### Debug Commands

#### MQTT Testing:
```bash
# Subscribe to all topics
mosquitto_sub -h YOUR_IP -t "#" -v

# Publish test commands
mosquitto_pub -h YOUR_IP -t "home/lights/living_room/set" -m "ON"
mosquitto_pub -h YOUR_IP -t "security/door/front/control" -m "OPEN"
mosquitto_pub -h YOUR_IP -t "appliances/music/song" -m "Happy Birthday"
```

#### ESP8266 Debug:
```cpp
// Add to setup() for detailed debugging
Serial.setDebugOutput(true);
WiFi.printDiag(Serial);
```

### Performance Optimization

1. **WiFi Signal**: Ensure strong WiFi signal for all ESP8266s
2. **Power Supply**: Use quality 5V/1A adapters, not just USB ports
3. **MQTT QoS**: Use QoS 0 for better performance in local networks
4. **Flutter**: Enable release mode for better performance

---

## 📚 Additional Resources

### Documentation
- [ESP8266 Arduino Core](https://arduino-esp8266.readthedocs.io/)
- [Flutter Documentation](https://flutter.dev/docs)
- [MQTT Protocol](https://mqtt.org/)
- [TensorFlow Lite](https://www.tensorflow.org/lite)

### Hardware Datasheets
- [ESP8266 NodeMCU Pinout](https://randomnerdtutorials.com/esp8266-pinout-reference-gpios/)
- [DHT22 Sensor](https://www.sparkfun.com/datasheets/Sensors/Temperature/DHT22.pdf)
- [SG90 Servo Motor](https://components101.com/motors/servo-motor-basics-pinout-datasheet)

### Useful Tools
- [MQTT Explorer](http://mqtt-explorer.com/) - GUI MQTT client
- [Arduino Serial Monitor](https://docs.arduino.cc/software/ide-v2/tutorials/ide-v2-serial-monitor)
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)

---

## 🎯 Quick Start Checklist

- [ ] Install Arduino IDE + ESP8266 support
- [ ] Install required Arduino libraries
- [ ] Install Flutter SDK
- [ ] Install MQTT broker (Mosquitto)
- [ ] Wire ESP8266 boards according to pin diagrams
- [ ] Update WiFi/MQTT credentials in all `.ino` files
- [ ] Upload code to each ESP8266 board
- [ ] Configure Flutter app with correct IP address
- [ ] Start MQTT broker
- [ ] Run Flutter app
- [ ] Test all features using the app interface

**Estimated Setup Time**: 2-4 hours for complete system

---

**🏠 Happy Smart Home Automation!** 

For issues or questions, check the troubleshooting section or review the Serial Monitor output for detailed error messages.
