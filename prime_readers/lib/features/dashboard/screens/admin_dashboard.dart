import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prime Readers - 관리자'),
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
          final isDesktop = constraints.maxWidth > 1000;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Text(
                  '관리자님 안녕하세요! 👨‍💼',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '시스템 전체를 관리하고 분석하세요',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 24.h),

                // System overview stats
                _buildSystemOverview(context, isDesktop),
                SizedBox(height: 24.h),

                // Quick actions
                _buildQuickActions(context, isDesktop),
                SizedBox(height: 24.h),

                // Analytics charts
                if (isDesktop) ...[
                  Row(
                    children: [
                      Expanded(child: _buildUserActivityChart(context)),
                      SizedBox(width: 16.w),
                      Expanded(child: _buildLearningProgressChart(context)),
                    ],
                  ),
                ] else ...[
                  _buildUserActivityChart(context),
                  SizedBox(height: 16.h),
                  _buildLearningProgressChart(context),
                ],
                SizedBox(height: 24.h),

                // System alerts
                _buildSystemAlerts(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSystemOverview(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시스템 현황',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 5 : 2,
          childAspectRatio: isDesktop ? 1.2 : 1.5,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          children: [
            _buildStatCard('전체 사용자', '248명', Icons.people, Colors.blue),
            _buildStatCard('활성 학생', '156명', Icons.school, Colors.green),
            _buildStatCard('교사', '12명', Icons.person, Colors.orange),
            _buildStatCard('차량', '4대', Icons.directions_bus, Colors.purple),
            _buildStatCard('시스템 상태', '정상', Icons.check_circle, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32.w),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDesktop) {
    final actions = [
      _ActionItem(
        title: '사용자 관리',
        subtitle: '학생, 학부모, 교사 관리',
        icon: Icons.manage_accounts,
        color: Colors.blue,
        onTap: () => context.go('/admin-dashboard/user-management'),
      ),
      _ActionItem(
        title: '시스템 설정',
        subtitle: '앱 설정 및 구성',
        icon: Icons.settings,
        color: Colors.grey,
        onTap: () => context.go('/admin-dashboard/system-settings'),
      ),
      _ActionItem(
        title: '분석 리포트',
        subtitle: '사용량 및 성과 분석',
        icon: Icons.analytics,
        color: Colors.green,
        onTap: () => context.go('/admin-dashboard/analytics'),
      ),
      _ActionItem(
        title: '차량 관리',
        subtitle: '차량 및 경로 관리',
        icon: Icons.directions_bus,
        color: Colors.orange,
        onTap: () => context.go('/admin-dashboard/vehicle-management'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요 기능',
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

  Widget _buildUserActivityChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '일별 사용자 활동',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['월', '화', '수', '목', '금', '토', '일'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(days[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 120),
                        FlSpot(1, 135),
                        FlSpot(2, 148),
                        FlSpot(3, 156),
                        FlSpot(4, 142),
                        FlSpot(5, 98),
                        FlSpot(6, 88),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningProgressChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '학습 진도 분포',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 45,
                      title: '45%\n우수',
                      color: Colors.green,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 35,
                      title: '35%\n보통',
                      color: Colors.blue,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 15,
                      title: '15%\n개선필요',
                      color: Colors.orange,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 5,
                      title: '5%\n부진',
                      color: Colors.red,
                      radius: 60,
                    ),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemAlerts(BuildContext context) {
    final alerts = [
      {'type': 'info', 'title': '시스템 업데이트', 'message': '새로운 기능이 추가되었습니다', 'time': '1시간 전'},
      {'type': 'warning', 'title': '서버 용량 주의', 'message': '저장 공간이 80%를 초과했습니다', 'time': '2시간 전'},
      {'type': 'success', 'title': '백업 완료', 'message': '일일 백업이 성공적으로 완료되었습니다', 'time': '12시간 전'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시스템 알림',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Card(
          child: Column(
            children: alerts.map((alert) {
              Color color;
              IconData icon;
              
              switch (alert['type']) {
                case 'warning':
                  color = Colors.orange;
                  icon = Icons.warning;
                  break;
                case 'success':
                  color = Colors.green;
                  icon = Icons.check_circle;
                  break;
                default:
                  color = Colors.blue;
                  icon = Icons.info;
              }

              return ListTile(
                leading: Icon(icon, color: color),
                title: Text(alert['title'] as String),
                subtitle: Text(alert['message'] as String),
                trailing: Text(
                  alert['time'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
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