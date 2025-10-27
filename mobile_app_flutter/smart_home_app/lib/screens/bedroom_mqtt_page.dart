import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class BedroomMqttPage extends StatefulWidget {
  const BedroomMqttPage({super.key});

  @override
  State<BedroomMqttPage> createState() => _BedroomMqttPageState();
}

class _BedroomMqttPageState extends State<BedroomMqttPage> {
  // Updated to connect to your laptop's Mosquitto broker via phone hotspot
  final client = MqttServerClient('10.217.139.106', 'flutter_app_${DateTime.now().millisecondsSinceEpoch}');
  bool lightOn = false;
  bool fanOn = false;
  bool buzzerOn = false;
  bool isConnected = false;
  String temperature = "0.0";
  String humidity = "0.0";

  @override
  void initState() {
    super.initState();
    connectMQTT();
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  Future<void> connectMQTT() async {
    print('Starting MQTT connection to 10.217.139.106:1883');
    
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.autoReconnect = true;
    client.connectTimeoutPeriod = 10000; // 10 seconds timeout
    
    client.onConnected = () {
      print('✅ Successfully connected to MQTT broker');
      setState(() {
        isConnected = true;
      });
      // Subscribe to sensor data topics
      client.subscribe('bedroom/temperature', MqttQos.atMostOnce);
      client.subscribe('bedroom/humidity', MqttQos.atMostOnce);
      print('📡 Subscribed to temperature and humidity topics');
    };
    
    client.onDisconnected = () {
      print('❌ Disconnected from MQTT broker');
      setState(() {
        isConnected = false;
      });
    };
    
    client.onAutoReconnect = () {
      print('🔄 Attempting to reconnect to MQTT broker...');
    };
    
    client.onAutoReconnected = () {
      print('✅ Auto-reconnected to MQTT broker');
      setState(() {
        isConnected = true;
      });
      // Re-subscribe to topics after reconnection
      client.subscribe('bedroom/temperature', MqttQos.atMostOnce);
      client.subscribe('bedroom/humidity', MqttQos.atMostOnce);
    };
    
    // Set up message received callback
    client.onSubscribed = (String topic) {
      print('📋 Subscribed to: $topic');
    };
    
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final topic = c[0].topic;
      
      print('📨 Received: $topic -> $pt');
      
      setState(() {
        if (topic == 'bedroom/temperature') {
          temperature = pt;
        } else if (topic == 'bedroom/humidity') {
          humidity = pt;
        }
      });
    });
    
    // Enable logging for debugging
    client.logging(on: true);

    try {
      print('🔄 Attempting MQTT connection...');
      await client.connect();
      print('✅ MQTT connection attempt completed');
    } catch (e) {
      print('❌ MQTT Connection failed: $e');
      setState(() {
        isConnected = false;
      });
      // Don't disconnect immediately, let auto-reconnect handle it
    }
  }

  void publishMessage(String topic, String message) {
    if (isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      print('Published: $topic → $message');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to MQTT broker')),
      );
    }
  }

  Widget buildSwitch(String label, bool value, Function(bool) onChanged, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(value ? 'ON' : 'OFF', style: TextStyle(
          color: value ? Colors.green : Colors.grey,
          fontWeight: FontWeight.w500,
        )),
        secondary: Icon(icon, color: value ? Colors.green : Colors.grey, size: 28),
        value: value,
        onChanged: isConnected ? onChanged : null,
      ),
    );
  }

  Widget buildConnectionStatus() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
      child: ListTile(
        leading: Icon(
          isConnected ? Icons.wifi : Icons.wifi_off,
          color: isConnected ? Colors.green : Colors.red,
        ),
        title: Text(
          isConnected ? 'Connected to MQTT Broker' : 'Disconnected from MQTT Broker',
          style: TextStyle(
            color: isConnected ? Colors.green.shade800 : Colors.red.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: isConnected ? null : IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: connectMQTT,
        ),
      ),
    );
  }

  Widget buildSensorData() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Room Environment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.thermostat, color: Colors.blue.shade600, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Temperature',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$temperature°C',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.water_drop, color: Colors.green.shade600, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Humidity',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$humidity%',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Bedroom - MQTT"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: connectMQTT,
            tooltip: 'Reconnect',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildConnectionStatus(),
            buildSensorData(),
            
            const Text(
              'Bedroom Controls',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildSwitch("Light", lightOn, (val) {
                      setState(() => lightOn = val);
                      publishMessage("bedroom/light", val ? "ON" : "OFF");
                    }, Icons.lightbulb_outline),

                    buildSwitch("Fan", fanOn, (val) {
                      setState(() => fanOn = val);
                      publishMessage("bedroom/fan", val ? "ON" : "OFF");
                    }, Icons.toys_outlined),

                    buildSwitch("Buzzer", buzzerOn, (val) {
                      setState(() => buzzerOn = val);
                      publishMessage("bedroom/buzzer", val ? "ON" : "OFF");
                    }, Icons.volume_up_outlined),
                    
                    if (!isConnected) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(height: 8),
                            Text(
                              'Make sure your laptop is running Mosquitto broker and connected to your phone\'s hotspot.',
                              style: TextStyle(color: Colors.orange.shade700),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Laptop should be connected to hotspot IP: 10.217.139.106',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
