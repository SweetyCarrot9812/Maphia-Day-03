import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

class ParentDashboard extends ConsumerWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prime Readers - 학부모'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout_outlined),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header with child selection
                _buildWelcomeHeader(context),
                SizedBox(height: 24.h),

                // Quick actions
                _buildQuickActions(context, isDesktop),
                SizedBox(height: 24.h),

                // Child progress overview
                _buildProgressOverview(context),
                SizedBox(height: 24.h),

                // Weekly report summary
                _buildWeeklyReport(context),
                SizedBox(height: 24.h),

                // Vehicle tracking
                _buildVehicleTracking(context),
                SizedBox(height: 24.h),

                // Recent activities
                _buildRecentActivities(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade400,
            Colors.green.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '김학부모님 안녕하세요! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Child selector
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.child_care, color: Colors.white70, size: 16),
                    SizedBox(width: 4.w),
                    Text(
                      '김학생',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                    SizedBox(width: 4.w),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '자녀의 학습 현황을 확인하세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildStatItem('이번 주 출석', '5/5일', Icons.calendar_today),
              SizedBox(width: 24.w),
              _buildStatItem('완료 과제', '12/15개', Icons.assignment),
              SizedBox(width: 24.w),
              _buildStatItem('평균 점수', '85점', Icons.grade),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20.w),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDesktop) {
    final actions = [
      _ActionItem(
        title: '학습 리포트',
        subtitle: '주간/월간 리포트 보기',
        icon: Icons.assessment_outlined,
        color: Colors.blue,
        onTap: () => context.go('/parent-dashboard/reports'),
      ),
      _ActionItem(
        title: '차량 추적',
        subtitle: '실시간 위치 확인',
        icon: Icons.directions_bus_outlined,
        color: Colors.orange,
        onTap: () => context.go('/parent-dashboard/vehicle-tracking'),
      ),
      _ActionItem(
        title: '자녀 진도',
        subtitle: '상세 학습 현황',
        icon: Icons.trending_up_outlined,
        color: Colors.green,
        onTap: () => context.go('/parent-dashboard/child-progress/child-001'),
      ),
      _ActionItem(
        title: '출석 현황',
        subtitle: '출석/지각/결석 내역',
        icon: Icons.event_available_outlined,
        color: Colors.purple,
        onTap: () => {}, // TODO: Implement attendance history
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 메뉴',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _QuickActionCard(action: action);
          },
        ),
      ],
    );
  }

  Widget _buildProgressOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자녀 학습 현황',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Progress chart
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 120.h,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 85,
                            title: '85%',
                            color: Colors.green,
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: 15,
                            title: '',
                            color: Colors.grey.shade300,
                            radius: 50,
                          ),
                        ],
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                
                // Progress details
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressItem('단어 학습', '850/1000개', 0.85, Colors.blue),
                      _buildProgressItem('스피킹 연습', '24/30회', 0.80, Colors.red),
                      _buildProgressItem('독서 완료', '8/10권', 0.80, Colors.teal),
                      _buildProgressItem('라이팅 과제', '12/15개', 0.80, Colors.purple),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem(String title, String value, double progress, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12.sp)),
              Text(value, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 4.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '이번 주 리포트',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/parent-dashboard/reports'),
              child: const Text('전체 보기'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Top book this week
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade200,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: const Icon(Icons.book, color: Colors.white),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '이번 주 대표 도서',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Charlie and the Chocolate Factory',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                            Row(
                              children: [
                                Text('AR: 5.1', style: TextStyle(fontSize: 12.sp)),
                                SizedBox(width: 8.w),
                                Text('퀴즈: 85점', style: TextStyle(fontSize: 12.sp)),
                                SizedBox(width: 8.w),
                                Text('포인트: +120P', style: TextStyle(fontSize: 12.sp, color: Colors.green)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Weekly stats
                Row(
                  children: [
                    Expanded(
                      child: _buildWeeklyStatCard('스피킹 점수', '평균 82점', Icons.mic, Colors.red),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildWeeklyStatCard('라이팅 과제', '3개 완료', Icons.edit, Colors.purple),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20.w),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTracking(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '차량 현황',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/parent-dashboard/vehicle-tracking'),
              child: const Text('실시간 추적'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Icon(
                        Icons.directions_bus,
                        color: Colors.orange,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '차량 번호: 서울 12가 3456',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '현재 위치: 학원 근처',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                          Text(
                            '예상 도착: 오후 6시 20분 (7분 후)',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '운행 중',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    final activities = [
      {'time': '15:30', 'activity': '스토리 "바다 모험" 완료', 'type': 'story'},
      {'time': '15:15', 'activity': '스피킹 연습 3문장 완료 (평균 80점)', 'type': 'speaking'},
      {'time': '15:00', 'activity': '단어 학습 10개 완료', 'type': 'vocabulary'},
      {'time': '14:30', 'activity': '출석 체크 완료', 'type': 'attendance'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 활동',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Card(
          child: Column(
            children: activities.map((activity) {
              IconData icon;
              Color color;
              
              switch (activity['type']) {
                case 'story':
                  icon = Icons.auto_stories;
                  color = Colors.orange;
                  break;
                case 'speaking':
                  icon = Icons.mic;
                  color = Colors.red;
                  break;
                case 'vocabulary':
                  icon = Icons.quiz;
                  color = Colors.blue;
                  break;
                case 'attendance':
                  icon = Icons.how_to_reg;
                  color = Colors.green;
                  break;
                default:
                  icon = Icons.circle;
                  color = Colors.grey;
              }

              return ListTile(
                leading: Icon(icon, color: color),
                title: Text(activity['activity'] as String),
                subtitle: Text(activity['time'] as String),
                trailing: const Icon(Icons.chevron_right),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _ActionItem action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24.w,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                action.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                action.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}