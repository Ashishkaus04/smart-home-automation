"""
Convert your trained LSTM model to TensorFlow Lite format for Flutter app.

Supports:
- Keras .h5 files
- SavedModel format
- .keras files
- Direct model objects

Usage:
    python convert_model_to_tflite.py --input your_model.h5 --output energy_lstm.tflite
"""

import argparse
import os
import sys
import numpy as np

# Fix Windows console encoding
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

try:
    import tensorflow as tf
    print(f"[OK] TensorFlow version: {tf.__version__}")
except ImportError:
    print("[ERROR] TensorFlow not installed. Install with: pip install tensorflow")
    sys.exit(1)


def convert_h5_to_tflite(input_path: str, output_path: str, optimize: bool = False, use_select_tf_ops: bool = False):
    """Convert Keras .h5 model to TFLite."""
    print(f"\n[INFO] Loading model from: {input_path}")
        
    try:
        # Load the model
        model = tf.keras.models.load_model(input_path)
        print(f"[OK] Model loaded successfully")
        print(f"     Input shape: {model.input_shape}")
        print(f"     Output shape: {model.output_shape}")
        
        # Convert to TFLite
        print(f"\n[INFO] Converting to TensorFlow Lite...")
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        
        if optimize:
            # Optional: Apply optimizations (may reduce accuracy slightly)
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            print("     [OPT] Optimizations enabled")
        
        # Handle TensorList operations (common with LSTM models)
        if use_select_tf_ops:
            converter.target_spec.supported_ops = [
                tf.lite.OpsSet.TFLITE_BUILTINS,
                tf.lite.OpsSet.SELECT_TF_OPS
            ]
            converter._experimental_lower_tensor_list_ops = False
            print("     [INFO] Using SELECT_TF_OPS for TensorList support")
        
        try:
            tflite_model = converter.convert()
        except Exception as e:
            error_msg = str(e)
            if "TensorList" in error_msg or "tensor list" in error_msg.lower():
                print("     [WARN] TensorList error detected, retrying with SELECT_TF_OPS...")
                converter.target_spec.supported_ops = [
                    tf.lite.OpsSet.TFLITE_BUILTINS,
                    tf.lite.OpsSet.SELECT_TF_OPS
                ]
                converter._experimental_lower_tensor_list_ops = False
                tflite_model = converter.convert()
                print("     [OK] Conversion successful with SELECT_TF_OPS")
            else:
                raise
        
        # Save the model
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        file_size = os.path.getsize(output_path) / (1024 * 1024)  # MB
        print(f"[OK] Conversion successful!")
        print(f"     Output: {output_path}")
        print(f"     Size: {file_size:.2f} MB")
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Error converting model: {e}")
        return False


def convert_savedmodel_to_tflite(input_path: str, output_path: str, optimize: bool = False, use_select_tf_ops: bool = False):
    """Convert SavedModel to TFLite."""
    print(f"\n[INFO] Loading SavedModel from: {input_path}")
    
    try:
        converter = tf.lite.TFLiteConverter.from_saved_model(input_path)
        
        if optimize:
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            print("     [OPT] Optimizations enabled")
        
        # Handle TensorList operations
        if use_select_tf_ops:
            converter.target_spec.supported_ops = [
                tf.lite.OpsSet.TFLITE_BUILTINS,
                tf.lite.OpsSet.SELECT_TF_OPS
            ]
            converter._experimental_lower_tensor_list_ops = False
            print("     [INFO] Using SELECT_TF_OPS for TensorList support")
        
        try:
            tflite_model = converter.convert()
        except Exception as e:
            error_msg = str(e)
            if "TensorList" in error_msg or "tensor list" in error_msg.lower():
                print("     [WARN] TensorList error detected, retrying with SELECT_TF_OPS...")
                converter.target_spec.supported_ops = [
                    tf.lite.OpsSet.TFLITE_BUILTINS,
                    tf.lite.OpsSet.SELECT_TF_OPS
                ]
                converter._experimental_lower_tensor_list_ops = False
                tflite_model = converter.convert()
                print("     [OK] Conversion successful with SELECT_TF_OPS")
            else:
                raise
        
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        file_size = os.path.getsize(output_path) / (1024 * 1024)
        print(f"[OK] Conversion successful!")
        print(f"     Output: {output_path}")
        print(f"     Size: {file_size:.2f} MB")
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Error converting model: {e}")
        return False


def test_tflite_model(model_path: str, input_shape: tuple = (1, 24, 1)):
    """Test the converted TFLite model with sample input."""
    print(f"\n[TEST] Testing TFLite model...")
    
    try:
        # Load TFLite model
        interpreter = tf.lite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()
        
        # Get input and output details
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print(f"     Input shape: {input_details[0]['shape']}")
        print(f"     Output shape: {output_details[0]['shape']}")
        print(f"     Input dtype: {input_details[0]['dtype']}")
        print(f"     Output dtype: {output_details[0]['dtype']}")
        
        # Create sample input
        input_shape_actual = input_details[0]['shape']
        sample_input = np.random.random(input_shape_actual).astype(input_details[0]['dtype'])
        
        # Run inference
        interpreter.set_tensor(input_details[0]['index'], sample_input)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]['index'])
        
        print(f"     [OK] Test inference successful!")
        print(f"     Sample output shape: {output.shape}")
        print(f"     Sample output range: [{output.min():.4f}, {output.max():.4f}]")
        
        return True
        
    except Exception as e:
        print(f"     [ERROR] Test failed: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description='Convert LSTM model to TensorFlow Lite for Flutter app',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Convert Keras .h5 model
  python convert_model_to_tflite.py --input model.h5 --output energy_lstm.tflite
  
  # Convert with optimizations
  python convert_model_to_tflite.py --input model.h5 --output energy_lstm.tflite --optimize
  
  # Convert SavedModel
  python convert_model_to_tflite.py --input saved_model/ --output energy_lstm.tflite
        """
    )
    
    parser.add_argument(
        '--input', '-i',
        type=str,
        required=True,
        help='Input model file (.h5, .keras) or SavedModel directory'
    )
    
    parser.add_argument(
        '--output', '-o',
        type=str,
        default='energy_lstm.tflite',
        help='Output TFLite file path (default: energy_lstm.tflite)'
    )
    
    parser.add_argument(
        '--optimize',
        action='store_true',
        help='Apply TFLite optimizations (may reduce accuracy slightly)'
    )
    
    parser.add_argument(
        '--test',
        action='store_true',
        help='Test the converted model with sample input'
    )
    
    parser.add_argument(
        '--select-tf-ops',
        action='store_true',
        help='Use SELECT_TF_OPS for TensorList support (required for some LSTM models)'
    )
    
    args = parser.parse_args()
    
    # Check if input file exists
    if not os.path.exists(args.input):
        print(f"[ERROR] Input file/directory not found: {args.input}")
        sys.exit(1)
    
    # Determine conversion method based on input
    input_lower = args.input.lower()
    success = False
    
    if input_lower.endswith('.h5') or input_lower.endswith('.keras'):
        success = convert_h5_to_tflite(args.input, args.output, args.optimize, args.select_tf_ops)
    elif os.path.isdir(args.input):
        # Assume SavedModel format
        success = convert_savedmodel_to_tflite(args.input, args.output, args.optimize, args.select_tf_ops)
    else:
        print(f"[ERROR] Unsupported input format: {args.input}")
        print("        Supported formats: .h5, .keras, or SavedModel directory")
        sys.exit(1)
    
    if success:
        # Test the model if requested
        if args.test:
            test_tflite_model(args.output)
        
        # Provide next steps
        print(f"\n[NEXT STEPS]")
        print(f"    1. Copy '{args.output}' to:")
        print(f"       mobile_app_flutter/smart_home_app/assets/models/energy_lstm.tflite")
        print(f"    2. Run: flutter pub get")
        print(f"    3. Run: flutter run")
        print(f"    4. Check Energy tab for predictions!")
    else:
        sys.exit(1)


if __name__ == '__main__':
    main()

