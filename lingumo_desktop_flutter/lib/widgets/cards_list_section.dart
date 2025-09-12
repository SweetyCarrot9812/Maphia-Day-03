import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/card_providers.dart';
import '../models/card_model.dart';
import '../widgets/card_item.dart';

class CardsListSection extends ConsumerWidget {
  const CardsListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredCardsAsync = ref.watch(filteredCardsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final currentVocabulary = ref.watch(currentVocabularyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with search and count
        Row(
          children: [
            const Icon(Icons.list_alt, size: 24),
            const SizedBox(width: 8),
            const Text(
              '저장된 카드',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            filteredCardsAsync.when(
              data: (cards) => Chip(
                label: Text('${cards.length}개'),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Search bar
        TextField(
          controller: TextEditingController(text: searchQuery)..selection = TextSelection.collapsed(offset: searchQuery.length),
          onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
          decoration: InputDecoration(
            hintText: '카드 검색...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Cards list
        Expanded(
          child: filteredCardsAsync.when(
            data: (cards) => cards.isEmpty
                ? _buildEmptyState(context, searchQuery.isNotEmpty)
                : ListView.separated(
                    itemCount: cards.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return CardItem(
                        card: card,
                        onDelete: () => _deleteCard(context, ref, card.id!),
                        onEdit: () => _editCard(context, ref, card),
                      );
                    },
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading cards',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Action buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () => _importFromTxt(context, ref),
              icon: const Icon(Icons.upload_file),
              label: const Text('TXT 불러오기'),
            ),
            ElevatedButton.icon(
              onPressed: () => _exportToTxt(context, ref),
              icon: const Icon(Icons.download),
              label: const Text('TXT 내보내기'),
            ),
            ElevatedButton.icon(
              onPressed: () => _deleteAllCards(context, ref),
              icon: const Icon(Icons.delete_sweep),
              label: const Text('전체 삭제'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.search_off : Icons.note_add,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? '검색 결과가 없습니다' : '저장된 카드가 없습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? '다른 검색어를 시도해보세요'
                : '왼쪽 패널에서 카드를 추가해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCard(BuildContext context, WidgetRef ref, String cardId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 삭제'),
        content: const Text('이 카드를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(cardOperationsProvider).deleteCard(cardId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('카드가 삭제되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _editCard(BuildContext context, WidgetRef ref, CardModel card) {
    // Fill the form with card data for editing
    ref.read(frontInputProvider.notifier).state = card.front;
    ref.read(backInputProvider.notifier).state = card.back;
    ref.read(noteInputProvider.notifier).state = card.note;
    ref.read(selectedCardProvider.notifier).state = card;
    ref.read(isEditingCardProvider.notifier).state = true;
  }

  Future<void> _importFromTxt(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final lines = content.split('\n');
        
        final cards = <CardModel>[];
        final currentVocabulary = ref.read(currentVocabularyProvider);

        for (final line in lines) {
          final parts = line.split('\t');
          if (parts.length >= 2) {
            cards.add(CardModel.create(
              front: parts[0].trim(),
              back: parts[1].trim(),
              note: parts.length > 2 ? parts[2].trim() : '',
              vocabularyId: currentVocabulary?.id ?? 'default',
            ));
          }
        }

        if (cards.isNotEmpty) {
          await ref.read(cardOperationsProvider).importCards(cards);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${cards.length}개의 카드를 가져왔습니다.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('가져오기 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToTxt(BuildContext context, WidgetRef ref) async {
    final cardsAsync = ref.read(filteredCardsProvider);
    
    cardsAsync.when(
      data: (cards) async {
        if (cards.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('내보낼 카드가 없습니다.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final content = cards.map((card) {
          return '${card.front}\t${card.back}\t${card.note}';
        }).join('\n');

        // Save file
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'TXT 파일로 저장',
          fileName: 'lingumo_cards_${DateTime.now().millisecondsSinceEpoch}.txt',
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsString(content);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('카드가 TXT 파일로 저장되었습니다.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
      loading: () {},
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('내보내기 실패: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Future<void> _deleteAllCards(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 카드를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('전체 삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final currentVocabulary = ref.read(currentVocabularyProvider);
        await ref.read(cardOperationsProvider).deleteAllCards(
          vocabularyId: currentVocabulary?.id,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('모든 카드가 삭제되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}