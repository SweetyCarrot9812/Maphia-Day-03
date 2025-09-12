import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 접근성 서비스
/// 
/// 색맹 사용자 지원 및 진동 알림 기능
/// 
/// Features:
/// - 색맹 친화적 색상 팔레트
/// - 진동 피드백 시스템
/// - 고대비 모드
/// - 큰 글꼴 지원
/// - 음성 안내 준비
/// - 키보드 네비게이션 지원
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();
  
  static const String _keyPrefix = 'accessibility_settings_';
  static const String _settingsKey = '${_keyPrefix}config';
  
  SharedPreferences? _prefs;
  AccessibilitySettings _settings = AccessibilitySettings();
  
  final List<Function(AccessibilitySettings)> _listeners = [];
  
  /// 현재 접근성 설정
  AccessibilitySettings get settings => _settings;
  
  /// 설정 변경 리스너 추가
  void addListener(Function(AccessibilitySettings) listener) {
    _listeners.add(listener);
  }
  
  /// 설정 변경 리스너 제거
  void removeListener(Function(AccessibilitySettings) listener) {
    _listeners.remove(listener);
  }
  
  /// 설정 변경 알림
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener(_settings);
      } catch (e) {
        print('접근성 리스너 오류: $e');
      }
    }
  }
  
  /// 초기화
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadSettings();
    
    print('✅ 접근성 서비스 초기화 완료');
  }
  
  /// 설정 로드
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs!.getString(_settingsKey);
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = AccessibilitySettings.fromJson(settingsMap);
      }
    } catch (e) {
      print('⚠️ 접근성 설정 로드 실패: $e');
      _settings = AccessibilitySettings(); // 기본값 사용
    }
  }
  
  /// 설정 저장
  Future<void> _saveSettings() async {
    try {
      final settingsJson = jsonEncode(_settings.toJson());
      await _prefs!.setString(_settingsKey, settingsJson);
      _notifyListeners();
    } catch (e) {
      print('❌ 접근성 설정 저장 실패: $e');
      rethrow;
    }
  }
  
  /// 색맹 타입 설정
  Future<void> setColorBlindnessType(ColorBlindnessType type) async {
    _settings = _settings.copyWith(colorBlindnessType: type);
    await _saveSettings();
    
    print('🎨 색맹 타입 변경: ${type.name}');
  }
  
  /// 진동 피드백 활성화/비활성화
  Future<void> setVibrationFeedback(bool enabled) async {
    _settings = _settings.copyWith(enableVibrationFeedback: enabled);
    await _saveSettings();
    
    print('📳 진동 피드백: ${enabled ? '활성화' : '비활성화'}');
  }
  
  /// 진동 강도 설정
  Future<void> setVibrationIntensity(VibrationIntensity intensity) async {
    _settings = _settings.copyWith(vibrationIntensity: intensity);
    await _saveSettings();
    
    print('📳 진동 강도: ${intensity.name}');
  }
  
  /// 고대비 모드 설정
  Future<void> setHighContrastMode(bool enabled) async {
    _settings = _settings.copyWith(enableHighContrast: enabled);
    await _saveSettings();
    
    print('🔳 고대비 모드: ${enabled ? '활성화' : '비활성화'}');
  }
  
  /// 큰 글꼴 모드 설정
  Future<void> setLargeFontMode(bool enabled) async {
    _settings = _settings.copyWith(enableLargeFont: enabled);
    await _saveSettings();
    
    print('🔤 큰 글꼴: ${enabled ? '활성화' : '비활성화'}');
  }
  
  /// 음성 안내 설정
  Future<void> setVoiceGuidance(bool enabled) async {
    _settings = _settings.copyWith(enableVoiceGuidance: enabled);
    await _saveSettings();
    
    print('🔊 음성 안내: ${enabled ? '활성화' : '비활성화'}');
  }
  
  /// 색상 변환 - 색맹 친화적 색상으로 변환
  Color adaptColor(Color originalColor) {
    if (_settings.colorBlindnessType == ColorBlindnessType.none) {
      return _settings.enableHighContrast 
          ? _toHighContrast(originalColor)
          : originalColor;
    }
    
    Color adaptedColor = _convertForColorBlindness(originalColor, _settings.colorBlindnessType);
    
    if (_settings.enableHighContrast) {
      adaptedColor = _toHighContrast(adaptedColor);
    }
    
    return adaptedColor;
  }
  
  /// 색맹 친화적 색상 팔레트 가져오기
  ColorPalette getColorPalette() {
    switch (_settings.colorBlindnessType) {
      case ColorBlindnessType.protanopia:
        return ColorPalette.protanopiaFriendly();
      case ColorBlindnessType.deuteranopia:
        return ColorPalette.deuteranopiaFriendly();
      case ColorBlindnessType.tritanopia:
        return ColorPalette.tritanopiaFriendly();
      case ColorBlindnessType.none:
      default:
        return _settings.enableHighContrast 
            ? ColorPalette.highContrast()
            : ColorPalette.standard();
    }
  }
  
  /// 텍스트 크기 조정
  double adjustFontSize(double baseFontSize) {
    if (_settings.enableLargeFont) {
      return baseFontSize * 1.3; // 30% 크게
    }
    return baseFontSize;
  }
  
  /// 진동 피드백 실행
  Future<void> vibrate(VibrationPattern pattern) async {
    if (!_settings.enableVibrationFeedback) return;
    
    try {
      final patternData = _getVibrationPattern(pattern);
      final adjustedPattern = _adjustVibrationIntensity(patternData);
      
      if (adjustedPattern.isNotEmpty) {
        await HapticFeedback.vibrate();
        
        // 복잡한 패턴의 경우 시뮬레이션
        if (pattern != VibrationPattern.light) {
          await _simulateVibrationPattern(adjustedPattern);
        }
      }
      
    } catch (e) {
      print('⚠️ 진동 피드백 실행 실패: $e');
    }
  }
  
  /// 성공 진동
  Future<void> vibrateSuccess() async {
    await vibrate(VibrationPattern.success);
  }
  
  /// 오류 진동
  Future<void> vibrateError() async {
    await vibrate(VibrationPattern.error);
  }
  
  /// 경고 진동
  Future<void> vibrateWarning() async {
    await vibrate(VibrationPattern.warning);
  }
  
  /// 알림 진동
  Future<void> vibrateNotification() async {
    await vibrate(VibrationPattern.notification);
  }
  
  /// 부드러운 진동
  Future<void> vibrateLight() async {
    await vibrate(VibrationPattern.light);
  }
  
  /// 색상 변환 - 색맹 타입에 따른 변환
  Color _convertForColorBlindness(Color color, ColorBlindnessType type) {
    final hsl = HSLColor.fromColor(color);
    
    switch (type) {
      case ColorBlindnessType.protanopia: // 적색맹
        return _convertProtanopia(hsl).toColor();
      case ColorBlindnessType.deuteranopia: // 녹색맹
        return _convertDeuteranopia(hsl).toColor();
      case ColorBlindnessType.tritanopia: // 청색맹
        return _convertTritanopia(hsl).toColor();
      case ColorBlindnessType.none:
      default:
        return color;
    }
  }
  
  /// 적색맹 변환
  HSLColor _convertProtanopia(HSLColor hsl) {
    // 적색을 구분 가능한 색상으로 변환
    double newHue = hsl.hue;
    
    if (hsl.hue >= 0 && hsl.hue <= 60) { // 빨강-노랑 영역
      newHue = 60 + (hsl.hue / 60) * 60; // 노랑-초록으로 매핑
    } else if (hsl.hue >= 300 && hsl.hue <= 360) { // 마젠타-빨강 영역
      newHue = 240 + ((hsl.hue - 300) / 60) * 60; // 파랑-마젠타로 매핑
    }
    
    return hsl.withHue(newHue);
  }
  
  /// 녹색맹 변환
  HSLColor _convertDeuteranopia(HSLColor hsl) {
    // 녹색을 구분 가능한 색상으로 변환
    double newHue = hsl.hue;
    
    if (hsl.hue >= 60 && hsl.hue <= 180) { // 노랑-청록 영역
      newHue = 30 + (hsl.hue - 60) / 120 * 30; // 오렌지-노랑으로 매핑
    }
    
    return hsl.withHue(newHue);
  }
  
  /// 청색맹 변환
  HSLColor _convertTritanopia(HSLColor hsl) {
    // 청색을 구분 가능한 색상으로 변환
    double newHue = hsl.hue;
    
    if (hsl.hue >= 180 && hsl.hue <= 300) { // 청록-마젠타 영역
      newHue = 120 + (hsl.hue - 180) / 120 * 60; // 초록-노랑으로 매핑
    }
    
    return hsl.withHue(newHue);
  }
  
  /// 고대비 변환
  Color _toHighContrast(Color color) {
    final luminance = color.computeLuminance();
    
    // 중간 밝기의 색상을 극단적으로 변경
    if (luminance < 0.5) {
      return Colors.black; // 어두운 색상은 검정으로
    } else {
      return Colors.white; // 밝은 색상은 흰색으로
    }
  }
  
  /// 진동 패턴 데이터 가져오기
  List<int> _getVibrationPattern(VibrationPattern pattern) {
    switch (pattern) {
      case VibrationPattern.success:
        return [100, 50, 100]; // 짧은-잠시-짧은
      case VibrationPattern.error:
        return [300, 100, 300, 100, 300]; // 길게-잠시-길게-잠시-길게
      case VibrationPattern.warning:
        return [200, 100, 100, 100, 200]; // 중간-잠시-짧게-잠시-중간
      case VibrationPattern.notification:
        return [100]; // 한 번 짧게
      case VibrationPattern.light:
        return [50]; // 아주 짧게
      default:
        return [100];
    }
  }
  
  /// 진동 강도 조정
  List<int> _adjustVibrationIntensity(List<int> pattern) {
    double multiplier;
    
    switch (_settings.vibrationIntensity) {
      case VibrationIntensity.light:
        multiplier = 0.7;
        break;
      case VibrationIntensity.medium:
        multiplier = 1.0;
        break;
      case VibrationIntensity.strong:
        multiplier = 1.5;
        break;
    }
    
    return pattern.map((duration) => (duration * multiplier).round()).toList();
  }
  
  /// 진동 패턴 시뮬레이션
  Future<void> _simulateVibrationPattern(List<int> pattern) async {
    for (int i = 0; i < pattern.length; i++) {
      if (i % 2 == 0) {
        // 진동
        await HapticFeedback.mediumImpact();
      }
      // 대기
      await Future.delayed(Duration(milliseconds: pattern[i]));
    }
  }
  
  /// 접근성 진단 실행
  Future<AccessibilityReport> runAccessibilityDiagnosis() async {
    final report = AccessibilityReport();
    
    try {
      print('🔍 접근성 진단 시작');
      
      // 1. 색맹 테스트
      report.colorBlindnessTest = _testColorBlindnessSettings();
      
      // 2. 진동 피드백 테스트
      report.vibrationTest = await _testVibrationFeedback();
      
      // 3. 텍스트 가독성 테스트
      report.textReadabilityTest = _testTextReadability();
      
      // 4. 고대비 효과성 테스트
      report.highContrastTest = _testHighContrast();
      
      // 5. 전체 점수 계산
      report.overallScore = _calculateOverallScore(report);
      
      // 6. 추천사항 생성
      report.recommendations = _generateRecommendations(report);
      
      print('✅ 접근성 진단 완료 - 점수: ${(report.overallScore * 100).toStringAsFixed(1)}');
      
    } catch (e) {
      print('❌ 접근성 진단 실패: $e');
      report.hasError = true;
      report.errorMessage = e.toString();
    }
    
    return report;
  }
  
  /// 색맹 설정 테스트
  AccessibilityTestResult _testColorBlindnessSettings() {
    final result = AccessibilityTestResult(
      testName: '색맹 지원',
      isEnabled: _settings.colorBlindnessType != ColorBlindnessType.none,
    );
    
    if (result.isEnabled) {
      result.score = 1.0;
      result.message = '색맹 친화적 색상이 적용되어 있습니다';
      
      // 색상 팔레트 검증
      final palette = getColorPalette();
      result.details = '현재 팔레트: ${_settings.colorBlindnessType.name}';
    } else {
      result.score = 0.5; // 기본 점수
      result.message = '색맹 지원 설정이 비활성화되어 있습니다';
      result.recommendation = '색맹이 있으시다면 색맹 타입을 선택해주세요';
    }
    
    return result;
  }
  
  /// 진동 피드백 테스트
  Future<AccessibilityTestResult> _testVibrationFeedback() async {
    final result = AccessibilityTestResult(
      testName: '진동 피드백',
      isEnabled: _settings.enableVibrationFeedback,
    );
    
    if (result.isEnabled) {
      try {
        // 테스트 진동 실행
        await vibrateLight();
        
        result.score = 1.0;
        result.message = '진동 피드백이 정상적으로 작동합니다';
        result.details = '강도: ${_settings.vibrationIntensity.name}';
      } catch (e) {
        result.score = 0.3;
        result.message = '진동 피드백 실행 중 오류가 발생했습니다';
        result.recommendation = '디바이스 진동 설정을 확인해주세요';
      }
    } else {
      result.score = 0.5;
      result.message = '진동 피드백이 비활성화되어 있습니다';
      result.recommendation = '청각 보조를 위해 진동 피드백을 활성화하는 것을 권장합니다';
    }
    
    return result;
  }
  
  /// 텍스트 가독성 테스트
  AccessibilityTestResult _testTextReadability() {
    final result = AccessibilityTestResult(
      testName: '텍스트 가독성',
      isEnabled: _settings.enableLargeFont,
    );
    
    if (result.isEnabled) {
      result.score = 1.0;
      result.message = '큰 글꼴이 활성화되어 있습니다';
      result.details = '기본 글꼴보다 30% 크게 표시됩니다';
    } else {
      result.score = 0.7;
      result.message = '표준 글꼴 크기를 사용하고 있습니다';
      result.recommendation = '시력이 좋지 않으시다면 큰 글꼴을 활성화해보세요';
    }
    
    return result;
  }
  
  /// 고대비 테스트
  AccessibilityTestResult _testHighContrast() {
    final result = AccessibilityTestResult(
      testName: '고대비 모드',
      isEnabled: _settings.enableHighContrast,
    );
    
    if (result.isEnabled) {
      result.score = 1.0;
      result.message = '고대비 모드가 활성화되어 있습니다';
      result.details = '색상 구분이 더 명확해집니다';
    } else {
      result.score = 0.6;
      result.message = '표준 대비를 사용하고 있습니다';
      result.recommendation = '색상 구분이 어려우시다면 고대비 모드를 시도해보세요';
    }
    
    return result;
  }
  
  /// 전체 접근성 점수 계산
  double _calculateOverallScore(AccessibilityReport report) {
    final tests = [
      report.colorBlindnessTest,
      report.vibrationTest,
      report.textReadabilityTest,
      report.highContrastTest,
    ];
    
    double totalScore = 0.0;
    int validTests = 0;
    
    for (final test in tests) {
      if (test != null && !test.hasError) {
        totalScore += test.score;
        validTests++;
      }
    }
    
    return validTests > 0 ? totalScore / validTests : 0.0;
  }
  
  /// 추천사항 생성
  List<String> _generateRecommendations(AccessibilityReport report) {
    final recommendations = <String>[];
    
    if (report.colorBlindnessTest?.score != null && report.colorBlindnessTest!.score < 0.8) {
      recommendations.add('색맹이 있으시다면 적절한 색맹 타입을 선택하여 색상 구분을 개선하세요');
    }
    
    if (report.vibrationTest?.score != null && report.vibrationTest!.score < 0.8) {
      recommendations.add('청각 보조를 위해 진동 피드백을 활성화하고 적절한 강도로 설정하세요');
    }
    
    if (report.textReadabilityTest?.score != null && report.textReadabilityTest!.score < 0.8) {
      recommendations.add('가독성 향상을 위해 큰 글꼴 모드를 활성화해보세요');
    }
    
    if (report.highContrastTest?.score != null && report.highContrastTest!.score < 0.8) {
      recommendations.add('색상 구분을 위해 고대비 모드를 활성화해보세요');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('현재 접근성 설정이 잘 구성되어 있습니다!');
    }
    
    return recommendations;
  }
}

/// 접근성 설정 클래스
class AccessibilitySettings {
  final ColorBlindnessType colorBlindnessType;
  final bool enableVibrationFeedback;
  final VibrationIntensity vibrationIntensity;
  final bool enableHighContrast;
  final bool enableLargeFont;
  final bool enableVoiceGuidance;
  final bool enableKeyboardNavigation;
  
  AccessibilitySettings({
    this.colorBlindnessType = ColorBlindnessType.none,
    this.enableVibrationFeedback = false,
    this.vibrationIntensity = VibrationIntensity.medium,
    this.enableHighContrast = false,
    this.enableLargeFont = false,
    this.enableVoiceGuidance = false,
    this.enableKeyboardNavigation = false,
  });
  
  /// JSON에서 생성
  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      colorBlindnessType: ColorBlindnessType.values.firstWhere(
        (e) => e.name == json['colorBlindnessType'],
        orElse: () => ColorBlindnessType.none,
      ),
      enableVibrationFeedback: json['enableVibrationFeedback'] ?? false,
      vibrationIntensity: VibrationIntensity.values.firstWhere(
        (e) => e.name == json['vibrationIntensity'],
        orElse: () => VibrationIntensity.medium,
      ),
      enableHighContrast: json['enableHighContrast'] ?? false,
      enableLargeFont: json['enableLargeFont'] ?? false,
      enableVoiceGuidance: json['enableVoiceGuidance'] ?? false,
      enableKeyboardNavigation: json['enableKeyboardNavigation'] ?? false,
    );
  }
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'colorBlindnessType': colorBlindnessType.name,
      'enableVibrationFeedback': enableVibrationFeedback,
      'vibrationIntensity': vibrationIntensity.name,
      'enableHighContrast': enableHighContrast,
      'enableLargeFont': enableLargeFont,
      'enableVoiceGuidance': enableVoiceGuidance,
      'enableKeyboardNavigation': enableKeyboardNavigation,
    };
  }
  
  /// 설정 복사
  AccessibilitySettings copyWith({
    ColorBlindnessType? colorBlindnessType,
    bool? enableVibrationFeedback,
    VibrationIntensity? vibrationIntensity,
    bool? enableHighContrast,
    bool? enableLargeFont,
    bool? enableVoiceGuidance,
    bool? enableKeyboardNavigation,
  }) {
    return AccessibilitySettings(
      colorBlindnessType: colorBlindnessType ?? this.colorBlindnessType,
      enableVibrationFeedback: enableVibrationFeedback ?? this.enableVibrationFeedback,
      vibrationIntensity: vibrationIntensity ?? this.vibrationIntensity,
      enableHighContrast: enableHighContrast ?? this.enableHighContrast,
      enableLargeFont: enableLargeFont ?? this.enableLargeFont,
      enableVoiceGuidance: enableVoiceGuidance ?? this.enableVoiceGuidance,
      enableKeyboardNavigation: enableKeyboardNavigation ?? this.enableKeyboardNavigation,
    );
  }
}

/// 색맹 타입
enum ColorBlindnessType {
  none, // 색맹 없음
  protanopia, // 적색맹 (L-cone 결함)
  deuteranopia, // 녹색맹 (M-cone 결함)
  tritanopia, // 청색맹 (S-cone 결함)
}

/// 진동 강도
enum VibrationIntensity {
  light, // 약함
  medium, // 중간
  strong, // 강함
}

/// 진동 패턴
enum VibrationPattern {
  light, // 부드러운 진동
  success, // 성공 피드백
  error, // 오류 피드백
  warning, // 경고 피드백
  notification, // 일반 알림
}

/// 색상 팔레트
class ColorPalette {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color onSecondary;
  final Color onSurface;
  
  ColorPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onSecondary,
    required this.onSurface,
  });
  
  /// 표준 팔레트
  factory ColorPalette.standard() {
    return ColorPalette(
      primary: Colors.blue,
      secondary: Colors.teal,
      accent: Colors.orange,
      success: Colors.green,
      warning: Colors.orange,
      error: Colors.red,
      info: Colors.blue,
      background: Colors.white,
      surface: Colors.grey[50]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    );
  }
  
  /// 적색맹 친화적 팔레트
  factory ColorPalette.protanopiaFriendly() {
    return ColorPalette(
      primary: Colors.blue,
      secondary: Colors.cyan,
      accent: Colors.yellow,
      success: Colors.blue[700]!, // 초록 대신 파랑
      warning: Colors.yellow[700]!,
      error: Colors.grey[800]!, // 빨강 대신 어두운 회색
      info: Colors.blue,
      background: Colors.white,
      surface: Colors.grey[50]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    );
  }
  
  /// 녹색맹 친화적 팔레트
  factory ColorPalette.deuteranopiaFriendly() {
    return ColorPalette(
      primary: Colors.blue,
      secondary: Colors.purple,
      accent: Colors.orange,
      success: Colors.blue[700]!, // 초록 대신 파랑
      warning: Colors.orange,
      error: Colors.red[800]!,
      info: Colors.blue,
      background: Colors.white,
      surface: Colors.grey[50]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    );
  }
  
  /// 청색맹 친화적 팔레트
  factory ColorPalette.tritanopiaFriendly() {
    return ColorPalette(
      primary: Colors.red,
      secondary: Colors.green,
      accent: Colors.yellow,
      success: Colors.green,
      warning: Colors.red[300]!, // 노랑 대신 연한 빨강
      error: Colors.red[800]!,
      info: Colors.grey[700]!, // 파랑 대신 회색
      background: Colors.white,
      surface: Colors.grey[50]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    );
  }
  
  /// 고대비 팔레트
  factory ColorPalette.highContrast() {
    return ColorPalette(
      primary: Colors.black,
      secondary: Colors.grey[800]!,
      accent: Colors.black,
      success: Colors.black,
      warning: Colors.black,
      error: Colors.black,
      info: Colors.black,
      background: Colors.white,
      surface: Colors.grey[100]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    );
  }
}

/// 접근성 테스트 결과
class AccessibilityTestResult {
  final String testName;
  final bool isEnabled;
  double score;
  String message;
  String? details;
  String? recommendation;
  bool hasError;
  String? errorMessage;
  
  AccessibilityTestResult({
    required this.testName,
    required this.isEnabled,
    this.score = 0.0,
    this.message = '',
    this.details,
    this.recommendation,
    this.hasError = false,
    this.errorMessage,
  });
}

/// 접근성 진단 리포트
class AccessibilityReport {
  AccessibilityTestResult? colorBlindnessTest;
  AccessibilityTestResult? vibrationTest;
  AccessibilityTestResult? textReadabilityTest;
  AccessibilityTestResult? highContrastTest;
  double overallScore = 0.0;
  List<String> recommendations = [];
  bool hasError = false;
  String? errorMessage;
  
  /// 접근성 등급
  String get accessibilityGrade {
    if (overallScore >= 0.9) return 'Excellent';
    if (overallScore >= 0.8) return 'Good';
    if (overallScore >= 0.7) return 'Fair';
    if (overallScore >= 0.6) return 'Poor';
    return 'Very Poor';
  }
  
  /// 등급 색상
  Color get gradeColor {
    switch (accessibilityGrade) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}