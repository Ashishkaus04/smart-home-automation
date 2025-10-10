import 'package:flutter/material.dart';
import '../models/device_models.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart' show ApiConfig;

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final ApiService _api = ApiService();
  final SocketService _socket = SocketService();
  DeviceState? _state;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _socket.connect(ApiConfig.baseUrl, onConnect: () {});
    _socket.onDeviceState((data) {
      setState(() {
        _state = DeviceState.fromJson(Map<String, dynamic>.from(data as Map));
      });
    });
    _socket.onDeviceUpdate((_) => _refresh());
    _socket.onSensorUpdate((sensors) {
      if (_state == null) return;
      final current = _state!;
      final merged = Map<String, dynamic>.from({
        'lights': current.lights,
        'thermostat': {
          'temperature': current.thermostat.temperature,
          'target': current.thermostat.target,
          'mode': current.thermostat.mode,
        },
        'security': {
          'armed': current.security.armed,
          'doors': current.security.doors,
        },
        'appliances': current.appliances,
        'sensors': sensors,
      });
      setState(() {
        _state = DeviceState.fromJson(merged);
      });
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.getDevices();
      _state = DeviceState.fromJson(res['data'] as Map<String, dynamic>);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() => _load();

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 8),
            FilledButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      );
    }
    final s = _state!;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.shield, color: s.security.armed ? Colors.green : Colors.red),
              title: Text(s.security.armed ? 'System Armed' : 'System Disarmed'),
              subtitle: const Text('Security status'),
              trailing: Switch(
                value: s.security.armed,
                onChanged: (value) async {
                  try {
                    await _api.updateSecurityArmed(value);
                    await _refresh();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Doors', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...s.security.doors.entries.map((e) => Card(
                child: ListTile(
                  leading: Icon(e.value ? Icons.lock : Icons.lock_open, color: e.value ? Colors.green : Colors.red),
                  title: Text('${e.key[0].toUpperCase()}${e.key.substring(1)} door'),
                  subtitle: Text(e.value ? 'Locked' : 'Unlocked'),
                  trailing: Switch(
                    value: e.value,
                    onChanged: (value) async {
                      try {
                        await _api.updateDoorLock(e.key, value);
                        await _refresh();
                      } catch (ex) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $ex')));
                      }
                    },
                  ),
                ),
              )),
          const SizedBox(height: 12),
          const Text('Sensors', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Card(
            child: Column(children: [
              ListTile(
                leading: Icon(s.sensors.motion ? Icons.motion_photos_on : Icons.motion_photos_off),
                title: const Text('Motion'),
                trailing: Text(s.sensors.motion ? 'Detected' : 'Clear'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(s.sensors.smoke ? Icons.warning : Icons.check_circle),
                title: const Text('Smoke'),
                trailing: Text(s.sensors.smoke ? 'Alert' : 'Normal'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.water_drop_outlined),
                title: const Text('Humidity'),
                trailing: Text('${s.sensors.humidity}%'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.light_mode_outlined),
                title: const Text('Light'),
                trailing: Text('${s.sensors.light}'),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}


