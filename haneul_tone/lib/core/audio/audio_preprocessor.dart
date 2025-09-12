import 'dart:typed_data';
import 'dart:math' as math;

/// 오디오 전처리 클래스
/// 
/// HaneulTone v1 고도화 - 오디오 신호 전처리 유틸리티
class AudioPreprocessor {
  /// 오디오 정규화 (RMS 기반)
  static Float32List normalize(Float32List audio) {
    if (audio.isEmpty) return Float32List(0);
    
    // RMS 계산
    double sumSquares = 0.0;
    for (int i = 0; i < audio.length; i++) {
      sumSquares += audio[i] * audio[i];
    }
    final rms = math.sqrt(sumSquares / audio.length);
    
    if (rms == 0.0) return Float32List.fromList(audio);
    
    // 정규화
    final normalized = Float32List(audio.length);
    for (int i = 0; i < audio.length; i++) {
      normalized[i] = audio[i] / rms;
    }
    
    return normalized;
  }
  
  /// 프리엠퍼시스 필터 적용
  static Float32List applyPreemphasis(Float32List audio, [double alpha = 0.97]) {
    if (audio.length <= 1) return Float32List.fromList(audio);
    
    final processed = Float32List(audio.length);
    processed[0] = audio[0];
    
    for (int i = 1; i < audio.length; i++) {
      processed[i] = audio[i] - alpha * audio[i - 1];
    }
    
    return processed;
  }
  
  /// 다운샘플링
  static Float32List downsample(Float32List audio, int originalSampleRate, int targetSampleRate) {
    if (originalSampleRate == targetSampleRate) {
      return Float32List.fromList(audio);
    }
    
    final ratio = originalSampleRate / targetSampleRate;
    final newLength = (audio.length / ratio).round();
    final downsampled = Float32List(newLength);
    
    for (int i = 0; i < newLength; i++) {
      final sourceIndex = (i * ratio).round();
      if (sourceIndex < audio.length) {
        downsampled[i] = audio[sourceIndex];
      }
    }
    
    return downsampled;
  }
  
  /// 오디오 큰소리 검출
  static bool isSilence(Float32List audio, [double threshold = 0.01]) {
    if (audio.isEmpty) return true;
    
    double rms = 0.0;
    for (int i = 0; i < audio.length; i++) {
      rms += audio[i] * audio[i];
    }
    rms = math.sqrt(rms / audio.length);
    
    return rms < threshold;
  }
}