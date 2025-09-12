import 'package:flutter/foundation.dart';
import '../utils/fft_utils.dart';

// Payload for isolate compute
class _PitchArgs {
  final List<double> audioData;
  final double sampleRate;
  final double minFreq;
  final double maxFreq;
  const _PitchArgs(this.audioData, this.sampleRate, this.minFreq, this.maxFreq);
}

Future<double> _pitchWorker(_PitchArgs args) async {
  if (args.audioData.length < 512) return 0.0;
  final window = FFTUtils.hanningWindow(args.audioData.length);
  final windowedData = FFTUtils.applyWindow(args.audioData, window);

  final fftResult = FFTUtils.realFft(windowedData);
  final pitch = FFTUtils.findFundamentalFrequency(
    fftResult,
    args.sampleRate,
    minFreq: args.minFreq,
    maxFreq: args.maxFreq,
  );

  final autocorrPitch = FFTUtils.findPitchAutocorrelation(
    windowedData,
    args.sampleRate,
    minFreq: args.minFreq,
    maxFreq: args.maxFreq,
  );

  if ((pitch - autocorrPitch).abs() < 10.0 && pitch > 0 && autocorrPitch > 0) {
    return (pitch + autocorrPitch) / 2.0;
  } else if (pitch > 0) {
    return pitch;
  } else if (autocorrPitch > 0) {
    return autocorrPitch;
  }
  return 0.0;
}

Future<double> computePitch(List<double> audioData, double sampleRate,
    {double minFreq = 80.0, double maxFreq = 2000.0}) {
  return compute<_PitchArgs, double>(
    _pitchWorker,
    _PitchArgs(audioData, sampleRate, minFreq, maxFreq),
  );
}

