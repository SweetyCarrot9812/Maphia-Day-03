import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/concept_provider.dart';
import '../../../core/theme/app_theme.dart';

/// 개념 목록 화면
class ConceptListScreen extends ConsumerStatefulWidget {
  const ConceptListScreen({super.key});

  @override
  ConsumerState<ConceptListScreen> createState() => _ConceptListScreenState();
}

class _ConceptListScreenState extends ConsumerState<ConceptListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conceptsAsync = ref.watch(filteredConceptsProvider);
    final searchQuery = ref.watch(conceptSearchProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('개념 학습'),
        backgroundColor: AppTheme.primaryColor,
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
                hintText: '개념 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(conceptSearchProvider.notifier).state = '';
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
                ref.read(conceptSearchProvider.notifier).state = value;
              },
            ),
          ),
          
          // 개념 목록
          Expanded(
            child: conceptsAsync.when(
              data: (concepts) {
                if (concepts.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: concepts.length,
                  itemBuilder: (context, index) {
                    final concept = concepts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.book_outlined,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          concept.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: concept.body.isNotEmpty
                            ? Text(
                                concept.body.length > 100
                                    ? '${concept.body.substring(0, 100)}...'
                                    : concept.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: concept.tags.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${concept.tags.length}개 태그',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.accentColor,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () => context.go('/concepts/edit?id=${concept.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
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
                      '개념을 불러오는데 실패했습니다',
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
                      onPressed: () => ref.refresh(conceptsProvider),
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
        onPressed: () => context.go('/concepts/edit'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    final searchQuery = ref.watch(conceptSearchProvider);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.book_outlined,
              color: AppTheme.primaryColor,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty
                ? '검색 결과가 없습니다'
                : '아직 개념이 없습니다',
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
                : '첫 번째 의료 개념을 추가해보세요',
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/concepts/edit'),
              icon: const Icon(Icons.add),
              label: const Text('개념 추가하기'),
            ),
          ],
        ],
      ),
    );
  }
}