import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  // Local UI state (no backend yet)
  bool _armed = true;
  bool _camFrontOnline = true;
  bool _camBackOnline = true;
  bool _doorFrontLocked = true;
  bool _doorBackLocked = false;
  bool _motionLiving = false;
  bool _motionBedroom = false;
  bool _motionKitchen = false;
  bool _smokeAlert = false;
  bool _lpgAlert = false;
  // Windows
  bool _winLivingClosed = true;
  bool _winBedroomClosed = true;
  bool _winKitchenClosed = false;

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
                leading: Icon(Icons.shield, color: _armed ? Colors.green : Colors.red),
                title: Text(_armed ? 'System Armed' : 'System Disarmed'),
                subtitle: const Text('Security status'),
                trailing: Switch(value: _armed, onChanged: (v) {
                  setState(() => _armed = v);
                  MqttService.instance.publishOnOff('security/armed', v);
                }),
              ),
            ),
            const SizedBox(height: 12),
            _section('Cameras', Row(
              children: [
                Expanded(child: _statusCard('Front Camera', Icons.videocam, _camFrontOnline ? 'Online' : 'Offline', _camFrontOnline ? Colors.green : Colors.red, onTap: () => setState(() => _camFrontOnline = !_camFrontOnline))),
                const SizedBox(width: 12),
                Expanded(child: _statusCard('Back Camera', Icons.videocam, _camBackOnline ? 'Online' : 'Offline', _camBackOnline ? Colors.green : Colors.red, onTap: () => setState(() => _camBackOnline = !_camBackOnline))),
              ],
            )),
            const SizedBox(height: 12),
            _section('Doors', Row(
              children: [
                Expanded(child: _statusCard('Front Door', Icons.door_front_door, _doorFrontLocked ? 'Locked' : 'Unlocked', _doorFrontLocked ? Colors.green : Colors.red, onTap: () => setState(() => _doorFrontLocked = !_doorFrontLocked))),
                const SizedBox(width: 12),
                Expanded(child: _statusCard('Back Door', Icons.door_back_door, _doorBackLocked ? 'Locked' : 'Unlocked', _doorBackLocked ? Colors.green : Colors.red, onTap: () => setState(() => _doorBackLocked = !_doorBackLocked))),
              ],
            )),
            const SizedBox(height: 12),
            _section('Windows', Row(
              children: [
                Expanded(child: _statusCard('Living Window', Icons.window, _winLivingClosed ? 'Closed' : 'Open', _winLivingClosed ? Colors.green : Colors.orange, onTap: () => setState(() => _winLivingClosed = !_winLivingClosed))),
                const SizedBox(width: 12),
                Expanded(child: _statusCard('Bedroom Window', Icons.window, _winBedroomClosed ? 'Closed' : 'Open', _winBedroomClosed ? Colors.green : Colors.orange, onTap: () => setState(() => _winBedroomClosed = !_winBedroomClosed))),
              ],
            )),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statusCard('Kitchen Window', Icons.window, _winKitchenClosed ? 'Closed' : 'Open', _winKitchenClosed ? Colors.green : Colors.orange, onTap: () => setState(() => _winKitchenClosed = !_winKitchenClosed))),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 12),
            _section('Motion', Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _statusCard('Living Motion', _motionLiving ? Icons.motion_photos_on : Icons.motion_photos_off, _motionLiving ? 'Detected' : 'Clear', _motionLiving ? Colors.orange : Colors.green, onTap: () => setState(() => _motionLiving = !_motionLiving))),
                    const SizedBox(width: 12),
                    Expanded(child: _statusCard('Bedroom Motion', _motionBedroom ? Icons.motion_photos_on : Icons.motion_photos_off, _motionBedroom ? 'Detected' : 'Clear', _motionBedroom ? Colors.orange : Colors.green, onTap: () => setState(() => _motionBedroom = !_motionBedroom))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statusCard('Kitchen Motion', _motionKitchen ? Icons.motion_photos_on : Icons.motion_photos_off, _motionKitchen ? 'Detected' : 'Clear', _motionKitchen ? Colors.orange : Colors.green, onTap: () => setState(() => _motionKitchen = !_motionKitchen))),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            )),
            const SizedBox(height: 12),
            _section('Other Sensors', Column(
              children: [
                _sensorTile('Smoke', _smokeAlert ? Icons.warning : Icons.check_circle, _smokeAlert ? 'ALERT' : 'Normal', _smokeAlert ? Colors.red : Colors.green, onTap: () => setState(() => _smokeAlert = !_smokeAlert)),
                const Divider(height: 1),
                _sensorTile('LPG', _lpgAlert ? Icons.blur_on : Icons.check_circle, _lpgAlert ? 'ALERT' : 'Normal', _lpgAlert ? Colors.red : Colors.green, onTap: () => setState(() => _lpgAlert = !_lpgAlert)),
              ],
            )),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Subscribe to security-related MQTT topics
    final m = MqttService.instance;
    m.subscribe('security/door/front');
    m.subscribe('security/door/back');
    m.subscribe('security/window/living');
    m.subscribe('security/window/bedroom');
    m.subscribe('security/window/kitchen');
    m.subscribe('bedroom/motion');
    m.subscribe('kitchen/motion');
    m.subscribe('living_room/motion');
    m.subscribe('security/smoke');
    m.subscribe('security/lpg');

    m.messages.listen((event) {
      final topic = event.topic;
      final rec = event.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(rec.payload.message);
      if (!mounted) return;
      setState(() {
        if (topic == 'security/door/front') {
          _doorFrontLocked = payload.toUpperCase().contains('LOCK');
        } else if (topic == 'security/door/back') {
          _doorBackLocked = payload.toUpperCase().contains('LOCK');
        } else if (topic == 'security/window/living') {
          _winLivingClosed = payload.toUpperCase().contains('CLOSED');
        } else if (topic == 'security/window/bedroom') {
          _winBedroomClosed = payload.toUpperCase().contains('CLOSED');
        } else if (topic == 'security/window/kitchen') {
          _winKitchenClosed = payload.toUpperCase().contains('CLOSED');
        } else if (topic == 'living_room/motion') {
          _motionLiving = payload.toUpperCase().contains('DETECTED') || payload.toUpperCase() == 'ON';
        } else if (topic == 'bedroom/motion') {
          _motionBedroom = payload.toUpperCase().contains('DETECTED') || payload.toUpperCase() == 'ON';
        } else if (topic == 'kitchen/motion') {
          _motionKitchen = payload.toUpperCase().contains('DETECTED') || payload.toUpperCase() == 'ON';
        } else if (topic == 'security/smoke') {
          _smokeAlert = payload.toUpperCase().contains('ALERT');
        } else if (topic == 'security/lpg') {
          _lpgAlert = payload.toUpperCase().contains('ALERT');
        }
      });
    });
  }

  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _statusCard(String title, IconData icon, String status, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _sensorTile(String title, IconData icon, String status, Color color, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Text(status, style: TextStyle(color: color)),
    );
  }

  Widget _motionRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(value ? Icons.motion_photos_on : Icons.motion_photos_off, color: value ? Colors.orange : Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

