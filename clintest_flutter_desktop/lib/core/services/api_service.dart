import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'http://localhost:3001';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 인터셉터 추가
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // 헬스 체크
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data;
    } on DioException catch (e) {
      throw ApiException('Health check failed: ${e.message}');
    }
  }

  // 간호사 과목 조회
  Future<List<dynamic>> getNursingSubjects() async {
    try {
      final response = await _dio.get('/api/nursing/subjects');
      return response.data;
    } on DioException catch (e) {
      throw ApiException('Failed to get nursing subjects: ${e.message}');
    }
  }

  // 간호사 통계
  Future<Map<String, dynamic>> getNursingStats() async {
    try {
      final response = await _dio.get('/api/nursing/stats');
      return response.data;
    } on DioException catch (e) {
      throw ApiException('Failed to get nursing stats: ${e.message}');
    }
  }

  // Jobs 통계
  Future<Map<String, dynamic>> getJobsStats() async {
    try {
      final response = await _dio.get('/api/jobs/stats');
      return response.data;
    } on DioException catch (e) {
      throw ApiException('Failed to get jobs stats: ${e.message}');
    }
  }

  // SRS 통계 조회
  Future<Map<String, dynamic>> getSrsStats(String userId) async {
    try {
      final response = await _dio.get('/api/srs/stats/$userId');
      return response.data;
    } on DioException catch (e) {
      throw ApiException('Failed to get SRS stats: ${e.message}');
    }
  }

  // AI 파이프라인 상태
  Future<Map<String, dynamic>> getAiStatus() async {
    try {
      final response = await _dio.get('/api/ai/status');
      return response.data;
    } on DioException catch (e) {
      throw ApiException('Failed to get AI status: ${e.message}');
    }
  }

  // 비용 트래킹 요약
  Future<Map<String, dynamic>> getCostSummary() async {
    try {
      final response = await _dio.get('/api/costs/summary');
      return response.data;
    } on DioException catch (e) {
      throw ApiException('Failed to get cost summary: ${e.message}');
    }
  }

  // Hanoa 상태
  Future<Map<String, dynamic>> getHanoaStatus() async {
    try {
      final response = await _dio.get('/api/hanoa/status');
      return response.data;
    } on DioException catch (e) {
      throw ApiException('Failed to get Hanoa status: ${e.message}');
    }
  }
}

// API 예외 클래스
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

// Riverpod Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());