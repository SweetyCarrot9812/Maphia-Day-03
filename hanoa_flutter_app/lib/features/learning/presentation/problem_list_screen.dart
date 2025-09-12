import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/problem_provider.dart';
import '../../../core/theme/app_theme.dart';

/// 문제 목록 화면
class ProblemListScreen extends ConsumerStatefulWidget {
  const ProblemListScreen({super.key});

  @override
  ConsumerState<ProblemListScreen> createState() => _ProblemListScreenState();
}

class _ProblemListScreenState extends ConsumerState<ProblemListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final problemsAsync = ref.watch(filteredProblemsProvider);
    final searchQuery = ref.watch(problemSearchProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('문제 풀이'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 검색바
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '문제 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(problemSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                ref.read(problemSearchProvider.notifier).state = value;
              },
            ),
          ),
          
          // 문제 목록
          Expanded(
            child: problemsAsync.when(
              data: (problems) {
                if (problems.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: problems.length,
                  itemBuilder: (context, index) {
                    final problem = problems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.quiz_outlined,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        title: Text(
                          problem.stem.length > 80
                              ? '${problem.stem.substring(0, 80)}...'
                              : problem.stem,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '선택지 ${problem.choices.length}개',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (problem.tags.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: problem.tags.take(3).map((tag) => 
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.accentColor,
                                      ),
                                    ),
                                  ),
                                ).toList(),
                              ),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '정답: ${problem.answerIndex + 1}번',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => context.go('/problems/edit?id=${problem.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentColor,
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '문제를 불러오는데 실패했습니다',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(problemsProvider),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/problems/edit'),
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    final searchQuery = ref.watch(problemSearchProvider);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.quiz_outlined,
              color: AppTheme.accentColor,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty
                ? '검색 결과가 없습니다'
                : '아직 문제가 없습니다',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? '다른 키워드로 검색해보세요'
                : '첫 번째 연습 문제를 추가해보세요',
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/problems/edit'),
              icon: const Icon(Icons.add),
              label: const Text('문제 추가하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}