import 'dart:async';
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Placeholder state/data. Replace with real services later.
  double todayKwh = 3.8;
  double monthKwh = 0;
  int monthDays = 30;
  String weatherSummary = 'Partly Cloudy';
  double weatherTemp = double.nan; // updated from MQTT
  int weatherHumidity = -1;        // updated from MQTT
  int aqi = -1;                    // updated from MQTT
  bool acOn = false;
  int acTemp = 24;
  // Quick lighting states
  bool bedroomLight = false;
  bool livingLight = false;
  bool kitchenLight = false;
  bool bathroomLight = false;
  final List<String> recentActivities = <String>[
    'Bedroom light turned ON',
    'Living room fan set to speed 2',
    'Kitchen light turned OFF',
    'Bathroom exhaust ON',
  ];

  StreamSubscription? _mqttSub;

  String _formattedNow() {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return '$date  •  $time';
  }

  @override
  void initState() {
    super.initState();

    // Ensure the client connects and subscribe to topics we care about.
    // Connect will no-op if already connected.
    MqttService.instance.connect().then((_) {
      // Subscribe to the topics you want updates from
      MqttService.instance.subscribe('living_room/temperature');
      MqttService.instance.subscribe('living_room/humidity');
      MqttService.instance.subscribe('living_room/aqi');
      MqttService.instance.subscribe('living_room/#');
      MqttService.instance.subscribe('energy/consumption');
      // You can also subscribe to lighting state topics if you want quick sync:
      MqttService.instance.subscribe('bedroom/light');
      MqttService.instance.subscribe('living_room/light');
      MqttService.instance.subscribe('kitchen/light');
      MqttService.instance.subscribe('bathroom/light');
    });

    // Listen for decoded messages from the service (MqttMsg with .topic/.message)
    _mqttSub = MqttService.instance.messageStream.listen((msg) {
      if (!mounted) return;
      _handleMqttMessage(msg.topic, msg.message);
    });
  }

  @override
  void dispose() {
    _mqttSub?.cancel();
    super.dispose();
  }

  void _handleMqttMessage(String topic, String payload) {
    // Debug: uncomment if you need to inspect messages in console
    // print('[Dashboard] MQTT <- $topic : $payload');

    setState(() {
      if (topic == 'living_room/temperature') {
        final v = double.tryParse(payload);
        if (v != null) weatherTemp = v;
      } else if (topic == 'living_room/humidity') {
        final v = double.tryParse(payload);
        if (v != null) weatherHumidity = v.round();
      } else if (topic == 'living_room/aqi') {
        final v = int.tryParse(payload);
        if (v != null) aqi = v;
      } else if (topic == 'energy/consumption') {
        final v = double.tryParse(payload);
        if (v != null) monthKwh = v;
      } else if (topic == 'bedroom/light') {
        bedroomLight = (payload == 'ON');
      } else if (topic == 'living_room/light') {
        livingLight = (payload == 'ON');
      } else if (topic == 'kitchen/light') {
        kitchenLight = (payload == 'ON');
      } else if (topic == 'bathroom/light') {
        bathroomLight = (payload == 'ON');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (mounted) setState(() {});
      },
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildEnergyCards(context),
              const SizedBox(height: 12),
              _buildQuickLighting(context),
              const SizedBox(height: 12),
              _buildWeather(context),
              const SizedBox(height: 12),
              _buildClimateControl(context),
              const SizedBox(height: 12),
              _buildRecentActivity(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.dashboard, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_formattedNow(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        Widget todayCard = Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Grid Usage (Monthly)'),
                    Icon(Icons.bolt, color: Colors.amber.shade700),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${todayKwh.toStringAsFixed(1)} kWh',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: (todayKwh / 10).clamp(0.0, 1.0)),
              ],
            ),
          ),
        );
        Widget monthCard = Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Energy Today'),
                    Icon(Icons.grid_on, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${monthKwh.toStringAsFixed(1)} kWh',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
        if (isNarrow) {
          return Column(
            children: [
              todayCard,
              const SizedBox(height: 12),
              monthCard,
            ],
          );
        }
        return Row(children: [Expanded(child: todayCard), const SizedBox(width: 12), Expanded(child: monthCard)]);
      },
    );
  }

  Widget _buildQuickLighting(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quick Lighting'),
                Icon(Icons.flash_on, color: Colors.amber.shade700),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _roomQuickAction('Bedroom', Icons.bed, bedroomLight, () => setState(() => bedroomLight = !bedroomLight));
                  case 1:
                    return _roomQuickAction('Living', Icons.weekend, livingLight, () => setState(() => livingLight = !livingLight));
                  case 2:
                    return _roomQuickAction('Kitchen', Icons.kitchen, kitchenLight, () => setState(() => kitchenLight = !kitchenLight));
                  default:
                    return _roomQuickAction('Bathroom', Icons.shower, bathroomLight, () => setState(() => bathroomLight = !bathroomLight));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomQuickAction(String label, IconData icon, bool isOn, VoidCallback onTap) {
    final Color onBg = Colors.amber.shade100;
    final Color onFg = Colors.amber.shade900;
    final Color borderColor = Colors.amber.shade700;
    return ElevatedButton(
      onPressed: () {
        // Compute next state and publish it
        final next = !isOn;
        final topic = _topicForRoom(label);
        if (topic != null) {
          // publishOnOff uses retain: false internally
          MqttService.instance.publishOnOff(topic, next);
        }
        // Update UI after publishing
        onTap();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: isOn ? onBg : null,
        foregroundColor: isOn ? onFg : null,
        elevation: isOn ? 3 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOn ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String? _topicForRoom(String room) {
    switch (room) {
      case 'Bedroom':
        return 'bedroom/light';
      case 'Living':
      case 'Living Room':
        return 'living_room/light';
      case 'Kitchen':
        return 'kitchen/light';
      case 'Bathroom':
        return 'bathroom/light';
    }
    return null;
  }

  Widget _buildWeather(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Living Room Environment', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Icon(Icons.home, color: Colors.blue.shade600),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _envTile(
                  color: Colors.blue,
                  icon: Icons.thermostat,
                  label: 'Temp',
                  value: weatherTemp.isNaN ? '—' : '${weatherTemp.toStringAsFixed(1)}°C',
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _envTile(
                  color: Colors.green,
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: (weatherHumidity < 0) ? '—' : '$weatherHumidity%',
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _envTile(
                  color: Colors.amber,
                  icon: Icons.air,
                  label: 'AQI',
                  value: (aqi < 0) ? '—' : '$aqi',
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _envTile({
    required MaterialColor color,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.shade600),
          const SizedBox(height: 6),
          Text(label),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color.shade900,
                ),
                children: [
                  TextSpan(text: value.replaceAll('°C', '')), // main numeric part
                  if (value.contains('°C'))
                    WidgetSpan(
                      alignment: PlaceholderAlignment.top,
                      child: Transform.translate(
                        offset: const Offset(1, -6),
                        child: Text(
                          '°C',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color.shade900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateControl(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Climate Control'),
                Icon(Icons.ac_unit, color: Colors.blue.shade600),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Switch(
                  value: acOn,
                  onChanged: (v) {
                    setState(() => acOn = v);
                    MqttService.instance.publishOnOff('climate/ac', v);
                    if (v) {
                      MqttService.instance.publishString('climate/ac_temperature', acTemp.toString());
                    }
                  },
                ),
                const SizedBox(width: 8),
                Text(acOn ? 'AC On' : 'AC Off'),
                const Spacer(),
                IconButton(
                  onPressed: acOn
                      ? () {
                          setState(() => acTemp = (acTemp - 1).clamp(16, 30));
                          MqttService.instance.publishString('climate/ac_temperature', acTemp.toString());
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$acTemp°C', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: acOn
                      ? () {
                          setState(() => acTemp = (acTemp + 1).clamp(16, 30));
                          MqttService.instance.publishString('climate/ac_temperature', acTemp.toString());
                        }
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Activity'),
                Icon(Icons.history, color: Colors.grey[700]),
              ],
            ),
            const SizedBox(height: 12),
            ...recentActivities.take(6).map((e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text(e),
                  subtitle: Text('Just now'),
                )),
          ],
        ),
      ),
    );
  }
}
