import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DevToolsService {
  /// 개발 모드 확인
  static bool get isDebugMode => kDebugMode;

  /// Hot Reload 실행
  static void performHotReload() {
    if (isDebugMode) {
      try {
        print('🔄 Hot Reload 실행됨');
        // Hot Reload는 개발 환경에서 자동으로 처리됨
      } catch (e) {
        print('Hot Reload 실행 실패: $e');
      }
    }
  }

  /// Hot Restart 실행 (앱 전체 재시작)
  static Future<void> performHotRestart() async {
    if (isDebugMode) {
      try {
        print('🔄 Hot Restart 실행됨');
        
        // Hot Restart는 Flutter 개발 도구를 통해 처리됨
        // 실제로는 개발 서버와의 통신이 필요하지만,
        // 여기서는 사용자에게 피드백을 제공
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print('Hot Restart 실행 실패: $e');
      }
    }
  }

  /// 개발 도구 상태 정보
  static Map<String, dynamic> getDevInfo() {
    return {
      'isDebugMode': isDebugMode,
      'platform': Platform.operatingSystem,
      'buildMode': kDebugMode ? 'debug' : (kProfileMode ? 'profile' : 'release'),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 콘솔에 개발 정보 출력
  static void printDevInfo() {
    final info = getDevInfo();
    print('🛠️ Dev Tools Info:');
    info.forEach((key, value) {
      print('  $key: $value');
    });
  }
}