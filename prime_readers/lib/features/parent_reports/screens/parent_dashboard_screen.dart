import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/report_models.dart';
import '../services/report_service.dart';
import '../services/notification_service.dart';

// Providers for parent reports system
final reportServiceProvider = Provider<ReportService>((ref) => ReportService());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final parentReportsProvider = FutureProvider.family<List<ParentReport>, String>((ref, parentId) async {
  final service = ref.read(reportServiceProvider);
  await service.initialize();
  return service.getReportsForParent(parentId);
});

final parentNotificationsProvider = FutureProvider.family<List<PushNotification>, String>((ref, userId) async {
  final service = ref.read(notificationServiceProvider);
  await service.initialize();
  return service.getNotifications(userId);
});

final unreadNotificationCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.read(notificationServiceProvider);
  await service.initialize();
  return service.getUnreadCount(userId);
});

class ParentDashboardScreen extends ConsumerStatefulWidget {
  final String parentId;
  
  const ParentDashboardScreen({
    super.key,
    required this.parentId,
  });

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider(widget.parentId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '학부모 대시보드',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Notification badge
          unreadCountAsync.when(
            data: (unreadCount) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    _tabController.animateTo(1); // Switch to notifications tab
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.h,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            loading: () => IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard),
              text: '개요',
            ),
            Tab(
              icon: const Icon(Icons.notifications),
              text: '알림',
            ),
            Tab(
              icon: const Icon(Icons.assessment),
              text: '리포트',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildNotificationsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final reportsAsync = ref.watch(parentReportsProvider(widget.parentId));
    final notificationsAsync = ref.watch(parentNotificationsProvider(widget.parentId));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.family_restroom,
                        size: 32.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '안녕하세요, 학부모님!',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '자녀의 학습 현황을 확인하세요',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: '이번 주 리포트',
                  value: reportsAsync.when(
                    data: (reports) => reports
                        .where((r) => r.type == ReportType.weekly && 
                               r.generatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
                        .length
                        .toString(),
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                  icon: Icons.assessment,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  title: '읽지 않은 알림',
                  value: ref.watch(unreadNotificationCountProvider(widget.parentId)).when(
                    data: (count) => count.toString(),
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                  icon: Icons.notifications,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Recent reports section
          Text(
            '최근 리포트',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          reportsAsync.when(
            data: (reports) {
              final recentReports = reports.take(3).toList();
              if (recentReports.isEmpty) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assessment_outlined,
                          size: 48.sp,
                          color: Theme.of(context).disabledColor,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '아직 생성된 리포트가 없습니다',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () => _generateSampleReport(),
                          child: const Text('샘플 리포트 생성'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Column(
                children: recentReports
                    .map((report) => _buildReportSummaryCard(report))
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text('리포트를 불러오는 중 오류가 발생했습니다: $error'),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Recent notifications section
          Text(
            '최근 알림',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          notificationsAsync.when(
            data: (notifications) {
              final recentNotifications = notifications.take(3).toList();
              if (recentNotifications.isEmpty) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 48.sp,
                          color: Theme.of(context).disabledColor,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '알림이 없습니다',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Column(
                children: recentNotifications
                    .map((notification) => _buildNotificationCard(notification, isCompact: true))
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text('알림을 불러오는 중 오류가 발생했습니다: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    final notificationsAsync = ref.watch(parentNotificationsProvider(widget.parentId));

    return Column(
      children: [
        // Notifications header
        Container(
          padding: EdgeInsets.all(16.w),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Icon(Icons.notifications, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                '알림',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _markAllNotificationsAsRead(),
                child: const Text('모두 읽음'),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showNotificationSettings(),
              ),
            ],
          ),
        ),

        // Notifications list
        Expanded(
          child: notificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64.sp,
                        color: Theme.of(context).disabledColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '알림이 없습니다',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => _generateTestNotifications(),
                        child: const Text('테스트 알림 생성'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(parentNotificationsProvider(widget.parentId));
                  ref.refresh(unreadNotificationCountProvider(widget.parentId));
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(notifications[index]);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '알림을 불러오는 중 오류가 발생했습니다',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => ref.refresh(parentNotificationsProvider(widget.parentId)),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    final reportsAsync = ref.watch(parentReportsProvider(widget.parentId));

    return Column(
      children: [
        // Reports header
        Container(
          padding: EdgeInsets.all(16.w),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Icon(Icons.assessment, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                '학습 리포트',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'generate_weekly') {
                    _generateWeeklyReport();
                  } else if (value == 'generate_monthly') {
                    _generateMonthlyReport();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'generate_weekly',
                    child: Text('주간 리포트 생성'),
                  ),
                  const PopupMenuItem(
                    value: 'generate_monthly',
                    child: Text('월간 리포트 생성'),
                  ),
                ],
                child: Icon(Icons.more_vert),
              ),
            ],
          ),
        ),

        // Reports list
        Expanded(
          child: reportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment_outlined,
                        size: 64.sp,
                        color: Theme.of(context).disabledColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '생성된 리포트가 없습니다',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => _generateSampleReport(),
                        child: const Text('샘플 리포트 생성'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(parentReportsProvider(widget.parentId));
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportCard(reports[index]);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '리포트를 불러오는 중 오류가 발생했습니다',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => ref.refresh(parentReportsProvider(widget.parentId)),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
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
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSummaryCard(ParentReport report) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getReportTypeColor(report.type),
          child: Icon(
            _getReportTypeIcon(report.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          report.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.summary,
              style: TextStyle(fontSize: 13.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              _formatDate(report.generatedAt),
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        trailing: Icon(
          report.status == ReportStatus.viewed 
              ? Icons.visibility 
              : Icons.visibility_off,
          color: report.status == ReportStatus.viewed 
              ? Colors.green 
              : Colors.grey,
        ),
        onTap: () => _viewReportDetail(report),
      ),
    );
  }

  Widget _buildReportCard(ParentReport report) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getReportTypeColor(report.type),
                  child: Icon(
                    _getReportTypeIcon(report.type),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatDateRange(report.periodStart, report.periodEnd)} • ${_getReportTypeText(report.type)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildReportStatusChip(report.status),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              report.summary,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildMetricChip('지표 ${report.metrics.length}개', Icons.bar_chart),
                SizedBox(width: 8.w),
                _buildMetricChip('성취 ${report.achievements.length}개', Icons.emoji_events),
                SizedBox(width: 8.w),
                _buildMetricChip('권장사항 ${report.recommendations.length}개', Icons.lightbulb),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _shareReport(report),
                  child: const Text('공유'),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () => _viewReportDetail(report),
                  child: const Text('자세히 보기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(PushNotification notification, {bool isCompact = false}) {
    return Card(
      margin: EdgeInsets.only(bottom: isCompact ? 4.h : 8.h),
      color: notification.isRead ? null : Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationTypeColor(notification.type),
          child: Icon(
            _getNotificationTypeIcon(notification.type),
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: isCompact ? 14.sp : 16.sp,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: TextStyle(
                fontSize: isCompact ? 12.sp : 13.sp,
              ),
              maxLines: isCompact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              _formatTimeAgo(notification.createdAt),
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        trailing: !notification.isRead 
            ? Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Widget _buildReportStatusChip(ReportStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case ReportStatus.generating:
        color = Colors.orange;
        text = '생성 중';
        icon = Icons.hourglass_empty;
        break;
      case ReportStatus.ready:
        color = Colors.blue;
        text = '준비됨';
        icon = Icons.check_circle;
        break;
      case ReportStatus.sent:
        color = Colors.green;
        text = '발송됨';
        icon = Icons.send;
        break;
      case ReportStatus.viewed:
        color = Colors.green;
        text = '확인됨';
        icon = Icons.visibility;
        break;
      case ReportStatus.archived:
        color = Colors.grey;
        text = '보관됨';
        icon = Icons.archive;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16.sp, color: color),
      label: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: color),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color, width: 1),
    );
  }

  Widget _buildMetricChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 14.sp),
      label: Text(
        text,
        style: TextStyle(fontSize: 11.sp),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      visualDensity: VisualDensity.compact,
    );
  }

  // Helper methods for UI
  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.weekly: return Colors.blue;
      case ReportType.monthly: return Colors.green;
      case ReportType.progress: return Colors.orange;
      case ReportType.achievement: return Colors.purple;
      case ReportType.alert: return Colors.red;
    }
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.weekly: return Icons.calendar_view_week;
      case ReportType.monthly: return Icons.calendar_month;
      case ReportType.progress: return Icons.trending_up;
      case ReportType.achievement: return Icons.emoji_events;
      case ReportType.alert: return Icons.warning;
    }
  }

  String _getReportTypeText(ReportType type) {
    switch (type) {
      case ReportType.weekly: return '주간 리포트';
      case ReportType.monthly: return '월간 리포트';
      case ReportType.progress: return '진도 리포트';
      case ReportType.achievement: return '성취 리포트';
      case ReportType.alert: return '알림 리포트';
    }
  }

  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.progress: return Colors.blue;
      case NotificationType.achievement: return ColorsExtension.gold;
      case NotificationType.reminder: return Colors.orange;
      case NotificationType.alert: return Colors.red;
      case NotificationType.report_ready: return Colors.green;
      case NotificationType.goal_achieved: return Colors.purple;
      case NotificationType.streak_milestone: return Colors.deepOrange;
      case NotificationType.low_activity: return Colors.amber;
    }
  }

  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.progress: return Icons.trending_up;
      case NotificationType.achievement: return Icons.emoji_events;
      case NotificationType.reminder: return Icons.alarm;
      case NotificationType.alert: return Icons.warning;
      case NotificationType.report_ready: return Icons.assessment;
      case NotificationType.goal_achieved: return Icons.flag;
      case NotificationType.streak_milestone: return Icons.local_fire_department;
      case NotificationType.low_activity: return Icons.trending_down;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${_formatDate(start)} ~ ${_formatDate(end)}';
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    } else {
      return _formatDate(date);
    }
  }

  // Action methods
  Future<void> _generateSampleReport() async {
    try {
      final reportService = ref.read(reportServiceProvider);
      await reportService.initialize();
      await reportService.generateWeeklyReport('student1', widget.parentId);
      
      // Refresh the reports
      ref.refresh(parentReportsProvider(widget.parentId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('샘플 리포트가 생성되었습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리포트 생성 실패: $e')),
      );
    }
  }

  Future<void> _generateWeeklyReport() async {
    try {
      final reportService = ref.read(reportServiceProvider);
      await reportService.generateWeeklyReport('student1', widget.parentId);
      ref.refresh(parentReportsProvider(widget.parentId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주간 리포트가 생성되었습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리포트 생성 실패: $e')),
      );
    }
  }

  Future<void> _generateMonthlyReport() async {
    try {
      final reportService = ref.read(reportServiceProvider);
      await reportService.generateMonthlyReport('student1', widget.parentId);
      ref.refresh(parentReportsProvider(widget.parentId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('월간 리포트가 생성되었습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리포트 생성 실패: $e')),
      );
    }
  }

  Future<void> _generateTestNotifications() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();
      await notificationService.simulateRandomNotifications(
        'student1',
        parentId: widget.parentId,
        count: 5,
      );
      
      // Refresh notifications
      ref.refresh(parentNotificationsProvider(widget.parentId));
      ref.refresh(unreadNotificationCountProvider(widget.parentId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('테스트 알림이 생성되었습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('알림 생성 실패: $e')),
      );
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.markAllAsRead(widget.parentId);
      
      ref.refresh(parentNotificationsProvider(widget.parentId));
      ref.refresh(unreadNotificationCountProvider(widget.parentId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 알림을 읽음 처리했습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('처리 실패: $e')),
      );
    }
  }

  void _handleNotificationTap(PushNotification notification) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.markAsRead(notification.id);
      
      ref.refresh(parentNotificationsProvider(widget.parentId));
      ref.refresh(unreadNotificationCountProvider(widget.parentId));
      
      // Handle action URL if present
      if (notification.actionUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('액션: ${notification.actionUrl}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('알림 처리 실패: $e')),
      );
    }
  }

  void _viewReportDetail(ParentReport report) {
    // Mark report as viewed
    final reportService = ref.read(reportServiceProvider);
    reportService.markReportAsViewed(report.id);
    ref.refresh(parentReportsProvider(widget.parentId));

    // Navigate to report detail (placeholder)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('리포트 상세보기: ${report.title}')),
    );
  }

  void _shareReport(ParentReport report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('리포트 공유: ${report.title}')),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('알림 설정 화면을 여기에 구현')),
    );
  }
}

// Extension for Colors.gold
extension ColorsExtension on Colors {
  static const Color gold = Color(0xFFFFD700);
}