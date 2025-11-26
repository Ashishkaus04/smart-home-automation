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

  // Appliance states (Smart TV, Music System, Coffee Maker)
  final Map<String, bool> _applianceStates = {
    'Smart TV': false,
    'Music System': false,
    'Coffee Maker': false,
  };

  final Map<String, String> _applianceTopic = {
    'Smart TV': 'appliances/tv',
    'Music System': 'appliances/music',
    'Coffee Maker': 'appliances/coffee',
  };

  // Music System song selection
  final List<String> _availableSongs = [
    'Happy Birthday',
    'Jingle Bells',
    'Twinkle Twinkle',
    'Mario Theme',
    'Star Wars',
    'Beep Beep',
  ];
  String _selectedSong = 'Happy Birthday';

  final Map<String, IconData> _applianceIcons = {
    'Smart TV': Icons.tv,
    'Music System': Icons.music_note,
    'Coffee Maker': Icons.coffee,
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
      final topics = <String>{
        ..._lightTopic.values,
        ..._applianceTopic.values,
        'appliances/music/song', // Song selection topic
      };
      for (final t in topics) {
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
    final handledLights = _updateStateFromTopic(
      topic,
      message,
      _lightTopic,
      _lightStates,
    );

    if (!handledLights) {
      _updateStateFromTopic(
        topic,
        message,
        _applianceTopic,
        _applianceStates,
      );
    }
  }

  bool _updateStateFromTopic(
    String topic,
    String message,
    Map<String, String> topicMap,
    Map<String, bool> stateMap,
  ) {
    for (final entry in topicMap.entries) {
      if (topic == entry.value) {
        final key = entry.key;
        final isOn = (message == 'ON' || message == '1' || message == 'true');

        if (_shouldIgnoreEcho(key)) {
          // Ignore MQTT update triggered by our own manual toggle
          return true;
        }

        final currentState = stateMap[key] ?? false;
        if (currentState != isOn) {
          setState(() => stateMap[key] = isOn);
        }
        return true;
      }
    }
    return false;
  }

  bool _shouldIgnoreEcho(String key) {
    final lastToggle = _pendingToggles[key];
    if (lastToggle == null) return false;
    final timeSinceToggle = DateTime.now().difference(lastToggle);
    if (timeSinceToggle < _ignoreDuration) {
      return true;
    }
    _pendingToggles.remove(key);
    return false;
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
    return Column(
      children: _applianceStates.keys.map((appliance) {
        final isOn = _applianceStates[appliance] ?? false;
        final topic = _applianceTopic[appliance];
        final icon = _applianceIcons[appliance] ?? Icons.power;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: isOn ? Colors.green : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appliance,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: isOn,
                      onChanged: topic == null
                          ? null
                          : (value) {
                              setState(() => _applianceStates[appliance] = value);
                              _pendingToggles[appliance] = DateTime.now();
                              MqttService.instance.publishOnOff(topic, value);
                              
                              // If Music System is turned on, play selected song
                              if (appliance == 'Music System' && value) {
                                _playSelectedSong();
                              }
                            },
                    ),
                  ],
                ),
                // Song selection for Music System
                if (appliance == 'Music System' && isOn) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.queue_music, size: 20),
                      const SizedBox(width: 8),
                      const Text('Select Song:', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedSong,
                          isExpanded: true,
                          items: _availableSongs.map((song) {
                            return DropdownMenuItem(
                              value: song,
                              child: Text(song, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (String? newSong) {
                            if (newSong != null) {
                              setState(() => _selectedSong = newSong);
                              _playSelectedSong();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _playSelectedSong() {
    // Publish song selection to ESP8266
    MqttService.instance.publishString('appliances/music/song', _selectedSong);
  }

}
