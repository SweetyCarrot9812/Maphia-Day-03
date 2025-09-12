import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prime Readers - 교사'),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            Text(
              '김선생님 안녕하세요! 👨‍🏫',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '학생들의 학습을 관리하고 지도하세요',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 24.h),

            // Quick stats
            Row(
              children: [
                Expanded(child: _buildStatCard('담당 학생', '24명', Icons.people, Colors.blue)),
                SizedBox(width: 12.w),
                Expanded(child: _buildStatCard('대기 중인 승인', '3건', Icons.pending, Colors.orange)),
                SizedBox(width: 12.w),
                Expanded(child: _buildStatCard('오늘 출석률', '92%', Icons.check_circle, Colors.green)),
              ],
            ),
            SizedBox(height: 24.h),

            // Quick actions
            Text(
              '주요 기능',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              children: [
                _buildActionCard(
                  '출석 승인',
                  '학생 출석 확인 및 승인',
                  Icons.how_to_reg,
                  Colors.green,
                  () => context.go('/teacher-dashboard/attendance-approval'),
                ),
                _buildActionCard(
                  '학생 관리',
                  '학생 정보 및 진도 관리',
                  Icons.people_alt,
                  Colors.blue,
                  () => context.go('/teacher-dashboard/student-management'),
                ),
                _buildActionCard(
                  '라이팅 첨삭',
                  'AI 첨삭 검토 및 승인',
                  Icons.edit_note,
                  Colors.purple,
                  () => context.go('/teacher-dashboard/writing-review'),
                ),
                _buildActionCard(
                  '진도 리포트',
                  '학생별 학습 진도 확인',
                  Icons.assessment,
                  Colors.teal,
                  () => context.go('/teacher-dashboard/progress-reports'),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Pending tasks
            Text(
              '처리 대기 목록',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.orange),
                    title: const Text('김학생 출석 체크 승인 요청'),
                    subtitle: const Text('2분 전'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.check, color: Colors.green),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.purple),
                    title: const Text('이학생 라이팅 과제 첨삭 검토'),
                    subtitle: const Text('5분 전'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_remove, color: Colors.red),
                    title: const Text('박학생 퇴실 체크 승인 요청'),
                    subtitle: const Text('8분 전'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.check, color: Colors.green),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                fontSize: 20.sp,
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

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32.w),
              SizedBox(height: 8.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}