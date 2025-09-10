#!/usr/bin/env python3
"""
Smart Home IoT Device Simulator
Simulates Arduino/ESP32 sensors and actuators
"""

import time
import json
import random
import requests
from datetime import datetime

class IoTSimulator:
    def __init__(self):
        self.server_url = "http://localhost:5000"
        self.devices = {
            "temperature": 22.0,
            "humidity": 45.0,
            "motion": False,
            "light_level": 75.0,
            "door_sensor": True,
            "smoke_detector": False
        }
        
    def read_sensors(self):
        """Simulate sensor readings"""
        # Temperature: 18-28°C with gradual changes
        self.devices["temperature"] += random.uniform(-0.5, 0.5)
        self.devices["temperature"] = max(18, min(28, self.devices["temperature"]))
        
        # Humidity: 30-70% with gradual changes  
        self.devices["humidity"] += random.uniform(-2, 2)
        self.devices["humidity"] = max(30, min(70, self.devices["humidity"]))
        
        # Motion: Random detection events
        self.devices["motion"] = random.random() < 0.1
        
        # Light level: Varies by time of day
        hour = datetime.now().hour
        if 6 <= hour <= 18:  # Daytime
            base_light = 80
        else:  # Nighttime
            base_light = 20
        self.devices["light_level"] = base_light + random.uniform(-10, 10)
        
        # Door sensor: Mostly closed
        self.devices["door_sensor"] = random.random() > 0.05
        
        # Smoke detector: Very rarely triggered
        self.devices["smoke_detector"] = random.random() < 0.001
        
    def send_data(self):
        """Send data to backend server"""
        try:
            response = requests.post(
                f"{self.server_url}/api/sensors/update",
                json=self.devices,
                timeout=5
            )
            status = "✓" if response.status_code == 200 else "✗"
            print(f"{status} Data sent at {datetime.now().strftime('%H:%M:%S')}")
        except Exception as e:
            print(f"✗ Connection failed: {e}")
    
    def display_readings(self):
        """Display current sensor readings"""
        print("\n" + "="*50)
        print("🔧 IoT Device Simulator - Live Data")
        print("="*50)
        
        print(f"🌡️  Temperature: {self.devices['temperature']:.1f}°C")
        print(f"💧 Humidity: {self.devices['humidity']:.1f}%")
        print(f"🚶 Motion: {'Detected' if self.devices['motion'] else 'Clear'}")
        print(f"💡 Light Level: {self.devices['light_level']:.1f} lux")
        print(f"🚪 Door: {'Closed' if self.devices['door_sensor'] else 'Open'}")
        print(f"🔥 Smoke: {'ALERT!' if self.devices['smoke_detector'] else 'Clear'}")
        
        if self.devices['smoke_detector']:
            print("🚨 SMOKE DETECTED - EMERGENCY ALERT! 🚨")
    
    def run(self):
        """Main simulation loop"""
        print("🏠 Smart Home IoT Simulator Starting...")
        print("📡 Simulating Arduino/ESP32 devices")
        print("Press Ctrl+C to stop\n")
        
        try:
            while True:
                self.read_sensors()
                self.display_readings()
                self.send_data()
                time.sleep(8)  # Update every 8 seconds
                
        except KeyboardInterrupt:
            print("\n\n🛑 Simulator stopped")
        except Exception as e:
            print(f"❌ Error: {e}")

if __name__ == "__main__":
    simulator = IoTSimulator()
    simulator.run()