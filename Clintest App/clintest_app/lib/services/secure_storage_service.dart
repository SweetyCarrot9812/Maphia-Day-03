import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/atlas_config.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // 저장소 키들
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRole = 'user_role';
  static const String _keyAuthData = 'auth_data';

  /// 인증 토큰들 저장
  static Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      _storage.write(key: _keyUserId, value: userId),
    ]);
  }

  /// 사용자 정보 저장
  static Future<void> saveUserProfile({
    required String email,
    String? name,
    String? role,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserEmail, value: email),
      if (name != null) _storage.write(key: _keyUserName, value: name),
      if (role != null) _storage.write(key: _keyUserRole, value: role),
    ]);
  }

  /// 전체 인증 응답 저장
  static Future<void> saveAuthResponse(AtlasAuthResponse authResponse) async {
    final authDataJson = authResponse.toJson();
    await _storage.write(
      key: _keyAuthData, 
      value: authDataJson.toString(),
    );
    
    // 개별 토큰들도 저장
    await saveAuthTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      userId: authResponse.userId,
    );
  }

  /// Access Token 가져오기
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Refresh Token 가져오기
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// User ID 가져오기
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// User Email 가져오기
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// User Name 가져오기
  static Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  /// User Role 가져오기
  static Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  /// 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// 모든 인증 데이터 삭제 (로그아웃)
  static Future<void> clearAuthData() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyUserEmail),
      _storage.delete(key: _keyUserName),
      _storage.delete(key: _keyUserRole),
      _storage.delete(key: _keyAuthData),
    ]);
  }

  /// 모든 저장소 데이터 삭제
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// 저장된 모든 키들 가져오기 (디버깅용)
  static Future<Map<String, String>> getAllData() async {
    return await _storage.readAll();
  }

  /// 특정 키 존재 여부 확인
  static Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }

  /// 커스텀 데이터 저장
  static Future<void> saveCustomData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// 커스텀 데이터 가져오기
  static Future<String?> getCustomData(String key) async {
    return await _storage.read(key: key);
  }

  /// 커스텀 데이터 삭제
  static Future<void> deleteCustomData(String key) async {
    await _storage.delete(key: key);
  }
}