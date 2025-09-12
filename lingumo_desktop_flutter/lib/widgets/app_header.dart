import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/card_providers.dart';
import '../models/vocabulary_model.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabulariesAsync = ref.watch(vocabulariesStreamProvider);
    final currentVocabulary = ref.watch(currentVocabularyProvider);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo and title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Lingumo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'AI 기반 언어 학습',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const Spacer(),
          
          // Vocabulary selector
          vocabulariesAsync.when(
            data: (vocabularies) => _buildVocabularySelector(
              context, ref, vocabularies, currentVocabulary,
            ),
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (error, stack) => Text(
              'Error loading vocabularies',
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Action buttons
          Row(
            children: [
              IconButton(
                onPressed: () => _showAboutDialog(context),
                icon: const Icon(Icons.info_outline, color: Colors.white),
                tooltip: '정보',
              ),
              IconButton(
                onPressed: () => _refreshData(ref),
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: '새로고침',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularySelector(
    BuildContext context,
    WidgetRef ref,
    List<VocabularyModel> vocabularies,
    VocabularyModel? currentVocabulary,
  ) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
      child: DropdownButtonFormField<VocabularyModel?>(
        value: currentVocabulary,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          prefixIcon: const Icon(Icons.folder_outlined, color: Colors.white),
        ),
        dropdownColor: Theme.of(context).colorScheme.surface,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        hint: const Text(
          '단어장 선택',
          style: TextStyle(color: Colors.white70),
        ),
        items: [
          // Default vocabulary
          const DropdownMenuItem<VocabularyModel?>(
            value: null,
            child: Row(
              children: [
                Icon(Icons.folder, size: 16),
                SizedBox(width: 8),
                Text('기본 단어장'),
              ],
            ),
          ),
          // Other vocabularies
          ...vocabularies.map((vocabulary) => DropdownMenuItem<VocabularyModel?>(
            value: vocabulary,
            child: Row(
              children: [
                const Icon(Icons.folder, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vocabulary.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
        ],
        onChanged: (vocabulary) {
          ref.read(currentVocabularyProvider.notifier).state = vocabulary;
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star_rounded, color: Color(0xFF2E86AB)),
            SizedBox(width: 8),
            Text('Lingumo'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('버전 1.0.0'),
            SizedBox(height: 8),
            Text('AI 기반 개인 맞춤형 언어 학습 도우미'),
            SizedBox(height: 8),
            Text('© 2024 Lingumo Team. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _refreshData(WidgetRef ref) {
    // Refresh data by invalidating providers
    ref.invalidate(vocabulariesStreamProvider);
    ref.invalidate(cardsStreamProvider);
  }
}