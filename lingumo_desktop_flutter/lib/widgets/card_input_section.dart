import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/card_providers.dart';

class CardInputSection extends ConsumerWidget {
  const CardInputSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frontInput = ref.watch(frontInputProvider);
    final backInput = ref.watch(backInputProvider);
    final noteInput = ref.watch(noteInputProvider);
    final currentVocabulary = ref.watch(currentVocabularyProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section title
        Row(
          children: [
            const Icon(Icons.edit_note, size: 24),
            const SizedBox(width: 8),
            const Text(
              '카드 만들기',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (currentVocabulary != null)
              Chip(
                label: Text(currentVocabulary.name),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Error message
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(errorMessageProvider.notifier).state = null,
                  icon: const Icon(Icons.close, size: 16),
                  color: Colors.red.shade700,
                ),
              ],
            ),
          ),
        
        // Form fields
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Front field
              _buildFieldGroup(
                label: '▼ Front',
                hint: '앞면 내용을 입력하세요 (예: apple)',
                value: frontInput,
                onChanged: (value) => ref.read(frontInputProvider.notifier).state = value,
              ),
              
              const SizedBox(height: 16),
              
              // Back field
              _buildFieldGroup(
                label: '▼ Back',
                hint: '뒷면 내용을 입력하세요 (예: 사과)',
                value: backInput,
                onChanged: (value) => ref.read(backInputProvider.notifier).state = value,
              ),
              
              const SizedBox(height: 16),
              
              // Note field (optional)
              _buildFieldGroup(
                label: '▼ Note (선택사항)',
                hint: '추가 메모를 입력하세요',
                value: noteInput,
                onChanged: (value) => ref.read(noteInputProvider.notifier).state = value,
                maxLines: 2,
              ),
              
              const Spacer(),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : () => _addCard(context, ref),
                      icon: isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(isLoading ? '추가 중...' : '추가'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : () => _clearForm(ref),
                      icon: const Icon(Icons.clear),
                      label: const Text('지우기'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldGroup({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    int maxLines = 4,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _addCard(BuildContext context, WidgetRef ref) async {
    final frontInput = ref.read(frontInputProvider);
    final backInput = ref.read(backInputProvider);
    final noteInput = ref.read(noteInputProvider);
    final currentVocabulary = ref.read(currentVocabularyProvider);
    final cardOperations = ref.read(cardOperationsProvider);

    // Clear previous error
    ref.read(errorMessageProvider.notifier).state = null;

    if (frontInput.trim().isEmpty || backInput.trim().isEmpty) {
      ref.read(errorMessageProvider.notifier).state = 'Front와 Back은 필수 입력 항목입니다.';
      return;
    }

    try {
      ref.read(isLoadingProvider.notifier).state = true;
      
      await cardOperations.addCard(
        front: frontInput,
        back: backInput,
        note: noteInput,
        vocabularyId: currentVocabulary?.id,
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카드가 성공적으로 추가되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = e.toString();
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void _clearForm(WidgetRef ref) {
    ref.read(frontInputProvider.notifier).state = '';
    ref.read(backInputProvider.notifier).state = '';
    ref.read(noteInputProvider.notifier).state = '';
    ref.read(errorMessageProvider.notifier).state = null;
  }
}