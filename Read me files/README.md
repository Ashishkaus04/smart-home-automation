# Smart Home Hardware Documentation

## 📚 Documentation Files

### 🚀 Getting Started
1. **[COMPLETE_HARDWARE_CONNECTIONS.md](./COMPLETE_HARDWARE_CONNECTIONS.md)** - **START HERE!** Complete pin-by-pin wiring guide for all 3 ESP8266 boards
2. **[QUICK_WIRING_REFERENCE.md](./QUICK_WIRING_REFERENCE.md)** - Quick reference for pin connections and component lists
3. **[MOBILE_HOTSPOT_SETUP.md](./MOBILE_HOTSPOT_SETUP.md)** - Step-by-step guide to connect ESP8266 boards to mobile hotspot

### 📖 Detailed Guides
4. **[ESP8266_MULTI_BOARD_SETUP.md](./ESP8266_MULTI_BOARD_SETUP.md)** - Comprehensive setup guide with circuit diagrams and troubleshooting
5. **[HARDWARE_OVERVIEW.md](./HARDWARE_OVERVIEW.md)** - System architecture and board distribution overview
6. **[FLUTTER_APP_COMPATIBILITY.md](./FLUTTER_APP_COMPATIBILITY.md)** - MQTT topic mapping and Flutter app compatibility details

## 🔌 Arduino Code Files

All ESP8266 code files are in the `arduino_code/` directory:

- **esp8266_01_living_room.ino** - Living Room & Common Areas (Lights, Fan, DHT22)
- **esp8266_02_bedroom_security.ino** - Bedroom & Security (Light, DHT22, MQ135, Motion, Doors, Buzzer)
- **esp8266_03_outdoor_appliances.ino** - Outdoor & Appliances (Garage, Garden, Car Charger)

## 🎯 Quick Start

1. Read **[COMPLETE_HARDWARE_CONNECTIONS.md](./COMPLETE_HARDWARE_CONNECTIONS.md)** for wiring
2. Follow **[MOBILE_HOTSPOT_SETUP.md](./MOBILE_HOTSPOT_SETUP.md)** for network setup
3. Upload the appropriate `.ino` file to each ESP8266 board
4. Test from Flutter app

## 📦 Component Lists

See **[QUICK_WIRING_REFERENCE.md](./QUICK_WIRING_REFERENCE.md)** for complete component shopping list.

## 🔧 Need Help?

- **Wiring Issues**: Check [COMPLETE_HARDWARE_CONNECTIONS.md](./COMPLETE_HARDWARE_CONNECTIONS.md)
- **Network Issues**: Check [MOBILE_HOTSPOT_SETUP.md](./MOBILE_HOTSPOT_SETUP.md)
- **MQTT Topics**: Check [FLUTTER_APP_COMPATIBILITY.md](./FLUTTER_APP_COMPATIBILITY.md)
- **General Setup**: Check [ESP8266_MULTI_BOARD_SETUP.md](./ESP8266_MULTI_BOARD_SETUP.md)

