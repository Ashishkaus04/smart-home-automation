# Quick Model Conversion Guide

## Step 1: Install Dependencies

```bash
pip install tensorflow
```

## Step 2: Convert Your Model

### Option A: Using the Script (Recommended)

```bash
# Basic conversion
python convert_model_to_tflite.py --input your_model.h5 --output energy_lstm.tflite

# With optimizations (smaller file size)
python convert_model_to_tflite.py --input your_model.h5 --output energy_lstm.tflite --optimize

# Test the converted model
python convert_model_to_tflite.py --input your_model.h5 --output energy_lstm.tflite --test
```

### Option B: Manual Python Script

Create a file `convert.py`:

```python
import tensorflow as tf

# Load your model
model = tf.keras.models.load_model('your_model.h5')

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save
with open('energy_lstm.tflite', 'wb') as f:
    f.write(tflite_model)

print("✅ Conversion complete!")
```

Run: `python convert.py`

## Step 3: Place Model in Flutter App

1. Copy `energy_lstm.tflite` to:
   ```
   mobile_app_flutter/smart_home_app/assets/models/energy_lstm.tflite
   ```

2. The model is already registered in `pubspec.yaml`, so just run:
   ```bash
   cd mobile_app_flutter/smart_home_app
   flutter pub get
   flutter run
   ```

## Supported Input Formats

- ✅ Keras `.h5` files
- ✅ Keras `.keras` files  
- ✅ TensorFlow SavedModel directories
- ✅ Direct Keras model objects

## Model Requirements

Your model should:
- **Input**: `[batch_size, sequence_length, features]`
  - Example: `[1, 24, 1]` for 24-hour sequences
- **Output**: `[batch_size, prediction_steps]`
  - Example: `[1, 24]` for 24-hour predictions

## Troubleshooting

### "Model file not found"
- Ensure the file is at `assets/models/energy_lstm.tflite`
- Run `flutter pub get` after adding the file

### "Shape mismatch"
- Check your model's input/output shapes
- Adjust `sequenceLength` in `lstm_prediction_service.dart`

### Conversion errors
- Ensure TensorFlow version >= 2.0
- Check model compatibility with TFLite
- Try without optimizations first

## Need Help?

If you encounter issues:
1. Check the model file format
2. Verify TensorFlow version: `python -c "import tensorflow as tf; print(tf.__version__)"`
3. Test the model manually before placing in Flutter app

