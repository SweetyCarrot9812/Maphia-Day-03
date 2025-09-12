import 'dart:math' as math;
import 'dart:typed_data';
import 'pitch_frame.dart';
import 'pitch_engine.dart';
import 'window_functions.dart';

/// FFT 기반 피치 추정 알고리즘 구현
/// 
/// HaneulTone v1 고도화 - 스펙트럼 분석을 통한 피치 추정
/// 
/// Features:
/// - 파라볼라 보간을 통한 정밀 주파수 추정
/// - 하모닉 분석을 통한 confidence 계산
/// - 적응형 임계값을 이용한 피크 검출
class FftEstimator implements PitchEngine {
  final double _minFreq;
  final double _maxFreq;
  final int _fftSize;
  final double _peakThreshold;
  
  /// FFT 생성자
  /// 
  /// [minFreq]: 최소 주파수 (Hz)
  /// [maxFreq]: 최대 주파수 (Hz) 
  /// [fftSize]: FFT 크기 (2의 거듭제곱, 기본값은 프레임 크기의 2배)
  /// [peakThreshold]: 피크 검출 임계값 (-40dB 권장)
  FftEstimator({
    double minFreq = 70.0,
    double maxFreq = 1000.0,
    int? fftSize,
    double peakThreshold = -40.0,
  }) : _minFreq = minFreq,
       _maxFreq = maxFreq,
       _fftSize = fftSize ?? _getNextPowerOfTwo((24000 * 0.04).round()) * 2,
       _peakThreshold = peakThreshold;

  @override
  String get engineName => 'FFT';

  @override
  double get minFreqHz => _minFreq;

  @override
  double get maxFreqHz => _maxFreq;

  @override
  int get preferredSampleRate => 24000;

  @override
  int get frameSize => (preferredSampleRate * 0.04).round();

  @override
  int get hopSize => (preferredSampleRate * 0.01).round();

  @override
  WindowType get windowType => WindowType.hann;

  /// 다음 2의 거듭제곱 계산
  static int _getNextPowerOfTwo(int n) {
    return math.pow(2, (math.log(n) / math.ln2).ceil()).toInt();
  }

  @override
  Future<List<PitchFrame>> estimate(Float32List pcm, int sampleRate) async {
    final frames = <PitchFrame>[];
    final windowSize = frameSize;
    final hopLength = hopSize;
    final numFrames = ((pcm.length - windowSize) / hopLength).floor() + 1;

    // 윈도우 함수 미리 계산
    final window = WindowFunctions.hann(windowSize);
    final coherentGain = WindowFunctions.coherentGain(WindowType.hann, windowSize);

    for (int frameIdx = 0; frameIdx < numFrames; frameIdx++) {
      final startSample = frameIdx * hopLength;
      final endSample = math.min(startSample + windowSize, pcm.length);
      
      if (endSample - startSample < windowSize) break;

      // 프레임 추출 및 윈도잉
      final frame = Float32List.sublistView(pcm, startSample, endSample);
      final windowedFrame = Float32List.fromList(frame);
      WindowFunctions.applyWindow(windowedFrame, window);

      // FFT 스펙트럼 계산
      final spectrum = _computeSpectrum(windowedFrame, sampleRate);
      
      // 피치 추정
      final fftResult = _estimatePitch(spectrum, sampleRate);
      
      final timeMs = (startSample / sampleRate) * 1000.0;
      final pitchFrame = PitchFrame(
        timeMs: timeMs,
        f0Hz: fftResult.f0Hz,
        cents: PitchFrame.hzToCents(fftResult.f0Hz),
        voicingProb: fftResult.voicingProb,
        confidence: fftResult.confidence,
      );

      frames.add(pitchFrame);
    }

    return frames;
  }

  /// 스펙트럼 크기 계산 (FFT → magnitude spectrum)
  _SpectrumResult _computeSpectrum(Float32List windowedFrame, int sampleRate) {
    // Zero-padding to FFT size
    final paddedFrame = Float32List(_fftSize);
    final frameLength = windowedFrame.length;
    
    for (int i = 0; i < frameLength; i++) {
      paddedFrame[i] = windowedFrame[i];
    }
    // 나머지는 0으로 채워짐 (zero-padding)

    // FFT 계산 (순수 Dart 구현)
    final fftResult = _fft(paddedFrame);
    
    // 크기 스펙트럼 계산 (DC부터 Nyquist까지만)
    final spectrumSize = _fftSize ~/ 2 + 1;
    final magnitudes = Float32List(spectrumSize);
    final phases = Float32List(spectrumSize);
    
    for (int i = 0; i < spectrumSize; i++) {
      final real = fftResult.real[i];
      final imag = fftResult.imaginary[i];
      magnitudes[i] = math.sqrt(real * real + imag * imag);
      phases[i] = math.atan2(imag, real);
    }

    return _SpectrumResult(
      magnitudes: magnitudes,
      phases: phases,
      sampleRate: sampleRate,
      fftSize: _fftSize,
    );
  }

  /// 스펙트럼에서 피치 추정
  _FftResult _estimatePitch(_SpectrumResult spectrum, int sampleRate) {
    final magnitudes = spectrum.magnitudes;
    final binResolution = sampleRate / _fftSize.toDouble();
    
    // 주파수 범위를 bin 인덱스로 변환
    final minBin = (_minFreq / binResolution).round();
    final maxBin = math.min((_maxFreq / binResolution).round(), magnitudes.length - 1);
    
    if (minBin >= maxBin || maxBin >= magnitudes.length) {
      return _FftResult(f0Hz: 0.0, voicingProb: 0.0, confidence: 0.0);
    }

    // 피크 검출을 위한 적응형 임계값 계산
    final threshold = _computeAdaptiveThreshold(magnitudes, minBin, maxBin);
    
    // 피크 검출
    final peaks = _findPeaks(magnitudes, minBin, maxBin, threshold);
    
    if (peaks.isEmpty) {
      return _FftResult(f0Hz: 0.0, voicingProb: 0.0, confidence: 0.0);
    }

    // 하모닉 분석을 통한 기본 주파수 추정
    final fundamentalResult = _findFundamentalFrequency(peaks, magnitudes, binResolution);
    
    if (fundamentalResult.binIndex == -1) {
      return _FftResult(f0Hz: 0.0, voicingProb: 0.0, confidence: 0.0);
    }

    // 파라볼라 보간을 통한 정밀 주파수 추정
    final preciseFreq = _parabolicInterpolation(
      magnitudes,
      fundamentalResult.binIndex,
      binResolution,
    );

    // 신뢰도 및 유성음 확률 계산
    final voicingProb = _computeVoicingProbability(
      magnitudes,
      fundamentalResult.binIndex,
      fundamentalResult.harmonicStrength,
      threshold,
    );
    
    final confidence = _computeFftConfidence(voicingProb, preciseFreq);

    return _FftResult(
      f0Hz: preciseFreq,
      voicingProb: voicingProb,
      confidence: confidence,
    );
  }

  /// 적응형 임계값 계산
  double _computeAdaptiveThreshold(Float32List magnitudes, int minBin, int maxBin) {
    // 관심 구간의 통계 계산
    double sum = 0.0;
    double sumSquared = 0.0;
    int count = 0;

    for (int i = minBin; i <= maxBin; i++) {
      final mag = magnitudes[i];
      sum += mag;
      sumSquared += mag * mag;
      count++;
    }

    if (count == 0) return 0.0;

    final mean = sum / count;
    final variance = (sumSquared / count) - (mean * mean);
    final stdDev = math.sqrt(math.max(0.0, variance));

    // 평균 + 2*표준편차를 기본 임계값으로 설정
    final adaptiveThreshold = mean + 2.0 * stdDev;
    
    // 최소 임계값 적용 (매우 조용한 신호에 대한 보호)
    final minThreshold = mean * 1.5;
    
    return math.max(adaptiveThreshold, minThreshold);
  }

  /// 피크 검출
  List<_Peak> _findPeaks(Float32List magnitudes, int minBin, int maxBin, double threshold) {
    final peaks = <_Peak>[];
    
    for (int i = minBin + 1; i < maxBin; i++) {
      final current = magnitudes[i];
      final prev = magnitudes[i - 1];
      final next = magnitudes[i + 1];
      
      // 지역 최대값이고 임계값을 넘는 경우
      if (current > prev && current > next && current > threshold) {
        peaks.add(_Peak(binIndex: i, magnitude: current));
      }
    }

    // 크기 순으로 정렬
    peaks.sort((a, b) => b.magnitude.compareTo(a.magnitude));
    
    return peaks;
  }

  /// 하모닉 분석을 통한 기본 주파수 추정
  _FundamentalResult _findFundamentalFrequency(
    List<_Peak> peaks,
    Float32List magnitudes,
    double binResolution,
  ) {
    if (peaks.isEmpty) {
      return _FundamentalResult(binIndex: -1, harmonicStrength: 0.0);
    }

    double bestScore = 0.0;
    int bestBinIndex = -1;
    double bestHarmonicStrength = 0.0;

    // 각 피크를 기본 주파수 후보로 고려
    for (final peak in peaks.take(math.min(10, peaks.length))) {
      final candidateBin = peak.binIndex;
      final candidateFreq = candidateBin * binResolution;
      
      // 하모닉 강도 계산
      final harmonicStrength = _calculateHarmonicStrength(
        magnitudes,
        candidateBin,
        binResolution,
      );
      
      // 점수 = 기본 주파수 크기 * 하모닉 강도
      final score = peak.magnitude * harmonicStrength;
      
      if (score > bestScore) {
        bestScore = score;
        bestBinIndex = candidateBin;
        bestHarmonicStrength = harmonicStrength;
      }
    }

    return _FundamentalResult(
      binIndex: bestBinIndex,
      harmonicStrength: bestHarmonicStrength,
    );
  }

  /// 하모닉 강도 계산
  double _calculateHarmonicStrength(
    Float32List magnitudes,
    int fundamentalBin,
    double binResolution,
  ) {
    final fundamentalFreq = fundamentalBin * binResolution;
    double totalHarmonicEnergy = 0.0;
    double fundamentalEnergy = magnitudes[fundamentalBin];
    int validHarmonics = 0;

    // 2배음부터 8배음까지 검사
    for (int harmonic = 2; harmonic <= 8; harmonic++) {
      final harmonicFreq = fundamentalFreq * harmonic;
      final harmonicBin = (harmonicFreq / binResolution).round();
      
      if (harmonicBin >= magnitudes.length) break;
      
      // 하모닉 주변 ±1 bin에서 최대값 찾기 (주파수 변동 고려)
      double maxHarmonicMagnitude = 0.0;
      for (int offset = -1; offset <= 1; offset++) {
        final bin = harmonicBin + offset;
        if (bin >= 0 && bin < magnitudes.length) {
          maxHarmonicMagnitude = math.max(maxHarmonicMagnitude, magnitudes[bin]);
        }
      }
      
      totalHarmonicEnergy += maxHarmonicMagnitude;
      validHarmonics++;
    }

    if (validHarmonics == 0) return 0.0;

    // 하모닉 강도 = 하모닉 에너지 / 기본 주파수 에너지
    return totalHarmonicEnergy / (fundamentalEnergy * validHarmonics);
  }

  /// 파라볼라 보간을 통한 정밀 주파수 추정
  double _parabolicInterpolation(
    Float32List magnitudes,
    int peakBin,
    double binResolution,
  ) {
    if (peakBin <= 0 || peakBin >= magnitudes.length - 1) {
      return peakBin * binResolution;
    }

    final y1 = magnitudes[peakBin - 1];
    final y2 = magnitudes[peakBin];
    final y3 = magnitudes[peakBin + 1];

    // 파라볼라 보간: x = -b/2a where y = ax² + bx + c
    final denominator = y1 - 2 * y2 + y3;
    
    if (denominator.abs() < 1e-10) {
      return peakBin * binResolution; // 거의 평평한 경우
    }

    final offset = 0.5 * (y1 - y3) / denominator;
    final interpolatedBin = peakBin + math.max(-0.5, math.min(0.5, offset));
    
    return interpolatedBin * binResolution;
  }

  /// 유성음 확률 계산
  double _computeVoicingProbability(
    Float32List magnitudes,
    int fundamentalBin,
    double harmonicStrength,
    double threshold,
  ) {
    final fundamentalMagnitude = magnitudes[fundamentalBin];
    
    // 1. 기본 주파수 크기 기반 확률
    final magnitudeProb = math.min(1.0, fundamentalMagnitude / (threshold * 2.0));
    
    // 2. 하모닉 구조 기반 확률
    final harmonicProb = math.min(1.0, harmonicStrength);
    
    // 3. 종합 확률 (가중 평균)
    return 0.6 * magnitudeProb + 0.4 * harmonicProb;
  }

  /// FFT 신뢰도 계산
  double _computeFftConfidence(double voicingProb, double f0Hz) {
    if (f0Hz < _minFreq || f0Hz > _maxFreq) return 0.0;
    
    // 주파수 범위별 가중치
    double freqWeight = 1.0;
    if (f0Hz < 100 || f0Hz > 600) {
      freqWeight = 0.8; // 경계 영역
    }
    
    return voicingProb * freqWeight;
  }

  /// 간단한 FFT 구현 (Cooley-Tukey 알고리즘)
  _ComplexArray _fft(Float32List real) {
    final n = real.length;
    if (n <= 1) {
      return _ComplexArray(
        real: Float32List.fromList(real),
        imaginary: Float32List(n),
      );
    }

    // Bit-reversal permutation
    final realCopy = Float32List.fromList(real);
    final imaginary = Float32List(n);
    
    _bitReversalPermutation(realCopy, imaginary, n);

    // FFT computation
    for (int size = 2; size <= n; size *= 2) {
      final halfSize = size ~/ 2;
      final step = 2 * math.pi / size;
      
      for (int i = 0; i < n; i += size) {
        for (int j = 0; j < halfSize; j++) {
          final u = i + j;
          final v = u + halfSize;
          
          final angle = -j * step;
          final cos = math.cos(angle);
          final sin = math.sin(angle);
          
          final tempReal = realCopy[v] * cos - imaginary[v] * sin;
          final tempImag = realCopy[v] * sin + imaginary[v] * cos;
          
          realCopy[v] = realCopy[u] - tempReal;
          imaginary[v] = imaginary[u] - tempImag;
          
          realCopy[u] += tempReal;
          imaginary[u] += tempImag;
        }
      }
    }

    return _ComplexArray(real: realCopy, imaginary: imaginary);
  }

  /// Bit-reversal permutation for FFT
  void _bitReversalPermutation(Float32List real, Float32List imaginary, int n) {
    final logN = (math.log(n) / math.ln2).round();
    
    for (int i = 0; i < n; i++) {
      int reversed = 0;
      int temp = i;
      
      for (int bit = 0; bit < logN; bit++) {
        reversed = (reversed << 1) | (temp & 1);
        temp >>= 1;
      }
      
      if (i < reversed) {
        // Swap
        final tempReal = real[i];
        real[i] = real[reversed];
        real[reversed] = tempReal;
        
        final tempImag = imaginary[i];
        imaginary[i] = imaginary[reversed];
        imaginary[reversed] = tempImag;
      }
    }
  }
}

/// FFT 결과를 담는 복소수 배열
class _ComplexArray {
  final Float32List real;
  final Float32List imaginary;

  _ComplexArray({required this.real, required this.imaginary});
}

/// 스펙트럼 분석 결과
class _SpectrumResult {
  final Float32List magnitudes;
  final Float32List phases;
  final int sampleRate;
  final int fftSize;

  _SpectrumResult({
    required this.magnitudes,
    required this.phases,
    required this.sampleRate,
    required this.fftSize,
  });
}

/// FFT 피치 추정 결과
class _FftResult {
  final double f0Hz;
  final double voicingProb;
  final double confidence;

  _FftResult({
    required this.f0Hz,
    required this.voicingProb,
    required this.confidence,
  });
}

/// 스펙트럼 피크
class _Peak {
  final int binIndex;
  final double magnitude;

  _Peak({required this.binIndex, required this.magnitude});
}

/// 기본 주파수 추정 결과
class _FundamentalResult {
  final int binIndex;
  final double harmonicStrength;

  _FundamentalResult({
    required this.binIndex,
    required this.harmonicStrength,
  });
}