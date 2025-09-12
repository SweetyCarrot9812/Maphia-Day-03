import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../services/srs_service.dart';
import '../../../shared/models/srs_card.dart';

class SRSReviewScreen extends ConsumerStatefulWidget {
  const SRSReviewScreen({super.key});

  @override
  ConsumerState<SRSReviewScreen> createState() => _SRSReviewScreenState();
}

class _SRSReviewScreenState extends ConsumerState<SRSReviewScreen> {
  final String userId = 'demo_user';
  
  int currentCardIndex = 0;
  bool isAnswerShown = false;
  List<SRSCard> reviewCards = [];
  int completedReviews = 0;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _loadReviewCards();
  }

  Future<void> _loadReviewCards() async {
    try {
      final srsService = ref.read(srsServiceProvider);
      final cards = await srsService.getTodayReviewCards(userId: userId);
      
      setState(() {
        reviewCards = cards;
      });
      
      if (cards.isNotEmpty) {
        _stopwatch.start();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('복습 카드 로드 실패: $e')),
      );
    }
  }

  void _showAnswer() {
    setState(() {
      isAnswerShown = true;
    });
  }

  Future<void> _submitReview(String userResponse) async {
    if (currentCardIndex >= reviewCards.length) return;
    
    final currentCard = reviewCards[currentCardIndex];
    final responseTime = _stopwatch.elapsedMilliseconds;
    _stopwatch.reset();
    _stopwatch.start();
    
    try {
      await ref.read(srsCardsProvider.notifier).reviewCard(
        cardId: currentCard.cardId,
        userId: userId,
        userResponse: userResponse,
        responseTimeMs: responseTime,
      );
      
      setState(() {
        completedReviews++;
        currentCardIndex++;
        isAnswerShown = false;
      });
      
      // 완료 확인
      if (currentCardIndex >= reviewCards.length) {
        _stopwatch.stop();
        _showCompletionDialog();
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('복습 처리 실패: $e')),
      );
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green, size: 28.r),
            SizedBox(width: 8.w),
            const Text('복습 완료!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘의 복습을 모두 완료했습니다.'),
            SizedBox(height: 8.h),
            Text('• 완료한 카드: $completedReviews장'),
            Text('• 소요 시간: ${_getFormattedTime(_stopwatch.elapsed)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.go('/srs');
            },
            child: const Text('대시보드로 이동'),
          ),
        ],
      ),
    );
  }

  String _getFormattedTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}분 ${seconds}초';
  }

  @override
  Widget build(BuildContext context) {
    if (reviewCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SRS 복습'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentCardIndex >= reviewCards.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SRS 복습'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('복습이 완료되었습니다!'),
        ),
      );
    }

    final currentCard = reviewCards[currentCardIndex];
    final progress = (currentCardIndex + 1) / reviewCards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('복습 ${currentCardIndex + 1}/${reviewCards.length}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/srs'),
        ),
      ),
      body: Column(
        children: [
          // 진도 표시
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
                SizedBox(height: 8.h),
                Text(
                  '진행률: ${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // 카드 정보
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카드 헤더
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          currentCard.itemType == 'problem' ? Icons.quiz : Icons.lightbulb,
                          color: Colors.deepPurple,
                          size: 24.r,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentCard.itemType == 'problem' ? '문제' : '개념',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                'ID: ${currentCard.itemId}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildDifficultyIndicator(currentCard.aiDifficultyScore),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 문제 내용 (임시)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
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
                        Text(
                          '문제 내용',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '이것은 ${currentCard.itemId}에 해당하는 ${currentCard.itemType == 'problem' ? '문제' : '개념'}입니다.\n\n'
                          '실제 구현에서는 여기에 문제 텍스트나 개념 설명이 표시됩니다.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 답안 표시
                  if (isAnswerShown) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20.r),
                              SizedBox(width: 8.w),
                              Text(
                                '정답 및 해설',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '이것은 ${currentCard.itemId}의 정답과 해설입니다.\n\n'
                            '실제 구현에서는 여기에 정답과 상세한 해설이 표시됩니다.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ],
              ),
            ),
          ),

          // 버튼 영역
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (!isAnswerShown) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        '정답 보기',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    '답을 얼마나 잘 기억했나요?',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _submitReview('again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.refresh, size: 20.r),
                              SizedBox(height: 4.h),
                              Text(
                                '다시',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _submitReview('good'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.check, size: 20.r),
                              SizedBox(height: 4.h),
                              Text(
                                '맞음',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyIndicator(double difficulty) {
    Color color;
    String label;
    IconData icon;

    if (difficulty < 0.3) {
      color = Colors.green;
      label = '쉬움';
      icon = Icons.sentiment_satisfied;
    } else if (difficulty < 0.7) {
      color = Colors.orange;
      label = '보통';
      icon = Icons.sentiment_neutral;
    } else {
      color = Colors.red;
      label = '어려움';
      icon = Icons.sentiment_dissatisfied;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.r),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}