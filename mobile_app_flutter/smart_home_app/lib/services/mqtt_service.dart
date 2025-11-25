import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/app_config.dart';

// Message model for cleaner UI use
class MqttMsg {
  final String topic;
  final String message;
  MqttMsg(this.topic, this.message);
}

class MqttService {
  MqttService._();
  static final MqttService instance = MqttService._();

  late final MqttServerClient _client = MqttServerClient(
    AppConfig.mqttHost,
    'flutter_${DateTime.now().millisecondsSinceEpoch}',
  )
    ..port = AppConfig.mqttPort
    ..keepAlivePeriod = 20
    ..autoReconnect = true
    ..connectTimeoutPeriod = 10000
    ..logging(on: false);

  bool _connected = false;
  bool get isConnected => _connected;

  final StreamController<MqttMsg> _msgStream = StreamController.broadcast();
  Stream<MqttMsg> get messageStream => _msgStream.stream;

  final List<_PendingPublish> _queue = [];
  final Set<_Sub> _subs = {};

  // =====================================================
  // CONNECT
  // =====================================================
  Future<void> connect() async {
    if (_connected) return;

    print('[MQTT] Connecting to ${_client.server}:${_client.port}');

    _client.onConnected = () {
      _connected = true;
      print('[MQTT] ✅ Connected');

      // Attach listener
      _client.updates?.listen((events) {
        if (events == null || events.isEmpty) return;
        for (final msg in events) {
          try {
            final publish = msg.payload as MqttPublishMessage;
            final payload =
                MqttPublishPayload.bytesToStringAsString(publish.payload.message)
                    .trim();

            print("📥 MQTT MSG: ${msg.topic} -> $payload");

            _msgStream.add(MqttMsg(msg.topic, payload));
          } catch (e) {
            print('[MQTT] Decode error: $e');
          }
        }
      });

      // Reapply subs and pending messages
      _applySubs();
      _flushQueue();
    };

    _client.onDisconnected = () {
      _connected = false;
      print('[MQTT] ❌ Disconnected');
    };

    try {
      await _client.connect();
    } catch (e) {
      print('[MQTT] ❌ Connect error: $e');
    }
  }

  // =====================================================
  // SUBSCRIBE
  // =====================================================
  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    _subs.add(_Sub(topic, qos));

    if (!_connected) {
      connect();
      return;
    }

    try {
      _client.subscribe(topic, qos);
      print("🔔 Subscribed: $topic");
    } catch (_) {}
  }

  // =====================================================
  // PUBLISH
  // =====================================================
  void publishString(
    String topic,
    String payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    if (!_connected) {
      _queue.add(_PendingPublish(topic, payload, qos, retain));
      connect();
      return;
    }

    final builder = MqttClientPayloadBuilder()..addString(payload);

    try {
      _client.publishMessage(topic, qos, builder.payload!, retain: retain);
      print("📤 MQTT Publish: $topic -> $payload");
    } catch (e) {
      print("[MQTT] Publish failed, queuing: $topic");
      _queue.add(_PendingPublish(topic, payload, qos, retain));
    }
  }

  // For ON/OFF buttons
  void publishOnOff(String topic, bool value) {
    publishString(topic, value ? 'ON' : 'OFF', retain: false);
  }

  // =====================================================
  // INTERNAL
  // =====================================================
  void _applySubs() {
    if (!_connected) return;

    for (final s in _subs) {
      try {
        _client.subscribe(s.topic, s.qos);
        print("🔁 Re-Subscribed: ${s.topic}");
      } catch (_) {}
    }
  }

  void _flushQueue() {
    if (!_connected || _queue.isEmpty) return;
    final list = List<_PendingPublish>.from(_queue);
    _queue.clear();
    for (final p in list) {
      publishString(p.topic, p.payload,
          qos: p.qos, retain: p.retain);
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
  bool operator ==(Object other) =>
      other is _Sub && other.topic == topic;

  @override
  int get hashCode => topic.hashCode;
}
