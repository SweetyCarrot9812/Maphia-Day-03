import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary_model.dart';
import '../services/vocabulary_service.dart';

// Vocabulary Service Provider
final vocabularyServiceProvider = Provider<VocabularyService>((ref) {
  return VocabularyService();
});

// 사용자별 모든 단어 Provider
final vocabularyWordsProvider = StreamProvider.family<List<VocabularyWord>, String>((ref, userId) async* {
  final service = ref.read(vocabularyServiceProvider);
  
  await for (final words in service.getWordsStream(userId)) {
    yield words;
  }
});

// 복습 대상 단어들 Provider
final reviewWordsProvider = StreamProvider.family<List<VocabularyWord>, String>((ref, userId) async* {
  final service = ref.read(vocabularyServiceProvider);
  
  await for (final words in service.getReviewWordsStream(userId)) {
    yield words;
  }
});

// 새 단어들 Provider
final newWordsProvider = StreamProvider.family<List<VocabularyWord>, String>((ref, userId) async* {
  final service = ref.read(vocabularyServiceProvider);
  
  await for (final words in service.getNewWordsStream(userId)) {
    yield words;
  }
});

// 학습 통계 Provider
final vocabularyStatsProvider = FutureProvider.family<VocabularyStats, String>((ref, userId) async {
  final service = ref.read(vocabularyServiceProvider);
  return await service.getStats(userId);
});

// 단어 관리 Controller
final vocabularyControllerProvider = StateNotifierProvider<VocabularyController, AsyncValue<void>>((ref) {
  final service = ref.read(vocabularyServiceProvider);
  return VocabularyController(service);
});

class VocabularyController extends StateNotifier<AsyncValue<void>> {
  final VocabularyService _service;
  
  VocabularyController(this._service) : super(const AsyncValue.data(null));
  
  // 새 단어 추가
  Future<VocabularyWord?> addWord({
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
    state = const AsyncValue.loading();
    
    try {
      final newWord = await _service.addWord(
        word: word,
        meaning: meaning,
        pronunciation: pronunciation,
        example: example,
        exampleTranslation: exampleTranslation,
        difficulty: difficulty,
        category: category,
        tags: tags,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        userId: userId,
      );
      
      state = const AsyncValue.data(null);
      return newWord;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
  
  // 단어 수정
  Future<void> updateWord(VocabularyWord word) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateWord(word);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  // 단어 삭제
  Future<void> deleteWord(String wordId) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.deleteWord(wordId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  // 단어 복습 처리
  Future<void> reviewWord(String wordId, ReviewResult result) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.reviewWord(wordId, result);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  // 학습 시작
  Future<void> startLearning(String wordId) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.startLearning(wordId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  // 샘플 데이터 추가
  Future<void> addSampleData(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.addSampleData(userId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  // 단어 검색
  Future<List<VocabularyWord>> searchWords(String userId, String query) async {
    try {
      return await _service.searchWords(userId, query);
    } catch (error) {
      return [];
    }
  }
}

// 학습 세션 Controller
final learningSessionControllerProvider = StateNotifierProvider<LearningSessionController, LearningSessionState>((ref) {
  final service = ref.read(vocabularyServiceProvider);
  return LearningSessionController(service);
});

class LearningSessionController extends StateNotifier<LearningSessionState> {
  final VocabularyService _service;
  
  LearningSessionController(this._service) : super(LearningSessionState.initial());
  
  // 학습 세션 시작
  Future<void> startSession(String userId, {SessionType type = SessionType.mixed}) async {
    state = state.copyWith(isLoading: true);
    
    try {
      List<VocabularyWord> sessionWords;
      
      switch (type) {
        case SessionType.newWords:
          sessionWords = _service.getNewWordsSync(userId);
          break;
        case SessionType.review:
          sessionWords = _service.getReviewWordsSync(userId);
          break;
        case SessionType.mixed:
          final newWords = _service.getNewWordsSync(userId);
          final reviewWords = _service.getReviewWordsSync(userId);
          sessionWords = [...reviewWords, ...newWords.take(5)]; // 복습 우선, 새 단어 5개 추가
          break;
      }
      
      if (sessionWords.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: '학습할 단어가 없습니다.',
        );
        return;
      }
      
      // 최대 20개 단어로 제한
      sessionWords = sessionWords.take(20).toList();
      sessionWords.shuffle(); // 순서 섞기
      
      state = state.copyWith(
        isLoading: false,
        sessionWords: sessionWords,
        currentIndex: 0,
        correctCount: 0,
        sessionType: type,
        isActive: true,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }
  
  // 답변 제출
  Future<void> submitAnswer(ReviewResult result) async {
    if (!state.isActive || state.currentWord == null) return;
    
    try {
      await _service.reviewWord(state.currentWord!.id, result);
      
      if (result == ReviewResult.correct || result == ReviewResult.perfect) {
        state = state.copyWith(correctCount: state.correctCount + 1);
      }
      
      // 다음 단어로 이동
      if (state.currentIndex < state.sessionWords.length - 1) {
        state = state.copyWith(currentIndex: state.currentIndex + 1);
      } else {
        // 세션 완료
        state = state.copyWith(isActive: false, isCompleted: true);
      }
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }
  
  // 세션 종료
  void endSession() {
    state = LearningSessionState.initial();
  }
  
  // 이전 단어로 이동
  void previousWord() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }
}

// 학습 세션 상태
class LearningSessionState {
  final List<VocabularyWord> sessionWords;
  final int currentIndex;
  final int correctCount;
  final SessionType sessionType;
  final bool isLoading;
  final bool isActive;
  final bool isCompleted;
  final String? error;
  
  LearningSessionState({
    required this.sessionWords,
    required this.currentIndex,
    required this.correctCount,
    required this.sessionType,
    required this.isLoading,
    required this.isActive,
    required this.isCompleted,
    this.error,
  });
  
  factory LearningSessionState.initial() {
    return LearningSessionState(
      sessionWords: [],
      currentIndex: 0,
      correctCount: 0,
      sessionType: SessionType.mixed,
      isLoading: false,
      isActive: false,
      isCompleted: false,
    );
  }
  
  LearningSessionState copyWith({
    List<VocabularyWord>? sessionWords,
    int? currentIndex,
    int? correctCount,
    SessionType? sessionType,
    bool? isLoading,
    bool? isActive,
    bool? isCompleted,
    String? error,
  }) {
    return LearningSessionState(
      sessionWords: sessionWords ?? this.sessionWords,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      sessionType: sessionType ?? this.sessionType,
      isLoading: isLoading ?? this.isLoading,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
  
  VocabularyWord? get currentWord {
    if (currentIndex < sessionWords.length) {
      return sessionWords[currentIndex];
    }
    return null;
  }
  
  double get progress {
    if (sessionWords.isEmpty) return 0.0;
    return (currentIndex + (isCompleted ? 1 : 0)) / sessionWords.length;
  }
  
  double get accuracy {
    if (currentIndex == 0) return 0.0;
    return correctCount / currentIndex;
  }
}

enum SessionType {
  newWords,    // 새 단어만
  review,      // 복습만
  mixed,       // 혼합
}

extension SessionTypeExtension on SessionType {
  String get displayName {
    switch (this) {
      case SessionType.newWords:
        return '새 단어 학습';
      case SessionType.review:
        return '복습';
      case SessionType.mixed:
        return '혼합 학습';
    }
  }
  
  String get emoji {
    switch (this) {
      case SessionType.newWords:
        return '✨';
      case SessionType.review:
        return '🔄';
      case SessionType.mixed:
        return '📚';
    }
  }
}