import 'dart:math' as math;
import 'package:flutter/material.dart';

class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  // Current data (static demo values)
  double currentKwh = 1.8;
  double currentCost = 12.6;
  double gridKwhMonth = 92.4;

  // Demo data for LSTM comparison chart (matches notebook-style plot)
  static final List<double> _demoActual = List<double>.generate(
    200,
    (index) => double.parse(
      (1.05 + 0.25 * math.sin(index / 12)).toStringAsFixed(3),
    ),
  );

  static final List<double> _demoPredicted = List<double>.generate(
    200,
    (index) => double.parse(
      (1.02 + 0.22 * math.sin((index + 2) / 12)).toStringAsFixed(3),
    ),
  );


  // --------------------------------------------------------------
  // UI
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerStats(context),
            const SizedBox(height: 12),
            _monthlyGridUsage(context),
            const SizedBox(height: 12),
            _predictionTabs(context),
            const SizedBox(height: 12),
            Text(
              'AI Recommendations',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _aiRecommendation('Shift laundry to off-peak hours',
                'Potential saving ~8%',
                actions: ['Schedule 10 PM', 'Notify household']),
            _aiRecommendation('Reduce AC setpoint from 24°C to 25°C',
                'Potential saving ~5%',
                actions: ['Apply now', 'Set for afternoons']),
            _aiRecommendation('Enable eco mode on refrigerator',
                'Potential saving ~3%',
                actions: ['Open appliance settings']),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // UI COMPONENTS
  // --------------------------------------------------------------
  Widget _headerStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Current Usage',
            value: '${currentKwh.toStringAsFixed(2)} kWh',
            icon: Icons.bolt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Current Cost',
            value: '₹ ${currentCost.toStringAsFixed(2)}',
            icon: Icons.currency_rupee,
          ),
        ),
      ],
    );
  }

  Widget _monthlyGridUsage(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.grid_on,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grid Usage (Monthly)'),
                  const SizedBox(height: 4),
                  Text(
                    '${gridKwhMonth.toStringAsFixed(1)} kWh',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (gridKwhMonth / 150).clamp(0.0, 1.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _predictionTabs(BuildContext context) {
    final labels = List.generate(
      _demoActual.length,
      (i) => i % 20 == 0 ? 't$i' : '',
    );

    return Card(
      elevation: 2,
      child: SizedBox(
        height: 260,
        child: _LstmComparisonChart(
          label: 'LSTM Prediction (kWh)',
          actual: _demoActual,
          predicted: _demoPredicted,
          xLabels: labels,
          isLoading: false,
          error: null,
        ),
      ),
    );
  }
}

// --------------------------------------------------------------
//  Stat Card
// --------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.title, required this.value, required this.icon});

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
                    Text(title,
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
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

// --------------------------------------------------------------
//  LSTM Comparison Chart (Actual vs Predicted)
// --------------------------------------------------------------
class _LstmComparisonChart extends StatelessWidget {
  final String label;
  final List<double> actual;
  final List<double>? predicted;
  final List<String> xLabels;
  final bool isLoading;
  final String? error;

  const _LstmComparisonChart({
    required this.label,
    required this.actual,
    this.predicted,
    required this.xLabels,
    required this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Text(error!,
            style: TextStyle(color: Colors.red.shade600)),
      );
    }
    final predictedList = predicted ?? <double>[];
    if (actual.isEmpty && predictedList.isEmpty) {
      return Center(
        child: Text(
          'No data yet.\nKeep the ESP publishing energy data.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return _LstmComparisonLineChart(
      actual: actual,
      predicted: predicted,
      xLabels: xLabels,
    );
  }
}

// --------------------------------------------------------------
// LSTM Comparison Line Chart (Actual vs Predicted)
// --------------------------------------------------------------
class _LstmComparisonLineChart extends StatelessWidget {
  final List<double> actual;
  final List<double>? predicted;
  final List<String> xLabels;

  const _LstmComparisonLineChart({
    required this.actual,
    this.predicted,
    required this.xLabels,
  });

  @override
  Widget build(BuildContext context) {
    final predictedList = predicted ?? <double>[];
    final maxLength = actual.length > predictedList.length ? actual.length : predictedList.length;
    final effectiveLabels = xLabels.length >= maxLength
        ? xLabels.take(maxLength).toList()
        : List.generate(maxLength, (i) => i < xLabels.length ? xLabels[i] : '');

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 2,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                const Text('actual', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 2,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                const Text('prediction', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Chart
        Expanded(
          child: CustomPaint(
            painter: _LstmComparisonPainter(
              actual: actual,
              predicted: predicted,
            ),
            child: Row(
              children: List.generate(
                effectiveLabels.length,
                (i) => Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      effectiveLabels[i],
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LstmComparisonPainter extends CustomPainter {
  final List<double> actual;
  final List<double>? predicted;

  _LstmComparisonPainter({
    required this.actual,
    this.predicted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (actual.isEmpty && (predicted == null || predicted!.isEmpty)) return;

    // Combine both datasets to find global min/max
    final predictedList = predicted ?? <double>[];
    final allValues = <double>[...actual, ...predictedList];
    
    if (allValues.isEmpty) return;

    final maxVal = allValues.reduce((a, b) => a > b ? a : b);
    final minVal = allValues.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;
    if (range == 0) return;

    final height = size.height - 18;
    final chartTop = 4.0;
    final chartHeight = height - chartTop;

    // Draw actual line (blue with markers like notebook)
    if (actual.isNotEmpty) {
      final dx = size.width / (actual.length - 1);
      final actualPath = Path();

      for (int i = 0; i < actual.length; i++) {
        final x = i * dx;
        final t = (actual[i] - minVal) / range;
        final y = height - t * chartHeight;

        if (i == 0) {
          actualPath.moveTo(x, y);
        } else {
          actualPath.lineTo(x, y);
        }

        // Draw marker (dot) like in notebook
        final markerPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 2.5, markerPaint);
      }

      final actualStroke = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(actualPath, actualStroke);
    }

    // Draw predicted line (red like notebook)
    if (predictedList.isNotEmpty) {
      final dx = size.width / (predictedList.length - 1);
      final predPath = Path();

      for (int i = 0; i < predictedList.length; i++) {
        final x = i * dx;
        final t = (predictedList[i] - minVal) / range;
        final y = height - t * chartHeight;

        if (i == 0) {
          predPath.moveTo(x, y);
        } else {
          predPath.lineTo(x, y);
        }
      }

      final predStroke = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(predPath, predStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --------------------------------------------------------------
// AI Recommendation
// --------------------------------------------------------------
Widget _aiRecommendation(String title, String subtitle,
    {List<String> actions = const []}) {
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
              Expanded(
                  child: Text(title,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.green.shade700)),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: actions
                  .map((a) => OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: Text(a)))
                  .toList(),
            ),
          ],
        ],
      ),
    ),
  );
}
