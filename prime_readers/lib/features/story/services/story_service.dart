import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/story_model.dart';

class StoryService {
  static const String _storyBoxName = 'stories';
  static const String _progressBoxName = 'story_progress';
  static const String _quizBoxName = 'story_quizzes';
  
  Box<Story>? _storyBox;
  Box<StoryProgress>? _progressBox;
  Box<StoryQuiz>? _quizBox;

  // Initialize Hive boxes
  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(StoryAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(StoryLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(StoryProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(StoryQuizAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(QuizTypeAdapter());
    }
    
    _storyBox = await Hive.openBox<Story>(_storyBoxName);
    _progressBox = await Hive.openBox<StoryProgress>(_progressBoxName);
    _quizBox = await Hive.openBox<StoryQuiz>(_quizBoxName);
  }

  Box<Story> get storyBox {
    if (_storyBox == null || !_storyBox!.isOpen) {
      throw Exception('StoryService not initialized. Call initialize() first.');
    }
    return _storyBox!;
  }

  Box<StoryProgress> get progressBox {
    if (_progressBox == null || !_progressBox!.isOpen) {
      throw Exception('StoryService not initialized. Call initialize() first.');
    }
    return _progressBox!;
  }

  Box<StoryQuiz> get quizBox {
    if (_quizBox == null || !_quizBox!.isOpen) {
      throw Exception('StoryService not initialized. Call initialize() first.');
    }
    return _quizBox!;
  }

  // 사용자별 스토리 목록 조회
  Stream<List<Story>> getStoriesStream(String userId) async* {
    await initialize();
    
    yield storyBox.values.where((story) => story.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await for (final _ in storyBox.watch()) {
      yield storyBox.values.where((story) => story.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  // 레벨별 스토리 조회
  Stream<List<Story>> getStoriesByLevelStream(String userId, StoryLevel level) async* {
    await initialize();
    
    yield _getStoriesByLevel(userId, level);

    await for (final _ in storyBox.watch()) {
      yield _getStoriesByLevel(userId, level);
    }
  }

  List<Story> _getStoriesByLevel(String userId, StoryLevel level) {
    return storyBox.values.where((story) => 
      story.userId == userId && story.level == level
    ).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // 특정 스토리 조회
  Future<Story?> getStory(String storyId) async {
    return storyBox.get(storyId);
  }

  // 스토리 진행도 조회
  Future<StoryProgress?> getProgress(String storyId, String userId) async {
    final progressList = progressBox.values.where((progress) => 
      progress.storyId == storyId && progress.userId == userId
    ).toList();
    
    return progressList.isNotEmpty ? progressList.first : null;
  }

  // 스토리 시작
  Future<StoryProgress> startStory(String storyId, String userId) async {
    final existingProgress = await getProgress(storyId, userId);
    
    if (existingProgress != null) {
      return existingProgress; // 이미 진행 중인 경우
    }

    final progress = StoryProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      storyId: storyId,
      userId: userId,
      startedAt: DateTime.now(),
    );

    await progressBox.put(progress.id, progress);
    return progress;
  }

  // 스토리 진행도 업데이트
  Future<void> updateProgress(StoryProgress progress) async {
    await progress.save();
  }

  // 스토리 완료
  Future<void> completeStory(String storyId, String userId, int score) async {
    final progress = await getProgress(storyId, userId);
    if (progress != null) {
      progress.isCompleted = true;
      progress.score = score;
      progress.completedAt = DateTime.now();
      await progress.save();
    }

    // 스토리 자체도 완료 처리
    final story = await getStory(storyId);
    if (story != null) {
      story.isCompleted = true;
      story.score = score;
      story.completedAt = DateTime.now();
      await story.save();
    }
  }

  // 스토리별 퀴즈 조회
  Future<List<StoryQuiz>> getStoryQuizzes(String storyId) async {
    return quizBox.values.where((quiz) => quiz.storyId == storyId).toList();
  }

  // 학습 통계 조회
  Future<StoryStats> getStats(String userId) async {
    final userStories = storyBox.values.where((story) => story.userId == userId).toList();
    final userProgress = progressBox.values.where((progress) => progress.userId == userId).toList();
    
    final totalStories = userStories.length;
    final completedStories = userProgress.where((p) => p.isCompleted).length;
    final inProgressStories = userProgress.where((p) => !p.isCompleted).length;
    
    final averageScore = userProgress
        .where((p) => p.isCompleted && p.score != null)
        .fold<double>(0, (sum, p) => sum + p.score!) /
        (completedStories > 0 ? completedStories : 1);

    final totalReadingTime = userProgress.fold<int>(0, (sum, progress) {
      if (progress.completedAt != null) {
        return sum + progress.completedAt!.difference(progress.startedAt).inMinutes;
      }
      return sum;
    });

    return StoryStats(
      totalStories: totalStories,
      completedStories: completedStories,
      inProgressStories: inProgressStories,
      averageScore: averageScore,
      totalReadingTime: totalReadingTime,
    );
  }

  // 샘플 데이터 추가
  Future<void> addSampleData(String userId) async {
    final sampleStories = [
      {
        'title': 'The Little Red Riding Hood',
        'description': '빨간 모자를 쓴 소녀의 모험 이야기',
        'content': 'Once upon a time, there was a little girl who always wore a red riding hood...',
        'imageUrl': 'assets/images/red_riding_hood.png',
        'level': StoryLevel.beginner,
        'keywords': ['adventure', 'forest', 'grandmother', 'wolf'],
        'scenes': [
          'Little girl starts journey',
          'Meets the wolf in forest',
          'Wolf tricks grandmother',
          'Hunter saves the day'
        ],
        'estimatedMinutes': 8,
      },
      {
        'title': 'The Three Little Pigs',
        'description': '세 마리 돼지와 늑대의 이야기',
        'content': 'Three little pigs decided to build houses...',
        'imageUrl': 'assets/images/three_pigs.png',
        'level': StoryLevel.beginner,
        'keywords': ['house', 'wolf', 'brick', 'straw'],
        'scenes': [
          'Pigs build houses',
          'Wolf visits straw house',
          'Wolf visits stick house',
          'Wolf cannot destroy brick house'
        ],
        'estimatedMinutes': 10,
      },
      {
        'title': 'Alice in Wonderland',
        'description': '앨리스의 환상적인 모험',
        'content': 'Alice was beginning to get very tired of sitting by her sister...',
        'imageUrl': 'assets/images/alice.png',
        'level': StoryLevel.intermediate,
        'keywords': ['rabbit', 'wonderland', 'adventure', 'magic'],
        'scenes': [
          'Alice follows white rabbit',
          'Falls down rabbit hole',
          'Meets Cheshire Cat',
          'Tea party with Mad Hatter'
        ],
        'estimatedMinutes': 15,
      },
      {
        'title': 'Romeo and Juliet',
        'description': '셰익스피어의 비극적 사랑 이야기',
        'content': 'Two households, both alike in dignity...',
        'imageUrl': 'assets/images/romeo_juliet.png',
        'level': StoryLevel.advanced,
        'keywords': ['love', 'tragedy', 'family', 'fate'],
        'scenes': [
          'Families feud',
          'Romeo and Juliet meet',
          'Secret marriage',
          'Tragic ending'
        ],
        'estimatedMinutes': 20,
      },
    ];

    for (final storyData in sampleStories) {
      try {
        final story = Story(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: storyData['title'] as String,
          description: storyData['description'] as String,
          content: storyData['content'] as String,
          imageUrl: storyData['imageUrl'] as String,
          level: storyData['level'] as StoryLevel,
          keywords: List<String>.from(storyData['keywords'] as List),
          scenes: List<String>.from(storyData['scenes'] as List),
          estimatedMinutes: storyData['estimatedMinutes'] as int,
          createdAt: DateTime.now(),
          userId: userId,
        );

        await storyBox.put(story.id, story);
        
        // 샘플 퀴즈도 추가
        await _addSampleQuizzes(story.id);
        
      } catch (e) {
        // 중복이나 오류 무시
        print('Sample story creation error: $e');
      }
    }
  }

  // 샘플 퀴즈 추가
  Future<void> _addSampleQuizzes(String storyId) async {
    final quiz = StoryQuiz(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      storyId: storyId,
      question: 'What is the main character\'s name?',
      options: ['Alice', 'Red Riding Hood', 'Juliet', 'Pig'],
      correctAnswer: 0,
      explanation: 'The main character varies by story.',
    );

    await quizBox.put(quiz.id, quiz);
  }

  // 모든 데이터 삭제 (테스트용)
  Future<void> clearAllData() async {
    await storyBox.clear();
    await progressBox.clear();
    await quizBox.clear();
  }
}

// 학습 통계 모델
class StoryStats {
  final int totalStories;
  final int completedStories;
  final int inProgressStories;
  final double averageScore;
  final int totalReadingTime; // minutes

  StoryStats({
    required this.totalStories,
    required this.completedStories,
    required this.inProgressStories,
    required this.averageScore,
    required this.totalReadingTime,
  });

  double get completionRate => totalStories > 0 ? completedStories / totalStories : 0.0;
}