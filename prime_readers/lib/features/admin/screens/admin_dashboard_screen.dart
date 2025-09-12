import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

// System Statistics Provider
final systemStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  return adminService.getSystemStatistics();
});

// Latest Metrics Provider
final latestMetricsProvider = StreamProvider<SystemMetrics?>((ref) async* {
  final adminService = ref.read(adminServiceProvider);
  await for (final metrics in adminService.metricsStream) {
    yield metrics.isNotEmpty ? metrics.first : null;
  }
});

// Recent Logs Provider
final recentLogsProvider = StreamProvider<List<SystemLog>>((ref) async* {
  final adminService = ref.read(adminServiceProvider);
  await for (final logs in adminService.logsStream) {
    yield logs.take(10).toList();
  }
});

// Active Users Provider
final activeUsersProvider = StreamProvider<List<AdminUser>>((ref) async* {
  final adminService = ref.read(adminServiceProvider);
  await for (final users in adminService.usersStream) {
    yield users.where((u) => u.status == UserStatus.active).toList();
  }
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Operations Dashboard',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          bottom: TabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.dashboard),
                text: 'Overview',
              ),
              Tab(
                icon: Icon(Icons.analytics),
                text: 'Analytics',
              ),
              Tab(
                icon: Icon(Icons.people),
                text: 'Users',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Logs',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            _AnalyticsTab(),
            _UsersTab(),
            _LogsTab(),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(systemStatsProvider);
    final metricsAsync = ref.watch(latestMetricsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(systemStatsProvider);
        ref.invalidate(latestMetricsProvider);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Overview',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            // System Statistics Cards
            statsAsync.when(
              data: (stats) => _buildStatsGrid(context, stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error loading stats: $error'),
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              'Current Performance',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Performance Metrics
            metricsAsync.when(
              data: (metrics) => metrics != null 
                  ? _buildPerformanceCard(context, metrics)
                  : const Text('No performance data available'),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error loading metrics: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats) {
    final items = [
      _StatItem('Total Users', '${stats['total_users']}', Icons.people, Colors.blue),
      _StatItem('Active Users', '${stats['active_users']}', Icons.person, Colors.green),
      _StatItem('Admin Users', '${stats['admin_users']}', Icons.admin_panel_settings, Colors.purple),
      _StatItem('Total Logs', '${stats['total_logs']}', Icons.description, Colors.orange),
      _StatItem('Error Logs', '${stats['error_logs']}', Icons.error, Colors.red),
      _StatItem('System Uptime', '${stats['system_uptime']?.toStringAsFixed(1) ?? '0.0'}%', Icons.trending_up, Colors.teal),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 32.sp,
                  color: item.color,
                ),
                SizedBox(height: 8.h),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: item.color,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceCard(BuildContext context, SystemMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            _buildProgressIndicator('CPU Usage', metrics.cpuUsage, '%', Colors.orange),
            SizedBox(height: 12.h),
            _buildProgressIndicator('Memory Usage', metrics.memoryUsage, '%', Colors.blue),
            SizedBox(height: 12.h),
            _buildProgressIndicator('Disk Usage', metrics.diskUsage, '%', Colors.purple),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Updated: ${_formatDateTime(metrics.timestamp)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Session: ${metrics.averageSessionDuration.toStringAsFixed(1)}m avg',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends ConsumerWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(latestMetricsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          metricsAsync.when(
            data: (metrics) => metrics != null 
                ? _buildAnalyticsCards(context, metrics)
                : const Text('No analytics data available'),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error loading analytics: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards(BuildContext context, SystemMetrics metrics) {
    return Column(
      children: [
        // User Statistics Card
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Statistics',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Total Users', '${metrics.totalUsers}', Colors.blue),
                    _buildStatColumn('Active Users', '${metrics.activeUsers}', Colors.green),
                    _buildStatColumn('Total Sessions', '${metrics.totalSessions}', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Learning Statistics Card
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Statistics',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Total Lessons', '${metrics.totalLessons}', Colors.purple),
                    _buildStatColumn('Completed', '${metrics.completedLessons}', Colors.teal),
                    _buildStatColumn('Completion Rate', 
                        '${((metrics.completedLessons / metrics.totalLessons) * 100).toStringAsFixed(1)}%', 
                        Colors.indigo),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(activeUsersProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Management',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add user functionality
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: usersAsync.when(
            data: (users) => users.isNotEmpty
                ? ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(user.role),
                          child: Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${user.email}\n${_getRoleDisplayName(user.role)} • Last login: ${user.lastLoginAt != null ? _formatDateTime(user.lastLoginAt!) : 'Never'}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            // TODO: Implement user actions
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit User'),
                            ),
                            const PopupMenuItem(
                              value: 'suspend',
                              child: Text('Suspend User'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete User'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No active users found')),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error loading users: $error')),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.super_admin:
        return Colors.red;
      case UserRole.admin:
        return Colors.orange;
      case UserRole.teacher:
        return Colors.blue;
      case UserRole.parent:
        return Colors.green;
      case UserRole.student:
        return Colors.purple;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.super_admin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.parent:
        return 'Parent';
      case UserRole.student:
        return 'Student';
    }
  }
}

class _LogsTab extends ConsumerWidget {
  const _LogsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(recentLogsProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Logs',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(recentLogsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: logsAsync.when(
            data: (logs) => logs.isNotEmpty
                ? ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getLogLevelColor(log.level),
                            child: Icon(
                              _getLogLevelIcon(log.level),
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                          title: Text(
                            log.message,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${log.category} • ${_formatDateTime(log.timestamp)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Text(
                            _getLogLevelName(log.level),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: _getLogLevelColor(log.level),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No logs available')),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error loading logs: $error')),
          ),
        ),
      ],
    );
  }

  Color _getLogLevelColor(SystemLogLevel level) {
    switch (level) {
      case SystemLogLevel.debug:
        return Colors.grey;
      case SystemLogLevel.info:
        return Colors.blue;
      case SystemLogLevel.warning:
        return Colors.orange;
      case SystemLogLevel.error:
        return Colors.red;
      case SystemLogLevel.critical:
        return Colors.red[900]!;
    }
  }

  IconData _getLogLevelIcon(SystemLogLevel level) {
    switch (level) {
      case SystemLogLevel.debug:
        return Icons.bug_report;
      case SystemLogLevel.info:
        return Icons.info;
      case SystemLogLevel.warning:
        return Icons.warning;
      case SystemLogLevel.error:
        return Icons.error;
      case SystemLogLevel.critical:
        return Icons.dangerous;
    }
  }

  String _getLogLevelName(SystemLogLevel level) {
    switch (level) {
      case SystemLogLevel.debug:
        return 'DEBUG';
      case SystemLogLevel.info:
        return 'INFO';
      case SystemLogLevel.warning:
        return 'WARNING';
      case SystemLogLevel.error:
        return 'ERROR';
      case SystemLogLevel.critical:
        return 'CRITICAL';
    }
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem(this.title, this.value, this.icon, this.color);
}

String _formatDateTime(DateTime dateTime) {
  return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}';
}