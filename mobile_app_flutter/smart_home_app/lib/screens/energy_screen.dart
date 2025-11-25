import 'dart:async';
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../services/energy_data_service.dart';
import '../services/lstm_prediction_service.dart';

class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen>
    with TickerProviderStateMixin {
  // Current data from MQTT
  double currentKwh = 1.8;
  double currentCost = 12.6;
  double gridKwhMonth = 92.4;

  late final TabController _tabController;

  // Historical chart data
  List<double> hourlyData = [];
  List<double> dailyData = [];
  List<double> monthlyData = [];

  // Predictions
  List<double>? hourlyPredictions;
  List<double>? dailyPredictions;
  List<double>? monthlyPredictions;

  bool isLoadingPredictions = false;
  String? predictionError;

  StreamSubscription? _mqttSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _initializeData();
    _loadLstmModel();
    _setupMqtt();
  }

  @override
  void dispose() {
    _mqttSub?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------------
  // INITIAL DATA
  // --------------------------------------------------------------
  Future<void> _initializeData() async {
    hourlyData = await EnergyDataService.getHourlyValues(hours: 24);
    dailyData = await EnergyDataService.getDailyValues(days: 7);

    if (monthlyData.isEmpty) {
      monthlyData = List.generate(30, (i) => 2.0 + (i % 5) * 0.6);
    }

    if (mounted) setState(() {});
  }

  // --------------------------------------------------------------
  // LSTM MODEL LOADING + PREDICTION
  // --------------------------------------------------------------
  Future<void> _loadLstmModel() async {
    setState(() {
      isLoadingPredictions = true;
      predictionError = null;
    });

    try {
      final loaded = await LstmPredictionService.instance.loadModel();
      if (loaded) {
        await _generatePredictions();
      } else {
        setState(() {
          predictionError = LstmPredictionService.instance.error ??
              'Failed to load model';
          isLoadingPredictions = false;
        });
      }
    } catch (e) {
      setState(() {
        predictionError = 'Error loading model: $e';
        isLoadingPredictions = false;
      });
    }
  }

  Future<void> _generatePredictions() async {
    try {
      final hourly = await LstmPredictionService.instance.predictNext24Hours();
      final daily = await LstmPredictionService.instance.predictNext7Days();
      final monthly = await LstmPredictionService.instance.predictNext3Months();

      if (!mounted) return;

      setState(() {
        hourlyPredictions = hourly;
        dailyPredictions = daily;
        monthlyPredictions = monthly;
        isLoadingPredictions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        predictionError = 'Prediction error: $e';
        isLoadingPredictions = false;
      });
    }
  }

  // --------------------------------------------------------------
  // MQTT HANDLING
  // --------------------------------------------------------------
  void _setupMqtt() {
    // Connect then subscribe
    MqttService.instance.connect().then((_) {
      MqttService.instance.subscribe('energy/consumption');
      MqttService.instance.subscribe('energy/cost');
      MqttService.instance.subscribe('energy/monthly');
      MqttService.instance.subscribe('energy/power');
    });

    // Listen to message stream
    _mqttSub = MqttService.instance.messageStream.listen((msg) {
      _handleMqtt(msg.topic, msg.message);
    });
  }

  void _handleMqtt(String topic, String payload) {
    if (!mounted) return;

    setState(() {
      if (topic == 'energy/consumption') {
        final val = double.tryParse(payload);
        if (val != null) {
          currentKwh = val;
          EnergyDataService.addHourlyData(val);
          _initializeData();

          if (LstmPredictionService.instance.isLoaded) {
            _generatePredictions();
          }
        }
      } else if (topic == 'energy/cost') {
        currentCost = double.tryParse(payload) ?? currentCost;
      } else if (topic == 'energy/monthly') {
        gridKwhMonth = double.tryParse(payload) ?? gridKwhMonth;
      }
    });
  }

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
    return Card(
      elevation: 2,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'This Week'),
                    Tab(text: 'This Month'),
                  ],
                ),
              ),
              if (isLoadingPredictions)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              if (predictionError != null)
                Tooltip(
                  message: predictionError!,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.warning,
                        color: Colors.orange, size: 20),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 220,
            child: TabBarView(
              controller: _tabController,
              children: [
                _PredictionChart(
                  label: 'Next 24 Hours (kWh/hr)',
                  predictions: hourlyPredictions,
                  xLabels: List.generate(
                    (hourlyPredictions?.length ?? 24),
                    (i) => i % 3 == 0 ? '${i}h' : '',
                  ),
                  isLoading: isLoadingPredictions,
                  error: predictionError,
                ),
                _PredictionChart(
                  label: 'Next 7 Days (kWh/day)',
                  predictions: dailyPredictions,
                  xLabels: List.generate(
                    (dailyPredictions?.length ?? 7),
                    (i) => const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i % 7],
                  ),
                  isLoading: isLoadingPredictions,
                  error: predictionError,
                ),
                _PredictionChart(
                  label: 'Next 3 Months (kWh/month)',
                  predictions: monthlyPredictions,
                  xLabels: List.generate(
                    (monthlyPredictions?.length ?? 3),
                    (i) => 'M${i + 1}',
                  ),
                  isLoading: isLoadingPredictions,
                  error: predictionError,
                ),
              ],
            ),
          ),
        ],
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
//  Prediction Chart
// --------------------------------------------------------------
class _PredictionChart extends StatelessWidget {
  final String label;
  final List<double>? predictions;
  final List<String> xLabels;
  final bool isLoading;
  final String? error;

  const _PredictionChart({
    required this.label,
    required this.predictions,
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
          Text('LSTM Prediction • $label',
              style: Theme.of(context).textTheme.labelLarge),
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
    if (predictions == null || predictions!.isEmpty) {
      return Center(
        child: Text(
          'No predictions yet.\nKeep the ESP publishing energy data.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final effectiveLabels = xLabels.length == predictions!.length
        ? xLabels
        : List.generate(predictions!.length,
            (i) => i < xLabels.length ? xLabels[i] : '$i');

    return _LineChart(
      label: label,
      data: predictions!,
      xLabels: effectiveLabels,
      lineColor: Colors.orange,
    );
  }
}

// --------------------------------------------------------------
// Line Chart + Painter
// --------------------------------------------------------------
class _LineChart extends StatelessWidget {
  final String label;
  final List<double> data;
  final List<String> xLabels;
  final Color lineColor;

  const _LineChart(
      {required this.label,
      required this.data,
      required this.xLabels,
      required this.lineColor});

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
              painter: _LineChartPainter(data: data, color: lineColor),
              child: Row(
                children: List.generate(
                  xLabels.length,
                  (i) => Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        xLabels[i],
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
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

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);

    final dx = size.width / (data.length - 1);
    final height = size.height - 18;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final t = maxVal == minVal ? 0.5 : (data[i] - minVal) / (maxVal - minVal);
      final y = height - t * (height - 8) + 4;

      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, stroke);

    final fillPath = Path.from(path)
      ..lineTo(size.width, height + 4)
      ..lineTo(0, height + 4)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.25),
          color.withOpacity(0.05)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
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
