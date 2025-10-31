import 'package:flutter/material.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  final List<AutomationRule> _rules = [
    AutomationRule(
      name: 'Evening Lights',
      enabled: true,
      conditions: ['Time is 7:00 PM', 'Sunset after 6:30 PM'],
      actions: ['Turn ON Living lights (60%)', 'Turn ON Porch light'],
    ),
    AutomationRule(
      name: 'Night Security',
      enabled: false,
      conditions: ['Time is 11:00 PM'],
      actions: ['Lock all doors', 'Arm security system'],
    ),
  ];

  final List<TodayScheduleItem> _today = [
    TodayScheduleItem(time: '07:30', title: 'Bedroom lights to 40%', status: ScheduleStatus.done),
    TodayScheduleItem(time: '09:00', title: 'Coffee maker ON', status: ScheduleStatus.skipped),
    TodayScheduleItem(time: '19:00', title: 'Evening Lights routine', status: ScheduleStatus.pending),
    TodayScheduleItem(time: '23:00', title: 'Night Security routine', status: ScheduleStatus.pending),
  ];

  void _openAddRule() {
    final nameController = TextEditingController();
    final condController = TextEditingController();
    final actController = TextEditingController();
    bool enabled = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Automation Rule', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Rule name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: condController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Conditions (comma separated)',
                  hintText: 'e.g., Time is 7:00 PM, Sunset after 6:30 PM',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: actController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Actions (comma separated)',
                  hintText: 'e.g., Turn ON Living light, Set AC to 25°C',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Enabled'),
                  const SizedBox(width: 8),
                  StatefulBuilder(
                    builder: (context, setBState) => Switch(
                      value: enabled,
                      onChanged: (v) => setBState(() => enabled = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  final conditions = condController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  final actions = actController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  setState(() {
                    _rules.insert(0, AutomationRule(name: name, enabled: enabled, conditions: conditions, actions: actions));
                  });
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Rule'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddRule,
          icon: const Icon(Icons.add),
          label: const Text('Add Rule'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Automation Rules', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._rules.map((r) => _ruleCard(r)).toList(),
              const SizedBox(height: 16),
              Text("Today's Schedule", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Column(
                  children: _today
                      .map((e) => Column(
                            children: [
                              ListTile(
                                leading: _statusDot(e.status),
                                title: Text(e.title),
                                subtitle: Text(e.time),
                                trailing: Icon(
                                  e.status == ScheduleStatus.pending
                                      ? Icons.schedule
                                      : (e.status == ScheduleStatus.done ? Icons.check_circle : Icons.remove_circle_outline),
                                  color: e.status == ScheduleStatus.pending
                                      ? Colors.orange
                                      : (e.status == ScheduleStatus.done ? Colors.green : Colors.grey),
                                ),
                              ),
                              const Divider(height: 1),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleCard(AutomationRule r) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                Switch(
                  value: r.enabled,
                  onChanged: (v) => setState(() => r.enabled = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 72, child: Text('IF', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: r.conditions.map((c) => Chip(label: Text(c))).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 72, child: Text('THEN', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: r.actions.map((a) => InputChip(label: Text(a), onPressed: () {})).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusDot(ScheduleStatus status) {
    Color color;
    switch (status) {
      case ScheduleStatus.pending:
        color = Colors.orange;
        break;
      case ScheduleStatus.done:
        color = Colors.green;
        break;
      case ScheduleStatus.skipped:
        color = Colors.grey;
        break;
    }
    return CircleAvatar(radius: 8, backgroundColor: color);
  }
}

class AutomationRule {
  final String name;
  bool enabled;
  final List<String> conditions;
  final List<String> actions;
  AutomationRule({required this.name, required this.enabled, required this.conditions, required this.actions});
}

class TodayScheduleItem {
  final String time;
  final String title;
  final ScheduleStatus status;
  TodayScheduleItem({required this.time, required this.title, required this.status});
}

enum ScheduleStatus { pending, done, skipped }


