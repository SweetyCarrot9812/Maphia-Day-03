import 'dart:typed_data';
import 'pitch_frame.dart';
import 'window_functions.dart';

/// 피치 추정 엔진의 추상 인터페이스
/// 
/// HaneulTone v1 고도화 - 다양한 피치 추정 알고리즘을 위한 공통 인터페이스
abstract class PitchEngine {
  /// PCM 오디오 데이터에서 피치 프레임 시퀀스를 추정
  /// 
  /// [pcm]: 입력 PCM 데이터 (Float32List)
  /// [sampleRate]: 샘플링 레이트 (Hz)
  /// [returns]: 시간 순서대로 정렬된 피치 프레임 리스트
  Future<List<PitchFrame>> estimate(Float32List pcm, int sampleRate);
  
  /// 엔진 이름 (디버깅/로깅용)
  String get engineName;
  
  /// 지원하는 주파수 범위
  double get minFreqHz;
  double get maxFreqHz;
  
  /// 권장 샘플링 레이트
  int get preferredSampleRate => 24000; // 48kHz → 24kHz 다운샘플
  
  /// 프레임 크기 (샘플 수)
  int get frameSize => (preferredSampleRate * 0.04).round(); // 40ms window
  
  /// 홉 크기 (샘플 수) 
  int get hopSize => (preferredSampleRate * 0.01).round(); // 10ms hop
  
  /// 윈도우 함수 타입
  WindowType get windowType => WindowType.hann;
}