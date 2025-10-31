import 'package:flutter/material.dart';
// UI-first mock version (no API calls)

class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> with TickerProviderStateMixin {
  // Mock data
  double currentKwh = 1.8; // current usage
  double currentCost = 12.6; // INR
  double gridKwhMonth = 92.4;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current usage & cost
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Current Usage', value: '${currentKwh.toStringAsFixed(2)} kWh', icon: Icons.bolt)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Current Cost', value: '₹ ${currentCost.toStringAsFixed(2)}', icon: Icons.currency_rupee)),
              ],
            ),
            const SizedBox(height: 12),
            // Grid usage
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.grid_on, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Grid Usage (Monthly)'),
                        const SizedBox(height: 4),
                        Text('${gridKwhMonth.toStringAsFixed(1)} kWh', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: (gridKwhMonth / 150).clamp(0.0, 1.0)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Trends with tabs
            Card(
              elevation: 2,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [Tab(text: 'Today'), Tab(text: 'This Week'), Tab(text: 'This Month')],
                  ),
                  SizedBox(
                    height: 220,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Today: 24 hours bar chart
                        _BarsChart(
                          label: 'Today (kWh/hr)',
                          data: List<double>.generate(24, (i) => 0.5 + (i % 6) * 0.2),
                          xLabels: List<String>.generate(24, (i) => i % 3 == 0 ? '${i}h' : ''),
                        ),
                        // Week: 7 days bar chart
                        _BarsChart(
                          label: 'This Week (kWh/day)',
                          data: const [2.1, 2.8, 3.2, 2.6, 3.9, 3.1, 2.4],
                          xLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                        ),
                        // Month: line chart over ~30 days
                        _LineChart(
                          label: 'This Month (kWh/day)',
                          data: List<double>.generate(30, (i) => 2.0 + (i % 5) * 0.6 + (i % 3) * 0.2),
                          xLabels: List<String>.generate(30, (i) => (i % 5 == 0) ? '${i + 1}' : ''),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // AI Recommendations
            Text('AI Recommendations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _aiRecommendation('Shift laundry to off-peak hours', 'Potential saving ~8%', actions: ['Schedule 10 PM', 'Notify household']),
            _aiRecommendation('Reduce AC setpoint from 24°C to 25°C', 'Potential saving ~5%', actions: ['Apply now', 'Set for afternoons']),
            _aiRecommendation('Enable eco mode on refrigerator', 'Potential saving ~3%', actions: ['Open appliance settings']),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 36) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Colors.indigo),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarsChart extends StatelessWidget {
  final String label;
  final List<double> data;
  final List<String> xLabels;
  const _BarsChart({required this.label, required this.data, required this.xLabels});

  @override
  Widget build(BuildContext context) {
    final double maxV = data.fold<double>(0, (p, e) => e > p ? e : p);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...List.generate(data.length, (i) {
                  final v = data[i];
                  final lbl = i < xLabels.length ? xLabels[i] : '';
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 8 + 120 * (maxV == 0 ? 0 : v / maxV),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(lbl, style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final String label;
  final List<double> data;
  final List<String> xLabels;
  const _LineChart({required this.label, required this.data, required this.xLabels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(data: data, color: Theme.of(context).colorScheme.primary),
              child: Row(
                children: List.generate(xLabels.length, (i) => Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(xLabels[i], style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double maxV = data.fold<double>(0, (p, e) => e > p ? e : p);
    final double minV = data.fold<double>(data.first, (p, e) => e < p ? e : p);
    final double dx = size.width / (data.length - 1);
    final double height = size.height - 18; // reserve for labels row overlay

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final t = maxV == minV ? 0.5 : (data[i] - minV) / (maxV - minV);
      final y = height - t * (height - 8) + 4; // padding
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);

    // Fill under curve (light)
    final fillPath = Path.from(path)
      ..lineTo(size.width, height + 4)
      ..lineTo(0, height + 4)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(colors: [color.withOpacity(0.25), color.withOpacity(0.05)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.data != data || oldDelegate.color != color;
}

Widget _aiRecommendation(String title, String subtitle, {List<String> actions = const []}) {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.green.shade700)),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions
                  .map((a) => OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.play_circle_outline, size: 18), label: Text(a)))
                  .toList(),
            ),
          ],
        ],
      ),
    ),
  );
}


