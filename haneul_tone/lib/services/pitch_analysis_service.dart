import 'dart:math' as math;
import '../models/pitch_data.dart';
import '../models/audio_reference.dart';
import '../utils/note_utils.dart';
import '../utils/fft_utils.dart';

class PitchAnalysisService {
  static const int sampleRate = 44100;
  static const int frameSize = 2048;
  static const int hopSize = 512;
  static const double minFreq = 80.0;  // 최소 주파수 (Hz)
  static const double maxFreq = 2000.0; // 최대 주파수 (Hz)

  // 오디오 파일을 분석하여 피치 곡선 생성 (데모 버전)
  static Future<PitchData?> analyzeAudioFile(
    String filePath, 
    AudioReference audioReference
  ) async {
    try {
      print('오디오 파일 분석 시작: $filePath');
      
      // 실제 피치 곡선 추출
      final pitchAnalysis = await _extractPitchCurve(filePath, audioReference);
      final pitchCurve = pitchAnalysis['pitches'] as List<double>;
      final timestamps = pitchAnalysis['timestamps'] as List<double>;
      
      if (pitchCurve.isEmpty) {
        print('피치 추출 실패');
        return null;
      }
      
      print('피치 곡선 추출 완료: ${pitchCurve.length}개 포인트');
      
      // 음표 세그먼트 생성
      final noteSegments = _generateNoteSegments(
        pitchCurve, 
        timestamps, 
        audioReference
      );
      
      return PitchData(
        id: 0, // 데이터베이스에서 자동 생성
        audioReferenceId: audioReference.id!,
        pitchCurve: pitchCurve,
        timestamps: timestamps,
        noteSegments: noteSegments,
        sampleRate: sampleRate.toDouble(),
        createdAt: DateTime.now(),
      );
      
    } catch (e) {
      print('피치 분석 오류: $e');
      return null;
    }
  }

  // 실제 오디오 파일에서 피치 곡선 추출
  static Future<Map<String, List<double>>> _extractPitchCurve(
    String filePath,
    AudioReference audioReference
  ) async {
    final pitches = <double>[];
    final timestamps = <double>[];
    
    try {
      // 실제 구현에서는 오디오 파일을 읽어서 분석해야 함
      // 현재는 데모 데이터를 생성 (추후 실제 오디오 파싱 구현 필요)
      print('오디오 파일에서 PCM 데이터 추출: $filePath');
      
      // TODO: 실제 오디오 파일 읽기 구현
      // 임시로 시뮬레이션된 PCM 데이터 생성
      final simulatedAudioData = _generateSimulatedAudioData(audioReference);
      
      // STFT를 사용한 피치 추출
      final stftResults = FFTUtils.stft(
        simulatedAudioData,
        frameSize,
        hopSize,
        windowType: 'hanning'
      );
      
      print('STFT 분석 완료: ${stftResults.length}개 프레임');
      
      // 각 프레임에서 피치 추출
      for (int i = 0; i < stftResults.length; i++) {
        final frameTime = (i * hopSize) / sampleRate.toDouble();
        timestamps.add(frameTime);
        
        // FFT 결과에서 기본 주파수 찾기
        final pitch = FFTUtils.findFundamentalFrequency(
          stftResults[i],
          sampleRate.toDouble(),
          minFreq: minFreq,
          maxFreq: maxFreq,
        );
        
        pitches.add(pitch);
      }
      
      print('피치 추출 완료: ${pitches.length}개 포인트');
      
    } catch (e) {
      print('피치 곡선 추출 오류: $e');
    }
    
    return {
      'pitches': pitches,
      'timestamps': timestamps,
    };
  }
  
  // 시뮬레이션된 오디오 데이터 생성 (실제 구현 전 테스트용)
  static List<double> _generateSimulatedAudioData(AudioReference audioReference) {
    final expectedNotes = NoteUtils.generateScale(
      audioReference.key,
      audioReference.scaleType,
      audioReference.octaves,
      audioReference.a4Freq,
    );
    
    const totalDuration = 10.0; // 10초
    final totalSamples = (sampleRate * totalDuration).round();
    final audioData = <double>[];
    
    final noteHoldSamples = totalSamples ~/ expectedNotes.length;
    
    for (int noteIndex = 0; noteIndex < expectedNotes.length; noteIndex++) {
      final frequency = expectedNotes[noteIndex]['frequency'] as double;
      final startSample = noteIndex * noteHoldSamples;
      final endSample = math.min((noteIndex + 1) * noteHoldSamples, totalSamples);
      
      // 사인파 생성 (기본 주파수)
      for (int sample = startSample; sample < endSample; sample++) {
        final t = sample / sampleRate.toDouble();
        final relativeT = (sample - startSample) / noteHoldSamples.toDouble();
        
        // 엔벨로프 적용 (어택-디케이-서스테인-릴리즈)
        double envelope = 1.0;
        if (relativeT < 0.1) {
          envelope = relativeT * 10; // 어택
        } else if (relativeT > 0.8) {
          envelope = (1.0 - relativeT) * 5; // 릴리즈
        }
        
        // 기본 주파수 + 배음 추가 (더 현실적인 소리)
        double amplitude = envelope * 0.3;
        double value = amplitude * (
          math.sin(2 * math.pi * frequency * t) +           // 기본 주파수
          0.3 * math.sin(2 * math.pi * frequency * 2 * t) + // 2차 배음
          0.1 * math.sin(2 * math.pi * frequency * 3 * t)   // 3차 배음
        );
        
        // 약간의 노이즈 추가
        final random = math.Random();
        value += (random.nextDouble() - 0.5) * 0.02;
        
        audioData.add(value);
      }
    }
    
    return audioData;
  }

  // 음표 세그먼트 생성
  static List<NoteSegment> _generateNoteSegments(
    List<double> pitchCurve,
    List<double> timestamps,
    AudioReference audioReference,
  ) {
    final segments = <NoteSegment>[];
    
    try {
      // 스케일의 예상 음표 생성
      final expectedNotes = NoteUtils.generateScale(
        audioReference.key,
        audioReference.scaleType,
        audioReference.octaves,
        audioReference.a4Freq,
      );
      
      // 간단한 세그먼테이션: 각 음표를 동일한 시간으로 분할
      final totalDuration = timestamps.isNotEmpty ? timestamps.last : 1.0;
      final segmentDuration = totalDuration / expectedNotes.length;
      
      for (int i = 0; i < expectedNotes.length; i++) {
        final startTime = i * segmentDuration;
        final endTime = (i + 1) * segmentDuration;
        final expectedFreq = expectedNotes[i]['frequency'] as double;
        final noteName = expectedNotes[i]['note'] as String;
        
        // 해당 구간의 실제 평균 피치 계산
        final actualFreq = _calculateAverageFrequencyInRange(
          pitchCurve, 
          timestamps, 
          startTime, 
          endTime
        );
        
        segments.add(NoteSegment(
          noteName: noteName,
          startTime: startTime,
          endTime: endTime,
          expectedFrequency: expectedFreq,
          actualFrequency: actualFreq,
        ));
      }
      
      print('음표 세그먼트 생성 완료: ${segments.length}개');
      
    } catch (e) {
      print('세그먼트 생성 오류: $e');
    }
    
    return segments;
  }

  // 특정 시간 범위의 평균 주파수 계산
  static double _calculateAverageFrequencyInRange(
    List<double> pitchCurve,
    List<double> timestamps,
    double startTime,
    double endTime,
  ) {
    final validFrequencies = <double>[];
    
    for (int i = 0; i < timestamps.length && i < pitchCurve.length; i++) {
      if (timestamps[i] >= startTime && 
          timestamps[i] <= endTime && 
          pitchCurve[i] > 0) {
        validFrequencies.add(pitchCurve[i]);
      }
    }
    
    if (validFrequencies.isEmpty) return 0.0;
    
    final sum = validFrequencies.reduce((a, b) => a + b);
    return sum / validFrequencies.length;
  }

  // 피치 데이터 후처리 (노이즈 제거, 스무딩 등)
  static List<double> smoothPitchCurve(List<double> pitchCurve, {int windowSize = 5}) {
    if (pitchCurve.length < windowSize) return pitchCurve;
    
    final smoothed = <double>[];
    final halfWindow = windowSize ~/ 2;
    
    for (int i = 0; i < pitchCurve.length; i++) {
      final start = math.max(0, i - halfWindow);
      final end = math.min(pitchCurve.length - 1, i + halfWindow);
      
      final validValues = <double>[];
      for (int j = start; j <= end; j++) {
        if (pitchCurve[j] > 0) {
          validValues.add(pitchCurve[j]);
        }
      }
      
      if (validValues.isEmpty) {
        smoothed.add(0.0);
      } else {
        final average = validValues.reduce((a, b) => a + b) / validValues.length;
        smoothed.add(average);
      }
    }
    
    return smoothed;
  }

  // 기본 통계 계산
  static Map<String, double> calculateBasicStats(List<NoteSegment> segments) {
    if (segments.isEmpty) {
      return {
        'accuracyMean': 0.0,
        'accuracyStd': 0.0,
        'validNotes': 0.0,
      };
    }
    
    final centErrors = <double>[];
    for (final segment in segments) {
      if (segment.actualFrequency > 0) {
        final cents = segment.getAccuracyInCents();
        centErrors.add(cents.abs()); // 절대값
      }
    }
    
    if (centErrors.isEmpty) {
      return {
        'accuracyMean': 0.0,
        'accuracyStd': 0.0,
        'validNotes': 0.0,
      };
    }
    
    // 평균 계산
    final mean = centErrors.reduce((a, b) => a + b) / centErrors.length;
    
    // 표준편차 계산
    final variance = centErrors
        .map((x) => math.pow(x - mean, 2))
        .reduce((a, b) => a + b) / centErrors.length;
    final std = math.sqrt(variance);
    
    return {
      'accuracyMean': mean,
      'accuracyStd': std,
      'validNotes': centErrors.length.toDouble(),
    };
  }

  // 약점 음표 식별
  static List<String> identifyWeakNotes(List<NoteSegment> segments, {double threshold = 50.0}) {
    final weakNotes = <String>[];
    
    for (final segment in segments) {
      if (segment.actualFrequency > 0) {
        final cents = segment.getAccuracyInCents().abs();
        if (cents > threshold) {
          weakNotes.add('${segment.noteName}(${cents.round()}¢)');
        }
      } else {
        weakNotes.add('${segment.noteName}(무음)');
      }
    }
    
    return weakNotes;
  }
}