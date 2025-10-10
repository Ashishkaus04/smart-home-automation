import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _ml;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.getMlPrediction();
      _ml = res['data'] as Map<String, dynamic>;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 8),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final data = _ml!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(title: 'Energy (pred)', value: '${data['energy_consumption']} kWh', icon: Icons.bolt),
              _StatCard(title: 'Cost (est)', value: '₹ ${data['cost_estimate']}', icon: Icons.currency_rupee),
              _StatCard(title: 'Optimization', value: '${data['optimization_potential']}%', icon: Icons.trending_up),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Recommendations', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List<String>.from(data['recommendations'] as List).map((r) => Card(
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(r),
                ),
              )),
        ],
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


