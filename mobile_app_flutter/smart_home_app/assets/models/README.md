# LSTM Model Directory

## Model File

Place your trained LSTM model file here:

**File name:** `energy_lstm.tflite`

## Model Requirements

1. **Format**: TensorFlow Lite (`.tflite`)
2. **Input Shape**: 
   - For hourly predictions: `[1, 24, 1]` (batch_size=1, sequence_length=24, features=1)
   - For daily predictions: `[1, 7, 1]` (batch_size=1, sequence_length=7, features=1)
   - Adjust `sequenceLength` in `lstm_prediction_service.dart` if your model uses different input shape

3. **Output Shape**: 
   - Should output predictions for the next N time steps
   - Example: `[1, 24]` for 24-hour predictions

## Converting Your Model

If you have a trained Keras/TensorFlow model (`.h5` or `.pb`), convert it to TFLite:

### Python Script:
```python
import tensorflow as tf

# Load your saved model
model = tf.keras.models.load_model('your_model.h5')

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save
with open('energy_lstm.tflite', 'wb') as f:
    f.write(tflite_model)
```

## Model Training Notes

- **Input**: Historical energy consumption values (kWh)
- **Output**: Predicted future consumption values (kWh)
- **Normalization**: The service handles min-max normalization automatically
- **Sequence Length**: Adjust based on your model's training configuration

## Testing

After placing the model file, the app will automatically:
1. Load the model on Energy screen initialization
2. Generate predictions when sufficient historical data is available
3. Display predictions alongside actual data in the charts

## Troubleshooting

- **Model not found**: Ensure the file is named exactly `energy_lstm.tflite` and placed in `assets/models/`
- **Shape mismatch**: Check your model's input/output shapes and adjust `sequenceLength` in the service
- **Prediction errors**: Verify your model was trained on similar data (kWh values in similar range)

