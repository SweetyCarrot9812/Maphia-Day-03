import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NursingScreen extends ConsumerWidget {
  const NursingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('간호사 시험 관리'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 통계 카드들
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    '총 문제 수',
                    '1,234',
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '카테고리 수',
                    '45',
                    Icons.category,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '평균 정답률',
                    '78%',
                    Icons.analytics,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '활성 사용자',
                    '567',
                    Icons.people,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            
            // 관리 메뉴
            Row(
              children: [
                Text(
                  '관리 메뉴',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    // 새 문제 추가 로직
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('문제 추가'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // 관리 메뉴 그리드
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16.w,
                crossAxisSpacing: 16.h,
                children: [
                  _buildMenuCard(
                    context,
                    '문제 관리',
                    Icons.quiz,
                    '문제 생성, 편집, 삭제',
                    () {},
                  ),
                  _buildMenuCard(
                    context,
                    '카테고리 관리',
                    Icons.category,
                    '카테고리 구성 관리',
                    () {},
                  ),
                  _buildMenuCard(
                    context,
                    '통계 분석',
                    Icons.analytics,
                    '시험 결과 분석',
                    () {},
                  ),
                  _buildMenuCard(
                    context,
                    '사용자 관리',
                    Icons.people,
                    '학습자 관리',
                    () {},
                  ),
                  _buildMenuCard(
                    context,
                    '백업/복원',
                    Icons.backup,
                    '데이터 백업 및 복원',
                    () {},
                  ),
                  _buildMenuCard(
                    context,
                    '설정',
                    Icons.settings,
                    '시스템 설정',
                    () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24.r,
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 16.r,
                ),
              ),
            ],
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.r,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}