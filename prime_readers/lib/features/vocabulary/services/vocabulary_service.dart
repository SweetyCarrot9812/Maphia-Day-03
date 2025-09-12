import 'dart:async';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/vocabulary_model.dart';

class VocabularyService {
  static const String _boxName = 'vocabulary_words';
  Box<VocabularyWord>? _box;

  // Initialize Hive box
  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(VocabularyWordAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DifficultyLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(LearningStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ReviewResultAdapter());
    }
    
    _box = await Hive.openBox<VocabularyWord>(_boxName);
  }

  Box<VocabularyWord> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('VocabularyService not initialized. Call initialize() first.');
    }
    return _box!;
  }

  // 새 단어 추가
  Future<VocabularyWord> addWord({
    required String word,
    required String meaning,
    String? pronunciation,
    String? example,
    String? exampleTranslation,
    DifficultyLevel? difficulty,
    String category = '일반',
    List<String> tags = const [],
    String? imageUrl,
    String? audioUrl,
    required String userId,
  }) async {
    // 중복 체크
    final existingWord = await getWordByText(word, userId);
    if (existingWord != null) {
      throw Exception('이미 등록된 단어입니다: $word');
    }

    final vocabularyWord = VocabularyWord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      word: word.trim().toLowerCase(),
      meaning: meaning.trim(),
      pronunciation: pronunciation?.trim(),
      example: example?.trim(),
      exampleTranslation: exampleTranslation?.trim(),
      difficulty: difficulty ?? VocabularyWord.estimateDifficulty(word),
      category: category,
      tags: tags,
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      userId: userId,
    );

    await box.put(vocabularyWord.id, vocabularyWord);
    return vocabularyWord;
  }

  // 단어 수정
  Future<void> updateWord(VocabularyWord word) async {
    await word.save();
  }

  // 단어 삭제
  Future<void> deleteWord(String wordId) async {
    await box.delete(wordId);
  }

  // 특정 단어 조회
  Future<VocabularyWord?> getWordByText(String word, String userId) async {
    final words = box.values.where((w) => 
      w.userId == userId && w.word.toLowerCase() == word.toLowerCase()
    ).toList();
    return words.isNotEmpty ? words.first : null;
  }

  // 사용자별 모든 단어 조회
  Stream<List<VocabularyWord>> getWordsStream(String userId) async* {
    await initialize();
    
    yield box.values.where((word) => word.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await for (final _ in box.watch()) {
      yield box.values.where((word) => word.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  // 복습 대상 단어들
  Stream<List<VocabularyWord>> getReviewWordsStream(String userId) async* {
    await initialize();
    
    yield _getReviewWords(userId);

    await for (final _ in box.watch()) {
      yield _getReviewWords(userId);
    }
  }

  List<VocabularyWord> _getReviewWords(String userId) {
    final now = DateTime.now();
    return box.values.where((word) => 
      word.userId == userId && 
      word.status != LearningStatus.newWord &&
      word.nextReview.isBefore(now)
    ).toList()
      ..sort((a, b) => a.nextReview.compareTo(b.nextReview));
  }

  // 새 단어들 (학습 시작 전)
  Stream<List<VocabularyWord>> getNewWordsStream(String userId) async* {
    await initialize();
    
    yield _getNewWords(userId);

    await for (final _ in box.watch()) {
      yield _getNewWords(userId);
    }
  }

  List<VocabularyWord> _getNewWords(String userId) {
    return box.values.where((word) => 
      word.userId == userId && word.status == LearningStatus.newWord
    ).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Public 메서드로 변경 (Provider에서 사용하기 위해)
  List<VocabularyWord> getNewWordsSync(String userId) => _getNewWords(userId);
  List<VocabularyWord> getReviewWordsSync(String userId) => _getReviewWords(userId);

  // 카테고리별 단어 조회
  Future<List<VocabularyWord>> getWordsByCategory(String userId, String category) async {
    return box.values.where((word) => 
      word.userId == userId && word.category == category
    ).toList();
  }

  // 난이도별 단어 조회
  Future<List<VocabularyWord>> getWordsByDifficulty(String userId, DifficultyLevel difficulty) async {
    return box.values.where((word) => 
      word.userId == userId && word.difficulty == difficulty
    ).toList();
  }

  // 태그별 단어 조회
  Future<List<VocabularyWord>> getWordsByTag(String userId, String tag) async {
    return box.values.where((word) => 
      word.userId == userId && word.tags.contains(tag)
    ).toList();
  }

  // 단어 검색
  Future<List<VocabularyWord>> searchWords(String userId, String query) async {
    final lowerQuery = query.toLowerCase();
    return box.values.where((word) => 
      word.userId == userId && (
        word.word.toLowerCase().contains(lowerQuery) ||
        word.meaning.toLowerCase().contains(lowerQuery) ||
        (word.example?.toLowerCase().contains(lowerQuery) ?? false)
      )
    ).toList();
  }

  // 단어 복습 처리
  Future<void> reviewWord(String wordId, ReviewResult result) async {
    final word = box.get(wordId);
    if (word == null) {
      throw Exception('단어를 찾을 수 없습니다.');
    }

    word.updateSRS(result);
    await word.save();
  }

  // 학습 세션 시작 (새 단어 → 학습 중으로 변경)
  Future<void> startLearning(String wordId) async {
    final word = box.get(wordId);
    if (word == null) {
      throw Exception('단어를 찾을 수 없습니다.');
    }

    if (word.status == LearningStatus.newWord) {
      word.status = LearningStatus.learning;
      word.nextReview = DateTime.now().add(Duration(days: word.interval));
      await word.save();
    }
  }

  // 학습 통계 조회
  Future<VocabularyStats> getStats(String userId) async {
    final userWords = box.values.where((word) => word.userId == userId).toList();
    
    final totalWords = userWords.length;
    final newWords = userWords.where((w) => w.status == LearningStatus.newWord).length;
    final learningWords = userWords.where((w) => w.status == LearningStatus.learning).length;
    final reviewWords = userWords.where((w) => w.status == LearningStatus.review).length;
    final masteredWords = userWords.where((w) => w.status == LearningStatus.mastered).length;
    
    final reviewDue = userWords.where((w) => w.needsReview).length;
    
    final totalReviews = userWords.fold<int>(0, (sum, word) => sum + word.reviewCount);
    final totalCorrect = userWords.fold<int>(0, (sum, word) => sum + word.correctCount);
    final overallAccuracy = totalReviews > 0 ? totalCorrect / totalReviews : 0.0;
    
    final averageMastery = totalWords > 0 
      ? userWords.fold<double>(0, (sum, word) => sum + word.masteryProgress) / totalWords 
      : 0.0;

    return VocabularyStats(
      totalWords: totalWords,
      newWords: newWords,
      learningWords: learningWords,
      reviewWords: reviewWords,
      masteredWords: masteredWords,
      reviewDue: reviewDue,
      overallAccuracy: overallAccuracy,
      averageMastery: averageMastery,
      studyStreak: await _calculateStudyStreak(userId),
    );
  }

  // 연속 학습일 계산
  Future<int> _calculateStudyStreak(String userId) async {
    final userWords = box.values.where((word) => word.userId == userId).toList();
    if (userWords.isEmpty) return 0;

    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) { // 최대 1년 계산
      final checkDate = now.subtract(Duration(days: i));
      final hasStudied = userWords.any((word) => 
        word.lastReviewed.year == checkDate.year &&
        word.lastReviewed.month == checkDate.month &&
        word.lastReviewed.day == checkDate.day
      );
      
      if (hasStudied) {
        streak++;
      } else if (i > 0) {
        break; // 연속이 끊어지면 중단 (오늘은 제외)
      }
    }
    
    return streak;
  }

  // 일별 학습 기록 조회
  Future<Map<DateTime, int>> getDailyStudyRecord(String userId, {int days = 30}) async {
    final userWords = box.values.where((word) => word.userId == userId).toList();
    final Map<DateTime, int> dailyRecord = {};
    
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      
      final studiedCount = userWords.where((word) => 
        word.lastReviewed.isAfter(dayStart) &&
        word.lastReviewed.isBefore(dayStart.add(const Duration(days: 1)))
      ).length;
      
      dailyRecord[dayStart] = studiedCount;
    }
    
    return dailyRecord;
  }

  // 샘플 데이터 추가
  Future<void> addSampleData(String userId) async {
    final sampleWords = [
      {
        'word': 'apple',
        'meaning': '사과',
        'pronunciation': '/ˈæpəl/',
        'example': 'I eat an apple every morning.',
        'exampleTranslation': '나는 매일 아침 사과를 하나씩 먹는다.',
        'category': '음식',
        'tags': ['과일', '건강'],
      },
      {
        'word': 'beautiful',
        'meaning': '아름다운',
        'pronunciation': '/ˈbjuːtɪfəl/',
        'example': 'The sunset is beautiful today.',
        'exampleTranslation': '오늘 석양이 아름답다.',
        'category': '형용사',
        'tags': ['감정', '외모'],
      },
      {
        'word': 'computer',
        'meaning': '컴퓨터',
        'pronunciation': '/kəmˈpjuːtər/',
        'example': 'I use my computer for work.',
        'exampleTranslation': '나는 일을 위해 컴퓨터를 사용한다.',
        'category': '기술',
        'tags': ['전자기기', '업무'],
      },
      {
        'word': 'education',
        'meaning': '교육',
        'pronunciation': '/ˌedjʊˈkeɪʃən/',
        'example': 'Education is important for everyone.',
        'exampleTranslation': '교육은 모든 사람에게 중요하다.',
        'category': '학습',
        'tags': ['학교', '성장'],
      },
      {
        'word': 'friendship',
        'meaning': '우정',
        'pronunciation': '/ˈfrendʃɪp/',
        'example': 'Their friendship lasted for many years.',
        'exampleTranslation': '그들의 우정은 수년간 지속되었다.',
        'category': '관계',
        'tags': ['감정', '사람'],
      },
    ];

    for (final wordData in sampleWords) {
      try {
        await addWord(
          word: wordData['word'] as String,
          meaning: wordData['meaning'] as String,
          pronunciation: wordData['pronunciation'] as String,
          example: wordData['example'] as String,
          exampleTranslation: wordData['exampleTranslation'] as String,
          category: wordData['category'] as String,
          tags: List<String>.from(wordData['tags'] as List),
          userId: userId,
        );
      } catch (e) {
        // 중복 단어는 무시
      }
    }
  }

  // 모든 데이터 삭제 (테스트용)
  Future<void> clearAllData() async {
    await box.clear();
  }
}

// 학습 통계 모델
class VocabularyStats {
  final int totalWords;
  final int newWords;
  final int learningWords;
  final int reviewWords;
  final int masteredWords;
  final int reviewDue;
  final double overallAccuracy;
  final double averageMastery;
  final int studyStreak;

  VocabularyStats({
    required this.totalWords,
    required this.newWords,
    required this.learningWords,
    required this.reviewWords,
    required this.masteredWords,
    required this.reviewDue,
    required this.overallAccuracy,
    required this.averageMastery,
    required this.studyStreak,
  });

  double get masteryPercentage => totalWords > 0 ? masteredWords / totalWords : 0.0;
  double get learningPercentage => totalWords > 0 ? (learningWords + masteredWords) / totalWords : 0.0;
}