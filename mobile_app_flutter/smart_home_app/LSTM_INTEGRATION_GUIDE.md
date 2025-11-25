# LSTM Model Integration Guide

This guide explains how to integrate your trained LSTM model for energy consumption predictions in the Flutter app.

## Overview

The app now includes:
- **Energy Data Service**: Stores historical energy consumption from MQTT
- **LSTM Prediction Service**: Loads and runs your TensorFlow Lite model
- **Dual-Line Charts**: Displays both actual and predicted values

## Setup Steps

### 1. Convert Your Model to TensorFlow Lite

If you have a Keras/TensorFlow model (`.h5` or SavedModel), convert it:

```python
import tensorflow as tf

# Load your saved model
model = tf.keras.models.load_model('your_energy_lstm_model.h5')

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save
with open('energy_lstm.tflite', 'wb') as f:
    f.write(tflite_model)
```

### 2. Place Model File

Copy `energy_lstm.tflite` to:
```
mobile_app_flutter/smart_home_app/assets/models/energy_lstm.tflite
```

### 3. Model Requirements

Your model should:
- **Input**: Historical energy consumption values (kWh)
  - Shape: `[batch_size, sequence_length, features]`
  - Example: `[1, 24, 1]` for 24-hour sequences
- **Output**: Predicted future consumption (kWh)
  - Shape: `[batch_size, prediction_steps]`
  - Example: `[1, 24]` for 24-hour predictions

### 4. Adjust Model Parameters (if needed)

Edit `lib/services/lstm_prediction_service.dart`:

```dart
// Adjust sequence length based on your model
Future<List<double>?> predictNext24Hours() async {
  // Change 24 to match your model's input sequence length
  return predict(inputData: hourlyData, sequenceLength: 24, predictionSteps: 24);
}
```

## How It Works

### Data Flow

1. **MQTT Data Collection**
   - ESP8266 publishes energy consumption to `energy/consumption`
   - App receives and stores in `EnergyDataService`

2. **Historical Data Storage**
   - Hourly data: Last 168 hours (7 days)
   - Daily data: Last 90 days
   - Automatically managed by `EnergyDataService`

3. **Prediction Generation**
   - When model is loaded, predictions are generated automatically
   - Uses last N values as input sequence
   - Returns predictions for next N time steps

4. **Visualization**
   - Charts show:
     - **Blue solid line**: Actual consumption
     - **Orange dashed line**: LSTM predictions
   - Available for: Today (24h), This Week (7d), This Month (30d)

## Usage

### Automatic Mode

The app automatically:
- Loads the model on Energy screen initialization
- Generates predictions when sufficient data is available
- Updates predictions when new MQTT data arrives

### Manual Prediction

You can also call predictions manually:

```dart
// Predict next 24 hours
final predictions = await LstmPredictionService.instance.predictNext24Hours();

// Predict next 7 days
final dailyPredictions = await LstmPredictionService.instance.predictNext7Days();
```

## Customization

### Normalization

The service uses min-max normalization by default. If your model was trained with different normalization:

1. Edit `_normalize()` and `_denormalize()` in `lstm_prediction_service.dart`
2. Match your training preprocessing

### Sequence Length

Adjust based on your model:
- **Hourly**: Default 24 hours
- **Daily**: Default 7 days
- **Monthly**: Aggregated from daily data

### Prediction Steps

Control how many future values to predict:
```dart
predict(inputData: data, sequenceLength: 24, predictionSteps: 48); // Predict 48 hours
```

## Troubleshooting

### Model Not Loading

**Error**: "Model file not found"

**Solution**:
1. Verify file exists at `assets/models/energy_lstm.tflite`
2. Run `flutter pub get` to ensure assets are registered
3. Check `pubspec.yaml` has `assets: - assets/models/`

### Shape Mismatch

**Error**: "Input tensor shape mismatch"

**Solution**:
1. Check your model's expected input shape
2. Adjust `sequenceLength` parameter
3. Verify input data length matches model requirements

### Insufficient Data

**Error**: "Insufficient data for prediction"

**Solution**:
- The app needs at least:
  - 24 hours of data for hourly predictions
  - 7 days for daily predictions
  - 30 days for monthly predictions
- Wait for ESP8266 to collect more data, or use mock data for testing

### Predictions Look Wrong

**Possible Causes**:
1. **Normalization mismatch**: Model trained with different normalization
2. **Data scale**: Model trained on different kWh range
3. **Sequence length**: Model expects different input length

**Solution**:
- Verify your model's training data preprocessing
- Adjust normalization in `lstm_prediction_service.dart`
- Check model input/output shapes match expectations

## Testing Without Model

If you don't have a model yet, the app will:
- Show actual data only (no predictions)
- Display a warning icon if model fails to load
- Continue functioning normally for data collection

## Model Training Tips

For best results, train your model with:
- **Input features**: Historical kWh consumption
- **Sequence length**: 24-48 hours for hourly, 7-14 days for daily
- **Output**: Next 24 hours/days predictions
- **Normalization**: Min-max or standard scaling
- **Data**: At least 3-6 months of historical data

## Example Model Architecture

```python
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense

model = Sequential([
    LSTM(50, return_sequences=True, input_shape=(24, 1)),
    LSTM(50, return_sequences=False),
    Dense(25),
    Dense(24)  # Predict next 24 hours
])

model.compile(optimizer='adam', loss='mse', metrics=['mae'])
```

## Next Steps

1. **Place your model**: Copy `energy_lstm.tflite` to `assets/models/`
2. **Run the app**: `flutter run`
3. **Check Energy tab**: Predictions should appear automatically
4. **Monitor**: Watch actual vs predicted values in the charts

## Support

If you encounter issues:
1. Check serial console for error messages
2. Verify model file format and location
3. Ensure sufficient historical data is collected
4. Review model input/output shapes

