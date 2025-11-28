# ACS712 Current Sensor Wiring Guide

## ⚠️ SAFETY WARNING
**AC MAINS VOLTAGE CAN BE LETHAL!**
- Always disconnect power before making connections
- Use proper insulation and wire ratings
- Never touch exposed wires when power is on
- Use a fuse or circuit breaker for protection
- If unsure, consult an electrician

---

## ACS712 Sensor Overview

The ACS712 is a **hall-effect current sensor** that measures AC/DC current **non-invasively**. The current-carrying wire passes through a hole in the sensor.

### Available Variants:
- **ACS712-5A**: Measures up to ±5 Amperes (Sensitivity: 185 mV/A)
- **ACS712-20A**: Measures up to ±20 Amperes (Sensitivity: 100 mV/A) ⭐ **Recommended**
- **ACS712-30A**: Measures up to ±30 Amperes (Sensitivity: 66 mV/A)

---

## Pin Connections

### ACS712 Module Pins:
```
ACS712 Module:
┌─────────────────┐
│  VCC  │  GND    │
│  OUT  │         │
│  [ ]  │  (hole) │  ← Wire passes through here
└─────────────────┘
```

### ESP8266 Connections:

| ACS712 Pin | ESP8266 Pin | Description |
|------------|-------------|-------------|
| **VCC** | **3.3V** or **5V** | Power supply (check your module - some need 5V) |
| **GND** | **GND** | Ground (common ground) |
| **OUT** | **A0** | Analog output (0-3.3V or 0-5V depending on module) |

---

## Wiring Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    AC Mains (220V/110V)                  │
│                                                          │
│  [Wall Outlet] ────[FUSE]───[LOAD]───[ACS712]───[Back] │
│                              (wire through hole)         │
└─────────────────────────────────────────────────────────┘
                              │
                              │ (Non-invasive measurement)
                              │
┌─────────────────────────────────────────────────────────┐
│                    ESP8266 Board                        │
│                                                          │
│  ┌──────────────┐                                         │
│  │   ESP8266    │                                         │
│  │              │                                         │
│  │  3.3V ───────┼─── VCC (ACS712)                        │
│  │  GND  ───────┼─── GND (ACS712)                        │
│  │  A0   ───────┼─── OUT (ACS712)                        │
│  └──────────────┘                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Connection

### Step 1: Power Connections
1. **Connect ACS712 VCC to ESP8266 3.3V** (or 5V if your module requires it)
   - ⚠️ **Check your ACS712 module**: Some modules need 5V, others work with 3.3V
   - If using 5V module, connect to ESP8266 5V pin (if available) or use external 5V supply

2. **Connect ACS712 GND to ESP8266 GND**
   - This creates a common ground reference

### Step 2: Signal Connection
3. **Connect ACS712 OUT to ESP8266 A0**
   - This is the analog output that carries the current measurement signal
   - ESP8266 A0 is the only analog input pin

### Step 3: AC Wire Connection (IMPORTANT!)
4. **Pass ONE wire of your AC circuit through the ACS712 sensor hole**
   - ⚠️ **Only pass ONE wire** (either Live/Hot or Neutral, typically Live)
   - ⚠️ **Do NOT pass both wires** - this will cancel out the measurement
   - The wire should pass through the center hole of the sensor
   - Make sure the wire is properly insulated and not touching the sensor body

### Step 4: Physical Installation
5. **Secure the sensor**
   - Use cable ties or mounting brackets to secure the ACS712 module
   - Ensure the wire passing through is not loose
   - Keep the sensor away from moisture and heat sources

---

## Connection Examples

### Example 1: Measuring Single Appliance
```
Wall Outlet (220V AC)
    │
    ├───[FUSE]───[ACS712 Sensor]───[Appliance (e.g., Fan)]
    │              (wire through)
    │
    └───[Neutral]─────────────────[Appliance]
```

### Example 2: Measuring Main Line (Whole House/Floor)
```
Main Circuit Breaker
    │
    ├───[Main Fuse]───[ACS712 Sensor]───[Distribution Panel]
    │                    (wire through)
    │
    └───[Neutral]────────────────────────[Distribution Panel]
```

---

## Important Notes

### 1. **Which Wire to Measure?**
- **Best Practice**: Measure the **Live/Hot wire** (not Neutral)
- The sensor works on either, but Live wire is standard
- In a 2-wire system: Measure the wire that goes to the load
- In a 3-wire system: Measure the Live wire (usually red/black)

### 2. **Power Supply**
- **3.3V modules**: Connect VCC to ESP8266 3.3V pin
- **5V modules**: 
  - Option A: Use ESP8266 5V pin (if available)
  - Option B: Use external 5V supply (share GND with ESP8266)
  - ⚠️ **Never connect 5V to ESP8266 3.3V pin** - it will damage the board!

### 3. **Isolation**
- The ACS712 provides **galvanic isolation** (no direct electrical connection)
- The sensor is safe to use with AC mains
- However, always use proper insulation and follow safety guidelines

### 4. **Wire Size**
- The sensor hole typically fits wires up to **14 AWG** (2.0 mm²)
- For larger wires, use a current transformer (CT) instead
- Ensure the wire fits comfortably without forcing

### 5. **Calibration**
- The sensor may need calibration for accurate readings
- With no current, the output should be at VCC/2 (1.65V for 3.3V, 2.5V for 5V)
- If readings are off, adjust the `ACS712_QUIESCENT_VOLTAGE` in code

---

## Testing the Connection

### 1. **No-Load Test** (Power OFF)
- Connect all wires (VCC, GND, OUT)
- Upload the code to ESP8266
- Open Serial Monitor (115200 baud)
- With no current, you should see:
  - Current: ~0.00 A (may show small noise)
  - Power: ~0.0 W

### 2. **Load Test** (Power ON - BE CAREFUL!)
- Turn on a small load (e.g., 100W bulb)
- Check serial monitor for readings
- Expected: Current ≈ Power / Voltage
  - Example: 100W / 220V ≈ 0.45 A

### 3. **Troubleshooting**
- **No reading or 0.00A**: Check wire is passing through sensor hole
- **Negative readings**: Wire is passing through in wrong direction (flip it)
- **Erratic readings**: Check connections, add more samples in code
- **Always 0V on OUT**: Check VCC connection

---

## Code Configuration

In `esp8266_03_energy_monitoring.ino`, verify these settings:

```cpp
#define ACS712_PIN A0              // ✅ Correct for ESP8266
#define ACS712_SENSITIVITY 100     // ⚠️ Change based on your sensor:
                                   //    5A: 185, 20A: 100, 30A: 66
#define ACS712_VCC 3.3             // ⚠️ Change to 5.0 if using 5V module
#define ACS712_QUIESCENT_VOLTAGE 1.65  // VCC/2 (1.65 for 3.3V, 2.5 for 5V)
#define AC_VOLTAGE 220.0           // ⚠️ Change to 110.0 for US/Japan
```

---

## Safety Checklist

- [ ] Power is disconnected before making connections
- [ ] All connections are secure and properly insulated
- [ ] Fuse/circuit breaker is installed in the AC line
- [ ] Only ONE wire passes through the sensor hole
- [ ] Sensor is mounted securely and away from heat/moisture
- [ ] VCC voltage matches sensor requirements (3.3V or 5V)
- [ ] GND is properly connected (common ground)
- [ ] Wire gauge fits through sensor hole
- [ ] Initial testing done with small load first
- [ ] Serial monitor shows reasonable readings

---

## Visual Reference

```
                    ┌─────────────┐
                    │   ACS712    │
                    │   Module    │
                    │             │
    AC Wire ────────┤  [  HOLE  ] ├─────── To Load
    (Live)          │             │
                    │  VCC  GND   │
                    │   │    │    │
                    │   │    │    │
                    └───┼────┼────┘
                        │    │
                    ┌───┴────┴───┐
                    │  ESP8266   │
                    │            │
                    │  3.3V  GND │
                    │   A0       │
                    └────────────┘
```

---

## Need Help?

If you encounter issues:
1. Check serial monitor for error messages
2. Verify all connections with a multimeter (power OFF)
3. Test with a small load first (LED bulb)
4. Ensure wire is properly passing through sensor hole
5. Verify sensor variant matches code sensitivity setting

**Remember: Safety first! When in doubt, consult a qualified electrician.**

