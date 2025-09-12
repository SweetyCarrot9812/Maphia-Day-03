import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/api_config.dart';
import 'sync_service.dart';

/// MongoDB API 연동 서비스
class MongoDBService {
  // MongoDB API 엔드포인트 (로컬 개발 환경)
  static String get _base => ApiConfig.api('');
  // 안드로이드 에뮬레이터에서는 10.0.2.2:3000 사용
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  static const Duration timeoutDuration = Duration(seconds: 12);
  
  /// 사용자 회원가입
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String username,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_base}auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'displayName': displayName,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류: $e',
      };
    }
  }

  /// 사용자 로그인
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_base}auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류: $e',
      };
    }
  }

  /// 사용자 프로필 가져오기
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${_base}user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류: $e',
      };
    }
  }

  /// 사용자 프로필 업데이트
  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${_base}user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류: $e',
      };
    }
  }

  /// 사용자 연습 세션 저장
  static Future<Map<String, dynamic>> saveSession({
    required String token,
    required Map<String, dynamic> sessionData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_base}sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(sessionData),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'session': data['session'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to save session',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류: $e',
      };
    }
  }

  /// 사용자 연습 세션 목록 가져오기
  static Future<Map<String, dynamic>> getUserSessions({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${_base}sessions?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'sessions': data['sessions'],
          'totalCount': data['totalCount'],
          'currentPage': data['currentPage'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get sessions',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류: $e',
      };
    }
  }

  /// 비밀번호 변경
  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${_base}auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류: $e',
      };
    }
  }
}
