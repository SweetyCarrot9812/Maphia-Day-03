import 'dart:io' show Platform;

/// Centralized API configuration for network services.
/// Resolves a sensible base URL depending on platform and environment.
class ApiConfig {
  // Compile-time override: --dart-define=HANEUL_API_BASE=https://api.example.com
  static const String _envBase = String.fromEnvironment('HANEUL_API_BASE');

  /// Returns the HTTP API base URL.
  static String get baseUrl {
    if (_envBase.isNotEmpty) return _ensureTrailingSlash(_envBase);

    // Default local dev targets
    // - Android emulator uses 10.0.2.2 to reach host machine
    // - iOS simulator and desktop/mobile target localhost
    final host = Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    return _ensureTrailingSlash(host);
  }

  static String api(String path) {
    final root = baseUrl.endsWith('/') ? '${baseUrl}api' : '$baseUrl/api';
    return path.startsWith('/') ? '$root$path' : '$root/$path';
  }

  static String _ensureTrailingSlash(String v) => v.endsWith('/') ? v : '$v/';
}
