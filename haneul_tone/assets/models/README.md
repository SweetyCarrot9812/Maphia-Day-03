# CREPE-Tiny TensorFlow Lite 모델

이 폴더에는 HaneulTone의 고정밀 피치 추정을 위한 CREPE-Tiny TFLite 모델이 저장됩니다.

## 모델 다운로드

1. **CREPE-Tiny 모델 다운로드**:
   ```bash
   wget https://github.com/marl/crepe/raw/master/crepe/models/tiny.h5
   ```

2. **TensorFlow Lite 변환**:
   ```python
   import tensorflow as tf
   
   # Keras 모델 로드
   model = tf.keras.models.load_model('tiny.h5')
   
   # TFLite 변환
   converter = tf.lite.TFLiteConverter.from_keras_model(model)
   converter.optimizations = [tf.lite.Optimize.DEFAULT]
   converter.target_spec.supported_types = [tf.lite.constants.FLOAT16]
   
   tflite_model = converter.convert()
   
   # 저장
   with open('crepe_tiny.tflite', 'wb') as f:
       f.write(tflite_model)
   ```

3. **모델 검증**:
   ```python
   import numpy as np
   
   interpreter = tf.lite.Interpreter(model_path='crepe_tiny.tflite')
   interpreter.allocate_tensors()
   
   # 입력/출력 정보 확인
   input_details = interpreter.get_input_details()
   output_details = interpreter.get_output_details()
   
   print(f"입력 shape: {input_details[0]['shape']}")
   print(f"출력 shape: {output_details[0]['shape']}")
   ```

## 파일 구조

```
assets/models/
├── README.md                    # 이 파일
├── crepe_tiny.tflite           # CREPE-Tiny TFLite 모델 (다운로드 필요)
├── crepe_tiny_metadata.json    # 모델 메타데이터
└── model_info.txt              # 모델 정보
```

## 모델 사양

- **입력**: [1, 1024] Float32 (16kHz 오디오, 64ms 프레임)
- **출력**: [1, 360] Float32 (salience 분포, 32.7Hz ~ 2093Hz)
- **크기**: ~2.1MB (FP16 양자화)
- **정확도**: ±5 cents 이내
- **레이턴시**: ~10-20ms (모바일 디바이스)

## 라이센스

CREPE 모델은 MIT 라이센스 하에 배포됩니다.
원본: https://github.com/marl/crepe

## 참고 자료

- CREPE 논문: "CREPE: A Convolutional Representation for Pitch Estimation"
- TensorFlow Lite 최적화: https://www.tensorflow.org/lite/performance/best_practices
- 모바일 추론 최적화: https://www.tensorflow.org/lite/performance/gpu_advanced