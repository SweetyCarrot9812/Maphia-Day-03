import 'dart:math' as math;

class Complex {
  final double real;
  final double imag;
  
  const Complex(this.real, this.imag);
  
  Complex operator +(Complex other) => Complex(real + other.real, imag + other.imag);
  Complex operator -(Complex other) => Complex(real - other.real, imag - other.imag);
  Complex operator *(Complex other) => 
    Complex(real * other.real - imag * other.imag, real * other.imag + imag * other.real);
    
  double get magnitude => math.sqrt(real * real + imag * imag);
  double get phase => math.atan2(imag, real);
  
  @override
  String toString() => '${real.toStringAsFixed(3)} + ${imag.toStringAsFixed(3)}i';
}

class FFTUtils {
  // Cooley-Tukey FFT implementation
  static List<Complex> fft(List<Complex> x) {
    final n = x.length;
    if (n <= 1) return x;
    
    // Ensure power of 2
    if (n & (n - 1) != 0) {
      throw ArgumentError('FFT input size must be power of 2');
    }
    
    // Divide
    final even = <Complex>[];
    final odd = <Complex>[];
    
    for (int i = 0; i < n; i += 2) {
      even.add(x[i]);
      if (i + 1 < n) {
        odd.add(x[i + 1]);
      }
    }
    
    // Conquer
    final evenFft = fft(even);
    final oddFft = fft(odd);
    
    // Combine
    final result = List<Complex>.filled(n, const Complex(0, 0));
    final halfN = n ~/ 2;
    
    for (int k = 0; k < halfN; k++) {
      final t = Complex(
        math.cos(-2 * math.pi * k / n),
        math.sin(-2 * math.pi * k / n)
      ) * oddFft[k];
      
      result[k] = evenFft[k] + t;
      result[k + halfN] = evenFft[k] - t;
    }
    
    return result;
  }
  
  // Real FFT for audio data
  static List<Complex> realFft(List<double> realData) {
    // Pad to next power of 2
    final paddedSize = _nextPowerOfTwo(realData.length);
    final complexData = List<Complex>.generate(paddedSize, (i) => 
      i < realData.length ? Complex(realData[i], 0.0) : const Complex(0.0, 0.0)
    );
    
    return fft(complexData);
  }
  
  // Find next power of 2
  static int _nextPowerOfTwo(int n) {
    int power = 1;
    while (power < n) {
      power <<= 1;
    }
    return power;
  }
  
  // Window functions for reducing spectral leakage
  static List<double> hanningWindow(int size) {
    return List<double>.generate(size, (i) => 
      0.5 * (1 - math.cos(2 * math.pi * i / (size - 1)))
    );
  }
  
  static List<double> hammingWindow(int size) {
    return List<double>.generate(size, (i) =>
      0.54 - 0.46 * math.cos(2 * math.pi * i / (size - 1))
    );
  }
  
  // Apply window to signal
  static List<double> applyWindow(List<double> signal, List<double> window) {
    if (signal.length != window.length) {
      throw ArgumentError('Signal and window must have same length');
    }
    
    return List<double>.generate(signal.length, (i) => signal[i] * window[i]);
  }
  
  // Find fundamental frequency from FFT magnitude spectrum
  static double findFundamentalFrequency(
    List<Complex> fftResult, 
    double sampleRate,
    {double minFreq = 80.0, double maxFreq = 2000.0}
  ) {
    final magnitudes = fftResult.map((c) => c.magnitude).toList();
    final n = magnitudes.length;
    
    // Convert frequency range to bin indices
    final minBin = ((minFreq * n) / sampleRate).round().clamp(1, n ~/ 2);
    final maxBin = ((maxFreq * n) / sampleRate).round().clamp(minBin, n ~/ 2);
    
    // Find peak in frequency range
    double maxMagnitude = 0.0;
    int peakBin = minBin;
    
    for (int i = minBin; i < maxBin; i++) {
      if (magnitudes[i] > maxMagnitude) {
        maxMagnitude = magnitudes[i];
        peakBin = i;
      }
    }
    
    // Convert bin back to frequency
    return (peakBin * sampleRate) / n;
  }
  
  // Autocorrelation-based pitch detection (YIN algorithm simplified)
  static double findPitchAutocorrelation(
    List<double> signal,
    double sampleRate,
    {double minFreq = 80.0, double maxFreq = 2000.0}
  ) {
    final minPeriod = (sampleRate / maxFreq).round();
    final maxPeriod = (sampleRate / minFreq).round().clamp(minPeriod, signal.length ~/ 2);
    
    // Calculate autocorrelation
    double bestCorrelation = -1.0;
    int bestPeriod = minPeriod;
    
    for (int period = minPeriod; period <= maxPeriod; period++) {
      double correlation = 0.0;
      double energy1 = 0.0;
      double energy2 = 0.0;
      
      final compareLength = signal.length - period;
      for (int i = 0; i < compareLength; i++) {
        correlation += signal[i] * signal[i + period];
        energy1 += signal[i] * signal[i];
        energy2 += signal[i + period] * signal[i + period];
      }
      
      // Normalized correlation
      final normalizedCorrelation = correlation / math.sqrt(energy1 * energy2);
      
      if (normalizedCorrelation > bestCorrelation) {
        bestCorrelation = normalizedCorrelation;
        bestPeriod = period;
      }
    }
    
    // Return frequency
    return bestCorrelation > 0.3 ? sampleRate / bestPeriod : 0.0;
  }
  
  // Short-time Fourier Transform for time-frequency analysis
  static List<List<Complex>> stft(
    List<double> signal,
    int windowSize,
    int hopSize,
    {String windowType = 'hanning'}
  ) {
    final window = windowType == 'hamming' 
      ? hammingWindow(windowSize)
      : hanningWindow(windowSize);
      
    final results = <List<Complex>>[];
    
    for (int i = 0; i + windowSize <= signal.length; i += hopSize) {
      final frame = signal.sublist(i, i + windowSize);
      final windowedFrame = applyWindow(frame, window);
      final fftFrame = realFft(windowedFrame);
      results.add(fftFrame);
    }
    
    return results;
  }
  
  // Convert magnitude spectrum to decibels
  static List<double> magnitudeToDb(List<double> magnitudes) {
    return magnitudes.map((mag) => 
      mag > 0 ? 20 * math.log(mag) / math.ln10 : -80.0
    ).toList();
  }
  
  // Zero-padding for better frequency resolution
  static List<double> zeroPad(List<double> signal, int targetSize) {
    if (signal.length >= targetSize) return signal;
    
    final padded = List<double>.filled(targetSize, 0.0);
    for (int i = 0; i < signal.length; i++) {
      padded[i] = signal[i];
    }
    return padded;
  }
}