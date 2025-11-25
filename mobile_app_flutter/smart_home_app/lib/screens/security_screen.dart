import 'dart:async';
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  // Local UI state
  bool _armed = true;
  bool _camFrontOnline = true;
  bool _camBackOnline = true;

  bool _doorFrontLocked = true;
  bool _doorBackLocked = false;

  bool _motionPir1 = false;
  bool _motionPir2 = false;

  bool _winLivingClosed = true;
  bool _winBedroomClosed = true;
  bool _winKitchenClosed = false;

  double _smokeLevel = 0;
  double _lpgLevel = 0;

  StreamSubscription? _mqttSub;

  @override
  void initState() {
    super.initState();

    // Connect MQTT
    MqttService.instance.connect().then((_) {
      // Subscriptions (state topics from ESP)
      MqttService.instance.subscribe('security/armed/state');
      MqttService.instance.subscribe('security/door/front');
      MqttService.instance.subscribe('security/door/back');
      MqttService.instance.subscribe('security/window/living');
      MqttService.instance.subscribe('security/window/bedroom');
      MqttService.instance.subscribe('security/window/kitchen');

      MqttService.instance.subscribe('security/motion/pir1');
      MqttService.instance.subscribe('security/motion/pir2');

      MqttService.instance.subscribe('security/smoke');
      MqttService.instance.subscribe('security/lpg');
    });

    // Listen to incoming messages
    _mqttSub = MqttService.instance.messageStream.listen((msg) {
      _handleMqttMessage(msg.topic, msg.message);
    });
  }

  @override
  void dispose() {
    _mqttSub?.cancel();
    super.dispose();
  }

  void _handleMqttMessage(String topic, String payload) {
    setState(() {
      // --- Armour status ---
      if (topic == 'security/armed/state') {
        _armed = payload.toUpperCase().contains("ON") ||
            payload.toUpperCase() == "ARMED";
      }

      // --- Doors ---
      else if (topic == 'security/door/front') {
        _doorFrontLocked = payload.toUpperCase().contains('LOCK');
      } else if (topic == 'security/door/back') {
        _doorBackLocked = payload.toUpperCase().contains('LOCK');
      }

      // --- Windows ---
      else if (topic == 'security/window/living') {
        _winLivingClosed = payload.toUpperCase().contains('CLOSED');
      } else if (topic == 'security/window/bedroom') {
        _winBedroomClosed = payload.toUpperCase().contains('CLOSED');
      } else if (topic == 'security/window/kitchen') {
        _winKitchenClosed = payload.toUpperCase().contains('CLOSED');
      }

      // --- Motion sensors ---
      else if (topic == 'security/motion/pir1') {
        _motionPir1 = payload.toUpperCase().contains('DETECTED') ||
            payload.toUpperCase() == 'ON';
      } else if (topic == 'security/motion/pir2') {
        _motionPir2 = payload.toUpperCase().contains('DETECTED') ||
            payload.toUpperCase() == 'ON';
      }

      // --- Smoke sensor ---
      else if (topic == 'security/smoke') {
        if (payload.toUpperCase().contains('ALERT')) {
          _smokeLevel = 100;
        } else {
          _smokeLevel = double.tryParse(payload) ?? _smokeLevel;
        }
      }

      // --- LPG sensor ---
      else if (topic == 'security/lpg') {
        if (payload.toUpperCase().contains('ALERT')) {
          _lpgLevel = 100;
        } else {
          _lpgLevel = double.tryParse(payload) ?? _lpgLevel;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.shield,
                    color: _armed ? Colors.green : Colors.red),
                title: Text(_armed ? 'System Armed' : 'System Disarmed'),
                subtitle: const Text('Security status'),
                trailing: Switch(
                  value: _armed,
                  onChanged: (v) {
                    setState(() => _armed = v);
                    MqttService.instance.publishOnOff('security/armed/set', v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cameras
            _section(
              'Cameras',
              Row(
                children: [
                  Expanded(
                      child: _statusCard(
                          'Front Camera',
                          Icons.videocam,
                          _camFrontOnline ? 'Online' : 'Offline',
                          _camFrontOnline ? Colors.green : Colors.red,
                          onTap: () => setState(
                              () => _camFrontOnline = !_camFrontOnline))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statusCard(
                          'Back Camera',
                          Icons.videocam,
                          _camBackOnline ? 'Online' : 'Offline',
                          _camBackOnline ? Colors.green : Colors.red,
                          onTap: () => setState(
                              () => _camBackOnline = !_camBackOnline))),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Doors
            _section(
              'Doors',
              Row(
                children: [
                  Expanded(
                    child: _statusCard(
                        'Front Door',
                        Icons.door_front_door,
                        _doorFrontLocked ? 'Locked' : 'Unlocked',
                        _doorFrontLocked ? Colors.green : Colors.red,
                        onTap: () {}),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statusCard(
                        'Back Door',
                        Icons.door_back_door,
                        _doorBackLocked ? 'Locked' : 'Unlocked',
                        _doorBackLocked ? Colors.green : Colors.red,
                        onTap: () {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Windows
            _section(
              'Windows',
              Row(
                children: [
                  Expanded(
                      child: _statusCard(
                          'Living Window',
                          Icons.window,
                          _winLivingClosed ? 'Closed' : 'Open',
                          _winLivingClosed ? Colors.green : Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statusCard(
                          'Bedroom Window',
                          Icons.window,
                          _winBedroomClosed ? 'Closed' : 'Open',
                          _winBedroomClosed ? Colors.green : Colors.orange)),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _statusCard(
                        'Kitchen Window',
                        Icons.window,
                        _winKitchenClosed ? 'Closed' : 'Open',
                        _winKitchenClosed ? Colors.green : Colors.orange)),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),

            const SizedBox(height: 12),

            // MOTION
            _section(
              'Motion',
              Row(
                children: [
                  Expanded(
                    child: _statusCard(
                      'PIR Sensor 1',
                      _motionPir1 ? Icons.motion_photos_on : Icons.motion_photos_off,
                      _motionPir1 ? 'Detected' : 'Clear',
                      _motionPir1 ? Colors.orange : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statusCard(
                      'PIR Sensor 2',
                      _motionPir2 ? Icons.motion_photos_on : Icons.motion_photos_off,
                      _motionPir2 ? 'Detected' : 'Clear',
                      _motionPir2 ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _section(
              'Air Quality Sensors',
              Column(
                children: [
                  _sensorTile(
                    'Smoke Level',
                    Icons.local_fire_department,
                    '${_smokeLevel.toStringAsFixed(1)} ppm',
                    _smokeLevel > 60 ? Colors.red : Colors.green,
                  ),
                  const Divider(height: 1),
                  _sensorTile(
                    'LPG Level',
                    Icons.local_gas_station,
                    '${_lpgLevel.toStringAsFixed(1)} ppm',
                    _lpgLevel > 60 ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // UI Helpers
  // ---------------------------------------------------------

  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _statusCard(String title, IconData icon, String status, Color color,
      {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(status, style: TextStyle(color: color)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sensorTile(String title, IconData icon, String status, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Text(status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
