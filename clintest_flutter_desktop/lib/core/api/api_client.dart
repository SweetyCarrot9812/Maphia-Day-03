import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;
  static const String baseUrl = 'http://localhost:8000';

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 인터셉터 추가
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;

  // GET 요청
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // POST 요청
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  // PUT 요청
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  // DELETE 요청
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}