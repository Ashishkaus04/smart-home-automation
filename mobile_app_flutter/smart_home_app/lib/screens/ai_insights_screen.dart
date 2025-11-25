import 'package:flutter/material.dart';

class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'AI Insights',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _insightCard(
              context,
              title: 'Optimization',
              icon: Icons.trending_up,
              color: Colors.green,
              points: const [
                'Shift heavy loads to off-peak hours',
                'Tune AC setpoint to 25°C for afternoons',
                'Enable eco modes on high-usage appliances',
              ],
            ),

            _insightCard(
              context,
              title: 'Security',
              icon: Icons.shield,
              color: Colors.indigo,
              points: const [
                'Unusual motion detected in kitchen at 2AM',
                'Recommend enabling auto-lock routine at 11PM',
                'Add window open alerts for bedroom',
              ],
            ),

            _insightCard(
              context,
              title: 'Energy',
              icon: Icons.bolt,
              color: Colors.amber,
              points: const [
                'Weekly peak on Friday between 7–9 PM',
                'Lighting contributes ~18% of total usage',
                'Potential saving ~12% with recommended plan',
              ],
            ),

            _insightCard(
              context,
              title: 'Maintenance',
              icon: Icons.build_circle,
              color: Colors.orange,
              points: const [
                'Filter replacement due in 10 days (HVAC)',
                'Fridge compressor runtime above baseline (+7%)',
                'Recommend appliance diagnostics next week',
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Model Performance',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _accuracyBar(context, 'Energy Prediction', 0.87),
            _accuracyBar(context, 'Pattern Recognition', 0.81),
            _accuracyBar(context, 'Anomaly Detection', 0.78),
            _accuracyBar(context, 'Optimization Engine', 0.84),

            const SizedBox(height: 16),
            Text(
              'Learning Progress',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _learningProgress(
              datapoints: 12437,
              patterns: 56,
              optimizations: 29,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> points,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),

            ...points.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(p)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _notify(context, '$title applied'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Apply'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _notify(context, '$title dismissed'),
                  icon: const Icon(Icons.close),
                  label: const Text('Dismiss'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _accuracyBar(BuildContext context, String label, double value) {
    final pct = (value * 100).toStringAsFixed(0);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('$pct%'),
              ],
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 10,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _learningProgress({
  required BuildContext context,
  required int datapoints,
  required int patterns,
  required int optimizations,
}) {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 380;

          final items = [
            _progressItem(context,
                label: 'Data points', value: datapoints.toString(), icon: Icons.dataset),
            _progressItem(context,
                label: 'Patterns', value: patterns.toString(), icon: Icons.auto_graph),
            _progressItem(context,
                label: 'Optimizations', value: optimizations.toString(), icon: Icons.tune),
          ];

          if (isNarrow) {
            return Column(
              children: [
                for (final item in items) ...[
                  Row(children: [Expanded(child: item)]),
                  const SizedBox(height: 8),
                ]
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: items[0]),
              _vDivider(),
              Expanded(child: items[1]),
              _vDivider(),
              Expanded(child: items[2]),
            ],
          );
        },
      ),
    ),
  );
}

Widget _vDivider() => SizedBox(
      width: 12,
      child: Center(
        child: Container(width: 1, height: 40, color: Colors.black12),
      ),
    );

Widget _progressItem(
  BuildContext context, {
  required String label,
  required String value,
  required IconData icon,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    ],
  );
}

void _notify(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg)),
  );
}
