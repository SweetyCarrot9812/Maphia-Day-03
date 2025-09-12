import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../services/srs_service.dart';
import '../../../shared/models/srs_card.dart';

class SRSDashboardScreen extends ConsumerStatefulWidget {
  const SRSDashboardScreen({super.key});

  @override
  ConsumerState<SRSDashboardScreen> createState() => _SRSDashboardScreenState();
}

class _SRSDashboardScreenState extends ConsumerState<SRSDashboardScreen> {
  final String userId = 'demo_user'; // 실제로는 로그인한 사용자 ID 사용

  @override
  void initState() {
    super.initState();
    // 사용자 카드 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(srsCardsProvider.notifier).loadUserCards(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(srsStatsProvider(userId));
    final todayCardsAsync = ref.watch(todayReviewCardsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('간격 반복 학습 (SRS)'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(
                  Icons.memory,
                  size: 32.r,
                  color: Colors.deepPurple,
                ),
                SizedBox(width: 12.w),
                Text(
                  '학습 진도 대시보드',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // 통계 카드들
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('통계 로드 실패: $error'),
              data: (stats) => Column(
                children: [
                  _buildStatsRow(stats),
                  SizedBox(height: 16.h),
                  _buildTypeStatsGrid(stats),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // 오늘 복습할 카드들
            Text(
              '오늘의 복습',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),

            todayCardsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('복습 카드 로드 실패: $error'),
              data: (todayCards) => todayCards.isEmpty
                  ? _buildNoReviewsCard()
                  : Column(
                      children: [
                        _buildReviewButton(todayCards.length),
                        SizedBox(height: 16.h),
                        _buildTodayCardsList(todayCards),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(SRSStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '총 카드',
            stats.totalCards.toString(),
            Colors.blue,
            Icons.style,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            '오늘 복습',
            stats.dueToday.toString(),
            Colors.orange,
            Icons.today,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            '총 복습',
            stats.totalReviews.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.r),
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
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStatsGrid(SRSStats stats) {
    if (stats.byType.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            '아직 학습 카드가 없습니다.\n문제를 풀어서 SRS 카드를 생성해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 2.5,
      ),
      itemCount: stats.byType.length,
      itemBuilder: (context, index) {
        final entry = stats.byType.entries.elementAt(index);
        final type = entry.key;
        final typeStats = entry.value;
        
        return _buildTypeStatCard(type, typeStats);
      },
    );
  }

  Widget _buildTypeStatCard(String type, ItemTypeStats stats) {
    final colors = {
      'problem': Colors.purple,
      'concept': Colors.teal,
    };
    
    final color = colors[type] ?? Colors.blueGrey;
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                width: 8.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                type == 'problem' ? '문제' : '개념',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '총 ${stats.total}장 • 복습 ${stats.dueToday}장',
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReviewsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 48.r,
            color: Colors.green,
          ),
          SizedBox(height: 12.h),
          Text(
            '오늘 복습할 카드가 없습니다!',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '새로운 문제를 풀어서 학습 카드를 만들어보세요.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(int cardCount) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 복습 화면으로 이동
          context.go('/srs-review');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              '복습 시작 ($cardCount장)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCardsList(List<SRSCard> cards) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16.r, color: Colors.deepPurple),
                SizedBox(width: 8.w),
                Text(
                  '복습 대기 중인 카드들',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          ...cards.take(5).map((card) => _buildCardListItem(card)),
          if (cards.length > 5)
            Container(
              padding: EdgeInsets.all(12.w),
              child: Text(
                '외 ${cards.length - 5}장 더',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardListItem(SRSCard card) {
    final isOverdue = card.dueDate.isBefore(DateTime.now());
    final overdueDays = isOverdue ? DateTime.now().difference(card.dueDate).inDays : 0;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: card.itemType == 'problem' ? Colors.purple : Colors.teal,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${card.itemId}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${card.itemType == 'problem' ? '문제' : '개념'} • 복습 ${card.totalReviews}회',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (isOverdue)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '$overdueDays일 연체',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}