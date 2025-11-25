import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'energy_data_service.dart';

/// Service to load and run LSTM model for energy consumption predictions
class LstmPredictionService {
  static LstmPredictionService? _instance;
  Interpreter? _interpreter;
  bool _isLoaded = false;
  String? _error;

  LstmPredictionService._();

  static LstmPredictionService get instance {
    _instance ??= LstmPredictionService._();
    return _instance!;
  }

  /// Load the LSTM model from assets
  /// Place your model file at: assets/models/energy_lstm.tflite
  Future<bool> loadModel() async {
    if (_isLoaded && _interpreter != null) return true;

    try {
      // Get the model file path
      final modelPath = await _getModelPath();
      if (modelPath == null) {
        _error = 'Model file not found. Please place energy_lstm.tflite in assets/models/';
        return false;
      }

      // Load the interpreter (convert String path to File)
      _interpreter = Interpreter.fromFile(File(modelPath));
      _isLoaded = true;
      _error = null;
      
      print('✅ LSTM model loaded successfully');
      return true;
    } catch (e) {
      _error = 'Failed to load LSTM model: $e';
      print('❌ LSTM model load error: $_error');
      return false;
    }
  }

  /// Get the model file path (copy from assets if needed)
  Future<String?> _getModelPath() async {
    try {
      // Try to load from assets
      final ByteData data = await rootBundle.load('assets/models/energy_lstm.tflite');
      final bytes = data.buffer.asUint8List();
      
      // Write to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${appDir.path}/energy_lstm.tflite');
      await modelFile.writeAsBytes(bytes);
      
      return modelFile.path;
    } catch (e) {
      print('⚠️ Model file not found in assets. Error: $e');
      // Try to use existing file if it exists
      final appDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${appDir.path}/energy_lstm.tflite');
      if (await modelFile.exists()) {
        return modelFile.path;
      }
      return null;
    }
  }

  /// Predict future energy consumption
  /// [inputData] should be a list of historical kWh values (sequence length depends on your model)
  /// [sequenceLength] is the number of time steps the model expects (default: 24 for hourly, 7 for daily)
  /// Returns predicted values for the next N time steps
  Future<List<double>?> predict({
    required List<double> inputData,
    int sequenceLength = 24,
    int predictionSteps = 24,
  }) async {
    if (!_isLoaded || _interpreter == null) {
      final loaded = await loadModel();
      if (!loaded) {
        print('❌ Cannot predict: Model not loaded');
        return null;
      }
    }

    try {
      // Ensure input data is the right length
      if (inputData.length < sequenceLength) {
        // Pad with last value or zeros
        final padding = List<double>.filled(sequenceLength - inputData.length, inputData.isNotEmpty ? inputData.last : 0.0);
        inputData = [...padding, ...inputData];
      } else if (inputData.length > sequenceLength) {
        // Take only the last N values
        inputData = inputData.sublist(inputData.length - sequenceLength);
      }

      // Normalize input data (you may need to adjust based on your model's training)
      final normalized = _normalize(inputData);
      
      // Get model input/output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      
      print('📊 Model Input Shape: $inputShape, Output Shape: $outputShape');

      // Reshape input to match model expectations
      // Handle different input shapes: [batch, time_steps, features]
      List<List<List<double>>> reshapedInput;
      
      if (inputShape.length == 3) {
        final batchSize = inputShape[0] == -1 ? 1 : inputShape[0];
        final timeSteps = inputShape[1] == -1 ? sequenceLength : inputShape[1];
        final features = inputShape[2] == -1 ? 1 : inputShape[2];
        
        // If model expects multiple features, pad or reshape accordingly
        if (features > 1 && normalized.length >= features) {
          // Model expects multiple features - reshape data accordingly
          reshapedInput = List.generate(
            batchSize,
            (_) => List.generate(
              timeSteps,
              (i) {
                if (i < normalized.length) {
                  // Use actual data
                  return List.generate(features, (j) => 
                    (i * features + j < normalized.length) 
                      ? normalized[i * features + j] 
                      : (normalized.isNotEmpty ? normalized.last : 0.0)
                  );
                } else {
                  // Pad with last value
                  return List.filled(features, normalized.isNotEmpty ? normalized.last : 0.0);
                }
              },
            ),
          );
        } else {
          // Standard case: [batch, time_steps, 1]
          reshapedInput = List.generate(
            batchSize,
            (_) => List.generate(
              timeSteps,
              (i) => [i < normalized.length ? normalized[i] : (normalized.isNotEmpty ? normalized.last : 0.0)],
            ),
          );
        }
      } else {
        // Fallback to standard shape
        reshapedInput = List.generate(
          1,
          (_) => List.generate(
            sequenceLength,
            (i) => [i < normalized.length ? normalized[i] : (normalized.isNotEmpty ? normalized.last : 0.0)],
          ),
        );
      }

      // Prepare output tensor
      final output = List.generate(
        outputShape[0] == 1 ? outputShape[1] : outputShape[0],
        (_) => List.filled(outputShape.last, 0.0),
      );

      // Run inference
      _interpreter!.run(reshapedInput, output);

      // Extract predictions
      List<double> predictions;
      if (output[0] is List) {
        predictions = (output[0] as List).map((e) => (e as num).toDouble()).toList();
      } else {
        predictions = output.map((e) => (e as num).toDouble()).toList();
      }

      // Denormalize predictions
      final denormalized = _denormalize(predictions, inputData);

      // If we need more predictions than the model outputs, use recursive prediction
      if (predictionSteps > predictions.length) {
        return _recursivePredict(inputData, predictionSteps, sequenceLength);
      }

      return denormalized.take(predictionSteps).toList();
    } catch (e) {
      print('❌ Prediction error: $e');
      return null;
    }
  }

  /// Recursive prediction: use model output as input for next prediction
  Future<List<double>> _recursivePredict(
    List<double> initialData,
    int steps,
    int sequenceLength,
  ) async {
    List<double> allPredictions = [];
    List<double> currentSequence = List.from(initialData);

    for (int i = 0; i < steps; i++) {
      final prediction = await predict(
        inputData: currentSequence,
        sequenceLength: sequenceLength,
        predictionSteps: 1,
      );

      if (prediction == null || prediction.isEmpty) break;

      final nextValue = prediction.first;
      allPredictions.add(nextValue);

      // Update sequence: remove first, add prediction
      currentSequence.removeAt(0);
      currentSequence.add(nextValue);
    }

    return allPredictions;
  }

  /// Normalize data to [0, 1] range (min-max normalization)
  List<double> _normalize(List<double> data) {
    if (data.isEmpty) return [];
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    
    if (range == 0) return List.filled(data.length, 0.5);
    
    return data.map((v) => (v - min) / range).toList();
  }

  /// Denormalize predictions back to original scale
  List<double> _denormalize(List<double> normalized, List<double> originalData) {
    if (originalData.isEmpty || normalized.isEmpty) return normalized;
    
    final min = originalData.reduce((a, b) => a < b ? a : b);
    final max = originalData.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    
    if (range == 0) return normalized.map((v) => min).toList();
    
    return normalized.map((v) => v * range + min).toList();
  }

  /// Predict hourly consumption for next 24 hours
  Future<List<double>?> predictNext24Hours() async {
    final hourlyData = await EnergyDataService.getHourlyValues(hours: 48);
    if (hourlyData.length < 24) {
      print('⚠️ Insufficient data for prediction. Need at least 24 hours of data.');
      return null;
    }
    return predict(inputData: hourlyData, sequenceLength: 24, predictionSteps: 24);
  }

  /// Predict daily consumption for next 7 days
  Future<List<double>?> predictNext7Days() async {
    final dailyData = await EnergyDataService.getDailyValues(days: 30);
    if (dailyData.length < 7) {
      print('⚠️ Insufficient data for prediction. Need at least 7 days of data.');
      return null;
    }
    return predict(inputData: dailyData, sequenceLength: 7, predictionSteps: 7);
  }

  /// Predict monthly consumption for next 3 months
  Future<List<double>?> predictNext3Months() async {
    final dailyData = await EnergyDataService.getDailyValues(days: 90);
    if (dailyData.length < 30) {
      print('⚠️ Insufficient data for prediction. Need at least 30 days of data.');
      return null;
    }
    // Aggregate daily data into monthly (approximate)
    final monthlyData = _aggregateToMonthly(dailyData);
    return predict(inputData: monthlyData, sequenceLength: 3, predictionSteps: 3);
  }

  List<double> _aggregateToMonthly(List<double> dailyData) {
    // Simple aggregation: group by ~30 days
    final monthly = <double>[];
    for (int i = 0; i < dailyData.length; i += 30) {
      final monthData = dailyData.skip(i).take(30).toList();
      if (monthData.isNotEmpty) {
        monthly.add(monthData.reduce((a, b) => a + b));
      }
    }
    return monthly;
  }

  bool get isLoaded => _isLoaded;
  String? get error => _error;

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}

