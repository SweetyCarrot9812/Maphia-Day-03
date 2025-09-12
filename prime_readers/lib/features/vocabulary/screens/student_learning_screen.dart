import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../models/vocabulary_model.dart';
import '../providers/vocabulary_provider.dart';

class StudentLearningScreen extends ConsumerStatefulWidget {
  const StudentLearningScreen({super.key});

  @override
  ConsumerState<StudentLearningScreen> createState() => _StudentLearningScreenState();
}

class _StudentLearningScreenState extends ConsumerState<StudentLearningScreen> {
  static const String currentUserId = 'student1';

  @override
  void initState() {
    super.initState();
    // 샘플 데이터 추가 (한 번만 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vocabularyControllerProvider.notifier).addSampleData(currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyStatsAsync = ref.watch(vocabularyStatsProvider(currentUserId));
    final newWordsAsync = ref.watch(newWordsProvider(currentUserId));
    final reviewWordsAsync = ref.watch(reviewWordsProvider(currentUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('단어 학습'),
        centerTitle: true,
        backgroundColor: Colors.green.shade50,
        actions: [
          IconButton(
            onPressed: () => _showAddWordDialog(),
            icon: const Icon(Icons.add),
            tooltip: '단어 추가',
          ),
          IconButton(
            onPressed: () => _showSearchDialog(),
            icon: const Icon(Icons.search),
            tooltip: '단어 검색',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(vocabularyStatsProvider(currentUserId));
          ref.invalidate(vocabularyWordsProvider(currentUserId));
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 학습 통계 카드
              vocabularyStatsAsync.when(
                data: (stats) => _buildStatsCard(stats),
                loading: () => _buildLoadingCard('통계 로딩 중...'),
                error: (error, _) => _buildErrorCard('통계 로딩 실패: $error'),
              ),
              
              SizedBox(height: 24.h),
              
              // 학습 세션 시작 버튼들
              _buildLearningActions(newWordsAsync, reviewWordsAsync),
              
              SizedBox(height: 24.h),
              
              // 최근 추가된 단어들
              _buildRecentWordsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startMixedLearningSession(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.play_arrow),
        label: const Text('학습 시작'),
      ),
    );
  }

  Widget _buildStatsCard(VocabularyStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green, size: 24.w),
                SizedBox(width: 8.w),
                Text(
                  '학습 현황',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // 진도율 표시
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '전체 진도율',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      LinearProgressIndicator(
                        value: stats.averageMastery,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${(stats.averageMastery * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  children: [
                    Text(
                      '${stats.studyStreak}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '연속일',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 상태별 단어 수 통계
            Row(
              children: [
                Expanded(child: _buildStatItem('총 단어', '${stats.totalWords}개', Colors.blue)),
                Expanded(child: _buildStatItem('새 단어', '${stats.newWords}개', Colors.purple)),
                Expanded(child: _buildStatItem('복습 대기', '${stats.reviewDue}개', Colors.orange)),
                Expanded(child: _buildStatItem('숙달', '${stats.masteredWords}개', Colors.green)),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 정확도 표시
            Row(
              children: [
                Icon(Icons.accuracy, size: 16.w, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  '정확도: ${(stats.overallAccuracy * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14.sp,
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningActions(
    AsyncValue<List<VocabularyWord>> newWordsAsync, 
    AsyncValue<List<VocabularyWord>> reviewWordsAsync,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '학습 메뉴',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                // 새 단어 학습
                Expanded(
                  child: newWordsAsync.when(
                    data: (words) => _buildActionButton(
                      icon: Icons.star,
                      label: '새 단어',
                      subtitle: '${words.length}개',
                      color: Colors.purple,
                      onTap: words.isNotEmpty ? () => _startLearningSession(SessionType.newWords) : null,
                    ),
                    loading: () => _buildActionButton(
                      icon: Icons.star,
                      label: '새 단어',
                      subtitle: '로딩중...',
                      color: Colors.grey,
                      onTap: null,
                    ),
                    error: (_, __) => _buildActionButton(
                      icon: Icons.star,
                      label: '새 단어',
                      subtitle: '오류',
                      color: Colors.grey,
                      onTap: null,
                    ),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // 복습
                Expanded(
                  child: reviewWordsAsync.when(
                    data: (words) => _buildActionButton(
                      icon: Icons.refresh,
                      label: '복습',
                      subtitle: '${words.length}개',
                      color: Colors.orange,
                      onTap: words.isNotEmpty ? () => _startLearningSession(SessionType.review) : null,
                    ),
                    loading: () => _buildActionButton(
                      icon: Icons.refresh,
                      label: '복습',
                      subtitle: '로딩중...',
                      color: Colors.grey,
                      onTap: null,
                    ),
                    error: (_, __) => _buildActionButton(
                      icon: Icons.refresh,
                      label: '복습',
                      subtitle: '오류',
                      color: Colors.grey,
                      onTap: null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(onTap != null ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(onTap != null ? 0.3 : 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.w,
              color: onTap != null ? color : Colors.grey,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: onTap != null ? color : Colors.grey,
              ),
            ),
            Text(
              subtitle,
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

  Widget _buildRecentWordsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final wordsAsync = ref.watch(vocabularyWordsProvider(currentUserId));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최근 단어',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            
            wordsAsync.when(
              data: (words) {
                if (words.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(40.w),
                      child: Column(
                        children: [
                          Icon(Icons.library_books, size: 48.w, color: Colors.grey),
                          SizedBox(height: 12.h),
                          Text(
                            '등록된 단어가 없습니다',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ElevatedButton.icon(
                            onPressed: () => _showAddWordDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('첫 단어 추가하기'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final recentWords = words.take(5).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentWords.length,
                  itemBuilder: (context, index) {
                    final word = recentWords[index];
                    return _buildWordCard(word);
                  },
                );
              },
              loading: () => _buildLoadingCard('단어 목록 로딩 중...'),
              error: (error, _) => _buildErrorCard('단어 목록 로딩 실패: $error'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWordCard(VocabularyWord word) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: word.difficulty.emoji == '🟢' ? Colors.green.shade100 : 
                         word.difficulty.emoji == '🟡' ? Colors.orange.shade100 : 
                         Colors.red.shade100,
          child: Text(
            word.difficulty.emoji,
            style: TextStyle(fontSize: 20.sp),
          ),
        ),
        title: Row(
          children: [
            Text(
              word.word,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: word.status.emoji == '✨' ? Colors.purple.shade100 :
                       word.status.emoji == '📚' ? Colors.blue.shade100 :
                       word.status.emoji == '🔄' ? Colors.orange.shade100 :
                       Colors.green.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                word.status.displayName,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(word.meaning),
            if (word.pronunciation != null)
              Text(
                word.pronunciation!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(word.masteryProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            LinearProgressIndicator(
              value: word.masteryProgress,
              minHeight: 2.h,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(message),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          children: [
            Icon(Icons.error, size: 48.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddWordDialog() async {
    final wordController = TextEditingController();
    final meaningController = TextEditingController();
    final pronunciationController = TextEditingController();
    final exampleController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 단어 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordController,
                decoration: const InputDecoration(
                  labelText: '단어 *',
                  hintText: '영어 단어를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: meaningController,
                decoration: const InputDecoration(
                  labelText: '의미 *',
                  hintText: '한국어 의미를 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: pronunciationController,
                decoration: const InputDecoration(
                  labelText: '발음 (선택)',
                  hintText: '/ˈwɜːrd/',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: exampleController,
                decoration: const InputDecoration(
                  labelText: '예문 (선택)',
                  hintText: 'This is an example.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (wordController.text.trim().isNotEmpty && meaningController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (result == true) {
      final addedWord = await ref.read(vocabularyControllerProvider.notifier).addWord(
        word: wordController.text.trim(),
        meaning: meaningController.text.trim(),
        pronunciation: pronunciationController.text.trim().isNotEmpty ? pronunciationController.text.trim() : null,
        example: exampleController.text.trim().isNotEmpty ? exampleController.text.trim() : null,
        userId: currentUserId,
      );

      if (mounted && addedWord != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${addedWord.word} 단어가 추가되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showSearchDialog() async {
    final searchController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('단어 검색'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: '검색어',
                hintText: '단어나 의미를 입력하세요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16.h),
            Text('검색 기능은 향후 업데이트될 예정입니다.', 
                 style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _startLearningSession(SessionType sessionType) {
    // 학습 세션 화면으로 이동 (향후 구현)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sessionType.displayName} 세션을 시작합니다!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _startMixedLearningSession() {
    _startLearningSession(SessionType.mixed);
  }
}