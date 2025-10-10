import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  // Change this to your machine's backend base URL if running on device/emulator.
  // For Android emulator use 10.0.2.2, for iOS simulator use localhost.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.251.6.106:5000',
  );
}

class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, dynamic>> getDevices() async {
    final response = await _client.get(_uri('/api/devices'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load devices: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateDevice({
    required String category,
    required String device,
    required dynamic state,
  }) async {
    final response = await _client.post(
      _uri('/api/devices/$category/$device'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'state': state}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update device: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSecurityArmed(bool armed) async {
    // If backend exposes a dedicated endpoint, use it; else update via security/armed
    return updateDevice(category: 'security', device: 'armed', state: armed);
  }

  Future<Map<String, dynamic>> updateDoorLock(String door, bool locked) async {
    return updateDevice(category: 'security', device: door, state: locked);
  }

  Future<Map<String, dynamic>> getMlPrediction() async {
    final response = await _client.get(_uri('/api/ml/prediction'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load ML prediction: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}


