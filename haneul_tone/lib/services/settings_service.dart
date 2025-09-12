import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'benchmark_service.dart';

/// AI 벤치마크 기반 설정 서비스
/// 
/// AI가 추천한 최적 설정을 자동으로 적용
/// 
/// Features:
/// - 벤치마크 결과 기반 자동 설정
/// - 사용자 수동 설정 보존
/// - 설정 프로필 관리 (성능/배터리/품질)
/// - 실시간 설정 변경 알림
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();
  
  static const String _keyPrefix = 'haneul_tone_settings_';
  static const String _benchmarkSettingsKey = '${_keyPrefix}benchmark';
  static const String _userSettingsKey = '${_keyPrefix}user';
  static const String _activeProfileKey = '${_keyPrefix}active_profile';
  static const String _lastBenchmarkKey = '${_keyPrefix}last_benchmark';
  
  SharedPreferences? _prefs;
  HaneulToneSettings? _currentSettings;
  
  final List<Function(HaneulToneSettings)> _listeners = [];
  
  /// 설정 변경 리스너 추가
  void addListener(Function(HaneulToneSettings) listener) {
    _listeners.add(listener);
  }
  
  /// 설정 변경 리스너 제거
  void removeListener(Function(HaneulToneSettings) listener) {
    _listeners.remove(listener);
  }
  
  /// 설정 변경 알림
  void _notifyListeners(HaneulToneSettings settings) {
    for (final listener in _listeners) {
      try {
        listener(settings);
      } catch (e) {
        print('설정 리스너 오류: $e');
      }
    }
  }
  
  /// 초기화
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    // 현재 설정 로드
    _currentSettings = await _loadCurrentSettings();
    
    print('✅ 설정 서비스 초기화 완료: ${_currentSettings?.activeProfile}');
  }
  
  /// 현재 설정 가져오기
  HaneulToneSettings get currentSettings {
    return _currentSettings ?? HaneulToneSettings.defaultSettings();
  }
  
  /// AI 벤치마크 설정 적용
  Future<void> applyBenchmarkSettings(BenchmarkSettings benchmarkSettings) async {
    await initialize();
    
    try {
      print('🤖 AI 벤치마크 설정 적용 시작');
      
      // 벤치마크 기반 HaneulTone 설정 생성
      final haneulSettings = _createHaneulSettingsFromBenchmark(benchmarkSettings);
      
      // 벤치마크 설정 저장
      final benchmarkJson = jsonEncode({
        'pitchEngine': benchmarkSettings.pitchEngine,
        'enableRealtimeProcessing': benchmarkSettings.enableRealtimeProcessing,
        'frameSize': benchmarkSettings.frameSize,
        'hopSize': benchmarkSettings.hopSize,
        'windowFunction': benchmarkSettings.windowFunction,
        'enableHighPassFilter': benchmarkSettings.enableHighPassFilter,
        'highPassCutoff': benchmarkSettings.highPassCutoff,
        'enableNotchFilter': benchmarkSettings.enableNotchFilter,
        'notchFrequency': benchmarkSettings.notchFrequency,
        'confidenceThreshold': benchmarkSettings.confidenceThreshold,
        'appliedAt': DateTime.now().toIso8601String(),
      });
      
      await _prefs!.setString(_benchmarkSettingsKey, benchmarkJson);
      
      // 활성 프로필을 'ai_optimized'로 변경
      haneulSettings.activeProfile = 'ai_optimized';
      await _saveSettings(haneulSettings);
      
      _currentSettings = haneulSettings;
      _notifyListeners(haneulSettings);
      
      print('✅ AI 설정 적용 완료: ${benchmarkSettings.pitchEngine}');
      
    } catch (e) {
      print('❌ AI 설정 적용 실패: $e');
      rethrow;
    }
  }
  
  /// 벤치마크 결과 전체 적용
  Future<void> applyBenchmarkResult(BenchmarkResult result) async {
    if (!result.isSuccess || result.recommendations?.settings == null) {
      throw ArgumentError('유효한 벤치마크 결과가 아닙니다');
    }
    
    try {
      // 벤치마크 결과 저장
      final resultJson = jsonEncode({
        'performanceGrade': result.performanceGrade?.grade ?? 'Unknown',
        'overallScore': result.performanceGrade?.overallScore ?? 0.0,
        'recommendedEngine': result.recommendations!.recommendedEngine,
        'qualityScore': result.recommendations!.qualityScore,
        'reason': result.recommendations!.reason,
        'completedAt': result.completedAt?.toIso8601String(),
        'duration': result.duration?.inSeconds,
      });
      
      await _prefs!.setString(_lastBenchmarkKey, resultJson);
      
      // 설정 적용
      await applyBenchmarkSettings(result.recommendations!.settings!);
      
    } catch (e) {
      print('❌ 벤치마크 결과 적용 실패: $e');
      rethrow;
    }
  }
  
  /// 설정 프로필 변경
  Future<void> changeProfile(String profileName) async {
    await initialize();
    
    final settings = await _loadProfileSettings(profileName);
    settings.activeProfile = profileName;
    
    await _saveSettings(settings);
    _currentSettings = settings;
    _notifyListeners(settings);
    
    print('📋 설정 프로필 변경: $profileName');
  }
  
  /// 사용자 정의 설정 저장
  Future<void> saveUserSettings(HaneulToneSettings settings) async {
    await initialize();
    
    settings.activeProfile = 'custom';
    await _saveSettings(settings);
    
    _currentSettings = settings;
    _notifyListeners(settings);
    
    print('👤 사용자 설정 저장 완료');
  }
  
  /// 설정 초기화
  Future<void> resetToDefaults() async {
    await initialize();
    
    final defaultSettings = HaneulToneSettings.defaultSettings();
    await _saveSettings(defaultSettings);
    
    _currentSettings = defaultSettings;
    _notifyListeners(defaultSettings);
    
    print('🔄 설정 초기화 완료');
  }
  
  /// 현재 설정 로드
  Future<HaneulToneSettings> _loadCurrentSettings() async {
    await initialize();
    
    final activeProfile = _prefs!.getString(_activeProfileKey) ?? 'default';
    return await _loadProfileSettings(activeProfile);
  }
  
  /// 프로필 설정 로드
  Future<HaneulToneSettings> _loadProfileSettings(String profileName) async {
    switch (profileName) {
      case 'ai_optimized':
        return await _loadAIOptimizedSettings();
      case 'performance':
        return HaneulToneSettings.performanceProfile();
      case 'battery':
        return HaneulToneSettings.batteryProfile();
      case 'quality':
        return HaneulToneSettings.qualityProfile();
      case 'custom':
        return await _loadUserSettings();
      default:
        return HaneulToneSettings.defaultSettings();
    }
  }
  
  /// AI 최적화 설정 로드
  Future<HaneulToneSettings> _loadAIOptimizedSettings() async {
    final benchmarkJson = _prefs!.getString(_benchmarkSettingsKey);
    if (benchmarkJson == null) {
      return HaneulToneSettings.defaultSettings();
    }
    
    try {
      final benchmarkData = jsonDecode(benchmarkJson) as Map<String, dynamic>;
      return _createHaneulSettingsFromJson(benchmarkData);
    } catch (e) {
      print('❌ AI 설정 로드 실패: $e');
      return HaneulToneSettings.defaultSettings();
    }
  }
  
  /// 사용자 설정 로드
  Future<HaneulToneSettings> _loadUserSettings() async {
    final userJson = _prefs!.getString(_userSettingsKey);
    if (userJson == null) {
      return HaneulToneSettings.defaultSettings();
    }
    
    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return HaneulToneSettings.fromJson(userData);
    } catch (e) {
      print('❌ 사용자 설정 로드 실패: $e');
      return HaneulToneSettings.defaultSettings();
    }
  }
  
  /// 설정 저장
  Future<void> _saveSettings(HaneulToneSettings settings) async {
    try {
      // 활성 프로필 저장
      await _prefs!.setString(_activeProfileKey, settings.activeProfile);
      
      // 프로필별 저장
      if (settings.activeProfile == 'custom') {
        final userJson = jsonEncode(settings.toJson());
        await _prefs!.setString(_userSettingsKey, userJson);
      }
      
    } catch (e) {
      print('❌ 설정 저장 실패: $e');
      rethrow;
    }
  }
  
  /// 벤치마크 설정에서 HaneulTone 설정 생성
  HaneulToneSettings _createHaneulSettingsFromBenchmark(BenchmarkSettings benchmarkSettings) {
    return HaneulToneSettings(
      // 피치 엔진 설정
      pitchEngine: _mapPitchEngine(benchmarkSettings.pitchEngine),
      hybridYinWeight: 0.6, // 기본값 유지
      hybridFftWeight: 0.4,
      
      // 오디오 처리 설정
      enableRealtimeProcessing: benchmarkSettings.enableRealtimeProcessing,
      frameSize: benchmarkSettings.frameSize,
      hopSize: benchmarkSettings.hopSize,
      windowFunction: _mapWindowFunction(benchmarkSettings.windowFunction),
      
      // 필터 설정
      enableHighPassFilter: benchmarkSettings.enableHighPassFilter,
      highPassCutoff: benchmarkSettings.highPassCutoff,
      enableNotchFilter: benchmarkSettings.enableNotchFilter,
      notchFrequency: benchmarkSettings.notchFrequency,
      
      // 분석 설정
      confidenceThreshold: benchmarkSettings.confidenceThreshold,
      enableFormantAnalysis: benchmarkSettings.pitchEngine == 'CREPE-Tiny', // CREPE 사용시 포먼트 분석 활성화
      enableVibratoDetection: true, // 기본 활성화
      
      // DTW 설정
      dtwBandRadius: benchmarkSettings.enableRealtimeProcessing ? 10 : 15, // 실시간 처리시 더 좁은 밴드
      dtwNormalizationMethod: 'zscore',
      
      // UI 설정 (기존 값 유지)
      enableSessionReplay: true,
      enableCoachingCards: true,
      enableExportFeatures: true,
      
      // 프로필
      activeProfile: 'ai_optimized',
    );
  }
  
  /// 벤치마크 JSON에서 HaneulTone 설정 생성
  HaneulToneSettings _createHaneulSettingsFromJson(Map<String, dynamic> json) {
    return HaneulToneSettings(
      pitchEngine: _mapPitchEngine(json['pitchEngine'] ?? 'Hybrid'),
      enableRealtimeProcessing: json['enableRealtimeProcessing'] ?? false,
      frameSize: json['frameSize'] ?? 1024,
      hopSize: json['hopSize'] ?? 512,
      windowFunction: _mapWindowFunction(json['windowFunction'] ?? 'hann'),
      enableHighPassFilter: json['enableHighPassFilter'] ?? true,
      highPassCutoff: json['highPassCutoff']?.toDouble() ?? 80.0,
      enableNotchFilter: json['enableNotchFilter'] ?? true,
      notchFrequency: json['notchFrequency']?.toDouble() ?? 60.0,
      confidenceThreshold: json['confidenceThreshold']?.toDouble() ?? 0.8,
      enableFormantAnalysis: json['pitchEngine'] == 'CREPE-Tiny',
      enableVibratoDetection: true,
      dtwBandRadius: json['enableRealtimeProcessing'] == true ? 10 : 15,
      dtwNormalizationMethod: 'zscore',
      enableSessionReplay: true,
      enableCoachingCards: true,
      enableExportFeatures: true,
      activeProfile: 'ai_optimized',
    );
  }
  
  /// 피치 엔진 매핑
  PitchEngineType _mapPitchEngine(String engineName) {
    switch (engineName.toLowerCase()) {
      case 'hybrid':
        return PitchEngineType.hybrid;
      case 'crepe':
      case 'crepe-tiny':
        return PitchEngineType.crepe;
      case 'fft':
        return PitchEngineType.fft;
      case 'yin':
        return PitchEngineType.yin;
      default:
        return PitchEngineType.hybrid;
    }
  }
  
  /// 윈도우 함수 매핑
  WindowFunctionType _mapWindowFunction(String windowName) {
    switch (windowName.toLowerCase()) {
      case 'hann':
        return WindowFunctionType.hann;
      case 'hamming':
        return WindowFunctionType.hamming;
      case 'blackman':
        return WindowFunctionType.blackman;
      case 'rectangular':
        return WindowFunctionType.rectangular;
      default:
        return WindowFunctionType.hann;
    }
  }
  
  /// 마지막 벤치마크 결과 가져오기
  Future<Map<String, dynamic>?> getLastBenchmarkResult() async {
    await initialize();
    
    final resultJson = _prefs!.getString(_lastBenchmarkKey);
    if (resultJson == null) return null;
    
    try {
      return jsonDecode(resultJson) as Map<String, dynamic>;
    } catch (e) {
      print('❌ 마지막 벤치마크 결과 로드 실패: $e');
      return null;
    }
  }
  
  /// AI 추천 설정 사용 여부
  Future<bool> isUsingAISettings() async {
    await initialize();
    return _currentSettings?.activeProfile == 'ai_optimized';
  }
  
  /// 설정 내보내기
  Future<Map<String, dynamic>> exportSettings() async {
    await initialize();
    
    final export = <String, dynamic>{
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'currentSettings': _currentSettings?.toJson(),
      'availableProfiles': {
        'default': HaneulToneSettings.defaultSettings().toJson(),
        'performance': HaneulToneSettings.performanceProfile().toJson(),
        'battery': HaneulToneSettings.batteryProfile().toJson(),
        'quality': HaneulToneSettings.qualityProfile().toJson(),
      },
    };
    
    // AI 설정이 있으면 포함
    final aiSettings = _prefs!.getString(_benchmarkSettingsKey);
    if (aiSettings != null) {
      export['aiOptimizedSettings'] = jsonDecode(aiSettings);
    }
    
    // 마지막 벤치마크 결과 포함
    final lastBenchmark = await getLastBenchmarkResult();
    if (lastBenchmark != null) {
      export['lastBenchmarkResult'] = lastBenchmark;
    }
    
    return export;
  }
  
  /// 설정 가져오기
  Future<void> importSettings(Map<String, dynamic> importData) async {
    await initialize();
    
    try {
      // 현재 설정 백업
      final backup = await exportSettings();
      await _prefs!.setString('${_keyPrefix}backup_${DateTime.now().millisecondsSinceEpoch}', 
                              jsonEncode(backup));
      
      // 새 설정 적용
      if (importData['currentSettings'] != null) {
        final settings = HaneulToneSettings.fromJson(importData['currentSettings']);
        await _saveSettings(settings);
        _currentSettings = settings;
        _notifyListeners(settings);
      }
      
      // AI 설정 복원
      if (importData['aiOptimizedSettings'] != null) {
        await _prefs!.setString(_benchmarkSettingsKey, 
                                jsonEncode(importData['aiOptimizedSettings']));
      }
      
      // 벤치마크 결과 복원
      if (importData['lastBenchmarkResult'] != null) {
        await _prefs!.setString(_lastBenchmarkKey, 
                                jsonEncode(importData['lastBenchmarkResult']));
      }
      
      print('✅ 설정 가져오기 완료');
      
    } catch (e) {
      print('❌ 설정 가져오기 실패: $e');
      rethrow;
    }
  }
}

/// HaneulTone 앱 설정 클래스
class HaneulToneSettings {
  // 피치 엔진 설정
  PitchEngineType pitchEngine;
  double hybridYinWeight;
  double hybridFftWeight;
  
  // 오디오 처리 설정
  bool enableRealtimeProcessing;
  int frameSize;
  int hopSize;
  WindowFunctionType windowFunction;
  
  // 필터 설정
  bool enableHighPassFilter;
  double highPassCutoff;
  bool enableNotchFilter;
  double notchFrequency;
  
  // 분석 설정
  double confidenceThreshold;
  bool enableFormantAnalysis;
  bool enableVibratoDetection;
  
  // DTW 설정
  int dtwBandRadius;
  String dtwNormalizationMethod;
  
  // UI 기능 설정
  bool enableSessionReplay;
  bool enableCoachingCards;
  bool enableExportFeatures;
  
  // 프로필
  String activeProfile;
  
  HaneulToneSettings({
    this.pitchEngine = PitchEngineType.hybrid,
    this.hybridYinWeight = 0.6,
    this.hybridFftWeight = 0.4,
    this.enableRealtimeProcessing = false,
    this.frameSize = 1024,
    this.hopSize = 512,
    this.windowFunction = WindowFunctionType.hann,
    this.enableHighPassFilter = true,
    this.highPassCutoff = 80.0,
    this.enableNotchFilter = true,
    this.notchFrequency = 60.0,
    this.confidenceThreshold = 0.8,
    this.enableFormantAnalysis = false,
    this.enableVibratoDetection = true,
    this.dtwBandRadius = 15,
    this.dtwNormalizationMethod = 'zscore',
    this.enableSessionReplay = true,
    this.enableCoachingCards = true,
    this.enableExportFeatures = true,
    this.activeProfile = 'default',
  });
  
  /// 기본 설정
  factory HaneulToneSettings.defaultSettings() {
    return HaneulToneSettings();
  }
  
  /// 성능 우선 프로필
  factory HaneulToneSettings.performanceProfile() {
    return HaneulToneSettings(
      pitchEngine: PitchEngineType.fft, // 빠른 FFT 엔진
      enableRealtimeProcessing: true,
      frameSize: 512, // 작은 프레임
      hopSize: 256,
      enableFormantAnalysis: false, // 성능을 위해 비활성화
      dtwBandRadius: 5, // 좁은 밴드
      activeProfile: 'performance',
    );
  }
  
  /// 배터리 절약 프로필
  factory HaneulToneSettings.batteryProfile() {
    return HaneulToneSettings(
      pitchEngine: PitchEngineType.yin, // 저전력 YIN 엔진
      enableRealtimeProcessing: false,
      frameSize: 2048, // 큰 프레임으로 호출 빈도 감소
      hopSize: 1024,
      enableFormantAnalysis: false,
      enableVibratoDetection: false,
      confidenceThreshold: 0.9, // 높은 임계값으로 처리량 감소
      activeProfile: 'battery',
    );
  }
  
  /// 품질 우선 프로필
  factory HaneulToneSettings.qualityProfile() {
    return HaneulToneSettings(
      pitchEngine: PitchEngineType.crepe, // 고품질 CREPE 엔진
      enableRealtimeProcessing: false,
      frameSize: 1024,
      hopSize: 256, // 작은 홉으로 높은 해상도
      enableFormantAnalysis: true,
      enableVibratoDetection: true,
      confidenceThreshold: 0.7, // 낮은 임계값으로 더 많은 분석
      dtwBandRadius: 25, // 넓은 밴드로 정확한 매칭
      activeProfile: 'quality',
    );
  }
  
  /// JSON에서 생성
  factory HaneulToneSettings.fromJson(Map<String, dynamic> json) {
    return HaneulToneSettings(
      pitchEngine: PitchEngineType.values.firstWhere(
        (e) => e.name == json['pitchEngine'],
        orElse: () => PitchEngineType.hybrid,
      ),
      hybridYinWeight: json['hybridYinWeight']?.toDouble() ?? 0.6,
      hybridFftWeight: json['hybridFftWeight']?.toDouble() ?? 0.4,
      enableRealtimeProcessing: json['enableRealtimeProcessing'] ?? false,
      frameSize: json['frameSize'] ?? 1024,
      hopSize: json['hopSize'] ?? 512,
      windowFunction: WindowFunctionType.values.firstWhere(
        (e) => e.name == json['windowFunction'],
        orElse: () => WindowFunctionType.hann,
      ),
      enableHighPassFilter: json['enableHighPassFilter'] ?? true,
      highPassCutoff: json['highPassCutoff']?.toDouble() ?? 80.0,
      enableNotchFilter: json['enableNotchFilter'] ?? true,
      notchFrequency: json['notchFrequency']?.toDouble() ?? 60.0,
      confidenceThreshold: json['confidenceThreshold']?.toDouble() ?? 0.8,
      enableFormantAnalysis: json['enableFormantAnalysis'] ?? false,
      enableVibratoDetection: json['enableVibratoDetection'] ?? true,
      dtwBandRadius: json['dtwBandRadius'] ?? 15,
      dtwNormalizationMethod: json['dtwNormalizationMethod'] ?? 'zscore',
      enableSessionReplay: json['enableSessionReplay'] ?? true,
      enableCoachingCards: json['enableCoachingCards'] ?? true,
      enableExportFeatures: json['enableExportFeatures'] ?? true,
      activeProfile: json['activeProfile'] ?? 'default',
    );
  }
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'pitchEngine': pitchEngine.name,
      'hybridYinWeight': hybridYinWeight,
      'hybridFftWeight': hybridFftWeight,
      'enableRealtimeProcessing': enableRealtimeProcessing,
      'frameSize': frameSize,
      'hopSize': hopSize,
      'windowFunction': windowFunction.name,
      'enableHighPassFilter': enableHighPassFilter,
      'highPassCutoff': highPassCutoff,
      'enableNotchFilter': enableNotchFilter,
      'notchFrequency': notchFrequency,
      'confidenceThreshold': confidenceThreshold,
      'enableFormantAnalysis': enableFormantAnalysis,
      'enableVibratoDetection': enableVibratoDetection,
      'dtwBandRadius': dtwBandRadius,
      'dtwNormalizationMethod': dtwNormalizationMethod,
      'enableSessionReplay': enableSessionReplay,
      'enableCoachingCards': enableCoachingCards,
      'enableExportFeatures': enableExportFeatures,
      'activeProfile': activeProfile,
    };
  }
  
  /// 설정 복사
  HaneulToneSettings copyWith({
    PitchEngineType? pitchEngine,
    double? hybridYinWeight,
    double? hybridFftWeight,
    bool? enableRealtimeProcessing,
    int? frameSize,
    int? hopSize,
    WindowFunctionType? windowFunction,
    bool? enableHighPassFilter,
    double? highPassCutoff,
    bool? enableNotchFilter,
    double? notchFrequency,
    double? confidenceThreshold,
    bool? enableFormantAnalysis,
    bool? enableVibratoDetection,
    int? dtwBandRadius,
    String? dtwNormalizationMethod,
    bool? enableSessionReplay,
    bool? enableCoachingCards,
    bool? enableExportFeatures,
    String? activeProfile,
  }) {
    return HaneulToneSettings(
      pitchEngine: pitchEngine ?? this.pitchEngine,
      hybridYinWeight: hybridYinWeight ?? this.hybridYinWeight,
      hybridFftWeight: hybridFftWeight ?? this.hybridFftWeight,
      enableRealtimeProcessing: enableRealtimeProcessing ?? this.enableRealtimeProcessing,
      frameSize: frameSize ?? this.frameSize,
      hopSize: hopSize ?? this.hopSize,
      windowFunction: windowFunction ?? this.windowFunction,
      enableHighPassFilter: enableHighPassFilter ?? this.enableHighPassFilter,
      highPassCutoff: highPassCutoff ?? this.highPassCutoff,
      enableNotchFilter: enableNotchFilter ?? this.enableNotchFilter,
      notchFrequency: notchFrequency ?? this.notchFrequency,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      enableFormantAnalysis: enableFormantAnalysis ?? this.enableFormantAnalysis,
      enableVibratoDetection: enableVibratoDetection ?? this.enableVibratoDetection,
      dtwBandRadius: dtwBandRadius ?? this.dtwBandRadius,
      dtwNormalizationMethod: dtwNormalizationMethod ?? this.dtwNormalizationMethod,
      enableSessionReplay: enableSessionReplay ?? this.enableSessionReplay,
      enableCoachingCards: enableCoachingCards ?? this.enableCoachingCards,
      enableExportFeatures: enableExportFeatures ?? this.enableExportFeatures,
      activeProfile: activeProfile ?? this.activeProfile,
    );
  }
}

/// 피치 엔진 타입
enum PitchEngineType {
  hybrid,
  fft,
  yin,
  crepe,
}

/// 윈도우 함수 타입
enum WindowFunctionType {
  hann,
  hamming,
  blackman,
  rectangular,
}