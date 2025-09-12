import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}

class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  RecordingState _state = RecordingState.idle;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  // 스트림 컨트롤러
  final StreamController<RecordingState> _stateController = 
      StreamController<RecordingState>.broadcast();
  final StreamController<Duration> _durationController = 
      StreamController<Duration>.broadcast();
  final StreamController<double> _amplitudeController = 
      StreamController<double>.broadcast();

  // Getters
  RecordingState get state => _state;
  String? get currentRecordingPath => _currentRecordingPath;
  Duration get recordingDuration => _recordingDuration;

  // Streams
  Stream<RecordingState> get stateStream => _stateController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  // 권한 확인 (웹에서는 브라우저 권한 사용)
  Future<bool> hasPermission() async {
    try {
      // 웹 환경에서는 MediaDevices.getUserMedia를 통해 권한 확인
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // 데스크톱 환경에서는 일반적으로 권한이 있다고 가정
        return true;
      }
      
      // TODO: 실제 권한 확인 로직 구현 (record 패키지 등 사용)
      return true;
    } catch (e) {
      return false;
    }
  }

  // 권한 요청
  Future<bool> requestPermission() async {
    try {
      // TODO: 실제 권한 요청 로직 구현
      return await hasPermission();
    } catch (e) {
      return false;
    }
  }

  // 녹음 시작
  Future<bool> startRecording() async {
    if (_state == RecordingState.recording) return false;

    try {
      final hasPermissions = await hasPermission();
      if (!hasPermissions) {
        final permissionGranted = await requestPermission();
        if (!permissionGranted) return false;
      }

      // 녹음 파일 경로 생성
      _currentRecordingPath = await _generateRecordingPath();
      
      // TODO: 실제 녹음 시작 로직
      // await _recorder.startRecorder(toFile: _currentRecordingPath);
      
      _recordingStartTime = DateTime.now();
      _recordingDuration = Duration.zero;
      _setState(RecordingState.recording);
      _startTimer();

      return true;
    } catch (e) {
      print('Recording start error: $e');
      return false;
    }
  }

  // 녹음 정지
  Future<String?> stopRecording() async {
    if (_state != RecordingState.recording && _state != RecordingState.paused) {
      return null;
    }

    try {
      // TODO: 실제 녹음 정지 로직
      // await _recorder.stopRecorder();
      
      _stopTimer();
      _setState(RecordingState.stopped);
      
      final recordingPath = _currentRecordingPath;
      _currentRecordingPath = null;
      _recordingStartTime = null;

      return recordingPath;
    } catch (e) {
      print('Recording stop error: $e');
      return null;
    }
  }

  // 녹음 일시정지
  Future<bool> pauseRecording() async {
    if (_state != RecordingState.recording) return false;

    try {
      // TODO: 실제 일시정지 로직
      // await _recorder.pauseRecorder();
      
      _stopTimer();
      _setState(RecordingState.paused);
      return true;
    } catch (e) {
      print('Recording pause error: $e');
      return false;
    }
  }

  // 녹음 재개
  Future<bool> resumeRecording() async {
    if (_state != RecordingState.paused) return false;

    try {
      // TODO: 실제 재개 로직
      // await _recorder.resumeRecorder();
      
      _setState(RecordingState.recording);
      _startTimer();
      return true;
    } catch (e) {
      print('Recording resume error: $e');
      return false;
    }
  }

  // 녹음 취소
  Future<void> cancelRecording() async {
    if (_state == RecordingState.idle) return;

    try {
      // TODO: 실제 취소 로직
      // await _recorder.stopRecorder();
      
      _stopTimer();
      
      // 녹음 파일이 있다면 삭제
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _currentRecordingPath = null;
      _recordingStartTime = null;
      _recordingDuration = Duration.zero;
      _setState(RecordingState.idle);
    } catch (e) {
      print('Recording cancel error: $e');
    }
  }

  // 현재 녹음 레벨 가져오기 (데시벨)
  Future<double> getCurrentAmplitude() async {
    if (_state != RecordingState.recording) return 0.0;

    try {
      // TODO: 실제 진폭 측정 로직
      // final amplitude = await _recorder.getAmplitude();
      // return amplitude.current;
      
      // 임시로 랜덤 값 반환
      return (DateTime.now().millisecondsSinceEpoch % 100) / 100.0;
    } catch (e) {
      return 0.0;
    }
  }

  // 녹음 파일 경로 생성
  Future<String> _generateRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${directory.path}/recordings');
    
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${recordingsDir.path}/recording_$timestamp.aac';
  }

  // 상태 변경
  void _setState(RecordingState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  // 타이머 시작
  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_recordingStartTime != null) {
        _recordingDuration = DateTime.now().difference(_recordingStartTime!);
        _durationController.add(_recordingDuration);
        
        // 진폭도 주기적으로 업데이트
        getCurrentAmplitude().then((amplitude) {
          _amplitudeController.add(amplitude);
        });
      }
    });
  }

  // 타이머 정지
  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  // 녹음 파일 재생 (선택사항)
  Future<bool> playRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      // TODO: 실제 재생 로직 구현
      // await _audioPlayer.play(DeviceFileSource(filePath));
      
      return true;
    } catch (e) {
      print('Playback error: $e');
      return false;
    }
  }

  // 리소스 정리
  void dispose() {
    _recordingTimer?.cancel();
    _stateController.close();
    _durationController.close();
    _amplitudeController.close();
  }
}