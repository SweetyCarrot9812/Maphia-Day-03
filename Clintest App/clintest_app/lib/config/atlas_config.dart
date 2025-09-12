class AtlasConfig {
  // Vercel 배포된 서버 (어디서든 접근 가능)
  static const String baseUrl = 'https://clintest-git-main-tkandpf26-9808s-projects.vercel.app';
  
  // 인증 엔드포인트들
  static const String authBaseUrl = '$baseUrl/api/auth';
  static const String registerEndpoint = '$authBaseUrl/register';
  static const String loginEndpoint = '$authBaseUrl/login';
  static const String refreshEndpoint = '$authBaseUrl/refresh';
  
  // GraphQL 엔드포인트 (사용자 데이터 CRUD)
  static const String graphqlEndpoint = '$baseUrl/graphql';
  
  // 기본 헤더
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // 인증된 요청용 헤더 생성
  static Map<String, String> getAuthHeaders(String accessToken) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $accessToken',
    };
  }
}

// Atlas App Services 응답 모델들
class AtlasAuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String? deviceId;
  
  const AtlasAuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    this.deviceId,
  });
  
  factory AtlasAuthResponse.fromJson(Map<String, dynamic> json) {
    return AtlasAuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      userId: json['user_id'] ?? '',
      deviceId: json['device_id'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_id': userId,
      'device_id': deviceId,
    };
  }
}

class AtlasUser {
  final String id;
  final String email;
  final String? name;
  final String role;
  final Map<String, dynamic>? customData;
  
  const AtlasUser({
    required this.id,
    required this.email,
    this.name,
    this.role = 'student',
    this.customData,
  });
  
  factory AtlasUser.fromJson(Map<String, dynamic> json) {
    return AtlasUser(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      role: json['role'] ?? 'student',
      customData: json['custom_data'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'custom_data': customData,
    };
  }
}