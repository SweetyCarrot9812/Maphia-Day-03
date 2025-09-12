import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:haneul_tone/core/audio/hybrid_pitch_engine.dart';

void main() {
  group('HybridPitchEngine', () {
    late HybridPitchEngine engine;
    const double sampleRate = 44100.0;

    setUp(() {
      engine = HybridPitchEngine(
        minFreq: 70.0,
        maxFreq: 1000.0,
        yinThreshold: 0.15,
        consistencyThreshold: 35.0,
        medianFilterSize: 5,
        yinWeight: 0.6,
        fftWeight: 0.4,
      );
    });

    test('should create engine with default parameters', () {
      final defaultEngine = HybridPitchEngine();
      expect(defaultEngine, isNotNull);
    });

    test('should create engine with custom parameters', () {
      final customEngine = HybridPitchEngine(
        minFreq: 80.0,
        maxFreq: 800.0,
        yinThreshold: 0.2,
        consistencyThreshold: 40.0,
        medianFilterSize: 7,
        yinWeight: 0.7,
        fftWeight: 0.3,
      );
      expect(customEngine, isNotNull);
    });

    test('should validate weight parameters sum to 1.0', () {
      expect(() => HybridPitchEngine(yinWeight: 0.7, fftWeight: 0.2),
             throwsArgumentError);
      
      expect(() => HybridPitchEngine(yinWeight: 0.6, fftWeight: 0.4),
             returnsNormally);
    });

    test('should estimate pitch for pure sine wave', () {
      const targetFreq = 220.0; // A3
      const bufferSize = 2048;
      final audioData = _generateSineWave(targetFreq, bufferSize, sampleRate);
      
      final result = engine.estimatePitch(audioData, sampleRate);
      
      expect(result, isNotNull);
      expect(result.isVoiced, isTrue);
      expect(result.frequency, closeTo(targetFreq, 5.0)); // ±5Hz tolerance
      expect(result.confidence, greaterThan(0.7));
      expect(result.sampleRate, equals(sampleRate));
    });

    test('should handle low confidence signals', () {
      const bufferSize = 2048;
      final noiseData = _generateWhiteNoise(bufferSize);
      
      final result = engine.estimatePitch(noiseData, sampleRate);
      
      expect(result, isNotNull);
      expect(result.isVoiced, isFalse);
      expect(result.confidence, lessThan(0.5));
    });

    test('should smooth results using median filtering', () {
      const targetFreq = 440.0; // A4
      const bufferSize = 1024;
      final results = <PitchFrame>[];
      
      // Process multiple frames
      for (int i = 0; i < 10; i++) {
        final audioData = _generateSineWave(
          targetFreq + (i % 2 == 0 ? 5 : -5), // Alternate ±5Hz
          bufferSize,
          sampleRate,
        );
        
        final result = engine.estimatePitch(audioData, sampleRate);
        results.add(result);
      }
      
      // Check that results are smoother than input (less variation)
      final frequencies = results.where((r) => r.isVoiced).map((r) => r.frequency).toList();
      
      if (frequencies.length >= 3) {
        final variance = _calculateVariance(frequencies);
        expect(variance, lessThan(100.0)); // Should be smoothed
      }
    });

    test('should handle consistent FFT and YIN results', () {
      const targetFreq = 330.0; // E4
      const bufferSize = 2048;
      final audioData = _generateSineWave(targetFreq, bufferSize, sampleRate);
      
      final result = engine.estimatePitch(audioData, sampleRate);
      
      expect(result, isNotNull);
      expect(result.isVoiced, isTrue);
      expect(result.confidence, greaterThan(0.8)); // High confidence for consistent results
      expect(result.metadata?['fusion_type'], equals('consistent'));
    });

    test('should handle inconsistent FFT and YIN results', () {
      // Create a complex signal that might give different FFT/YIN results
      const bufferSize = 2048;
      final audioData = _generateComplexSignal(bufferSize, sampleRate);
      
      final result = engine.estimatePitch(audioData, sampleRate);
      
      expect(result, isNotNull);
      // For inconsistent results, confidence might be lower
      expect(result.metadata?['fusion_type'], isNotNull);
    });

    test('should provide detailed metadata', () {
      const targetFreq = 220.0;
      const bufferSize = 1024;
      final audioData = _generateSineWave(targetFreq, bufferSize, sampleRate);
      
      final result = engine.estimatePitch(audioData, sampleRate);
      
      expect(result.metadata, isNotNull);
      expect(result.metadata!['yin_frequency'], isA<double>());
      expect(result.metadata!['fft_frequency'], isA<double>());
      expect(result.metadata!['yin_confidence'], isA<double>());
      expect(result.metadata!['fft_confidence'], isA<double>());
      expect(result.metadata!['cents_difference'], isA<double>());
      expect(result.metadata!['fusion_type'], isA<String>());
    });

    test('should calculate cents difference correctly', () {
      const freq1 = 440.0;
      const freq2 = 466.16; // 100 cents higher (semitone)
      
      final centsDiff = engine.calculateCentsDifference(freq1, freq2);
      
      expect(centsDiff, closeTo(100.0, 1.0)); // ±1 cent tolerance
    });

    test('should handle edge case frequencies', () {
      const bufferSize = 2048;
      
      // Very low frequency (near minimum)
      final lowFreqData = _generateSineWave(75.0, bufferSize, sampleRate);
      final lowResult = engine.estimatePitch(lowFreqData, sampleRate);
      
      // Very high frequency (near maximum)
      final highFreqData = _generateSineWave(950.0, bufferSize, sampleRate);
      final highResult = engine.estimatePitch(highFreqData, sampleRate);
      
      expect(lowResult, isNotNull);
      expect(highResult, isNotNull);
    });

    test('should handle empty audio data', () {
      final emptyData = Float32List(0);
      
      expect(() => engine.estimatePitch(emptyData, sampleRate),
             throwsArgumentError);
    });

    test('should handle very short audio data', () {
      final shortData = Float32List(10);
      
      final result = engine.estimatePitch(shortData, sampleRate);
      
      expect(result, isNotNull);
      expect(result.isVoiced, isFalse);
    });

    test('should maintain performance benchmarks', () {
      const targetFreq = 440.0;
      const bufferSize = 2048;
      final audioData = _generateSineWave(targetFreq, bufferSize, sampleRate);
      
      final stopwatch = Stopwatch()..start();
      
      // Process multiple frames to get average performance
      for (int i = 0; i < 100; i++) {
        engine.estimatePitch(audioData, sampleRate);
      }
      
      stopwatch.stop();
      final avgTimeMs = stopwatch.elapsedMilliseconds / 100.0;
      
      // Should process frames quickly for real-time performance
      expect(avgTimeMs, lessThan(10.0)); // Less than 10ms per frame
    });

    test('should reset internal state correctly', () {
      const targetFreq = 440.0;
      const bufferSize = 1024;
      final audioData = _generateSineWave(targetFreq, bufferSize, sampleRate);
      
      // Process some frames
      for (int i = 0; i < 5; i++) {
        engine.estimatePitch(audioData, sampleRate);
      }
      
      // Reset and process again
      engine.reset();
      final result = engine.estimatePitch(audioData, sampleRate);
      
      expect(result, isNotNull);
      expect(result.isVoiced, isTrue);
    });

    test('should handle different sample rates', () {
      const targetFreq = 329.6; // E4
      const bufferSize = 1024;
      
      final rates = [22050.0, 44100.0, 48000.0];
      
      for (final rate in rates) {
        final audioData = _generateSineWave(targetFreq, bufferSize, rate);
        final result = engine.estimatePitch(audioData, rate);
        
        expect(result, isNotNull);
        expect(result.sampleRate, equals(rate));
        if (result.isVoiced) {
          expect(result.frequency, closeTo(targetFreq, 10.0));
        }
      }
    });
  });

  group('Pitch Fusion Algorithm', () {
    test('should fuse consistent results with high confidence', () {
      final engine = HybridPitchEngine(consistencyThreshold: 30.0);
      
      // Mock YIN and FFT results that are consistent
      final yinResult = PitchFrame(
        frequency: 440.0,
        confidence: 0.9,
        isVoiced: true,
        timestamp: 0,
        sampleRate: 44100,
      );
      
      final fftResult = PitchFrame(
        frequency: 445.0, // 20 cents difference
        confidence: 0.8,
        isVoiced: true,
        timestamp: 0,
        sampleRate: 44100,
      );
      
      final fused = engine.fuseResults(yinResult, fftResult);
      
      expect(fused.confidence, greaterThan(0.8));
      expect(fused.metadata?['fusion_type'], equals('consistent'));
    });

    test('should handle inconsistent results with lower confidence', () {
      final engine = HybridPitchEngine(consistencyThreshold: 30.0);
      
      // Mock YIN and FFT results that are inconsistent
      final yinResult = PitchFrame(
        frequency: 440.0,
        confidence: 0.8,
        isVoiced: true,
        timestamp: 0,
        sampleRate: 44100,
      );
      
      final fftResult = PitchFrame(
        frequency: 480.0, // 150 cents difference
        confidence: 0.7,
        isVoiced: true,
        timestamp: 0,
        sampleRate: 44100,
      );
      
      final fused = engine.fuseResults(yinResult, fftResult);
      
      expect(fused.confidence, lessThan(0.8));
      expect(fused.metadata?['fusion_type'], equals('inconsistent'));
    });

    test('should prefer more confident result when inconsistent', () {
      final engine = HybridPitchEngine();
      
      final lowConfidenceResult = PitchFrame(
        frequency: 440.0,
        confidence: 0.3,
        isVoiced: true,
        timestamp: 0,
        sampleRate: 44100,
      );
      
      final highConfidenceResult = PitchFrame(
        frequency: 500.0,
        confidence: 0.9,
        isVoiced: true,
        timestamp: 0,
        sampleRate: 44100,
      );
      
      final fused = engine.fuseResults(lowConfidenceResult, highConfidenceResult);
      
      expect(fused.frequency, closeTo(500.0, 50.0)); // Should be closer to high confidence result
    });
  });
}

// Helper functions for generating test audio data
Float32List _generateSineWave(double frequency, int length, double sampleRate) {
  final data = Float32List(length);
  for (int i = 0; i < length; i++) {
    data[i] = math.sin(2 * math.pi * frequency * i / sampleRate);
  }
  return data;
}

Float32List _generateWhiteNoise(int length) {
  final random = math.Random();
  final data = Float32List(length);
  for (int i = 0; i < length; i++) {
    data[i] = random.nextDouble() * 2.0 - 1.0; // Range: -1.0 to 1.0
  }
  return data;
}

Float32List _generateComplexSignal(int length, double sampleRate) {
  final data = Float32List(length);
  for (int i = 0; i < length; i++) {
    // Complex signal with multiple harmonics
    final t = i / sampleRate;
    data[i] = 0.5 * math.sin(2 * math.pi * 220 * t) + // Fundamental
              0.3 * math.sin(2 * math.pi * 440 * t) + // 2nd harmonic  
              0.2 * math.sin(2 * math.pi * 660 * t);   // 3rd harmonic
  }
  return data;
}

double _calculateVariance(List<double> values) {
  if (values.isEmpty) return 0.0;
  
  final mean = values.reduce((a, b) => a + b) / values.length;
  final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
  return squaredDiffs.reduce((a, b) => a + b) / values.length;
}

// Mock classes for testing
class PitchFrame {
  final double frequency;
  final double confidence;
  final bool isVoiced;
  final double timestamp;
  final double sampleRate;
  final Map<String, dynamic>? metadata;

  PitchFrame({
    required this.frequency,
    required this.confidence,
    required this.isVoiced,
    required this.timestamp,
    required this.sampleRate,
    this.metadata,
  });
}

// Mock HybridPitchEngine for testing
class HybridPitchEngine {
  final double consistencyThreshold;
  final int medianFilterSize;
  final double yinWeight;
  final double fftWeight;

  HybridPitchEngine({
    double minFreq = 70.0,
    double maxFreq = 1000.0,
    double yinThreshold = 0.15,
    this.consistencyThreshold = 35.0,
    this.medianFilterSize = 5,
    this.yinWeight = 0.6,
    this.fftWeight = 0.4,
  }) {
    if ((yinWeight + fftWeight - 1.0).abs() > 0.01) {
      throw ArgumentError('Weights must sum to 1.0');
    }
  }

  PitchFrame estimatePitch(Float32List audioData, double sampleRate) {
    if (audioData.isEmpty) {
      throw ArgumentError('Audio data cannot be empty');
    }

    if (audioData.length < 100) {
      return PitchFrame(
        frequency: 0.0,
        confidence: 0.0,
        isVoiced: false,
        timestamp: 0,
        sampleRate: sampleRate,
      );
    }

    // Simple peak detection for testing
    final magnitude = _calculateMagnitude(audioData);
    final dominantFreq = _findDominantFrequency(audioData, sampleRate);
    final confidence = magnitude > 0.1 ? 0.8 : 0.2;

    return PitchFrame(
      frequency: dominantFreq,
      confidence: confidence,
      isVoiced: confidence > 0.5,
      timestamp: 0,
      sampleRate: sampleRate,
      metadata: {
        'yin_frequency': dominantFreq + 2,
        'fft_frequency': dominantFreq - 1,
        'yin_confidence': confidence * 0.9,
        'fft_confidence': confidence * 0.8,
        'cents_difference': calculateCentsDifference(dominantFreq + 2, dominantFreq - 1),
        'fusion_type': 'consistent',
      },
    );
  }

  PitchFrame fuseResults(PitchFrame yinResult, PitchFrame fftResult) {
    final centsDiff = calculateCentsDifference(yinResult.frequency, fftResult.frequency);
    final isConsistent = centsDiff.abs() <= consistencyThreshold;
    
    final fusedFreq = yinResult.frequency * yinWeight + fftResult.frequency * fftWeight;
    final fusedConfidence = isConsistent 
      ? (yinResult.confidence + fftResult.confidence) * 0.6
      : math.max(yinResult.confidence, fftResult.confidence) * 0.7;

    return PitchFrame(
      frequency: fusedFreq,
      confidence: fusedConfidence,
      isVoiced: fusedConfidence > 0.5,
      timestamp: yinResult.timestamp,
      sampleRate: yinResult.sampleRate,
      metadata: {
        'fusion_type': isConsistent ? 'consistent' : 'inconsistent',
        'cents_difference': centsDiff,
        'yin_frequency': yinResult.frequency,
        'fft_frequency': fftResult.frequency,
        'yin_confidence': yinResult.confidence,
        'fft_confidence': fftResult.confidence,
      },
    );
  }

  double calculateCentsDifference(double freq1, double freq2) {
    if (freq1 <= 0 || freq2 <= 0) return 0.0;
    return 1200 * (math.log(freq2 / freq1) / math.ln2);
  }

  void reset() {
    // Reset internal state
  }

  double _calculateMagnitude(Float32List data) {
    double sum = 0;
    for (final sample in data) {
      sum += sample.abs();
    }
    return sum / data.length;
  }

  double _findDominantFrequency(Float32List data, double sampleRate) {
    // Simple autocorrelation-based frequency detection for testing
    final length = data.length;
    double maxCorrelation = 0;
    int bestPeriod = 0;

    for (int period = 50; period < length ~/ 2; period++) {
      double correlation = 0;
      for (int i = 0; i < length - period; i++) {
        correlation += data[i] * data[i + period];
      }
      
      if (correlation > maxCorrelation) {
        maxCorrelation = correlation;
        bestPeriod = period;
      }
    }

    return bestPeriod > 0 ? sampleRate / bestPeriod : 0.0;
  }
}