import 'dart:async';
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  // Light states from ESP8266 #3 (Energy Monitoring)
  final Map<String, bool> _lightStates = {
    'Balcony Light': false,
    'Front Door Light': false,
    'Back Door Light': false,
    'Window Light': false,
  };

  // MQTT topics (same topic for both command and state - ESP8266 #3 uses base topics)
  final Map<String, String> _lightTopic = {
    'Balcony Light': 'lights/balcony',
    'Front Door Light': 'lights/front_door',
    'Back Door Light': 'lights/back_door',
    'Window Light': 'lights/window',
  };

  StreamSubscription? _mqttSub;
  
  // Track pending manual toggles to prevent feedback loop
  final Map<String, DateTime> _pendingToggles = {};
  static const Duration _ignoreDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    // Connect (no-op if already connected)
    MqttService.instance.connect().then((_) {
      // Subscribe to light state updates (ESP8266 #3 publishes retained messages on these topics)
      for (final t in _lightTopic.values) {
        MqttService.instance.subscribe(t);
      }
    });

    // Listen to all incoming messages
    _mqttSub = MqttService.instance.messageStream.listen((msg) {
      _handleMqttMessage(msg.topic, msg.message);
    });
  }

  @override
  void dispose() {
    _mqttSub?.cancel();
    super.dispose();
  }

  void _handleMqttMessage(String topic, String message) {
    _lightTopic.forEach((room, lightTopic) {
      if (topic == lightTopic) {
        final isOn =
            (message == 'ON' || message == '1' || message == 'true');
        
        // Check if this is a response to a recent manual toggle
        final lastToggle = _pendingToggles[room];
        if (lastToggle != null) {
          final timeSinceToggle = DateTime.now().difference(lastToggle);
          if (timeSinceToggle < _ignoreDuration) {
            // Ignore MQTT updates within 500ms of manual toggle
            // This prevents feedback loop from ESP8266 echo
            return;
          }
          // Clear the pending toggle after ignore period
          _pendingToggles.remove(room);
        }
        
        // Only update if state actually changed
        final currentState = _lightStates[room] ?? false;
        if (currentState != isOn) {
          setState(() => _lightStates[room] = isOn);
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
            _sectionTitle('Lighting'),
            const SizedBox(height: 8),
            _buildLighting(),
            const SizedBox(height: 16),
            _sectionTitle('Smart Appliances'),
            const SizedBox(height: 8),
            _buildAppliances(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLighting() {
    return Column(
      children: _lightStates.keys.map((room) {
        final isOn = _lightStates[room] ?? false;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: isOn ? Colors.amber : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(room,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600))),
                Switch(
                  value: isOn,
                  onChanged: (value) {
                    // Update local state immediately for responsive UI
                    setState(() => _lightStates[room] = value);
                    
                    // Track this manual toggle to ignore echo responses
                    _pendingToggles[room] = DateTime.now();

                    final topic = _lightTopic[room];
                    if (topic != null) {
                      MqttService.instance.publishOnOff(topic, value);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppliances() {
    // Placeholder appliances
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _applianceTile('Smart TV', Icons.tv, false, (_) {}),
            const Divider(),
            _applianceTile('Music System', Icons.music_note, false, (_) {}),
            const Divider(),
            _applianceTile('Coffee Maker', Icons.coffee, false, (_) {}),
          ],
        ),
      ),
    );
  }

  Widget _applianceTile(
      String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
