"""
Simple example: Convert your LSTM model to TFLite

Just update the INPUT_MODEL_PATH and run this script.
"""

import tensorflow as tf
import os

# ============================================
# CONFIGURATION - UPDATE THIS
# ============================================
INPUT_MODEL_PATH = 'your_model.h5'  # Change this to your model file
OUTPUT_MODEL_PATH = 'energy_lstm.tflite'  # Output file name
# ============================================

def main():
    print("🔄 Converting LSTM model to TensorFlow Lite...")
    print(f"   Input: {INPUT_MODEL_PATH}")
    print(f"   Output: {OUTPUT_MODEL_PATH}\n")
    
    # Check if input exists
    if not os.path.exists(INPUT_MODEL_PATH):
        print(f"❌ Error: Model file not found: {INPUT_MODEL_PATH}")
        print("\nPlease update INPUT_MODEL_PATH in this script with your model file path.")
        return
    
    try:
        # Load model
        print("📂 Loading model...")
        model = tf.keras.models.load_model(INPUT_MODEL_PATH)
        print(f"✅ Model loaded!")
        print(f"   Input shape: {model.input_shape}")
        print(f"   Output shape: {model.output_shape}")
        
        # Convert to TFLite
        print("\n🔄 Converting to TFLite...")
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        
        try:
            tflite_model = converter.convert()
        except Exception as e:
            error_msg = str(e)
            if "TensorList" in error_msg or "tensor list" in error_msg.lower():
                print("   ⚠️  TensorList error detected, using SELECT_TF_OPS...")
                # Use SELECT_TF_OPS for TensorList support (required for LSTM models)
                converter.target_spec.supported_ops = [
                    tf.lite.OpsSet.TFLITE_BUILTINS,
                    tf.lite.OpsSet.SELECT_TF_OPS
                ]
                converter._experimental_lower_tensor_list_ops = False
                tflite_model = converter.convert()
                print("   ✅ Conversion successful with SELECT_TF_OPS")
            else:
                raise
        
        # Save
        with open(OUTPUT_MODEL_PATH, 'wb') as f:
            f.write(tflite_model)
        
        file_size = os.path.getsize(OUTPUT_MODEL_PATH) / (1024 * 1024)
        print(f"✅ Conversion successful!")
        print(f"   Output: {OUTPUT_MODEL_PATH}")
        print(f"   Size: {file_size:.2f} MB")
        
        # Next steps
        print("\n📋 Next Steps:")
        print(f"   1. Copy '{OUTPUT_MODEL_PATH}' to:")
        print(f"      mobile_app_flutter/smart_home_app/assets/models/energy_lstm.tflite")
        print(f"   2. Run: cd mobile_app_flutter/smart_home_app")
        print(f"   3. Run: flutter pub get")
        print(f"   4. Run: flutter run")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\nTroubleshooting:")
        print("   - Ensure TensorFlow is installed: pip install tensorflow")
        print("   - Check that your model file is valid")
        print("   - Verify the model path is correct")

if __name__ == '__main__':
    main()

