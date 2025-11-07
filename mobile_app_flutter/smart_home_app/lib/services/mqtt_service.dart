import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/app_config.dart';

class MqttService {
  MqttService._();
  static final MqttService instance = MqttService._();

  late final MqttServerClient _client = MqttServerClient(AppConfig.mqttHost, 'flutter_${DateTime.now().millisecondsSinceEpoch}')
    ..port = AppConfig.mqttPort
    ..keepAlivePeriod = 20
    ..autoReconnect = true
    ..connectTimeoutPeriod = 10000
    ..logging(on: false);

  final StreamController<MqttReceivedMessage<MqttMessage?>> _messagesController = StreamController.broadcast();
  final List<_PendingPublish> _pendingPublishes = <_PendingPublish>[];
  final Set<_Sub> _desiredSubscriptions = <_Sub>{};
  bool _connected = false;

  bool get isConnected => _connected;
  Stream<MqttReceivedMessage<MqttMessage?>> get messages => _messagesController.stream;

  Future<void> connect() async {
  if (_connected) {
    print('[MQTT] Already connected.');
    return;
  }

  print('[MQTT] 🔌 Connecting to broker ${_client.server}:${_client.port} ...');

  _client.onConnected = () {
    _connected = true;
    print('[MQTT] ✅ Connected successfully.');

    // Attach listener *after* connect
    _client.updates?.listen((events) {
      if (events == null || events.isEmpty) return;
      for (final e in events) {
        try {
          final rec = e.payload as MqttPublishMessage;
          final payload =
              MqttPublishPayload.bytesToStringAsString(rec.payload.message);
          print('📥 MQTT -> ${e.topic} -> ${payload.trim()}');
        } catch (err) {
          print('[MQTT] ⚠️ Error decoding: $err');
        }
        _messagesController.add(e);
      }
    });

    _applySubscriptions();
    _flushPending();
  };

  _client.onDisconnected = () {
    _connected = false;
    print('[MQTT] ❌ Disconnected.');
  };

  try {
    await _client.connect();
  } catch (e) {
    print('[MQTT] ❌ Connect error: $e');
  }
}


  void disconnect() {
    try { _client.disconnect(); } catch (_) {}
  }

  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    _desiredSubscriptions.add(_Sub(topic, qos));
    if (!_connected) {
      // ensure connection will be (re)established
      // ignore: unawaited_futures
      connect();
      return;
    }
    try { _client.subscribe(topic, qos); } catch (_) {}
  }

  void unsubscribe(String topic) {
    if (!_connected) return;
    try { _client.unsubscribe(topic); } catch (_) {}
  }

  void publishString(String topic, String payload, {MqttQos qos = MqttQos.atMostOnce, bool retain = false}) {
    if (!_connected) {
      // Queue message and attempt (re)connect
      _pendingPublishes.add(_PendingPublish(topic, payload, qos, retain));
      // Fire and forget connect; if already connecting this is a no-op
      // ignore: unawaited_futures
      connect();
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(payload);
    try {
      _client.publishMessage(topic, qos, builder.payload!, retain: retain);
    } catch (_) {
      // On failure, queue for retry
      _pendingPublishes.add(_PendingPublish(topic, payload, qos, retain));
    }
  }

  /// Convenience helpers
  void publishOnOff(String topic, bool on) => publishString(topic, on ? 'ON' : 'OFF');

  void _flushPending() {
    if (!_connected || _pendingPublishes.isEmpty) return;
    // Copy and clear to avoid growth during iteration
    final pending = List<_PendingPublish>.from(_pendingPublishes);
    _pendingPublishes.clear();
    for (final p in pending) {
      publishString(p.topic, p.payload, qos: p.qos, retain: p.retain);
    }
  }

  void _applySubscriptions() {
    if (!_connected || _desiredSubscriptions.isEmpty) return;
    for (final s in _desiredSubscriptions) {
      try { _client.subscribe(s.topic, s.qos); } catch (_) {}
    }
  }
}

class _PendingPublish {
  final String topic;
  final String payload;
  final MqttQos qos;
  final bool retain;
  _PendingPublish(this.topic, this.payload, this.qos, this.retain);
}

class _Sub {
  final String topic;
  final MqttQos qos;
  const _Sub(this.topic, this.qos);

  @override
  bool operator ==(Object other) => other is _Sub && other.topic == topic;

  @override
  int get hashCode => topic.hashCode;
}
