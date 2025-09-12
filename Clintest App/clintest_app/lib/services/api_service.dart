import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'storage_service.dart';

class ApiService extends ChangeNotifier {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  
  String get _baseUrl => StorageService.apiBaseUrl;
  
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    if (StorageService.authToken != null)
      'Authorization': 'Bearer ${StorageService.authToken}',
  };

  // GET 요청
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint')
          .replace(queryParameters: queryParams);
      
      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(timeout ?? _defaultTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('GET 요청 실패: $e');
    }
  }

  // POST 요청
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      // 디버깅 로그
      debugPrint('🌐 POST 요청: $uri');
      debugPrint('📋 Headers: $_defaultHeaders');
      debugPrint('📦 Body: ${body != null ? json.encode(body) : null}');
      
      final response = await http
          .post(
            uri,
            headers: _defaultHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout ?? _defaultTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('POST 요청 실패: $e');
    }
  }

  // PUT 요청
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await http
          .put(
            uri,
            headers: _defaultHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout ?? _defaultTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('PUT 요청 실패: $e');
    }
  }

  // DELETE 요청
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await http
          .delete(uri, headers: _defaultHeaders)
          .timeout(timeout ?? _defaultTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('DELETE 요청 실패: $e');
    }
  }

  // 응답 처리
  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('📈 응답 상태: ${response.statusCode}');
    debugPrint('📄 응답 본문: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException('응답 파싱 실패: ${response.body}');
      }
    } else {
      String errorMessage = '서버 오류 (${response.statusCode})';
      
      try {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (e) {
        // JSON 파싱 실패 시 원래 메시지 사용
      }
      
      throw ApiException(errorMessage);
    }
  }
}

// API 예외 클래스
class ApiException implements Exception {
  final String message;
  
  const ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}