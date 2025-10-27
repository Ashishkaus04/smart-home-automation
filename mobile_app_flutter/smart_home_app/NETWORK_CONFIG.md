# Smart Home App - Network Configuration Guide

## Overview
This app supports multiple network environments (Home and College) with easy switching between MQTT server configurations.

## How to Change Network Environment

### Method 1: Using the Config Screen (Recommended)
1. Open the app and go to the **Config** tab (last tab in bottom navigation)
2. You'll see your current environment and available options
3. Follow the instructions shown in the app to modify the configuration

### Method 2: Direct File Editing
1. Open `lib/config/app_config.dart`
2. Find the `currentEnvironment` variable:
   ```dart
   static const Environment currentEnvironment = Environment.college;
   ```
3. Change it to your desired environment:
   - For **Home**: `Environment.home`
   - For **College**: `Environment.college`
4. Update the IP addresses if needed:
   ```dart
   // Home Network Configuration
   static const String homeMqttHost = '192.168.1.100';  // Your home router IP
   static const int homeMqttPort = 1883;
   
   // College Network Configuration  
   static const String collegeMqttHost = '10.217.139.106';  // Your college hotspot IP
   static const int collegeMqttPort = 1883;
   ```
5. **Hot restart** the app (not just hot reload)

## Current Configuration
- **Environment**: College
- **MQTT Server**: 10.217.139.106:1883
- **Auto-reconnect**: Enabled
- **Connection timeout**: 10 seconds

## Features
- ✅ Easy environment switching
- ✅ Visual connection status
- ✅ Auto-reconnection
- ✅ Real-time sensor data
- ✅ Device control (Light, Fan, Buzzer)
- ✅ Network configuration screen

## Troubleshooting
- If connection fails, check if your MQTT broker is running
- Verify the IP address is correct for your current network
- Make sure your device is connected to the same network as the MQTT broker
- Use hot restart (not hot reload) after changing configuration
