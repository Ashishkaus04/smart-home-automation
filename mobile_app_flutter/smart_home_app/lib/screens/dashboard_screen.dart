import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Placeholder state/data. Replace with real services later.
  double todayKwh = 3.8;
  double monthKwh = 92.4;
  int monthDays = 30;
  String weatherSummary = 'Partly Cloudy';
  double weatherTemp = 27.5;
  int weatherHumidity = 62;
  int aqi = 72;
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

  String _formattedNow() {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return '$date  •  $time';
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
                  Text('Dashboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_formattedNow(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
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
                    const Text('Energy Today'),
                    Icon(Icons.bolt, color: Colors.amber.shade700),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${todayKwh.toStringAsFixed(1)} kWh', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                    const Text('Grid Usage (Monthly)'),
                    Icon(Icons.grid_on, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${monthKwh.toStringAsFixed(1)} kWh', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Over $monthDays days', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 400;
                final spacing = 12.0;
                final columns = isNarrow ? 2 : 4;
                final totalSpacing = spacing * (columns - 1);
                final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

                List<Widget> items = [
                  _roomQuickAction('Bedroom', Icons.bed, bedroomLight, () => setState(() => bedroomLight = !bedroomLight)),
                  _roomQuickAction('Living', Icons.weekend, livingLight, () => setState(() => livingLight = !livingLight)),
                  _roomQuickAction('Kitchen', Icons.kitchen, kitchenLight, () => setState(() => kitchenLight = !kitchenLight)),
                  _roomQuickAction('Bathroom', Icons.shower, bathroomLight, () => setState(() => bathroomLight = !bathroomLight)),
                ];

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: items
                      .map((w) => SizedBox(width: itemWidth, child: w))
                      .toList(),
                );
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
      onPressed: onTap,
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

  Widget _buildWeather(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.cloud, size: 40, color: Colors.blue.shade600),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weatherSummary, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text('${weatherTemp.toStringAsFixed(1)}°C'),
                      Text('Humidity: $weatherHumidity%'),
                      Text('AQI: $aqi'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
                  onChanged: (v) => setState(() => acOn = v),
                ),
                const SizedBox(width: 8),
                Text(acOn ? 'AC On' : 'AC Off'),
                const Spacer(),
                IconButton(
                  onPressed: acOn ? () => setState(() => acTemp = (acTemp - 1).clamp(16, 30)) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$acTemp°C', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: acOn ? () => setState(() => acTemp = (acTemp + 1).clamp(16, 30)) : null,
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


