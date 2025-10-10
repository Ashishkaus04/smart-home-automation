import 'package:flutter/material.dart';
import '../models/device_models.dart';
import '../services/api_service.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final ApiService _api = ApiService();
  DeviceState? _deviceState;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.getDevices();
      final data = response['data'] as Map<String, dynamic>;
      setState(() {
        _deviceState = DeviceState.fromJson(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleLight(String room, bool newValue) async {
    try {
      await _api.updateDevice(category: 'lights', device: room, state: newValue);
      setState(() {
        final current = _deviceState;
        if (current != null) {
          final updatedLights = Map<String, bool>.from(current.lights);
          updatedLights[room] = newValue;
          _deviceState = DeviceState(
            lights: updatedLights,
            thermostat: current.thermostat,
            security: current.security,
            appliances: current.appliances,
            sensors: current.sensors,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 8),
            FilledButton(onPressed: _loadDevices, child: const Text('Retry')),
          ],
        ),
      );
    }

    final state = _deviceState!;
    final entries = state.lights.entries.toList();

    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = entries[index];
          final room = entry.key.replaceAll('_', ' ');
          final on = entry.value;
          return ListTile(
            leading: Icon(on ? Icons.lightbulb : Icons.lightbulb_outline, color: on ? Colors.amber : null),
            title: Text(room[0].toUpperCase() + room.substring(1)),
            trailing: Switch(
              value: on,
              onChanged: (value) => _toggleLight(entry.key, value),
            ),
          );
        },
      ),
    );
  }
}


