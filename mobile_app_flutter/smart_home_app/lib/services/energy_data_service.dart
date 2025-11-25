import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to store and retrieve historical energy consumption data
/// for LSTM model predictions
class EnergyDataService {
  static const String _keyHourly = 'energy_hourly';
  static const String _keyDaily = 'energy_daily';
  static const String _keyMonthly = 'energy_monthly';
  static const int _maxHourlyRecords = 168; // 7 days * 24 hours
  static const int _maxDailyRecords = 90; // ~3 months
  static const int _maxMonthlyRecords = 12; // 1 year

  /// Add hourly energy consumption (kWh)
  static Future<void> addHourlyData(double kwh) async {
    final prefs = await SharedPreferences.getInstance();
    final data = await getHourlyData();
    data.add({
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'kwh': kwh,
    });
    
    // Keep only recent data
    if (data.length > _maxHourlyRecords) {
      data.removeRange(0, data.length - _maxHourlyRecords);
    }
    
    await prefs.setString(_keyHourly, jsonEncode(data));
  }

  /// Get hourly energy data (last N hours)
  static Future<List<Map<String, dynamic>>> getHourlyData({int hours = 168}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyHourly);
    if (jsonStr == null) return [];
    
    final List<dynamic> decoded = jsonDecode(jsonStr);
    final data = decoded.cast<Map<String, dynamic>>();
    
    // Filter by time range
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return data.where((entry) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(entry['timestamp'] as int);
      return timestamp.isAfter(cutoff);
    }).toList();
  }

  /// Add daily energy consumption (kWh)
  static Future<void> addDailyData(double kwh) async {
    final prefs = await SharedPreferences.getInstance();
    final data = await getDailyData();
    data.add({
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'kwh': kwh,
    });
    
    // Keep only recent data
    if (data.length > _maxDailyRecords) {
      data.removeRange(0, data.length - _maxDailyRecords);
    }
    
    await prefs.setString(_keyDaily, jsonEncode(data));
  }

  /// Get daily energy data (last N days)
  static Future<List<Map<String, dynamic>>> getDailyData({int days = 90}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyDaily);
    if (jsonStr == null) return [];
    
    final List<dynamic> decoded = jsonDecode(jsonStr);
    final data = decoded.cast<Map<String, dynamic>>();
    
    // Filter by time range
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return data.where((entry) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(entry['timestamp'] as int);
      return timestamp.isAfter(cutoff);
    }).toList();
  }

  /// Get hourly values as a list (for LSTM input)
  /// Returns list of kWh values in chronological order
  static Future<List<double>> getHourlyValues({int hours = 24}) async {
    final data = await getHourlyData(hours: hours);
    return data.map((e) => (e['kwh'] as num).toDouble()).toList();
  }

  /// Get daily values as a list (for LSTM input)
  /// Returns list of kWh values in chronological order
  static Future<List<double>> getDailyValues({int days = 30}) async {
    final data = await getDailyData(days: days);
    return data.map((e) => (e['kwh'] as num).toDouble()).toList();
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHourly);
    await prefs.remove(_keyDaily);
    await prefs.remove(_keyMonthly);
  }
}

