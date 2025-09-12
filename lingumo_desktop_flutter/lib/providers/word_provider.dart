import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';

// 단어 목록 상태 관리
class WordNotifier extends StateNotifier<List<WordModel>> {
  WordNotifier() : super([]) {
    _loadWords();
  }

  // 초기 데이터 로드
  void _loadWords() {
    state = WordService.getAllWords();
  }

  // 새 단어/뜻 추가
  Future<void> addWord(String english, String korean) async {
    await WordService.saveWord(english: english, korean: korean);
    _loadWords(); // 상태 새로고침
  }

  // 단어 상태 업데이트
  Future<void> updateWordStatus(WordModel word, String newStatus) async {
    await WordService.updateWordStatus(word, newStatus);
    _loadWords(); // 상태 새로고침
  }

  // 단어 삭제
  Future<void> deleteWord(WordModel word) async {
    await WordService.deleteWord(word);
    _loadWords(); // 상태 새로고침
  }

  // 검색
  List<WordModel> searchWords(String query) {
    return WordService.searchWords(query);
  }

  // 새로고침
  void refresh() {
    _loadWords();
  }
}

// Provider 정의
final wordProvider = StateNotifierProvider<WordNotifier, List<WordModel>>((ref) {
  return WordNotifier();
});

// 통계 Provider
final wordStatsProvider = Provider<Map<String, int>>((ref) {
  // wordProvider 변경 시 자동으로 재계산
  ref.watch(wordProvider);
  return WordService.getWordStats();
});

// 오늘 추가된 단어 개수 Provider
final todayWordsProvider = Provider<int>((ref) {
  ref.watch(wordProvider);
  return WordService.getTodayAddedCount();
});