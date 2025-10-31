import 'package:flutter/material.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  // Lighting states with intensity (0-100)
  final Map<String, bool> _lightOn = {
    'Bedroom': false,
    'Living Room': false,
    'Kitchen': false,
    'Bathroom': false,
  };
  final Map<String, double> _lightIntensity = {
    'Bedroom': 70,
    'Living Room': 60,
    'Kitchen': 80,
    'Bathroom': 50,
  };

  // Appliances
  bool _tvOn = false;
  bool _musicOn = false;
  bool _coffeeOn = false;

  // (Security moved to Security screen)

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
            // Security section removed (moved to Security screen)
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildLighting() {
    final items = _lightOn.keys.toList();
    return Column(
      children: [
        ...items.map((room) => Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_lightOn[room]! ? Icons.lightbulb : Icons.lightbulb_outline,
                            color: _lightOn[room]! ? Colors.amber : null),
                        const SizedBox(width: 8),
                        Expanded(child: Text(room, style: const TextStyle(fontWeight: FontWeight.w600))),
                        Switch(
                          value: _lightOn[room]!,
                          onChanged: (v) => setState(() => _lightOn[room] = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Intensity'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Slider(
                            value: _lightIntensity[room]!,
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: _lightIntensity[room]!.round().toString(),
                            onChanged: _lightOn[room]!
                                ? (v) => setState(() => _lightIntensity[room] = v)
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text('${_lightIntensity[room]!.round()}%', textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildAppliances() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _applianceTile('Smart TV', Icons.tv, _tvOn, (v) => setState(() => _tvOn = v)),
            const Divider(),
            _applianceTile('Music System', Icons.music_note, _musicOn, (v) => setState(() => _musicOn = v)),
            const Divider(),
            _applianceTile('Coffee Maker', Icons.coffee, _coffeeOn, (v) => setState(() => _coffeeOn = v)),
          ],
        ),
      ),
    );
  }

  Widget _applianceTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  // Security-related UI moved to Security screen
}


