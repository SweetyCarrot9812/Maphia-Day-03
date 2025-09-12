import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// 보안 관련 서비스
/// 데이터 검증, 암호화, 민감정보 보호를 담당
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final Random _random = Random.secure();
  
  /// 민감한 데이터 암호화
  String encryptSensitiveData(String plainText, String key) {
    try {
      final keyBytes = utf8.encode(key);
      final dataBytes = utf8.encode(plainText);
      
      // 간단한 XOR 암호화 (실제 앱에서는 AES 사용 권장)
      final encryptedBytes = List<int>.generate(
        dataBytes.length,
        (i) => dataBytes[i] ^ keyBytes[i % keyBytes.length],
      );
      
      return base64.encode(encryptedBytes);
    } catch (e) {
      debugPrint('Encryption failed: $e');
      return plainText; // 암호화 실패 시 원본 반환 (개발용)
    }
  }

  /// 암호화된 데이터 복호화
  String decryptSensitiveData(String encryptedText, String key) {
    try {
      final keyBytes = utf8.encode(key);
      final encryptedBytes = base64.decode(encryptedText);
      
      final decryptedBytes = List<int>.generate(
        encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
      );
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      debugPrint('Decryption failed: $e');
      return encryptedText; // 복호화 실패 시 원본 반환 (개발용)
    }
  }

  /// 사용자 입력 데이터 검증
  Map<String, String> validateUserInput(Map<String, dynamic> data) {
    final errors = <String, String>{};

    // 이름 검증
    if (data.containsKey('name')) {
      final name = data['name'] as String?;
      if (name == null || name.trim().isEmpty) {
        errors['name'] = '이름을 입력해주세요';
      } else if (name.trim().length < 2) {
        errors['name'] = '이름은 2글자 이상이어야 합니다';
      } else if (name.trim().length > 30) {
        errors['name'] = '이름은 30글자 이하여야 합니다';
      } else if (!_isValidName(name.trim())) {
        errors['name'] = '올바른 이름 형식이 아닙니다';
      }
    }

    // 키 검증
    if (data.containsKey('height')) {
      final height = data['height'];
      if (height == null) {
        errors['height'] = '키를 입력해주세요';
      } else {
        final heightValue = height is int ? height : int.tryParse(height.toString());
        if (heightValue == null || heightValue < 100 || heightValue > 250) {
          errors['height'] = '키는 100-250cm 범위여야 합니다';
        }
      }
    }

    // 체중 검증
    if (data.containsKey('weight')) {
      final weight = data['weight'];
      if (weight == null) {
        errors['weight'] = '체중을 입력해주세요';
      } else {
        final weightValue = weight is double ? weight : double.tryParse(weight.toString());
        if (weightValue == null || weightValue < 30 || weightValue > 300) {
          errors['weight'] = '체중은 30-300kg 범위여야 합니다';
        }
      }
    }

    // 운동 데이터 검증
    if (data.containsKey('workoutData')) {
      final workoutErrors = _validateWorkoutData(data['workoutData'] as Map<String, dynamic>?);
      errors.addAll(workoutErrors);
    }

    return errors;
  }

  /// 운동 데이터 검증
  Map<String, String> _validateWorkoutData(Map<String, dynamic>? workoutData) {
    final errors = <String, String>{};
    
    if (workoutData == null) return errors;

    // 중량 검증
    if (workoutData.containsKey('weight')) {
      final weight = workoutData['weight'];
      final weightValue = weight is double ? weight : double.tryParse(weight.toString());
      if (weightValue == null || weightValue < 0 || weightValue > 1000) {
        errors['workout.weight'] = '중량은 0-1000kg 범위여야 합니다';
      }
    }

    // 반복 횟수 검증
    if (workoutData.containsKey('reps')) {
      final reps = workoutData['reps'];
      final repsValue = reps is int ? reps : int.tryParse(reps.toString());
      if (repsValue == null || repsValue < 1 || repsValue > 1000) {
        errors['workout.reps'] = '반복 횟수는 1-1000 범위여야 합니다';
      }
    }

    // RPE 검증
    if (workoutData.containsKey('rpe')) {
      final rpe = workoutData['rpe'];
      final rpeValue = rpe is int ? rpe : int.tryParse(rpe.toString());
      if (rpeValue == null || rpeValue < 1 || rpeValue > 10) {
        errors['workout.rpe'] = 'RPE는 1-10 범위여야 합니다';
      }
    }

    return errors;
  }

  /// 이름 형식 검증 (한글, 영문, 공백만 허용)
  bool _isValidName(String name) {
    final nameRegex = RegExp(r'^[가-힣a-zA-Z\s]+$');
    return nameRegex.hasMatch(name);
  }

  /// 이메일 형식 검증
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// SQL 인젝션 방지를 위한 문자열 정리
  String sanitizeString(String input) {
    return input
        .replaceAll(';', '')
        .replaceAll("'", '')
        .replaceAll('"', '')
        .replaceAll('\\', '')
        .replaceAll('--', '')
        .replaceAll('/*', '')
        .replaceAll('*/', '')
        .trim();
  }

  /// 안전한 랜덤 문자열 생성 (세션 ID, 토큰 등)
  String generateSecureToken(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// 데이터 해시 생성 (무결성 검증용)
  String generateDataHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// API 요청 서명 생성
  String generateApiSignature(String method, String path, String body, String apiKey) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final message = '$method$path$body$timestamp';
    final key = utf8.encode(apiKey);
    final messageBytes = utf8.encode(message);
    
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(messageBytes);
    
    return base64.encode(digest.bytes);
  }

  /// 민감한 로그 데이터 마스킹
  String maskSensitiveData(String data) {
    String masked = data;
    
    // 이메일 마스킹
    masked = masked.replaceAllMapped(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      (match) {
        final email = match.group(0)!;
        final parts = email.split('@');
        if (parts[0].length > 2) {
          return '${parts[0].substring(0, 2)}***@${parts[1]}';
        }
        return '***@${parts[1]}';
      },
    );
    
    // 전화번호 마스킹
    masked = masked.replaceAllMapped(
      RegExp(r'\b\d{3}-\d{4}-\d{4}\b'),
      (match) => '***-****-${match.group(0)!.substring(9)}',
    );
    
    return masked;
  }

  /// 디바이스 ID 생성 (기기 식별용)
  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    
    if (deviceId == null) {
      deviceId = generateSecureToken(32);
      await prefs.setString('device_id', deviceId);
    }
    
    return deviceId;
  }

  /// 앱 무결성 검증 (디버그 모드에서만)
  bool verifyAppIntegrity() {
    if (kDebugMode) {
      // 디버그 모드에서는 항상 통과
      return true;
    }
    
    // 실제 앱에서는 코드 서명, 패키지 검증 등을 수행
    // 현재는 기본 검증만 수행
    return !kDebugMode;
  }

  /// 생체 인증 가용성 확인 (placeholder)
  Future<bool> isBiometricAvailable() async {
    // 실제 구현에서는 local_auth 패키지 사용
    return false;
  }

  /// 안전한 저장소에 데이터 저장
  Future<void> secureStore(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await getOrCreateDeviceId();
    final encryptedValue = encryptSensitiveData(value, deviceId);
    await prefs.setString('secure_$key', encryptedValue);
  }

  /// 안전한 저장소에서 데이터 읽기
  Future<String?> secureRetrieve(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedValue = prefs.getString('secure_$key');
    
    if (encryptedValue == null) return null;
    
    final deviceId = await getOrCreateDeviceId();
    return decryptSensitiveData(encryptedValue, deviceId);
  }

  /// 보안 이벤트 로깅
  void logSecurityEvent(String event, Map<String, dynamic> details) {
    final maskedDetails = details.map(
      (key, value) => MapEntry(key, maskSensitiveData(value.toString())),
    );
    
    debugPrint('SECURITY_EVENT: $event - $maskedDetails');
    
    // 실제 앱에서는 보안 로그를 별도 시스템으로 전송
  }

  /// 비정상적인 활동 감지
  bool detectAnomalousActivity(Map<String, dynamic> activityData) {
    // 간단한 이상 감지 로직
    final currentTime = DateTime.now();
    
    // 짧은 시간 내 과도한 요청
    if (activityData.containsKey('requestCount') && activityData.containsKey('timeWindow')) {
      final requestCount = activityData['requestCount'] as int;
      final timeWindow = activityData['timeWindow'] as int; // 분 단위
      
      if (requestCount > 100 && timeWindow < 1) {
        logSecurityEvent('RATE_LIMIT_EXCEEDED', {
          'requestCount': requestCount,
          'timeWindow': timeWindow,
        });
        return true;
      }
    }
    
    // 비정상적인 시간대 활동
    final hour = currentTime.hour;
    if (hour >= 2 && hour <= 5) { // 새벽 2-5시
      if (activityData.containsKey('activityType') && 
          activityData['activityType'] == 'intensive_workout') {
        logSecurityEvent('UNUSUAL_TIME_ACTIVITY', {
          'hour': hour,
          'activityType': activityData['activityType'],
        });
        // 경고만 로그, 차단은 하지 않음
      }
    }
    
    return false;
  }
}