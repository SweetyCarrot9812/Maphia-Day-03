import 'dart:async';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/admin_models.dart';

class AdminService {
  static const String _metricsBoxName = 'system_metrics';
  static const String _usersBoxName = 'admin_users';
  static const String _logsBoxName = 'system_logs';
  static const String _configBoxName = 'system_configuration';
  static const String _widgetsBoxName = 'dashboard_widgets';

  Box<SystemMetrics>? _metricsBox;
  Box<AdminUser>? _usersBox;
  Box<SystemLog>? _logsBox;
  Box<SystemConfiguration>? _configBox;
  Box<DashboardWidget>? _widgetsBox;

  // Streams for real-time updates
  final StreamController<List<SystemMetrics>> _metricsController = 
      StreamController<List<SystemMetrics>>.broadcast();
  final StreamController<List<AdminUser>> _usersController = 
      StreamController<List<AdminUser>>.broadcast();
  final StreamController<List<SystemLog>> _logsController = 
      StreamController<List<SystemLog>>.broadcast();

  Stream<List<SystemMetrics>> get metricsStream => _metricsController.stream;
  Stream<List<AdminUser>> get usersStream => _usersController.stream;
  Stream<List<SystemLog>> get logsStream => _logsController.stream;

  Timer? _metricsTimer;

  Future<void> initialize() async {
    try {
      _metricsBox = await Hive.openBox<SystemMetrics>(_metricsBoxName);
      _usersBox = await Hive.openBox<AdminUser>(_usersBoxName);
      _logsBox = await Hive.openBox<SystemLog>(_logsBoxName);
      _configBox = await Hive.openBox<SystemConfiguration>(_configBoxName);
      _widgetsBox = await Hive.openBox<DashboardWidget>(_widgetsBoxName);

      // Start real-time metrics collection
      _startMetricsCollection();

      print('AdminService initialized successfully');
    } catch (e) {
      print('Error initializing AdminService: $e');
      rethrow;
    }
  }

  void _startMetricsCollection() {
    _metricsTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _generateSystemMetrics();
    });

    // Generate initial metrics
    _generateSystemMetrics();
  }

  void _generateSystemMetrics() {
    final now = DateTime.now();
    final random = Random();

    final metrics = SystemMetrics(
      id: 'metrics_${now.millisecondsSinceEpoch}',
      timestamp: now,
      totalUsers: 1000 + random.nextInt(500),
      activeUsers: 150 + random.nextInt(100),
      totalSessions: 5000 + random.nextInt(2000),
      averageSessionDuration: 20 + random.nextDouble() * 15,
      totalLessons: 10000 + random.nextInt(5000),
      completedLessons: 8000 + random.nextInt(3000),
      systemUptime: 95.0 + random.nextDouble() * 4.0,
      memoryUsage: 40.0 + random.nextDouble() * 30.0,
      cpuUsage: 20.0 + random.nextDouble() * 40.0,
      diskUsage: 60.0 + random.nextDouble() * 20.0,
      metadata: {
        'server_version': '1.2.3',
        'database_connections': 20 + random.nextInt(10),
        'api_requests_per_minute': 500 + random.nextInt(300),
      },
    );

    _metricsBox?.add(metrics);
    _metricsController.add(getAllMetrics());
  }

  // System Metrics Management
  List<SystemMetrics> getAllMetrics() {
    return _metricsBox?.values.toList() ?? [];
  }

  SystemMetrics? getLatestMetrics() {
    final metrics = getAllMetrics();
    if (metrics.isEmpty) return null;
    metrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return metrics.first;
  }

  List<SystemMetrics> getMetricsInRange(DateTime startDate, DateTime endDate) {
    final allMetrics = getAllMetrics();
    return allMetrics.where((metrics) =>
      metrics.timestamp.isAfter(startDate) &&
      metrics.timestamp.isBefore(endDate)
    ).toList();
  }

  // User Management
  Future<void> addUser(AdminUser user) async {
    await _usersBox?.put(user.id, user);
    _usersController.add(getAllUsers());
    _logActivity(
      SystemLogLevel.info,
      'user_management',
      'User created: ${user.name} (${user.email})',
      userId: user.id,
    );
  }

  Future<void> updateUser(AdminUser user) async {
    await _usersBox?.put(user.id, user);
    _usersController.add(getAllUsers());
    _logActivity(
      SystemLogLevel.info,
      'user_management',
      'User updated: ${user.name} (${user.email})',
      userId: user.id,
    );
  }

  Future<void> deleteUser(String userId) async {
    final user = _usersBox?.get(userId);
    await _usersBox?.delete(userId);
    _usersController.add(getAllUsers());
    _logActivity(
      SystemLogLevel.warning,
      'user_management',
      'User deleted: ${user?.name ?? 'Unknown'} ($userId)',
      userId: userId,
    );
  }

  List<AdminUser> getAllUsers() {
    return _usersBox?.values.toList() ?? [];
  }

  AdminUser? getUserById(String id) {
    return _usersBox?.get(id);
  }

  List<AdminUser> getUsersByRole(UserRole role) {
    return getAllUsers().where((user) => user.role == role).toList();
  }

  List<AdminUser> getUsersByStatus(UserStatus status) {
    return getAllUsers().where((user) => user.status == status).toList();
  }

  Future<void> changeUserStatus(String userId, UserStatus newStatus) async {
    final user = getUserById(userId);
    if (user != null) {
      final updatedUser = user.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      await updateUser(updatedUser);
    }
  }

  // System Logging
  void _logActivity(
    SystemLogLevel level,
    String category,
    String message, {
    String? userId,
    String? sessionId,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    final log = SystemLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      level: level,
      category: category,
      message: message,
      userId: userId,
      sessionId: sessionId,
      context: context ?? {},
      stackTrace: stackTrace,
    );

    _logsBox?.add(log);
    _logsController.add(getAllLogs());

    // Auto-cleanup old logs (keep last 1000)
    final allLogs = getAllLogs();
    if (allLogs.length > 1000) {
      allLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final logsToRemove = allLogs.take(allLogs.length - 1000);
      for (final log in logsToRemove) {
        final key = _logsBox?.keys.firstWhere(
          (k) => _logsBox!.get(k)?.id == log.id,
          orElse: () => null,
        );
        if (key != null) {
          _logsBox?.delete(key);
        }
      }
    }
  }

  List<SystemLog> getAllLogs() {
    return _logsBox?.values.toList() ?? [];
  }

  List<SystemLog> getLogsByLevel(SystemLogLevel level) {
    return getAllLogs().where((log) => log.level == level).toList();
  }

  List<SystemLog> getLogsByCategory(String category) {
    return getAllLogs().where((log) => log.category == category).toList();
  }

  List<SystemLog> getRecentLogs({int limit = 100}) {
    final logs = getAllLogs();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  // System Configuration Management
  Future<void> saveConfiguration(SystemConfiguration config) async {
    await _configBox?.put(config.key, config);
    _logActivity(
      SystemLogLevel.info,
      'configuration',
      'Configuration updated: ${config.name}',
      context: {'key': config.key, 'value': config.value},
    );
  }

  SystemConfiguration? getConfiguration(String key) {
    return _configBox?.get(key);
  }

  List<SystemConfiguration> getAllConfigurations() {
    return _configBox?.values.toList() ?? [];
  }

  List<SystemConfiguration> getConfigurationsByType(ConfigurationType type) {
    return getAllConfigurations()
        .where((config) => config.type == type)
        .toList();
  }

  Future<void> resetConfigurationToDefault(String key) async {
    final config = getConfiguration(key);
    if (config != null && config.isEditable) {
      final resetConfig = config.copyWith(
        value: config.defaultValue,
        updatedAt: DateTime.now(),
      );
      await saveConfiguration(resetConfig);
    }
  }

  // Dashboard Widget Management
  Future<void> saveDashboardWidget(DashboardWidget widget) async {
    await _widgetsBox?.put(widget.id, widget);
    _logActivity(
      SystemLogLevel.info,
      'dashboard',
      'Dashboard widget updated: ${widget.title}',
      context: {'widget_id': widget.id, 'type': widget.type},
    );
  }

  Future<void> deleteDashboardWidget(String widgetId) async {
    final widget = _widgetsBox?.get(widgetId);
    await _widgetsBox?.delete(widgetId);
    _logActivity(
      SystemLogLevel.info,
      'dashboard',
      'Dashboard widget deleted: ${widget?.title ?? 'Unknown'}',
      context: {'widget_id': widgetId},
    );
  }

  List<DashboardWidget> getAllDashboardWidgets() {
    return _widgetsBox?.values.toList() ?? [];
  }

  List<DashboardWidget> getVisibleDashboardWidgets() {
    return getAllDashboardWidgets()
        .where((widget) => widget.isVisible)
        .toList();
  }

  // System Statistics
  Map<String, dynamic> getSystemStatistics() {
    final users = getAllUsers();
    final logs = getAllLogs();
    final metrics = getLatestMetrics();

    return {
      'total_users': users.length,
      'active_users': users.where((u) => u.status == UserStatus.active).length,
      'admin_users': users.where((u) => u.role == UserRole.admin || u.role == UserRole.super_admin).length,
      'total_logs': logs.length,
      'error_logs': logs.where((l) => l.level == SystemLogLevel.error).length,
      'warning_logs': logs.where((l) => l.level == SystemLogLevel.warning).length,
      'system_uptime': metrics?.systemUptime ?? 0.0,
      'memory_usage': metrics?.memoryUsage ?? 0.0,
      'cpu_usage': metrics?.cpuUsage ?? 0.0,
      'disk_usage': metrics?.diskUsage ?? 0.0,
    };
  }

  // Sample Data Generation
  Future<void> addSampleData() async {
    try {
      // Add sample admin users
      final sampleUsers = [
        AdminUser(
          id: 'admin_1',
          email: 'admin@primereaders.com',
          name: '시스템 관리자',
          role: UserRole.super_admin,
          status: UserStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
          phoneNumber: '010-1234-5678',
          permissions: ['user_management', 'system_config', 'analytics'],
          metadata: {'department': 'IT', 'location': 'Seoul'},
          updatedAt: DateTime.now(),
        ),
        AdminUser(
          id: 'teacher_1',
          email: 'teacher@primereaders.com',
          name: '김선생님',
          role: UserRole.teacher,
          status: UserStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
          permissions: ['student_management', 'lesson_management'],
          metadata: {'subject': 'English', 'grade': '3rd'},
          updatedAt: DateTime.now(),
        ),
      ];

      for (final user in sampleUsers) {
        final existingUser = getUserById(user.id);
        if (existingUser == null) {
          await addUser(user);
        }
      }

      // Add sample configuration
      final sampleConfigs = [
        SystemConfiguration(
          id: 'max_session_duration',
          key: 'max_session_duration',
          name: '최대 세션 지속시간',
          description: '사용자 세션의 최대 지속시간 (분)',
          type: ConfigurationType.system,
          value: '120',
          defaultValue: '120',
          isEditable: true,
          requiresRestart: false,
          validValues: ['60', '120', '180', '240'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SystemConfiguration(
          id: 'enable_notifications',
          key: 'enable_notifications',
          name: '알림 기능 활성화',
          description: '시스템 알림 기능을 활성화합니다',
          type: ConfigurationType.feature,
          value: 'true',
          defaultValue: 'true',
          isEditable: true,
          requiresRestart: false,
          validValues: ['true', 'false'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final config in sampleConfigs) {
        final existingConfig = getConfiguration(config.key);
        if (existingConfig == null) {
          await saveConfiguration(config);
        }
      }

      // Add sample dashboard widgets
      final sampleWidgets = [
        DashboardWidget(
          id: 'active_users_widget',
          title: '활성 사용자',
          type: 'metric',
          positionX: 0,
          positionY: 0,
          width: 3,
          height: 2,
          config: {
            'metric_key': 'active_users',
            'icon': 'person',
            'color': 'blue',
          },
          isVisible: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DashboardWidget(
          id: 'system_performance_chart',
          title: '시스템 성능',
          type: 'chart',
          positionX: 3,
          positionY: 0,
          width: 6,
          height: 4,
          config: {
            'chart_type': 'line',
            'metrics': ['cpu_usage', 'memory_usage'],
            'time_range': '24h',
          },
          isVisible: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final widget in sampleWidgets) {
        final existingWidget = _widgetsBox?.get(widget.id);
        if (existingWidget == null) {
          await saveDashboardWidget(widget);
        }
      }

      _logActivity(
        SystemLogLevel.info,
        'system',
        'Sample admin data initialized',
      );

    } catch (e) {
      _logActivity(
        SystemLogLevel.error,
        'system',
        'Failed to add sample admin data: $e',
        stackTrace: e.toString(),
      );
    }
  }

  Future<void> dispose() async {
    _metricsTimer?.cancel();
    await _metricsController.close();
    await _usersController.close();
    await _logsController.close();
    
    await _metricsBox?.close();
    await _usersBox?.close();
    await _logsBox?.close();
    await _configBox?.close();
    await _widgetsBox?.close();
  }
}