import 'package:flutter_test/flutter_test.dart';
import 'package:haneul_tone/services/coaching_service.dart';

void main() {
  group('CoachingService', () {
    late CoachingService coachingService;

    setUp(() {
      coachingService = CoachingService();
    });

    test('should generate coaching card for session', () {
      final mockSession = MockSessionV2(
        id: 'test-session-1',
        accuracy: 0.85,
        timestamp: DateTime.now(),
      );

      final card = coachingService.generateCoachingCard(mockSession);

      expect(card, isNotNull);
      expect(card.sessionId, equals('test-session-1'));
      expect(card.createdAt, isA<DateTime>());
      expect(card.analysisResult, isNotNull);
      expect(card.progressData, isNotNull);
      expect(card.goals, isNotEmpty);
      expect(card.actionPlan, isNotNull);
      expect(card.estimatedPracticeTime, isA<Duration>());
    });

    test('should track coaching history', () {
      final session1 = MockSessionV2(id: 'session-1', accuracy: 0.8, timestamp: DateTime.now());
      final session2 = MockSessionV2(id: 'session-2', accuracy: 0.9, timestamp: DateTime.now());

      coachingService.generateCoachingCard(session1);
      coachingService.generateCoachingCard(session2);

      final history = coachingService.getCoachingHistory();
      expect(history.length, equals(2));
      expect(history[0].sessionId, equals('session-1'));
      expect(history[1].sessionId, equals('session-2'));
    });

    test('should limit coaching history to maximum size', () {
      // Generate more cards than the maximum allowed
      for (int i = 0; i < 105; i++) {
        final session = MockSessionV2(
          id: 'session-$i',
          accuracy: 0.8 + (i % 20) * 0.01,
          timestamp: DateTime.now(),
        );
        coachingService.generateCoachingCard(session);
      }

      final history = coachingService.getCoachingHistory();
      expect(history.length, equals(100)); // Should be limited to max
    });

    test('should calculate priority based on analysis result', () {
      final lowAccuracySession = MockSessionV2(
        id: 'low-accuracy',
        accuracy: 0.4,
        timestamp: DateTime.now(),
      );

      final highAccuracySession = MockSessionV2(
        id: 'high-accuracy',
        accuracy: 0.95,
        timestamp: DateTime.now(),
      );

      final lowPriorityCard = coachingService.generateCoachingCard(lowAccuracySession);
      final highPriorityCard = coachingService.generateCoachingCard(highAccuracySession);

      // Low accuracy should result in high priority coaching
      expect(lowPriorityCard.priority.index, greaterThan(highPriorityCard.priority.index));
    });

    test('should generate personalized goals based on performance', () {
      final session = MockSessionV2(
        id: 'test-session',
        accuracy: 0.7,
        pitchStability: 0.6,
        timingAccuracy: 0.8,
        timestamp: DateTime.now(),
      );

      final card = coachingService.generateCoachingCard(session);

      expect(card.goals, isNotEmpty);
      // Should have goals related to pitch stability (lowest score)
      expect(card.goals.any((goal) => goal.type == GoalType.pitchAccuracy), isTrue);
    });

    test('should create action plan with practice exercises', () {
      final session = MockSessionV2(
        id: 'test-session',
        accuracy: 0.75,
        timestamp: DateTime.now(),
      );

      final card = coachingService.generateCoachingCard(session);

      expect(card.actionPlan, isNotNull);
      expect(card.actionPlan.exercises, isNotEmpty);
      expect(card.actionPlan.recommendedPracticeTime, isA<Duration>());
      expect(card.actionPlan.focusAreas, isNotEmpty);
    });

    test('should estimate practice time based on goals', () {
      final easySession = MockSessionV2(
        id: 'easy-session',
        accuracy: 0.95,
        timestamp: DateTime.now(),
      );

      final hardSession = MockSessionV2(
        id: 'hard-session',
        accuracy: 0.4,
        timestamp: DateTime.now(),
      );

      final easyCard = coachingService.generateCoachingCard(easySession);
      final hardCard = coachingService.generateCoachingCard(hardSession);

      // More challenging sessions should require longer practice time
      expect(hardCard.estimatedPracticeTime.inMinutes,
             greaterThan(easyCard.estimatedPracticeTime.inMinutes));
    });

    test('should update user learning profile over time', () {
      final sessions = List.generate(10, (i) => MockSessionV2(
        id: 'session-$i',
        accuracy: 0.6 + i * 0.03, // Gradually improving
        timestamp: DateTime.now().subtract(Duration(days: 10 - i)),
      ));

      for (final session in sessions) {
        coachingService.generateCoachingCard(session, recentSessions: sessions);
      }

      final profile = coachingService.getUserLearningProfile();
      expect(profile, isNotNull);
      expect(profile!.skillLevel, isA<SkillLevel>());
      expect(profile.preferredPracticeTime, isA<Duration>());
      expect(profile.strengths, isNotEmpty);
      expect(profile.weaknesses, isNotEmpty);
    });
  });

  group('CoachingCard', () {
    test('should serialize and deserialize correctly', () {
      final original = CoachingCard(
        id: 'card-123',
        sessionId: 'session-456',
        createdAt: DateTime.now(),
        analysisResult: MockAnalysisResult(),
        progressData: MockProgressData(),
        goals: [MockGoal()],
        actionPlan: MockActionPlan(),
        estimatedPracticeTime: const Duration(minutes: 30),
        priority: CoachingPriority.high,
      );

      final json = original.toJson();
      final restored = CoachingCard.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.sessionId, equals(original.sessionId));
      expect(restored.priority, equals(original.priority));
      expect(restored.estimatedPracticeTime, equals(original.estimatedPracticeTime));
    });

    test('should calculate completion status correctly', () {
      final completedGoals = [
        MockGoal(isCompleted: true),
        MockGoal(isCompleted: true),
      ];

      final partialGoals = [
        MockGoal(isCompleted: true),
        MockGoal(isCompleted: false),
      ];

      final completedCard = CoachingCard(
        id: 'completed-card',
        sessionId: 'session-1',
        createdAt: DateTime.now(),
        analysisResult: MockAnalysisResult(),
        progressData: MockProgressData(),
        goals: completedGoals,
        actionPlan: MockActionPlan(),
        estimatedPracticeTime: const Duration(minutes: 20),
        priority: CoachingPriority.medium,
      );

      final partialCard = CoachingCard(
        id: 'partial-card',
        sessionId: 'session-2',
        createdAt: DateTime.now(),
        analysisResult: MockAnalysisResult(),
        progressData: MockProgressData(),
        goals: partialGoals,
        actionPlan: MockActionPlan(),
        estimatedPracticeTime: const Duration(minutes: 20),
        priority: CoachingPriority.medium,
      );

      expect(completedCard.isCompleted, isTrue);
      expect(partialCard.isCompleted, isFalse);
      expect(partialCard.completionPercentage, equals(0.5));
    });
  });
}

// Mock classes for testing
class MockSessionV2 {
  final String id;
  final double accuracy;
  final double pitchStability;
  final double timingAccuracy;
  final DateTime timestamp;

  MockSessionV2({
    required this.id,
    required this.accuracy,
    this.pitchStability = 0.8,
    this.timingAccuracy = 0.8,
    required this.timestamp,
  });
}

class MockAnalysisResult {
  final double overallScore = 0.8;
  final Map<String, double> componentScores = {
    'pitch': 0.7,
    'timing': 0.85,
    'tone': 0.75,
  };
}

class MockProgressData {
  final double improvementRate = 0.15;
  final List<String> achievedMilestones = ['basic_pitch_control'];
  final Map<String, dynamic> trends = {'accuracy': 0.05, 'consistency': 0.08};
}

class MockGoal {
  final GoalType type;
  final String description;
  final bool isCompleted;
  final double targetValue;
  final double currentValue;

  MockGoal({
    this.type = GoalType.pitchAccuracy,
    this.description = 'Improve pitch accuracy to 85%',
    this.isCompleted = false,
    this.targetValue = 0.85,
    this.currentValue = 0.75,
  });
}

class MockActionPlan {
  final List<String> exercises = ['pitch_slides', 'sustained_notes'];
  final Duration recommendedPracticeTime = const Duration(minutes: 25);
  final List<String> focusAreas = ['pitch_control', 'breath_support'];
}

// Enums and classes for testing
enum GoalType { pitchAccuracy, timing, tone, breath, articulation }
enum CoachingPriority { low, medium, high, urgent }
enum SkillLevel { beginner, intermediate, advanced, expert }

class CoachingCard {
  final String id;
  final String sessionId;
  final DateTime createdAt;
  final MockAnalysisResult analysisResult;
  final MockProgressData progressData;
  final List<MockGoal> goals;
  final MockActionPlan actionPlan;
  final Duration estimatedPracticeTime;
  final CoachingPriority priority;

  CoachingCard({
    required this.id,
    required this.sessionId,
    required this.createdAt,
    required this.analysisResult,
    required this.progressData,
    required this.goals,
    required this.actionPlan,
    required this.estimatedPracticeTime,
    required this.priority,
  });

  bool get isCompleted => goals.every((goal) => goal.isCompleted);
  
  double get completionPercentage {
    if (goals.isEmpty) return 0.0;
    final completedCount = goals.where((goal) => goal.isCompleted).length;
    return completedCount / goals.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.index,
      'estimatedPracticeTime': estimatedPracticeTime.inMilliseconds,
    };
  }

  factory CoachingCard.fromJson(Map<String, dynamic> json) {
    return CoachingCard(
      id: json['id'] ?? '',
      sessionId: json['sessionId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      analysisResult: MockAnalysisResult(),
      progressData: MockProgressData(),
      goals: [],
      actionPlan: MockActionPlan(),
      estimatedPracticeTime: Duration(milliseconds: json['estimatedPracticeTime'] ?? 0),
      priority: CoachingPriority.values[json['priority'] ?? 0],
    );
  }
}

class UserLearningProfile {
  final SkillLevel skillLevel;
  final Duration preferredPracticeTime;
  final List<String> strengths;
  final List<String> weaknesses;

  UserLearningProfile({
    required this.skillLevel,
    required this.preferredPracticeTime,
    required this.strengths,
    required this.weaknesses,
  });
}

// Mock CoachingService implementation
class CoachingService {
  final List<CoachingCard> _history = [];
  UserLearningProfile? _userProfile;

  CoachingCard generateCoachingCard(MockSessionV2 session, {
    List<MockSessionV2>? recentSessions,
  }) {
    final goals = _generateGoals(session);
    final card = CoachingCard(
      id: 'card-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: session.id,
      createdAt: DateTime.now(),
      analysisResult: MockAnalysisResult(),
      progressData: MockProgressData(),
      goals: goals,
      actionPlan: MockActionPlan(),
      estimatedPracticeTime: _estimatePracticeTime(session.accuracy),
      priority: _calculatePriority(session.accuracy),
    );

    _history.add(card);
    if (_history.length > 100) {
      _history.removeAt(0);
    }

    // Update user profile based on recent activity
    if (recentSessions != null && recentSessions.isNotEmpty) {
      _updateUserProfile(recentSessions);
    }

    return card;
  }

  List<CoachingCard> getCoachingHistory() => List.unmodifiable(_history);

  UserLearningProfile? getUserLearningProfile() => _userProfile;

  List<MockGoal> _generateGoals(MockSessionV2 session) {
    final goals = <MockGoal>[];
    
    if (session.accuracy < 0.8) {
      goals.add(MockGoal(
        type: GoalType.pitchAccuracy,
        description: 'Improve overall pitch accuracy',
      ));
    }
    
    if (session.pitchStability < 0.7) {
      goals.add(MockGoal(
        type: GoalType.pitchAccuracy,
        description: 'Improve pitch stability',
      ));
    }
    
    if (session.timingAccuracy < 0.8) {
      goals.add(MockGoal(
        type: GoalType.timing,
        description: 'Improve timing accuracy',
      ));
    }

    return goals.isNotEmpty ? goals : [MockGoal()];
  }

  Duration _estimatePracticeTime(double accuracy) {
    if (accuracy < 0.5) return const Duration(minutes: 45);
    if (accuracy < 0.7) return const Duration(minutes: 30);
    if (accuracy < 0.9) return const Duration(minutes: 20);
    return const Duration(minutes: 15);
  }

  CoachingPriority _calculatePriority(double accuracy) {
    if (accuracy < 0.5) return CoachingPriority.urgent;
    if (accuracy < 0.7) return CoachingPriority.high;
    if (accuracy < 0.8) return CoachingPriority.medium;
    return CoachingPriority.low;
  }

  void _updateUserProfile(List<MockSessionV2> recentSessions) {
    final avgAccuracy = recentSessions.map((s) => s.accuracy).reduce((a, b) => a + b) / recentSessions.length;
    
    SkillLevel level;
    if (avgAccuracy < 0.6) level = SkillLevel.beginner;
    else if (avgAccuracy < 0.8) level = SkillLevel.intermediate;
    else if (avgAccuracy < 0.9) level = SkillLevel.advanced;
    else level = SkillLevel.expert;

    _userProfile = UserLearningProfile(
      skillLevel: level,
      preferredPracticeTime: const Duration(minutes: 25),
      strengths: ['timing', 'tone'],
      weaknesses: ['pitch_control'],
    );
  }
}