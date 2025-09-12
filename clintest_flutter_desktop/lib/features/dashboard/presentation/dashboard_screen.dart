import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/firebase_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Firebase 데이터 구독
    final systemStatsAsync = ref.watch(systemStatsProvider);
    final firebaseConnectionAsync = ref.watch(firebaseConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clintest Desktop'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Firebase 연결 상태 표시
          Consumer(
            builder: (context, ref, child) {
              return firebaseConnectionAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (error, stack) => Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        color: Colors.red,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Firebase 오류',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                data: (isConnected) => Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: isConnected ? Colors.green : Colors.red,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isConnected ? 'Firebase 연결됨' : 'Firebase 연결 끊김',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // 컴팩트 헤더
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 28.r,
                    color: Colors.white,
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clintest Desktop',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '의료 교육 관리 플랫폼',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Firebase 연결 상태를 간단히
                  Consumer(
                    builder: (context, ref, child) {
                      return ref.watch(firebaseConnectionProvider).when(
                        loading: () => const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        error: (error, stack) => Icon(
                          Icons.cloud_off_rounded,
                          color: Colors.red[300],
                          size: 20.r,
                        ),
                        data: (isConnected) => Icon(
                          isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                          color: isConnected ? Colors.green[300] : Colors.red[300],
                          size: 20.r,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // 메인 컨텐츠 영역
            Expanded(
              child: Row(
                children: [
                  // 왼쪽: 통계 요약
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Consumer(
                        builder: (context, ref, child) {
                          return ref.watch(systemStatsProvider).when(
                            loading: () => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16.h),
                                Text('데이터 로딩 중...'),
                              ],
                            ),
                            error: (error, stack) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48.r,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Firebase 연결 오류',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '권한 오류가 발생했습니다',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            data: (stats) {
                              final totalQuestions = stats['totalQuestions'] ?? 0;
                              final totalConcepts = stats['totalConcepts'] ?? 0;
                              final activeUsers = stats['activeUsers'] ?? 0;
                              final systemStatus = stats['systemStatus'] ?? '알 수 없음';
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '시스템 현황',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  
                                  // 간단한 통계 요약
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCompactStatCard(
                                          context,
                                          '총 문제',
                                          totalQuestions.toString(),
                                          Icons.quiz_outlined,
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: _buildCompactStatCard(
                                          context,
                                          '총 개념',
                                          totalConcepts.toString(),
                                          Icons.lightbulb_outline,
                                          Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCompactStatCard(
                                          context,
                                          '활성 사용자',
                                          activeUsers.toString(),
                                          Icons.people_outline,
                                          Colors.green,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: _buildCompactStatCard(
                                          context,
                                          '시스템 상태',
                                          systemStatus.contains('연결됨') ? '정상' : '오류',
                                          systemStatus.contains('연결됨') ? Icons.check_circle_outline : Icons.error_outline,
                                          systemStatus.contains('연결됨') ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  
                  // 오른쪽: 주요 기능 버튼들
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '주요 기능',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          
                          Expanded(
                            child: Column(
                              children: [
                                _buildQuickActionCard(
                                  context,
                                  '수동 문제 입력',
                                  '직접 문제 작성',
                                  Icons.edit_note_rounded,
                                  Theme.of(context).colorScheme.primary,
                                  () => context.go('/manual-questions'),
                                ),
                                SizedBox(height: 12.h),
                                _buildQuickActionCard(
                                  context,
                                  '수동 개념 입력',
                                  '학습 개념 관리',
                                  Icons.book_rounded,
                                  Colors.purple,
                                  () => context.go('/manual-concepts'),
                                ),
                                SizedBox(height: 12.h),
                                _buildQuickActionCard(
                                  context,
                                  'AI 작업',
                                  '자동 생성 및 분석',
                                  Icons.psychology_rounded,
                                  Colors.orange,
                                  () => context.go('/ai-work'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24.r,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.green,
                  size: 16.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16.r,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12.r,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32.r,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              const Spacer(),
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: 60.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 120.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: 100.w,
            height: 13.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ],
      ),
    );
  }
}