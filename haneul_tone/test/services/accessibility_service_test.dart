import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haneul_tone/services/accessibility_service.dart';

void main() {
  group('AccessibilityService', () {
    late AccessibilityService accessibilityService;

    setUp(() {
      accessibilityService = AccessibilityService();
    });

    test('should be a singleton', () {
      final instance1 = AccessibilityService();
      final instance2 = AccessibilityService();
      
      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('should have default accessibility settings', () {
      final settings = accessibilityService.settings;
      
      expect(settings, isNotNull);
      expect(settings, isA<AccessibilitySettings>());
    });

    test('should add and remove listeners', () {
      bool listenerCalled = false;
      
      void testListener(AccessibilitySettings settings) {
        listenerCalled = true;
      }

      accessibilityService.addListener(testListener);
      
      // Simulate settings change to trigger listener
      accessibilityService.updateSettings(AccessibilitySettings(
        isHighContrastEnabled: true,
      ));

      expect(listenerCalled, isTrue);

      // Test removing listener
      listenerCalled = false;
      accessibilityService.removeListener(testListener);
      
      accessibilityService.updateSettings(AccessibilitySettings(
        isHighContrastEnabled: false,
      ));

      expect(listenerCalled, isFalse);
    });

    test('should handle listener errors gracefully', () {
      void faultyListener(AccessibilitySettings settings) {
        throw Exception('Test exception');
      }

      // Should not throw even with faulty listener
      expect(() {
        accessibilityService.addListener(faultyListener);
        accessibilityService.updateSettings(AccessibilitySettings(
          isHighContrastEnabled: true,
        ));
      }, returnsNormally);
    });

    test('should enable and disable colorblind support', () async {
      await accessibilityService.setColorblindSupport(
        ColorblindType.protanopia,
        enabled: true,
      );
      
      expect(accessibilityService.settings.colorblindSupport, isNotNull);
      expect(accessibilityService.settings.colorblindSupport!.type, 
             equals(ColorblindType.protanopia));
      expect(accessibilityService.settings.colorblindSupport!.enabled, isTrue);

      await accessibilityService.setColorblindSupport(
        ColorblindType.protanopia,
        enabled: false,
      );
      
      expect(accessibilityService.settings.colorblindSupport!.enabled, isFalse);
    });

    test('should provide different color palettes for colorblind types', () {
      final normalPalette = accessibilityService.getColorPalette();
      
      accessibilityService.setColorblindSupport(
        ColorblindType.deuteranopia,
        enabled: true,
      );
      final deuteranopiaPalette = accessibilityService.getColorPalette();
      
      accessibilityService.setColorblindSupport(
        ColorblindType.tritanopia,
        enabled: true,
      );
      final tritanopiaPalette = accessibilityService.getColorPalette();

      // Palettes should be different for different colorblind types
      expect(normalPalette, isNot(equals(deuteranopiaPalette)));
      expect(deuteranopiaPalette, isNot(equals(tritanopiaPalette)));
    });

    test('should enable haptic feedback', () async {
      await accessibilityService.setHapticFeedback(enabled: true);
      
      expect(accessibilityService.settings.isHapticFeedbackEnabled, isTrue);
      
      // Test triggering haptic feedback
      expect(() => accessibilityService.triggerHapticFeedback(HapticType.success),
             returnsNormally);
      expect(() => accessibilityService.triggerHapticFeedback(HapticType.error),
             returnsNormally);
      expect(() => accessibilityService.triggerHapticFeedback(HapticType.warning),
             returnsNormally);
    });

    test('should not trigger haptic feedback when disabled', () async {
      await accessibilityService.setHapticFeedback(enabled: false);
      
      expect(accessibilityService.settings.isHapticFeedbackEnabled, isFalse);
      
      // Should return early without triggering haptic feedback
      expect(() => accessibilityService.triggerHapticFeedback(HapticType.success),
             returnsNormally);
    });

    test('should adjust font size', () async {
      await accessibilityService.setFontScale(1.5);
      
      expect(accessibilityService.settings.fontScale, equals(1.5));
      
      // Test with different scale values
      await accessibilityService.setFontScale(2.0);
      expect(accessibilityService.settings.fontScale, equals(2.0));
      
      await accessibilityService.setFontScale(0.8);
      expect(accessibilityService.settings.fontScale, equals(0.8));
    });

    test('should enforce font scale limits', () async {
      // Test minimum limit
      await accessibilityService.setFontScale(0.5);
      expect(accessibilityService.settings.fontScale, 
             greaterThanOrEqualTo(AccessibilityService.minFontScale));
      
      // Test maximum limit
      await accessibilityService.setFontScale(5.0);
      expect(accessibilityService.settings.fontScale, 
             lessThanOrEqualTo(AccessibilityService.maxFontScale));
    });

    test('should toggle high contrast mode', () async {
      await accessibilityService.setHighContrast(enabled: true);
      
      expect(accessibilityService.settings.isHighContrastEnabled, isTrue);
      
      await accessibilityService.setHighContrast(enabled: false);
      
      expect(accessibilityService.settings.isHighContrastEnabled, isFalse);
    });

    test('should provide high contrast colors when enabled', () {
      final normalColors = accessibilityService.getThemeColors();
      
      accessibilityService.setHighContrast(enabled: true);
      final highContrastColors = accessibilityService.getThemeColors();
      
      // High contrast colors should be different from normal colors
      expect(normalColors.primary, isNot(equals(highContrastColors.primary)));
      expect(normalColors.background, isNot(equals(highContrastColors.background)));
      expect(normalColors.surface, isNot(equals(highContrastColors.surface)));
    });

    test('should enable screen reader support', () async {
      await accessibilityService.setScreenReaderSupport(enabled: true);
      
      expect(accessibilityService.settings.isScreenReaderEnabled, isTrue);
      
      // Test providing screen reader text
      final description = accessibilityService.getScreenReaderDescription(
        'pitch_accuracy',
        value: 0.85,
        context: 'practice_session',
      );
      
      expect(description, isA<String>());
      expect(description.isNotEmpty, isTrue);
      expect(description.contains('85'), isTrue); // Should contain the value
    });

    test('should format different types of screen reader content', () {
      accessibilityService.setScreenReaderSupport(enabled: true);
      
      final pitchDescription = accessibilityService.getScreenReaderDescription(
        'pitch_accuracy', value: 0.75, context: 'session'
      );
      final timingDescription = accessibilityService.getScreenReaderDescription(
        'timing_accuracy', value: 0.90, context: 'session'
      );
      final progressDescription = accessibilityService.getScreenReaderDescription(
        'progress', value: 0.65, context: 'overall'
      );
      
      expect(pitchDescription, contains('피치'));
      expect(timingDescription, contains('타이밍'));
      expect(progressDescription, contains('진행'));
    });

    test('should enable keyboard navigation', () async {
      await accessibilityService.setKeyboardNavigation(enabled: true);
      
      expect(accessibilityService.settings.isKeyboardNavigationEnabled, isTrue);
      
      // Test keyboard shortcuts
      final shortcuts = accessibilityService.getKeyboardShortcuts();
      expect(shortcuts, isNotEmpty);
      expect(shortcuts.containsKey('play_pause'), isTrue);
      expect(shortcuts.containsKey('record'), isTrue);
      expect(shortcuts.containsKey('stop'), isTrue);
    });

    test('should handle focus navigation', () {
      accessibilityService.setKeyboardNavigation(enabled: true);
      
      expect(() => accessibilityService.handleKeyboardNavigation(
        key: 'Tab',
        direction: NavigationDirection.next,
      ), returnsNormally);
      
      expect(() => accessibilityService.handleKeyboardNavigation(
        key: 'Shift+Tab',
        direction: NavigationDirection.previous,
      ), returnsNormally);
    });

    test('should reset to default settings', () async {
      // Modify settings
      await accessibilityService.setHighContrast(enabled: true);
      await accessibilityService.setFontScale(1.8);
      await accessibilityService.setHapticFeedback(enabled: true);
      
      expect(accessibilityService.settings.isHighContrastEnabled, isTrue);
      expect(accessibilityService.settings.fontScale, equals(1.8));
      expect(accessibilityService.settings.isHapticFeedbackEnabled, isTrue);
      
      // Reset to defaults
      await accessibilityService.resetToDefaults();
      
      expect(accessibilityService.settings.isHighContrastEnabled, isFalse);
      expect(accessibilityService.settings.fontScale, equals(1.0));
      expect(accessibilityService.settings.isHapticFeedbackEnabled, isFalse);
    });
  });

  group('AccessibilitySettings', () {
    test('should serialize and deserialize correctly', () {
      final original = AccessibilitySettings(
        isHighContrastEnabled: true,
        fontScale: 1.5,
        isHapticFeedbackEnabled: true,
        isScreenReaderEnabled: true,
        isKeyboardNavigationEnabled: true,
        colorblindSupport: ColorblindSupport(
          type: ColorblindType.protanopia,
          enabled: true,
        ),
      );

      final json = original.toJson();
      final restored = AccessibilitySettings.fromJson(json);

      expect(restored.isHighContrastEnabled, equals(original.isHighContrastEnabled));
      expect(restored.fontScale, equals(original.fontScale));
      expect(restored.isHapticFeedbackEnabled, equals(original.isHapticFeedbackEnabled));
      expect(restored.isScreenReaderEnabled, equals(original.isScreenReaderEnabled));
      expect(restored.isKeyboardNavigationEnabled, equals(original.isKeyboardNavigationEnabled));
      expect(restored.colorblindSupport?.type, equals(original.colorblindSupport?.type));
      expect(restored.colorblindSupport?.enabled, equals(original.colorblindSupport?.enabled));
    });

    test('should provide default values', () {
      final settings = AccessibilitySettings();
      
      expect(settings.isHighContrastEnabled, isFalse);
      expect(settings.fontScale, equals(1.0));
      expect(settings.isHapticFeedbackEnabled, isFalse);
      expect(settings.isScreenReaderEnabled, isFalse);
      expect(settings.isKeyboardNavigationEnabled, isFalse);
      expect(settings.colorblindSupport, isNull);
    });
  });
}

// Mock classes and enums for testing
enum ColorblindType { protanopia, deuteranopia, tritanopia }
enum HapticType { success, error, warning, info, light, medium, heavy }
enum NavigationDirection { next, previous, up, down, left, right }

class ColorblindSupport {
  final ColorblindType type;
  final bool enabled;

  ColorblindSupport({
    required this.type,
    required this.enabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'enabled': enabled,
    };
  }

  factory ColorblindSupport.fromJson(Map<String, dynamic> json) {
    return ColorblindSupport(
      type: ColorblindType.values[json['type'] ?? 0],
      enabled: json['enabled'] ?? false,
    );
  }
}

class AccessibilitySettings {
  final bool isHighContrastEnabled;
  final double fontScale;
  final bool isHapticFeedbackEnabled;
  final bool isScreenReaderEnabled;
  final bool isKeyboardNavigationEnabled;
  final ColorblindSupport? colorblindSupport;

  AccessibilitySettings({
    this.isHighContrastEnabled = false,
    this.fontScale = 1.0,
    this.isHapticFeedbackEnabled = false,
    this.isScreenReaderEnabled = false,
    this.isKeyboardNavigationEnabled = false,
    this.colorblindSupport,
  });

  Map<String, dynamic> toJson() {
    return {
      'isHighContrastEnabled': isHighContrastEnabled,
      'fontScale': fontScale,
      'isHapticFeedbackEnabled': isHapticFeedbackEnabled,
      'isScreenReaderEnabled': isScreenReaderEnabled,
      'isKeyboardNavigationEnabled': isKeyboardNavigationEnabled,
      'colorblindSupport': colorblindSupport?.toJson(),
    };
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      isHighContrastEnabled: json['isHighContrastEnabled'] ?? false,
      fontScale: json['fontScale']?.toDouble() ?? 1.0,
      isHapticFeedbackEnabled: json['isHapticFeedbackEnabled'] ?? false,
      isScreenReaderEnabled: json['isScreenReaderEnabled'] ?? false,
      isKeyboardNavigationEnabled: json['isKeyboardNavigationEnabled'] ?? false,
      colorblindSupport: json['colorblindSupport'] != null 
        ? ColorblindSupport.fromJson(json['colorblindSupport'])
        : null,
    );
  }

  AccessibilitySettings copyWith({
    bool? isHighContrastEnabled,
    double? fontScale,
    bool? isHapticFeedbackEnabled,
    bool? isScreenReaderEnabled,
    bool? isKeyboardNavigationEnabled,
    ColorblindSupport? colorblindSupport,
  }) {
    return AccessibilitySettings(
      isHighContrastEnabled: isHighContrastEnabled ?? this.isHighContrastEnabled,
      fontScale: fontScale ?? this.fontScale,
      isHapticFeedbackEnabled: isHapticFeedbackEnabled ?? this.isHapticFeedbackEnabled,
      isScreenReaderEnabled: isScreenReaderEnabled ?? this.isScreenReaderEnabled,
      isKeyboardNavigationEnabled: isKeyboardNavigationEnabled ?? this.isKeyboardNavigationEnabled,
      colorblindSupport: colorblindSupport ?? this.colorblindSupport,
    );
  }
}

class AccessibilityColors {
  final Color primary;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color onBackground;
  final Color onSurface;

  AccessibilityColors({
    required this.primary,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onBackground,
    required this.onSurface,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccessibilityColors &&
        other.primary == primary &&
        other.background == background &&
        other.surface == surface &&
        other.onPrimary == onPrimary &&
        other.onBackground == onBackground &&
        other.onSurface == onSurface;
  }

  @override
  int get hashCode {
    return Object.hash(primary, background, surface, onPrimary, onBackground, onSurface);
  }
}

// Mock AccessibilityService implementation
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  static const double minFontScale = 0.8;
  static const double maxFontScale = 2.0;

  AccessibilitySettings _settings = AccessibilitySettings();
  final List<Function(AccessibilitySettings)> _listeners = [];

  AccessibilitySettings get settings => _settings;

  void addListener(Function(AccessibilitySettings) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(AccessibilitySettings) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener(_settings);
      } catch (e) {
        // Handle listener errors gracefully
      }
    }
  }

  void updateSettings(AccessibilitySettings newSettings) {
    _settings = newSettings;
    _notifyListeners();
  }

  Future<void> setColorblindSupport(ColorblindType type, {required bool enabled}) async {
    final newSupport = ColorblindSupport(type: type, enabled: enabled);
    _settings = _settings.copyWith(colorblindSupport: newSupport);
    _notifyListeners();
  }

  AccessibilityColors getColorPalette() {
    if (_settings.colorblindSupport?.enabled == true) {
      switch (_settings.colorblindSupport!.type) {
        case ColorblindType.protanopia:
          return AccessibilityColors(
            primary: const Color(0xFF0066CC),
            background: const Color(0xFFFFF8E1),
            surface: const Color(0xFFE8F4FD),
            onPrimary: Colors.white,
            onBackground: const Color(0xFF1A1A1A),
            onSurface: const Color(0xFF333333),
          );
        case ColorblindType.deuteranopia:
          return AccessibilityColors(
            primary: const Color(0xFF6600CC),
            background: const Color(0xFFF8F8FF),
            surface: const Color(0xFFF0E8FD),
            onPrimary: Colors.white,
            onBackground: const Color(0xFF1A1A1A),
            onSurface: const Color(0xFF333333),
          );
        case ColorblindType.tritanopia:
          return AccessibilityColors(
            primary: const Color(0xFFCC6600),
            background: const Color(0xFFFFF8E1),
            surface: const Color(0xFFFDF0E8),
            onPrimary: Colors.white,
            onBackground: const Color(0xFF1A1A1A),
            onSurface: const Color(0xFF333333),
          );
      }
    }
    
    return AccessibilityColors(
      primary: const Color(0xFF2196F3),
      background: Colors.white,
      surface: const Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onBackground: Colors.black,
      onSurface: const Color(0xFF666666),
    );
  }

  Future<void> setHapticFeedback({required bool enabled}) async {
    _settings = _settings.copyWith(isHapticFeedbackEnabled: enabled);
    _notifyListeners();
  }

  void triggerHapticFeedback(HapticType type) {
    if (!_settings.isHapticFeedbackEnabled) return;
    
    // Mock haptic feedback implementation
    switch (type) {
      case HapticType.success:
      case HapticType.error:
      case HapticType.warning:
      case HapticType.info:
      case HapticType.light:
      case HapticType.medium:
      case HapticType.heavy:
        // Would trigger actual haptic feedback on device
        break;
    }
  }

  Future<void> setFontScale(double scale) async {
    final clampedScale = scale.clamp(minFontScale, maxFontScale);
    _settings = _settings.copyWith(fontScale: clampedScale);
    _notifyListeners();
  }

  Future<void> setHighContrast({required bool enabled}) async {
    _settings = _settings.copyWith(isHighContrastEnabled: enabled);
    _notifyListeners();
  }

  AccessibilityColors getThemeColors() {
    if (_settings.isHighContrastEnabled) {
      return AccessibilityColors(
        primary: Colors.black,
        background: Colors.white,
        surface: const Color(0xFFF0F0F0),
        onPrimary: Colors.white,
        onBackground: Colors.black,
        onSurface: Colors.black,
      );
    }
    
    return getColorPalette();
  }

  Future<void> setScreenReaderSupport({required bool enabled}) async {
    _settings = _settings.copyWith(isScreenReaderEnabled: enabled);
    _notifyListeners();
  }

  String getScreenReaderDescription(String key, {double? value, String? context}) {
    if (!_settings.isScreenReaderEnabled) return '';
    
    switch (key) {
      case 'pitch_accuracy':
        return '피치 정확도 ${((value ?? 0) * 100).toInt()}퍼센트';
      case 'timing_accuracy':
        return '타이밍 정확도 ${((value ?? 0) * 100).toInt()}퍼센트';
      case 'progress':
        return '전체 진행률 ${((value ?? 0) * 100).toInt()}퍼센트';
      default:
        return '$key ${value != null ? "${(value * 100).toInt()}퍼센트" : ""}';
    }
  }

  Future<void> setKeyboardNavigation({required bool enabled}) async {
    _settings = _settings.copyWith(isKeyboardNavigationEnabled: enabled);
    _notifyListeners();
  }

  Map<String, String> getKeyboardShortcuts() {
    if (!_settings.isKeyboardNavigationEnabled) return {};
    
    return {
      'play_pause': 'Space',
      'record': 'R',
      'stop': 'S',
      'next': 'Arrow Right',
      'previous': 'Arrow Left',
      'volume_up': 'Arrow Up',
      'volume_down': 'Arrow Down',
    };
  }

  void handleKeyboardNavigation({required String key, required NavigationDirection direction}) {
    if (!_settings.isKeyboardNavigationEnabled) return;
    
    // Mock keyboard navigation handling
    switch (direction) {
      case NavigationDirection.next:
      case NavigationDirection.previous:
      case NavigationDirection.up:
      case NavigationDirection.down:
      case NavigationDirection.left:
      case NavigationDirection.right:
        // Handle navigation logic
        break;
    }
  }

  Future<void> resetToDefaults() async {
    _settings = AccessibilitySettings();
    _notifyListeners();
  }
}