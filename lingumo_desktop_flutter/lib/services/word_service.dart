import 'package:hive/hive.dart';
import '../models/word_model.dart';

class WordService {
  static const String _boxName = 'words';
  static Box<WordModel>? _box;

  // Hive Box 초기화
  static Future<void> initializeBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<WordModel>(_boxName);
    }
  }

  // Box 가져오기
  static Box<WordModel> get _wordsBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('WordService not initialized. Call initializeBox() first.');
    }
    return _box!;
  }

  // 단어/뜻 저장
  static Future<void> saveWord({
    required String english,
    required String korean,
  }) async {
    final wordData = WordModel(
      id: DateTime.now().millisecondsSinceEpoch,
      english: english.trim(),
      korean: korean.trim(),
      createdAt: DateTime.now().toIso8601String(),
      status: 'new',
    );

    await _wordsBox.add(wordData);
    print('💾 저장됨: $english → $korean - ID: ${wordData.id}');
  }

  // 모든 단어/문장 가져오기
  static List<WordModel> getAllWords() {
    return _wordsBox.values.toList().reversed.toList(); // 최신순 정렬
  }

  // 상태별 단어 개수
  static Map<String, int> getWordStats() {
    final words = getAllWords();
    return {
      'total': words.length,
      'new': words.where((w) => w.status == 'new').length,
      'learning': words.where((w) => w.status == 'learning').length,
      'mastered': words.where((w) => w.status == 'mastered').length,
    };
  }

  // 오늘 추가된 단어 개수
  static int getTodayAddedCount() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return getAllWords()
        .where((word) => word.createdAt.startsWith(todayStr))
        .length;
  }

  // 단어 상태 업데이트
  static Future<void> updateWordStatus(WordModel word, String newStatus) async {
    final updatedWord = WordModel(
      id: word.id,
      english: word.english,
      korean: word.korean,
      createdAt: word.createdAt,
      status: newStatus,
      pronunciation: word.pronunciation,
      examples: word.examples,
      lastReviewed: DateTime.now(),
    );

    await word.delete(); // 기존 항목 삭제
    await _wordsBox.add(updatedWord); // 새 항목 추가
  }

  // 단어 삭제
  static Future<void> deleteWord(WordModel word) async {
    await word.delete();
    print('🗑️ 삭제됨: ${word.english} → ${word.korean}');
  }

  // 검색
  static List<WordModel> searchWords(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllWords()
        .where((word) => 
            word.english.toLowerCase().contains(lowercaseQuery) ||
            word.korean.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Box 닫기
  static Future<void> closeBox() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }

  // 데이터 백업 (JSON 형태)
  static Map<String, dynamic> exportData() {
    final words = getAllWords();
    return {
      'exported_at': DateTime.now().toIso8601String(),
      'total_count': words.length,
      'words': words.map((word) => word.toJson()).toList(),
    };
  }
}