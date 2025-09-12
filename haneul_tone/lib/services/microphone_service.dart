import 'dart:async';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import '../utils/fft_utils.dart';
import 'fft_worker.dart';
import 'package:audio_session/audio_session.dart';
import '../utils/note_utils.dart';

class MicrophoneService {
  static final MicrophoneService _instance = MicrophoneService._internal();
  factory MicrophoneService() => _instance;
  MicrophoneService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  StreamController<double>? _pitchController;
  StreamController<List<double>>? _audioDataController;
  Timer? _analysisTimer;
  
  bool _isRecording = false;
  bool _isAnalyzing = false;
  List<double> _audioBuffer = [];
  
  // 설정값
  static const int sampleRate = 44100;
  static const int bufferSize = 4096;
  static const int analysisInterval = 100; // 100ms마다 분석
  static const double minFreq = 80.0;
  static const double maxFreq = 2000.0;
  
  // 스트림 getter
  Stream<double> get pitchStream => _pitchController?.stream ?? const Stream.empty();
  Stream<List<double>> get audioDataStream => _audioDataController?.stream ?? const Stream.empty();
  
  bool get isRecording => _isRecording;
  bool get isAnalyzing => _isAnalyzing;

  // 마이크 권한 확인 및 요청
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      
      if (status.isDenied) {
        final result = await Permission.microphone.request();
        return result.isGranted;
      }
      
      return status.isGranted;
    } catch (e) {
      print('권한 요청 오류: $e');
      return false;
    }
  }

  // 호환성을 위한 별칭
  Future<bool> requestPermission() async {
    return await requestMicrophonePermission();
  }
  
  // 마이크 사용 가능 여부 확인
  Future<bool> isMicrophoneAvailable() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      print('마이크 사용 가능 여부 확인 오류: $e');
      return false;
    }
  }
  
  // 실시간 피치 분석 시작
  Future<bool> startRealtimeAnalysis() async {
    try {
      if (_isRecording) {
        print('이미 녹음 중입니다');
        return false;
      }
      
      // 권한 확인
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        print('마이크 권한이 필요합니다');
        return false;
      }
      
      // Audio Session 설정 (플랫폼별 오디오 최적화)
      try {
        final session = await AudioSession.instance;
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.record,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth | 
                                        AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.measurement,
          avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            flags: AndroidAudioFlags.audibilityEnforced,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ));
        print('Audio Session 설정 완료');
      } catch (e) {
        print('Audio Session 설정 오류 (계속 진행): $e');
      }
      
      // 스트림 컨트롤러 초기화
      _pitchController = StreamController<double>.broadcast();
      _audioDataController = StreamController<List<double>>.broadcast();
      
      // 임시 파일 경로 생성
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/realtime_audio.wav';
      
      // 녹음 설정
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: sampleRate,
        bitRate: 128000,
        numChannels: 1,
      );
      
      // 녹음 시작
      await _recorder.start(config, path: filePath);
      _isRecording = true;
      _isAnalyzing = true;
      _audioBuffer.clear();
      
      print('실시간 피치 분석 시작');
      
      // 주기적 분석 시작
      _startPeriodicAnalysis(filePath);
      
      return true;
    } catch (e) {
      print('실시간 분석 시작 오류: $e');
      await stopRealtimeAnalysis();
      return false;
    }
  }
  
  // 주기적 오디오 분석
  void _startPeriodicAnalysis(String filePath) {
    _analysisTimer = Timer.periodic(
      Duration(milliseconds: analysisInterval), 
      (timer) async {
        if (!_isRecording || !_isAnalyzing) {
          timer.cancel();
          return;
        }
        
        try {
          // 현재까지 녹음된 데이터 분석
          await _analyzeCurrentAudio(filePath);
        } catch (e) {
          print('주기적 분석 오류: $e');
        }
      }
    );
  }
  
  // 현재 피치 정보 가져오기 (실시간 분석용)
  Map<String, dynamic>? getCurrentPitchInfo() {
    try {
      // 시뮬레이션된 실시간 데이터 생성
      final frequency = _getSimulatedPitch();
      
      return {
        'frequency': frequency,
        'amplitude': 0.5, // 시뮬레이션
        'confidence': frequency > 0 ? 0.8 : 0.0,
      };
    } catch (e) {
      print('현재 피치 정보 오류: $e');
      return null;
    }
  }

  // 시뮬레이션된 피치 값 생성
  double _getSimulatedPitch() {
    final random = math.Random();
    if (random.nextBool()) {
      return 220.0 + random.nextDouble() * 220.0; // A3-A4 범위
    }
    return 0.0; // 무음
  }
  
  // 현재 오디오 데이터 분석
  Future<void> _analyzeCurrentAudio(String filePath) async {
    try {
      // 실제 구현에서는 녹음된 파일에서 최근 데이터를 읽어야 함
      // 현재는 시뮬레이션된 데이터로 테스트
      final simulatedData = _generateRealtimeTestData();
      
      if (simulatedData.length >= bufferSize) {
        // 최근 버퍼 크기만큼 데이터 사용
        final analysisData = simulatedData.sublist(
          math.max(0, simulatedData.length - bufferSize)
        );
        
        // 피치 추출
        final pitch = await _extractPitchFromBuffer(analysisData);
        
        // 스트림으로 데이터 전송
        _pitchController?.add(pitch);
        _audioDataController?.add(analysisData);
      }
    } catch (e) {
      print('현재 오디오 분석 오류: $e');
    }
  }
  
  // 버퍼에서 피치 추출 (Isolate 기반)
  Future<double> _extractPitchFromBuffer(List<double> audioData) async {
    try {
      if (audioData.length < 512) {
        return 0.0; // 데이터가 부족하면 무음으로 처리
      }
      
      // Isolate worker를 사용한 비동기 피치 분석 (UI 스레드 차단 방지)
      final pitch = await computePitch(
        audioData,
        sampleRate.toDouble(),
        minFreq: minFreq,
        maxFreq: maxFreq,
      );
      
      return pitch;
    } catch (e) {
      print('피치 추출 오류: $e');
      return 0.0;
    }
  }
  
  // 실시간 테스트 데이터 생성 (실제 구현에서는 불필요)
  List<double> _generateRealtimeTestData() {
    final random = math.Random();
    final testFreq = 220.0 + random.nextDouble() * 220.0; // A3-A4 범위
    final testData = <double>[];
    
    for (int i = 0; i < bufferSize; i++) {
      final t = i / sampleRate.toDouble();
      final amplitude = 0.1 + random.nextDouble() * 0.2;
      final noise = (random.nextDouble() - 0.5) * 0.02;
      
      final value = amplitude * math.sin(2 * math.pi * testFreq * t) + noise;
      testData.add(value);
    }
    
    return testData;
  }
  
  // 실시간 분석 중지
  Future<void> stopRealtimeAnalysis() async {
    try {
      _isAnalyzing = false;
      
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
      }
      
      _analysisTimer?.cancel();
      _analysisTimer = null;
      
      await _pitchController?.close();
      await _audioDataController?.close();
      _pitchController = null;
      _audioDataController = null;
      
      _audioBuffer.clear();
      
      print('실시간 피치 분석 중지');
    } catch (e) {
      print('실시간 분석 중지 오류: $e');
    }
  }
  
  // 현재 피치를 음계로 변환
  String pitchToNoteName(double frequency, double a4Freq) {
    if (frequency <= 0) return '';
    return NoteUtils.frequencyToNoteName(frequency, a4Freq);
  }
  
  // 피치 정확도 계산 (센트 단위)
  double calculatePitchAccuracy(double actualFreq, double targetFreq) {
    if (actualFreq <= 0 || targetFreq <= 0) return 0.0;
    return NoteUtils.calculateCents(actualFreq, targetFreq);
  }
  
  // 음성 활동 감지 (Voice Activity Detection)
  bool detectVoiceActivity(List<double> audioData, {double threshold = 0.01}) {
    if (audioData.isEmpty) return false;
    
    // RMS (Root Mean Square) 계산
    double sumSquares = 0.0;
    for (final sample in audioData) {
      sumSquares += sample * sample;
    }
    final rms = math.sqrt(sumSquares / audioData.length);
    
    return rms > threshold;
  }
  
  // 피치 안정성 계산
  double calculatePitchStability(List<double> recentPitches) {
    if (recentPitches.length < 2) return 0.0;
    
    final validPitches = recentPitches.where((p) => p > 0).toList();
    if (validPitches.length < 2) return 0.0;
    
    // 표준편차 계산
    final mean = validPitches.reduce((a, b) => a + b) / validPitches.length;
    final variance = validPitches
        .map((p) => math.pow(p - mean, 2))
        .reduce((a, b) => a + b) / validPitches.length;
    final stdDev = math.sqrt(variance);
    
    // 안정성 점수 (표준편차가 작을수록 높은 점수)
    return math.max(0.0, 1.0 - (stdDev / mean));
  }
  
  // 리소스 정리
  Future<void> dispose() async {
    await stopRealtimeAnalysis();
    await _recorder.dispose();
  }
}
