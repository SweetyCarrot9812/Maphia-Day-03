import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Hanoa 앱 전용 로거 유틸리티
/// 
/// 개발/프로덕션 환경에 따라 로그 레벨을 자동 조정하며,
/// 각 모듈별로 구분된 로그를 제공합니다.
class HanoaLogger {
  static late Logger _logger;
  static bool _initialized = false;

  /// 로거 초기화
  static void initialize() {
    if (_initialized) return;

    _logger = Logger(
      filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: kDebugMode ? ConsoleOutput() : null,
    );
    
    _initialized = true;
    _logger.i('🚀 Hanoa Logger 초기화 완료');
  }

  /// 디버그 로그 (개발 시에만 표시)
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 정보 로그
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 경고 로그
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 에러 로그
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 치명적 에러 로그
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 모듈별 로거 생성
  static ModuleLogger module(String moduleName) {
    return ModuleLogger(moduleName);
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      initialize();
    }
  }
}

/// 모듈별 로거
/// 
/// 각 기능 모듈(Auth, Database, API 등)에서 사용할 수 있는
/// 전용 로거를 제공합니다.
class ModuleLogger {
  final String moduleName;
  final String _prefix;

  ModuleLogger(this.moduleName) : _prefix = '[$moduleName]';

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    HanoaLogger.debug('$_prefix $message', error, stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    HanoaLogger.info('$_prefix $message', error, stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    HanoaLogger.warning('$_prefix $message', error, stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    HanoaLogger.error('$_prefix $message', error, stackTrace);
  }

  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    HanoaLogger.fatal('$_prefix $message', error, stackTrace);
  }
}

/// 미리 정의된 모듈 로거들
class Loggers {
  static final auth = HanoaLogger.module('🔐 Auth');
  static final admin = HanoaLogger.module('👑 Admin');
  static final database = HanoaLogger.module('💾 Database');
  static final api = HanoaLogger.module('🌐 API');
  static final ui = HanoaLogger.module('🎨 UI');
  static final navigation = HanoaLogger.module('🧭 Navigation');
  static final service = HanoaLogger.module('⚙️ Service');
  static final module = HanoaLogger.module('📦 Module');
  static final content = HanoaLogger.module('📄 Content');
}