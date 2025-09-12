import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioUtils', () {
    test('should normalize audio data correctly', () {
      final input = Float32List.fromList([0.5, -0.3, 0.8, -0.2]);
      final normalized = AudioUtils.normalizeAudio(input);

      // Check that max absolute value is 1.0
      final maxVal = normalized.map((v) => v.abs()).reduce(math.max);
      expect(maxVal, closeTo(1.0, 0.001));
    });

    test('should handle zero audio data', () {
      final input = Float32List.fromList([0.0, 0.0, 0.0, 0.0]);
      final normalized = AudioUtils.normalizeAudio(input);

      expect(normalized, equals(input));
    });

    test('should calculate RMS correctly', () {
      final input = Float32List.fromList([1.0, -1.0, 0.5, -0.5]);
      final rms = AudioUtils.calculateRMS(input);

      // RMS = sqrt((1² + 1² + 0.5² + 0.5²) / 4) = sqrt(2.5 / 4) = sqrt(0.625)
      expect(rms, closeTo(math.sqrt(0.625), 0.001));
    });

    test('should detect silence correctly', () {
      final silentData = Float32List.fromList([0.01, -0.01, 0.005, -0.005]);
      final noisyData = Float32List.fromList([0.1, -0.2, 0.3, -0.4]);

      expect(AudioUtils.isSilent(silentData, threshold: 0.02), isTrue);
      expect(AudioUtils.isSilent(noisyData, threshold: 0.02), isFalse);
    });

    test('should apply window function correctly', () {
      final input = Float32List.fromList([1.0, 1.0, 1.0, 1.0]);
      final windowed = AudioUtils.applyWindow(input, WindowType.hann);

      // Hann window should reduce values at edges
      expect(windowed[0], lessThan(input[0]));
      expect(windowed[windowed.length - 1], lessThan(input[input.length - 1]));
    });

    test('should resample audio data', () {
      final input = Float32List.fromList([1.0, 2.0, 3.0, 4.0, 5.0, 6.0]);
      final resampled = AudioUtils.resample(input, 6000, 3000); // Downsample by 2

      expect(resampled.length, equals(3));
      expect(resampled[0], closeTo(1.0, 0.1));
      expect(resampled[1], closeTo(3.0, 0.1));
      expect(resampled[2], closeTo(5.0, 0.1));
    });

    test('should convert samples to decibels', () {
      final amplitude = 0.5;
      final db = AudioUtils.amplitudeToDb(amplitude);

      // 20 * log10(0.5) ≈ -6.02 dB
      expect(db, closeTo(-6.02, 0.1));
    });

    test('should detect audio onset', () {
      // Create audio with sudden amplitude increase
      final audioData = Float32List(1000);
      for (int i = 0; i < 500; i++) {
        audioData[i] = 0.01; // Quiet
      }
      for (int i = 500; i < 1000; i++) {
        audioData[i] = 0.5; // Loud
      }

      final onsets = AudioUtils.detectOnsets(audioData, sampleRate: 44100);

      expect(onsets, isNotEmpty);
      // Should detect onset around sample 500
      expect(onsets.first, greaterThan(400));
      expect(onsets.first, lessThan(600));
    });

    test('should calculate spectral centroid', () {
      final input = Float32List.fromList([1.0, 2.0, 3.0, 2.0, 1.0]);
      final centroid = AudioUtils.calculateSpectralCentroid(input);

      expect(centroid, greaterThan(0.0));
      expect(centroid, lessThan(1.0));
    });

    test('should apply preemphasis filter', () {
      final input = Float32List.fromList([1.0, 2.0, 3.0, 4.0, 5.0]);
      final filtered = AudioUtils.preEmphasis(input, coefficient: 0.97);

      expect(filtered.length, equals(input.length));
      expect(filtered[0], equals(input[0])); // First sample unchanged
    });
  });

  group('FrequencyUtils', () {
    test('should convert Hz to cents correctly', () {
      const a4Hz = 440.0;
      const a5Hz = 880.0; // One octave higher

      final cents = FrequencyUtils.hzToCents(a5Hz, referenceHz: a4Hz);

      expect(cents, closeTo(1200.0, 0.1)); // One octave = 1200 cents
    });

    test('should convert cents to Hz correctly', () {
      const a4Hz = 440.0;
      const cents = 1200.0; // One octave

      final hz = FrequencyUtils.centsToHz(cents, referenceHz: a4Hz);

      expect(hz, closeTo(880.0, 0.1)); // A5
    });

    test('should calculate semitone difference', () {
      const c4Hz = 261.63;
      const c5Hz = 523.25;

      final semitones = FrequencyUtils.calculateSemitones(c4Hz, c5Hz);

      expect(semitones, closeTo(12.0, 0.1)); // One octave = 12 semitones
    });

    test('should detect closest musical note', () {
      final note440 = FrequencyUtils.getClosestNote(440.0); // A4
      final note494 = FrequencyUtils.getClosestNote(493.88); // B4
      final note523 = FrequencyUtils.getClosestNote(523.25); // C5

      expect(note440.name, contains('A'));
      expect(note494.name, contains('B'));
      expect(note523.name, contains('C'));
    });

    test('should validate frequency range', () {
      expect(FrequencyUtils.isValidFrequency(440.0), isTrue);
      expect(FrequencyUtils.isValidFrequency(0.0), isFalse);
      expect(FrequencyUtils.isValidFrequency(-100.0), isFalse);
      expect(FrequencyUtils.isValidFrequency(double.infinity), isFalse);
      expect(FrequencyUtils.isValidFrequency(double.nan), isFalse);
    });
  });
}

// Mock utility classes for testing
class AudioUtils {
  static Float32List normalizeAudio(Float32List input) {
    if (input.isEmpty) return input;

    final maxVal = input.map((v) => v.abs()).reduce(math.max);
    if (maxVal == 0) return input;

    final result = Float32List(input.length);
    for (int i = 0; i < input.length; i++) {
      result[i] = input[i] / maxVal;
    }
    return result;
  }

  static double calculateRMS(Float32List input) {
    if (input.isEmpty) return 0.0;

    double sum = 0.0;
    for (final sample in input) {
      sum += sample * sample;
    }
    return math.sqrt(sum / input.length);
  }

  static bool isSilent(Float32List input, {double threshold = 0.01}) {
    final rms = calculateRMS(input);
    return rms < threshold;
  }

  static Float32List applyWindow(Float32List input, WindowType windowType) {
    final result = Float32List(input.length);
    final n = input.length;

    for (int i = 0; i < n; i++) {
      double window = 1.0;
      
      switch (windowType) {
        case WindowType.hann:
          window = 0.5 - 0.5 * math.cos(2 * math.pi * i / (n - 1));
          break;
        case WindowType.hamming:
          window = 0.54 - 0.46 * math.cos(2 * math.pi * i / (n - 1));
          break;
        case WindowType.blackman:
          window = 0.42 - 0.5 * math.cos(2 * math.pi * i / (n - 1)) +
                  0.08 * math.cos(4 * math.pi * i / (n - 1));
          break;
      }
      
      result[i] = input[i] * window;
    }

    return result;
  }

  static Float32List resample(Float32List input, int originalRate, int targetRate) {
    if (originalRate == targetRate) return input;

    final ratio = originalRate / targetRate;
    final outputLength = (input.length / ratio).round();
    final result = Float32List(outputLength);

    for (int i = 0; i < outputLength; i++) {
      final sourceIndex = (i * ratio).round();
      if (sourceIndex < input.length) {
        result[i] = input[sourceIndex];
      }
    }

    return result;
  }

  static double amplitudeToDb(double amplitude) {
    if (amplitude <= 0) return -double.infinity;
    return 20 * (math.log(amplitude) / math.ln10);
  }

  static List<int> detectOnsets(Float32List audioData, {required int sampleRate}) {
    final onsets = <int>[];
    const windowSize = 1024;
    const threshold = 0.1;

    for (int i = windowSize; i < audioData.length - windowSize; i += windowSize ~/ 2) {
      final prevWindow = audioData.sublist(i - windowSize, i);
      final currWindow = audioData.sublist(i, i + windowSize);

      final prevRms = calculateRMS(Float32List.fromList(prevWindow));
      final currRms = calculateRMS(Float32List.fromList(currWindow));

      if (currRms > prevRms + threshold && prevRms < 0.05) {
        onsets.add(i);
      }
    }

    return onsets;
  }

  static double calculateSpectralCentroid(Float32List input) {
    double weightedSum = 0.0;
    double magnitudeSum = 0.0;

    for (int i = 0; i < input.length; i++) {
      final magnitude = input[i].abs();
      weightedSum += magnitude * i;
      magnitudeSum += magnitude;
    }

    return magnitudeSum > 0 ? weightedSum / magnitudeSum / input.length : 0.0;
  }

  static Float32List preEmphasis(Float32List input, {double coefficient = 0.97}) {
    final result = Float32List(input.length);
    result[0] = input[0];

    for (int i = 1; i < input.length; i++) {
      result[i] = input[i] - coefficient * input[i - 1];
    }

    return result;
  }
}

class FrequencyUtils {
  static double hzToCents(double hz, {double referenceHz = 440.0}) {
    if (hz <= 0 || referenceHz <= 0) return 0.0;
    return 1200 * (math.log(hz / referenceHz) / math.ln2);
  }

  static double centsToHz(double cents, {double referenceHz = 440.0}) {
    return referenceHz * math.pow(2, cents / 1200);
  }

  static double calculateSemitones(double freq1, double freq2) {
    if (freq1 <= 0 || freq2 <= 0) return 0.0;
    return 12 * (math.log(freq2 / freq1) / math.ln2);
  }

  static MusicalNote getClosestNote(double frequency) {
    // Simplified note detection
    final noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final a4 = 440.0;
    final semitones = 12 * (math.log(frequency / a4) / math.ln2) + 9; // A4 is 9th semitone in octave starting from C
    
    final octave = 4 + (semitones / 12).floor();
    final noteIndex = (semitones % 12).round() % 12;
    
    return MusicalNote(
      name: '${noteNames[noteIndex]}$octave',
      frequency: frequency,
      cents: ((semitones % 1) * 100).round(),
    );
  }

  static bool isValidFrequency(double frequency) {
    return frequency > 0 && 
           frequency.isFinite && 
           !frequency.isNaN &&
           frequency < 20000; // Reasonable upper limit
  }
}

enum WindowType { hann, hamming, blackman }

class MusicalNote {
  final String name;
  final double frequency;
  final int cents;

  MusicalNote({
    required this.name,
    required this.frequency,
    required this.cents,
  });

  @override
  String toString() => 'MusicalNote(name: $name, frequency: $frequency, cents: $cents)';
}