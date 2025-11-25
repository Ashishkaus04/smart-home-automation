import 'dart:async';

import 'package:flutter/material.dart';

import '../services/mqtt_service.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  final List<DeviceOption> _deviceOptions = const [
    DeviceOption(
      id: 'living_room_light',
      label: 'Living Room Light',
      topic: 'living_room/light',
      supportsDimming: true,
    ),
    DeviceOption(
      id: 'porch_light',
      label: 'Porch Light',
      topic: 'lights/front_door',
    ),
    DeviceOption(
      id: 'door_locks',
      label: 'Door Locks',
      topic: 'security/doors',
    ),
    DeviceOption(
      id: 'security_system',
      label: 'Security System',
      topic: 'security/armed',
    ),
    DeviceOption(
      id: 'coffee_maker',
      label: 'Coffee Maker',
      topic: 'appliances/coffee',
    ),
    DeviceOption(
      id: 'music_system',
      label: 'Music System',
      topic: 'appliances/music',
    ),
  ];

  final Map<String, bool> _deviceStates = {};
  final Map<String, DateTime> _lastRuleExecution = {};
  final Map<String, String> _timeTriggerLastFire = {};
  final Set<String> _subscribedTopics = {};
  StreamSubscription? _mqttAutomationSub;
  Timer? _timeTriggerTimer;

  late final List<AutomationRule> _rules;

  final List<TodayScheduleItem> _today = [
    TodayScheduleItem(time: '07:30', title: 'Bedroom lights to 40%', status: ScheduleStatus.done),
    TodayScheduleItem(time: '09:00', title: 'Coffee maker ON', status: ScheduleStatus.skipped),
    TodayScheduleItem(time: '19:00', title: 'Evening Lights routine', status: ScheduleStatus.pending),
    TodayScheduleItem(time: '23:00', title: 'Night Security routine', status: ScheduleStatus.pending),
  ];

  @override
  void initState() {
    super.initState();
    _rules = [
      AutomationRule(
        id: 'evening_lights',
        name: 'Evening Lights',
        enabled: true,
        triggers: [
          AutomationTrigger.time(const TimeOfDay(hour: 19, minute: 0)),
        ],
        actions: [
          AutomationAction.device(
            device: _deviceById('living_room_light'),
            targetState: true,
          ),
          AutomationAction.device(
            device: _deviceById('porch_light'),
            targetState: true,
          ),
        ],
      ),
      AutomationRule(
        id: 'night_security',
        name: 'Night Security',
        enabled: false,
        triggers: [
          AutomationTrigger.time(const TimeOfDay(hour: 23, minute: 0)),
        ],
        actions: [
          AutomationAction.device(
            device: _deviceById('door_locks'),
            targetState: true,
          ),
          AutomationAction.device(
            device: _deviceById('security_system'),
            targetState: true,
          ),
        ],
      ),
    ];
    _setupAutomationEngine();
  }

  DeviceOption _deviceById(String id) =>
      _deviceOptions.firstWhere((d) => d.id == id);

  @override
  void dispose() {
    _mqttAutomationSub?.cancel();
    _timeTriggerTimer?.cancel();
    super.dispose();
  }

  void _openAddRule() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _RuleBuilderSheet(
        deviceOptions: _deviceOptions,
        onSave: (rule) {
          setState(() => _rules.insert(0, rule));
        },
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
              Text(
                'Automation Rules',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ..._rules.map((r) => _ruleCard(r)).toList(),

              const SizedBox(height: 16),
              Text(
                "Today's Schedule",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
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
                                      : (e.status == ScheduleStatus.done
                                          ? Icons.check_circle
                                          : Icons.remove_circle_outline),
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
                TextButton(
                  onPressed: () => _executeRule(r, reason: 'Manual run'),
                  child: const Text('Run now'),
                ),
                Switch(
                  value: r.enabled,
                  onChanged: (v) => setState(() => r.enabled = v),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Conditions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 72, child: Text('IF', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: r.triggers.map((c) => Chip(label: Text(c.describe(context)))).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 72, child: Text('THEN', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: r.actions
                        .map((a) => InputChip(label: Text(a.describe(context)), onPressed: () {}))
                        .toList(),
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

  void _setupAutomationEngine() {
    MqttService.instance.connect().then((_) {
      final topics = _deviceOptions.map((d) => d.topic).toSet();
      for (final topic in topics) {
        if (_subscribedTopics.add(topic)) {
          MqttService.instance.subscribe(topic);
        }
      }
    });

    _mqttAutomationSub ??=
        MqttService.instance.messageStream.listen(_handleAutomationMqtt);

    _timeTriggerTimer?.cancel();
    _timeTriggerTimer =
        Timer.periodic(const Duration(minutes: 1), (_) => _checkTimeTriggers());
    _checkTimeTriggers();
  }

  void _handleAutomationMqtt(MqttMsg msg) {
    final lowercase = msg.message.toLowerCase();
    final boolState =
        lowercase == 'on' || msg.message == '1' || lowercase == 'true';
    _deviceStates[msg.topic] = boolState;

    for (final rule in _rules) {
      if (!rule.enabled) continue;
      for (final trigger in rule.triggers) {
        if (trigger.type != AutomationTriggerType.deviceState) continue;
        final deviceTopic = trigger.device?.topic;
        if (deviceTopic == null) continue;
        if (deviceTopic == msg.topic && trigger.desiredState == boolState) {
          _executeRule(
            rule,
            reason:
                '${trigger.device?.label ?? 'Device'} is ${boolState ? 'ON' : 'OFF'}',
          );
          break;
        }
      }
    }
  }

  void _checkTimeTriggers() {
    final now = DateTime.now();
    final keyStamp = '${now.year}${now.month}${now.day}${now.hour}${now.minute}';

    for (final rule in _rules) {
      if (!rule.enabled) continue;

      for (var i = 0; i < rule.triggers.length; i++) {
        final trigger = rule.triggers[i];
        if (trigger.type != AutomationTriggerType.time ||
            trigger.timeOfDay == null) {
          continue;
        }

        final t = trigger.timeOfDay!;
        if (t.hour == now.hour && t.minute == now.minute) {
          final key = '${rule.id}:$i';
          if (_timeTriggerLastFire[key] == keyStamp) {
            continue;
          }
          _timeTriggerLastFire[key] = keyStamp;
          _executeRule(
            rule,
            reason:
                'Scheduled time ${MaterialLocalizations.of(context).formatTimeOfDay(t)}',
          );
        }
      }
    }
  }

  void _executeRule(AutomationRule rule, {String? reason}) {
    if (!rule.enabled) return;

    final now = DateTime.now();
    final last = _lastRuleExecution[rule.id];
    if (last != null && now.difference(last) < const Duration(seconds: 15)) {
      return;
    }
    _lastRuleExecution[rule.id] = now;

    for (final action in rule.actions) {
      if (action.type == AutomationActionType.device && action.device != null) {
        MqttService.instance
            .publishOnOff(action.device!.topic, action.targetState);
      }
    }

    if (!mounted) return;
    if (reason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rule "${rule.name}" triggered ($reason)'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class AutomationRule {
  final String id;
  final String name;
  bool enabled;
  final List<AutomationTrigger> triggers;
  final List<AutomationAction> actions;

  AutomationRule({
    required this.id,
    required this.name,
    required this.enabled,
    required List<AutomationTrigger> triggers,
    required List<AutomationAction> actions,
  })  : triggers = List.from(triggers),
        actions = List.from(actions);
}

class AutomationTrigger {
  AutomationTriggerType type;
  TimeOfDay? timeOfDay;
  DeviceOption? device;
  bool desiredState;

  AutomationTrigger.time(TimeOfDay time)
      : type = AutomationTriggerType.time,
        timeOfDay = time,
        device = null,
        desiredState = true;

  AutomationTrigger.device({required DeviceOption device, bool desiredState = true})
      : type = AutomationTriggerType.deviceState,
        timeOfDay = null,
        device = device,
        desiredState = desiredState;

  AutomationTrigger._({
    required this.type,
    this.timeOfDay,
    this.device,
    required this.desiredState,
  });

  AutomationTrigger copy() => AutomationTrigger._(
        type: type,
        timeOfDay: timeOfDay,
        device: device,
        desiredState: desiredState,
      );

  String describe(BuildContext context) {
    switch (type) {
      case AutomationTriggerType.time:
        final formatted = timeOfDay == null
            ? 'time'
            : MaterialLocalizations.of(context).formatTimeOfDay(timeOfDay!);
        return 'Time is $formatted';
      case AutomationTriggerType.deviceState:
        final name = device?.label ?? 'Device';
        return '$name is ${desiredState ? 'ON' : 'OFF'}';
    }
  }
}

class AutomationAction {
  AutomationActionType type;
  DeviceOption? device;
  bool targetState;

  AutomationAction.device({required DeviceOption device, bool targetState = true})
      : type = AutomationActionType.device,
        device = device,
        targetState = targetState;

  AutomationAction._({
    required this.type,
    this.device,
    required this.targetState,
  });

  AutomationAction copy() => AutomationAction._(
        type: type,
        device: device,
        targetState: targetState,
      );

  String describe(BuildContext context) {
    switch (type) {
      case AutomationActionType.device:
        final name = device?.label ?? 'Device';
        return '${targetState ? 'Turn ON' : 'Turn OFF'} $name';
    }
  }
}

class DeviceOption {
  final String id;
  final String label;
  final String topic;
  final bool supportsDimming;

  const DeviceOption({
    required this.id,
    required this.label,
    required this.topic,
    this.supportsDimming = false,
  });
}

class TodayScheduleItem {
  final String time;
  final String title;
  final ScheduleStatus status;

  TodayScheduleItem({required this.time, required this.title, required this.status});
}

enum ScheduleStatus { pending, done, skipped }

enum AutomationTriggerType { time, deviceState }

enum AutomationActionType { device }

class _RuleBuilderSheet extends StatefulWidget {
  final List<DeviceOption> deviceOptions;
  final void Function(AutomationRule) onSave;

  const _RuleBuilderSheet({
    required this.deviceOptions,
    required this.onSave,
  });

  @override
  State<_RuleBuilderSheet> createState() => _RuleBuilderSheetState();
}

class _RuleBuilderSheetState extends State<_RuleBuilderSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _enabled = true;
  final List<AutomationTrigger> _triggers = [];
  final List<AutomationAction> _actions = [];

  @override
  void initState() {
    super.initState();
    _triggers.add(AutomationTrigger.time(TimeOfDay.now()));
    if (widget.deviceOptions.isNotEmpty) {
      _actions.add(AutomationAction.device(device: widget.deviceOptions.first));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Automation Rule',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Rule name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
              contentPadding: EdgeInsets.zero,
              title: const Text('Enabled'),
            ),
            const SizedBox(height: 8),
            _sectionHeader(
              context,
              title: 'When this happens',
              child: OutlinedButton.icon(
                onPressed: _pickTriggerType,
                icon: const Icon(Icons.add),
                label: const Text('Add trigger'),
              ),
            ),
            ..._triggers.asMap().entries.map(
                  (entry) => _triggerEditor(entry.key, entry.value),
                ),
            const SizedBox(height: 12),
            _sectionHeader(
              context,
              title: 'Then do this',
              child: OutlinedButton.icon(
                onPressed: _addAction,
                icon: const Icon(Icons.add_task),
                label: const Text('Add action'),
              ),
            ),
            ..._actions.asMap().entries.map(
                  (entry) => _actionEditor(entry.key, entry.value),
                ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _actions.isEmpty ? null : _saveRule,
              icon: const Icon(Icons.save),
              label: const Text('Save rule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context,
      {required String title, required Widget child}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        child,
      ],
    );
  }

  Widget _triggerEditor(int index, AutomationTrigger trigger) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<AutomationTriggerType>(
                  value: trigger.type,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      trigger.type = value;
                      if (value == AutomationTriggerType.time) {
                        trigger.timeOfDay ??= TimeOfDay.now();
                        trigger.device = null;
                      } else {
                        trigger.device ??= widget.deviceOptions.first;
                      }
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: AutomationTriggerType.time,
                      child: Text('Time schedule'),
                    ),
                    DropdownMenuItem(
                      value: AutomationTriggerType.deviceState,
                      child: Text('Device state'),
                    ),
                  ],
                ),
                const Spacer(),
                if (_triggers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _triggers.removeAt(index)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (trigger.type == AutomationTriggerType.time)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Trigger time'),
                subtitle: Text(
                  trigger.timeOfDay == null
                      ? 'Select time'
                      : MaterialLocalizations.of(context).formatTimeOfDay(trigger.timeOfDay!),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: trigger.timeOfDay ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => trigger.timeOfDay = picked);
                    }
                  },
                  child: const Text('Pick time'),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<DeviceOption>(
                    value: trigger.device ?? widget.deviceOptions.first,
                    onChanged: (value) => setState(() => trigger.device = value),
                    items: widget.deviceOptions
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(d.label),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('ON'),
                        selected: trigger.desiredState,
                        onSelected: (_) => setState(() => trigger.desiredState = true),
                      ),
                      ChoiceChip(
                        label: const Text('OFF'),
                        selected: !trigger.desiredState,
                        onSelected: (_) => setState(() => trigger.desiredState = false),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionEditor(int index, AutomationAction action) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Device action'),
                const Spacer(),
                if (_actions.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _actions.removeAt(index)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButton<DeviceOption>(
              value: action.device ?? widget.deviceOptions.first,
              onChanged: (value) => setState(() => action.device = value),
              items: widget.deviceOptions
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Turn ON'),
                  selected: action.targetState,
                  onSelected: (_) => setState(() => action.targetState = true),
                ),
                ChoiceChip(
                  label: const Text('Turn OFF'),
                  selected: !action.targetState,
                  onSelected: (_) => setState(() => action.targetState = false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTriggerOfType(AutomationTriggerType type) {
    setState(() {
      if (type == AutomationTriggerType.time) {
        _triggers.add(AutomationTrigger.time(TimeOfDay.now()));
      } else if (widget.deviceOptions.isNotEmpty) {
        _triggers.add(AutomationTrigger.device(device: widget.deviceOptions.first));
      }
    });
  }

  void _addAction() {
    if (widget.deviceOptions.isEmpty) return;
    setState(() {
      _actions.add(AutomationAction.device(device: widget.deviceOptions.first));
    });
  }

  Future<void> _pickTriggerType() async {
    final type = await showModalBottomSheet<AutomationTriggerType>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time schedule'),
              onTap: () => Navigator.pop(ctx, AutomationTriggerType.time),
            ),
            ListTile(
              leading: const Icon(Icons.power),
              title: const Text('Device state'),
              onTap: () => Navigator.pop(ctx, AutomationTriggerType.deviceState),
            ),
          ],
        ),
      ),
    );

    if (type != null) {
      _addTriggerOfType(type);
    }
  }

  void _saveRule() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter a rule name');
      return;
    }
    if (_triggers.isEmpty) {
      _showError('Add at least one trigger');
      return;
    }
    if (_actions.isEmpty) {
      _showError('Add at least one action');
      return;
    }

    widget.onSave(
      AutomationRule(
        id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        enabled: _enabled,
        triggers: _triggers.map((t) => t.copy()).toList(),
        actions: _actions.map((a) => a.copy()).toList(),
      ),
    );
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
