import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'security_service.dart';
import 'performance_service.dart';

/// 향상된 API 클라이언트
/// 보안, 성능 모니터링, 오프라인 지원, 재시도 로직 포함
class ApiClient {
  final Dio dio;
  final SecurityService _security = SecurityService();
  final PerformanceService _performance = PerformanceService();
  
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  ApiClient._(this.dio);

  factory ApiClient() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3004';
    final apiKey = dotenv.env['API_KEY'];
    final jwtAud = dotenv.env['JWT_AUD'] ?? 'areumfit-app';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'AreumFit/1.0.0 (${Platform.operatingSystem})',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final client = ApiClient._(dio);
    client._setupInterceptors(apiKey, jwtAud);
    
    return client;
  }

  /// 인터셉터 설정
  void _setupInterceptors(String? apiKey, String jwtAud) {
    // 요청 인터셉터
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 성능 모니터링 시작
          _performance.startOperation('api_${options.path}');
          
          // API 키 첨부
          if (apiKey != null && apiKey.isNotEmpty) {
            options.headers['authorization'] = 'Bearer $apiKey';
          }
          
          // 요청 ID 생성 (추적용)
          final requestId = _security.generateSecureToken(16);
          options.headers['X-Request-ID'] = requestId;
          
          // JWT Audience 추가
          options.headers['X-JWT-Aud'] = jwtAud;
          
          // 타임스탬프 추가
          options.headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
          
          // 요청 서명 생성 (보안)
          if (apiKey != null && apiKey.isNotEmpty) {
            final method = options.method.toUpperCase();
            final path = options.path;
            final body = options.data?.toString() ?? '';
            final signature = _security.generateApiSignature(method, path, body, apiKey);
            options.headers['X-Signature'] = signature;
          }
          
          debugPrint('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        
        onResponse: (response, handler) {
          // 성능 모니터링 종료
          _performance.endOperation('api_${response.requestOptions.path}');
          
          debugPrint('API Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        
        onError: (error, handler) {
          // 성능 모니터링 종료
          _performance.endOperation('api_${error.requestOptions.path}');
          
          // 보안 이벤트 로깅
          _security.logSecurityEvent('API_ERROR', {
            'path': error.requestOptions.path,
            'statusCode': error.response?.statusCode,
            'message': error.message,
          });
          
          debugPrint('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
    
    // 재시도 인터셉터
    dio.interceptors.add(_RetryInterceptor(
      maxRetries: _maxRetries,
      retryDelay: _retryDelay,
      dio: dio,
    ));
    
    // 로깅 인터셉터 (디버그 모드에서만)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: false, // 응답 본문은 민감할 수 있으므로 제외
        error: true,
        logPrint: (object) {
          // 민감한 데이터 마스킹
          final maskedLog = _security.maskSensitiveData(object.toString());
          debugPrint(maskedLog);
        },
      ));
    }
  }

  /// GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _performance.measureNetworkRequest(
      'GET_$path',
      () => dio.get<T>(path, queryParameters: queryParameters, options: options),
    );
  }

  /// POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // 입력 데이터 검증
    if (data is Map<String, dynamic>) {
      final validationErrors = _security.validateUserInput(data);
      if (validationErrors.isNotEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          message: 'Validation failed: ${validationErrors.values.first}',
          type: DioExceptionType.badResponse,
        );
      }
    }
    
    return await _performance.measureNetworkRequest(
      'POST_$path',
      () => dio.post<T>(path, data: data, queryParameters: queryParameters, options: options),
    );
  }

  /// PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _performance.measureNetworkRequest(
      'PUT_$path',
      () => dio.put<T>(path, data: data, queryParameters: queryParameters, options: options),
    );
  }

  /// DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _performance.measureNetworkRequest(
      'DELETE_$path',
      () => dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options),
    );
  }

  /// 파일 업로드
  Future<Response> uploadFile(
    String path,
    File file, {
    String? fileName,
    Map<String, dynamic>? extraData,
    ProgressCallback? onSendProgress,
  }) async {
    // 파일 크기 체크 (50MB 제한)
    final fileSizeBytes = await file.length();
    if (fileSizeBytes > 50 * 1024 * 1024) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        message: 'File size exceeds 50MB limit',
        type: DioExceptionType.badResponse,
      );
    }
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName ?? file.path.split('/').last,
      ),
      if (extraData != null) ...extraData,
    });

    return await _performance.measureNetworkRequest(
      'UPLOAD_$path',
      () => dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      ),
    );
  }

  /// 연결 상태 확인
  Future<bool> checkConnectivity() async {
    try {
      final response = await dio.get(
        '/health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 인증 토큰 갱신
  Future<void> refreshToken() async {
    try {
      // 저장된 리프레시 토큰 조회
      final refreshToken = await _security.secureRetrieve('refresh_token');
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        
        // 새 토큰들을 안전하게 저장
        await _security.secureStore('access_token', newAccessToken);
        await _security.secureStore('refresh_token', newRefreshToken);
        
        // 요청 헤더 업데이트
        dio.options.headers['authorization'] = 'Bearer $newAccessToken';
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      rethrow;
    }
  }
}

/// 재시도 인터셉터
class _RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final Dio dio;

  _RetryInterceptor({
    required this.maxRetries,
    required this.retryDelay,
    required this.dio,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retry_count'] ?? 0;

    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    // 재시도 가능한 에러 타입 확인
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    debugPrint('Retrying request (${retryCount + 1}/$maxRetries): ${err.requestOptions.path}');
    
    // 재시도 전 대기
    await Future.delayed(retryDelay * (retryCount + 1));

    // 재시도 카운트 증가
    err.requestOptions.extra['retry_count'] = retryCount + 1;

    try {
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      handler.next(DioException(
        requestOptions: err.requestOptions,
        error: e,
        type: DioExceptionType.unknown,
      ));
    }
  }

  bool _shouldRetry(DioException err) {
    // 네트워크 연결 오류, 타임아웃, 서버 오류(5xx)는 재시도
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

