# 🏠 Smart Home Automation System

A comprehensive IoT-based smart home automation system built with Flutter mobile app, ESP8266 microcontrollers, and MQTT communication protocol. Control your home devices, monitor security, track energy consumption, and automate your living space.

---

## ✨ Features

### 🎛️ Device Control
- **Smart Lighting**: Control multiple lights (Living Room, Kitchen, Bathroom) remotely
- **Appliances**: Smart TV, Music System, and Coffee Maker control
- **Climate Control**: Real-time temperature and humidity monitoring
- **Air Quality**: MQ135 sensor for air quality index (AQI) monitoring

### 🔒 Security System
- **Motion Detection**: Dual PIR sensors for motion monitoring
- **Door/Window Sensors**: Magnetic sensors for entry point monitoring
- **Servo Door Control**: Automated front door control with SG90 servo motor
- **Security Alarms**: Buzzer alerts for unauthorized access
- **Camera Status**: Real-time camera online/offline status

### ⚡ Energy Monitoring
- **Real-time Consumption**: Track power usage with dynamic updates
- **AI Predictions**: LSTM-based energy consumption forecasting
- **Visual Analytics**: Interactive charts for hourly, daily, and monthly data
- **Dashboard Metrics**: Today's consumption and monthly totals

### 🤖 Automation
- **Rule-based Automation**: Create custom automation rules
- **Trigger Actions**: Motion, time, and sensor-based triggers
- **Smart Scheduling**: Automated device control based on conditions

### 📱 Mobile App
- **Modern UI**: Beautiful Material Design interface
- **Real-time Updates**: Instant synchronization via MQTT
- **Multi-screen Navigation**: Dashboard, Devices, Security, Energy, and Automation screens
- **Cross-platform**: Android and iOS support

---

## 🛠️ Technology Stack

### Mobile Application
- **Framework**: Flutter 3.9.2+
- **State Management**: Provider
- **MQTT Client**: mqtt_client
- **ML/AI**: TensorFlow Lite (TFLite)
- **Charts**: Custom Flutter charts

### Hardware
- **Microcontrollers**: ESP8266 NodeMCU (3 boards)
- **Sensors**: DHT22 (Temp/Humidity), MQ135 (Air Quality), PIR (Motion), Magnetic (Door/Window)
- **Actuators**: Relay modules, SG90 Servo motor, LEDs, Buzzers
- **Communication**: WiFi + MQTT protocol

### Backend & Communication
- **MQTT Broker**: Mosquitto / HiveMQ / EMQX
- **Protocol**: MQTT (Message Queuing Telemetry Transport)
- **Optional Backend**: Node.js + Express.js (for additional features)

### Development Tools
- **Arduino IDE**: ESP8266 firmware development
- **Flutter SDK**: Mobile app development
- **Python**: ML model training (optional)

---

## 📁 Project Structure

```
smart-home-automation/
├── mobile_app_flutter/
│   └── smart_home_app/          # Flutter mobile application
│       ├── lib/
│       │   ├── config/           # App configuration (MQTT, etc.)
│       │   ├── models/          # Data models
│       │   ├── screens/          # UI screens
│       │   │   ├── dashboard_screen.dart
│       │   │   ├── devices_screen.dart
│       │   │   ├── security_screen.dart
│       │   │   ├── energy_screen.dart
│       │   │   └── automation_screen.dart
│       │   └── services/         # MQTT, LSTM prediction services
│       ├── assets/
│       │   └── models/
│       │       └── energy_lstm.tflite  # ML model
│       └── android/           # Android-specific files
│
├── hardware/
│   └── arduino_code/            # ESP8266 firmware
│       ├── esp8266_01_living_room.ino      # Living room controller
│       ├── esp8266_02_bedroom_security.ino # Security controller
│       └── esp8266_03_energy_monitoring.ino # Energy & appliances
│
├── backend/                     # Optional Node.js backend
│   ├── server.js
│   ├── routes/
│   └── models/
│
├── frontend/                    # Optional React web dashboard
│   └── src/
│
├── Read me files/               # Detailed documentation
│   └── PROJECT_SETUP_GUIDE.md  # Complete setup instructions
│
└── README.md                    # This file
```

---

## 🚀 Quick Start

### Prerequisites

1. **Arduino IDE** (1.8.19+ or 2.x)
   - Install ESP8266 board support
   - Install required libraries (PubSubClient, DHT sensor library, etc.)

2. **Flutter SDK** (3.9.2+)
   - Download from [flutter.dev](https://flutter.dev)
   - Add to PATH

3. **MQTT Broker**
   - **Local**: Install Mosquitto
   - **Cloud**: Use HiveMQ public broker (`broker.hivemq.com:1883`)

4. **Hardware**
   - 3x ESP8266 NodeMCU boards
   - Sensors (DHT22, MQ135, PIR, Magnetic)
   - Actuators (Relays, Servo, LEDs, Buzzers)

### Installation Steps

#### 1. Clone the Repository
```bash
git clone <repository-url>
cd smart-home-automation
```

#### 2. Configure ESP8266 Code

Edit WiFi and MQTT settings in each Arduino file:

**`hardware/arduino_code/esp8266_01_living_room.ino`**
```cpp
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* mqtt_broker = "YOUR_PC_IP_ADDRESS";  // e.g., "192.168.1.100"
const int mqtt_port = 1883;
```

Repeat for `esp8266_02_bedroom_security.ino` and `esp8266_03_energy_monitoring.ino`.

#### 3. Configure Flutter App

Edit `mobile_app_flutter/smart_home_app/lib/config/app_config.dart`:

```dart
// Set your MQTT broker IP address
static const String homeMqttHost = 'YOUR_PC_IP_ADDRESS';
static const String collegeMqttHost = 'YOUR_PC_IP_ADDRESS';

// Or use public broker for testing
static const Environment currentEnvironment = Environment.test;
```

#### 4. Upload ESP8266 Firmware

1. Connect ESP8266 #1 via USB
2. Open `esp8266_01_living_room.ino` in Arduino IDE
3. Select board: `Tools → Board → NodeMCU 1.0 (ESP-12E Module)`
4. Select port: `Tools → Port → COMx`
5. Upload code (`Ctrl+U`)
6. Repeat for ESP8266 #2 and #3

#### 5. Start MQTT Broker

**Local Mosquitto:**
```bash
# Windows
net start mosquitto

# macOS/Linux
sudo systemctl start mosquitto
# or
mosquitto -v
```

**Or use public broker** (for testing):
- No setup needed, app connects to `broker.hivemq.com`

#### 6. Run Flutter App

```bash
cd mobile_app_flutter/smart_home_app
flutter pub get
flutter run
```

---

## 📱 App Screens

### 🏠 Dashboard
- Real-time sensor data (Temperature, Humidity, Air Quality)
- Power consumption metrics (Today & Monthly)
- Quick device status overview
- Dynamic power values starting at 3.8 kWh

### 💡 Devices
- **Lights**: Living Room, Kitchen, Bathroom control
- **Appliances**: 
  - Smart TV (LED + Buzzer)
  - Music System (Dedicated buzzer with song selection)
  - Coffee Maker (Buzzer)
- Real-time toggle switches with feedback prevention

### 🔒 Security
- **Motion Sensors**: Dual PIR sensor monitoring
- **Doors**: Front door (Servo control) & Back door (Status only)
- **Windows**: Living, Bedroom, Kitchen monitoring
- **Cameras**: Always online status display
- **Alarm System**: Arm/Disarm functionality

### ⚡ Energy
- **Consumption Charts**: Visual representation of energy usage
- **AI Predictions**: LSTM model-based forecasting
- **Time Periods**: Hourly, Daily, Monthly views
- **Comparison Graphs**: Actual vs Predicted data

### 🤖 Automation
- Create custom automation rules
- Define triggers (motion, time, sensors)
- Set actions (lights, appliances, alarms)
- Enable/disable automation rules

---

## ⚙️ Configuration

### MQTT Topics

The system uses the following MQTT topic structure:

```
# Sensor Data
home/temperature          # Temperature readings
home/humidity             # Humidity readings
home/air_quality          # Air quality index

# Device Control
home/lights/living_room/set    # Living room light control
home/lights/kitchen/set         # Kitchen light control
home/lights/bathroom/set       # Bathroom light control

# Security
security/motion/pir1           # PIR sensor 1 motion
security/motion/pir2           # PIR sensor 2 motion
security/door/front/control    # Front door servo control (OPEN/CLOSE)
security/door/front/status     # Front door status (LOCKED/UNLOCKED)

# Appliances
appliances/tv/set              # Smart TV control
appliances/music/set           # Music system control
appliances/music/song          # Music system song selection
appliances/coffee/set          # Coffee maker control

# Energy
energy/consumption/today        # Today's energy consumption
energy/consumption/monthly     # Monthly energy consumption
energy/power/current           # Current power usage
```

### Environment Configuration

The app supports multiple environments:

```dart
enum Environment {
  home,      // Home network
  college,   // College network
  test,      // Public test broker
}
```

Switch environments in `app_config.dart`:
```dart
static const Environment currentEnvironment = Environment.test;
```

---

## 🔧 Hardware Setup

### ESP8266 #1 - Living Room Controller
- **DHT22**: Temperature/Humidity sensor (D4)
- **MQ135**: Air quality sensor (A0)
- **4-Channel Relay**: Light control (D1, D2, D5, D6)

### ESP8266 #2 - Security Controller
- **PIR Sensors**: Motion detection (D5, D6)
- **Magnetic Sensors**: Doors (D7, D8) & Windows (D0, D3, D4)
- **SG90 Servo**: Front door control (D1)
- **Buzzer**: Security alarm (D2)

### ESP8266 #3 - Energy & Appliances
- **LED**: Smart TV indicator (D7)
- **Buzzers**: TV/Coffee (D8), Music System (D4)

**📖 For detailed wiring diagrams, see [`Read me files/PROJECT_SETUP_GUIDE.md`](Read%20me%20files/PROJECT_SETUP_GUIDE.md)**

---

## 🧪 Testing

### Hardware Testing
1. **ESP8266 Serial Monitor**: Check for WiFi and MQTT connection messages
2. **MQTT Client**: Use `mosquitto_sub` to monitor all topics:
   ```bash
   mosquitto_sub -h YOUR_IP -t "#" -v
   ```
3. **Device Control**: Test via Flutter app or MQTT commands:
   ```bash
   mosquitto_pub -h YOUR_IP -t "home/lights/living_room/set" -m "ON"
   ```

### App Testing
- ✅ Dashboard shows real-time sensor data
- ✅ Devices screen controls all lights and appliances
- ✅ Security screen monitors sensors and controls door
- ✅ Energy screen displays consumption charts
- ✅ Automation rules execute correctly

---

## 🐛 Troubleshooting

### ESP8266 Won't Connect to WiFi
- Verify SSID and password are correct
- Ensure WiFi is 2.4GHz (ESP8266 doesn't support 5GHz)
- Check Serial Monitor for error messages

### MQTT Connection Failed
- Verify MQTT broker is running: `netstat -an | grep 1883`
- Check firewall settings (port 1883)
- Ensure ESP8266 and Flutter app use the same broker IP

### Flutter Build Errors
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run --android-skip-build-dependency-validation
```

### Servo Motor Not Moving
- Check power supply (servo needs adequate current)
- Verify wiring: Red→5V, Brown→GND, Orange→D1
- Test with simple servo sweep code first

### TensorFlow Lite Model Errors
- Ensure `energy_lstm.tflite` is in `assets/models/`
- Check `pubspec.yaml` includes the asset
- Verify Android dependency: `tensorflow-lite-select-tf-ops:2.14.0`

---

## 📚 Documentation

- **[Complete Setup Guide](Read%20me%20files/PROJECT_SETUP_GUIDE.md)**: Detailed installation and configuration instructions
- **[Hardware Overview](Read%20me%20files/HARDWARE_OVERVIEW.md)**: Component specifications
- **[Architecture Summary](Read%20me%20files/COMPLETE_ARCHITECTURE_SUMMARY.md)**: System architecture details
- **[Wiring Reference](Read%20me%20files/QUICK_WIRING_REFERENCE.md)**: Quick pin connection guide

---

## 🎯 Features in Detail

### Smart TV Control
- Turns on LED indicator when activated
- Plays buzzer sound for feedback
- Real-time status updates

### Music System
- Dedicated buzzer for music playback
- Song selection dropdown (Happy Birthday, Jingle Bells, etc.)
- Non-blocking playback (doesn't interfere with other operations)

### Coffee Maker
- Buzzer activation when turned on
- Shared buzzer with Smart TV

### Front Door Control
- SG90 servo motor for automated door movement
- Open/Close buttons in Security screen
- Dynamic status updates (Locked/Unlocked)
- Smooth servo movement with proper delays

### Energy Monitoring
- Dynamic power values (starts at 3.8 kWh)
- Real-time consumption tracking
- LSTM-based predictions
- Visual charts and graphs

---

## 🔐 Security Features

- **Motion Detection**: Dual PIR sensors for comprehensive coverage
- **Entry Point Monitoring**: Doors and windows with magnetic sensors
- **Automated Door Control**: Servo-based front door mechanism
- **Alarm System**: Buzzer alerts for security breaches
- **Real-time Status**: Instant updates on all security sensors

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.


---

## 🙏 Acknowledgments

- ESP8266 Community for excellent documentation
- Flutter Team for the amazing framework
- MQTT.org for the lightweight protocol
- TensorFlow Team for TFLite support

---

## 📞 Support

For issues, questions, or contributions:
- Check the [Troubleshooting](#-troubleshooting) section
- Review Serial Monitor output for hardware issues
- Check MQTT broker logs for communication problems
- Refer to [PROJECT_SETUP_GUIDE.md](Read%20me%20files/PROJECT_SETUP_GUIDE.md) for detailed instructions
---

**🏠 Happy Smart Home Automation!** 🚀
