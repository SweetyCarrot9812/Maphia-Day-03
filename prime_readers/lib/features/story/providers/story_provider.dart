import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_model.dart';
import '../services/story_service.dart';

// Story Service Provider
final storyServiceProvider = Provider<StoryService>((ref) {
  return StoryService();
});

// 사용자별 모든 스토리 Provider
final storiesProvider = StreamProvider.family<List<Story>, String>((ref, userId) async* {
  final service = ref.read(storyServiceProvider);
  
  await for (final stories in service.getStoriesStream(userId)) {
    yield stories;
  }
});

// 레벨별 스토리 Provider
final storiesByLevelProvider = StreamProvider.family<List<Story>, Map<String, dynamic>>((ref, params) async* {
  final service = ref.read(storyServiceProvider);
  final userId = params['userId'] as String;
  final level = params['level'] as StoryLevel;
  
  await for (final stories in service.getStoriesByLevelStream(userId, level)) {
    yield stories;
  }
});

// 스토리 통계 Provider
final storyStatsProvider = FutureProvider.family<StoryStats, String>((ref, userId) async {
  final service = ref.read(storyServiceProvider);
  return await service.getStats(userId);
});

// 스토리 관리 Controller
final storyControllerProvider = StateNotifierProvider<StoryController, AsyncValue<void>>((ref) {
  final service = ref.read(storyServiceProvider);
  return StoryController(service);
});

class StoryController extends StateNotifier<AsyncValue<void>> {
  final StoryService _service;
  
  StoryController(this._service) : super(const AsyncValue.data(null));
  
  // 스토리 시작
  Future<StoryProgress?> startStory(String storyId, String userId) async {
    state = const AsyncValue.loading();
    
    try {
      final progress = await _service.startStory(storyId, userId);
      state = const AsyncValue.data(null);
      return progress;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
  
  // 진행도 업데이트
  Future<void> updateProgress(StoryProgress progress) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateProgress(progress);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  // 스토리 완료
  Future<void> completeStory(String storyId, String userId, int score) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.completeStory(storyId, userId, score);
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
}

// 스토리 읽기 세션 Controller
final storyReadingSessionProvider = StateNotifierProvider<StoryReadingController, StoryReadingState>((ref) {
  final service = ref.read(storyServiceProvider);
  return StoryReadingController(service);
});

class StoryReadingController extends StateNotifier<StoryReadingState> {
  final StoryService _service;
  
  StoryReadingController(this._service) : super(StoryReadingState.initial());
  
  // 스토리 읽기 시작
  Future<void> startReading(Story story, String userId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final progress = await _service.startStory(story.id, userId);
      final quizzes = await _service.getStoryQuizzes(story.id);
      
      state = state.copyWith(
        isLoading: false,
        currentStory: story,
        progress: progress,
        quizzes: quizzes,
        currentScene: progress.currentScene,
        isActive: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }
  
  // 다음 씬으로 이동
  Future<void> nextScene() async {
    if (!state.isActive || state.currentStory == null) return;
    
    final newScene = state.currentScene + 1;
    final totalScenes = state.currentStory!.scenes.length;
    
    if (newScene < totalScenes) {
      // 다음 씬으로 이동
      state = state.copyWith(currentScene: newScene);
      
      // 진행도 업데이트
      if (state.progress != null) {
        state.progress!.currentScene = newScene;
        state.progress!.completedScenes = [
          ...state.progress!.completedScenes,
          state.currentStory!.scenes[state.currentScene - 1]
        ];
        await _service.updateProgress(state.progress!);
      }
    } else {
      // 스토리 완료
      state = state.copyWith(isCompleted: true);
    }
  }
  
  // 이전 씬으로 이동
  void previousScene() {
    if (state.currentScene > 0) {
      state = state.copyWith(currentScene: state.currentScene - 1);
    }
  }
  
  // 퀴즈 답안 제출
  Future<void> submitQuizAnswer(String quizId, int answer) async {
    // 퀴즈 결과 처리 로직 (향후 확장)
    final quiz = state.quizzes.firstWhere((q) => q.id == quizId);
    final isCorrect = quiz.correctAnswer == answer;
    
    // 점수 계산 및 업데이트 로직
    if (isCorrect) {
      state = state.copyWith(score: state.score + 10);
    }
  }
  
  // 스토리 읽기 완료
  Future<void> completeReading() async {
    if (state.currentStory == null || state.progress == null) return;
    
    try {
      await _service.completeStory(
        state.currentStory!.id, 
        state.progress!.userId, 
        state.score
      );
      
      state = state.copyWith(
        isCompleted: true,
        isActive: false,
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }
  
  // 세션 종료
  void endSession() {
    state = StoryReadingState.initial();
  }
}

// 스토리 읽기 세션 상태
class StoryReadingState {
  final Story? currentStory;
  final StoryProgress? progress;
  final List<StoryQuiz> quizzes;
  final int currentScene;
  final int score;
  final bool isLoading;
  final bool isActive;
  final bool isCompleted;
  final String? error;
  
  StoryReadingState({
    this.currentStory,
    this.progress,
    this.quizzes = const [],
    this.currentScene = 0,
    this.score = 0,
    this.isLoading = false,
    this.isActive = false,
    this.isCompleted = false,
    this.error,
  });
  
  factory StoryReadingState.initial() {
    return StoryReadingState();
  }
  
  StoryReadingState copyWith({
    Story? currentStory,
    StoryProgress? progress,
    List<StoryQuiz>? quizzes,
    int? currentScene,
    int? score,
    bool? isLoading,
    bool? isActive,
    bool? isCompleted,
    String? error,
  }) {
    return StoryReadingState(
      currentStory: currentStory ?? this.currentStory,
      progress: progress ?? this.progress,
      quizzes: quizzes ?? this.quizzes,
      currentScene: currentScene ?? this.currentScene,
      score: score ?? this.score,
      isLoading: isLoading ?? this.isLoading,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
  
  double get progressPercentage {
    if (currentStory == null || currentStory!.scenes.isEmpty) return 0.0;
    return (currentScene + (isCompleted ? 1 : 0)) / currentStory!.scenes.length;
  }
  
  String? get currentSceneText {
    if (currentStory == null || currentScene >= currentStory!.scenes.length) {
      return null;
    }
    return currentStory!.scenes[currentScene];
  }
}