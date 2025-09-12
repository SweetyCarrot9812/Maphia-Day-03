import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_progress.g.dart';

@collection
@JsonSerializable()
class UserProgress {
  Id id = Isar.autoIncrement;

  /// User identification (single user system for now)
  @Index(unique: true)
  @JsonKey(defaultValue: 'default_user')
  String userId = 'default_user';

  /// Overall statistics
  @JsonKey(defaultValue: 0)
  int totalProblemsAttempted = 0;

  @JsonKey(defaultValue: 0)
  int totalCorrectAnswers = 0;

  @JsonKey(defaultValue: 0)
  int totalIncorrectAnswers = 0;

  @JsonKey(defaultValue: 0.0)
  double averageScore = 0.0;

  /// Streak tracking
  @JsonKey(defaultValue: 0)
  int currentStreak = 0;

  @JsonKey(defaultValue: 0)
  int bestStreak = 0;

  /// Last study session
  DateTime? lastStudyDate;

  /// Time tracking (in minutes)
  @JsonKey(defaultValue: 0)
  int totalStudyTimeMinutes = 0;

  /// Subject-wise progress (JSON object as string)
  String? subjectProgress;

  /// Difficulty-wise progress (JSON object as string)  
  String? difficultyProgress;

  /// Problem type progress (JSON object as string)
  String? typeProgress;

  /// Weekly study goals (JSON object as string)
  String? studyGoals;

  /// Achievements unlocked (JSON array as string)
  String? achievements;

  /// Learning preferences (JSON object as string)
  String? preferences;

  /// Weak areas identified by AI (JSON array as string)
  String? weakAreas;

  /// Strong areas identified by AI (JSON array as string)
  String? strongAreas;

  /// Study schedule (JSON object as string)
  String? studySchedule;

  /// Progress tracking timestamps
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  UserProgress();

  // Factory constructor for JSON deserialization
  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$UserProgressToJson(this);

  /// Convenience getters for JSON fields
  @ignore
  Map<String, dynamic> get subjectProgressMap {
    if (subjectProgress == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(subjectProgress!) as Map);
    } catch (e) {
      return {};
    }
  }

  @ignore
  Map<String, dynamic> get difficultyProgressMap {
    if (difficultyProgress == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(difficultyProgress!) as Map);
    } catch (e) {
      return {};
    }
  }

  @ignore
  Map<String, dynamic> get typeProgressMap {
    if (typeProgress == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(typeProgress!) as Map);
    } catch (e) {
      return {};
    }
  }

  @ignore
  Map<String, dynamic> get studyGoalsMap {
    if (studyGoals == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(studyGoals!) as Map);
    } catch (e) {
      return {};
    }
  }

  List<String> get achievementsList {
    if (achievements == null) return [];
    try {
      return List<String>.from(jsonDecode(achievements!) as List);
    } catch (e) {
      return [];
    }
  }

  @ignore
  Map<String, dynamic> get preferencesMap {
    if (preferences == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(preferences!) as Map);
    } catch (e) {
      return {};
    }
  }

  List<String> get weakAreasList {
    if (weakAreas == null) return [];
    try {
      return List<String>.from(jsonDecode(weakAreas!) as List);
    } catch (e) {
      return [];
    }
  }

  List<String> get strongAreasList {
    if (strongAreas == null) return [];
    try {
      return List<String>.from(jsonDecode(strongAreas!) as List);
    } catch (e) {
      return [];
    }
  }

  @ignore
  Map<String, dynamic> get studyScheduleMap {
    if (studySchedule == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(studySchedule!) as Map);
    } catch (e) {
      return {};
    }
  }

  /// Calculated properties
  double get accuracy {
    if (totalProblemsAttempted == 0) return 0.0;
    return (totalCorrectAnswers / totalProblemsAttempted) * 100;
  }

  double get errorRate {
    if (totalProblemsAttempted == 0) return 0.0;
    return (totalIncorrectAnswers / totalProblemsAttempted) * 100;
  }

  @ignore
  Duration get totalStudyTime => Duration(minutes: totalStudyTimeMinutes);

  double get averageStudyTimePerSession {
    // Estimate based on problems attempted and average time per problem
    if (totalProblemsAttempted == 0) return 0.0;
    return totalStudyTimeMinutes / (totalProblemsAttempted / 10.0); // Estimate 10 problems per session
  }

  bool get hasStudiedToday {
    if (lastStudyDate == null) return false;
    final now = DateTime.now();
    final lastStudy = lastStudyDate!;
    return now.year == lastStudy.year && 
           now.month == lastStudy.month && 
           now.day == lastStudy.day;
  }

  int get daysStreak {
    if (lastStudyDate == null) return 0;
    final now = DateTime.now();
    final daysSinceLastStudy = now.difference(lastStudyDate!).inDays;
    
    if (daysSinceLastStudy == 0 || daysSinceLastStudy == 1) {
      return currentStreak;
    } else {
      return 0; // Streak broken
    }
  }

  /// Update progress after a quiz session
  UserProgress updateAfterSession({
    required int problemsAttempted,
    required int correctAnswers,
    required double sessionScore,
    required int studyTimeMinutes,
    required String subject,
    required Map<String, int> typeStats,
    required Map<String, int> difficultyStats,
  }) {
    final newTotalAttempted = totalProblemsAttempted + problemsAttempted;
    final newTotalCorrect = totalCorrectAnswers + correctAnswers;
    final newTotalIncorrect = totalIncorrectAnswers + (problemsAttempted - correctAnswers);
    
    // Update average score
    final newAverageScore = (averageScore * totalProblemsAttempted + sessionScore * problemsAttempted) / newTotalAttempted;
    
    // Update streak
    final now = DateTime.now();
    int newCurrentStreak = currentStreak;
    int newBestStreak = bestStreak;
    
    if (lastStudyDate == null || !hasStudiedToday) {
      if (correctAnswers > 0) {
        newCurrentStreak = hasStudiedToday ? currentStreak : currentStreak + 1;
        newBestStreak = newCurrentStreak > bestStreak ? newCurrentStreak : bestStreak;
      } else {
        newCurrentStreak = 0;
      }
    }
    
    // Update subject progress
    final subjectProgressUpdated = subjectProgressMap;
    subjectProgressUpdated[subject] = (subjectProgressUpdated[subject] ?? 0) + problemsAttempted;
    
    // Update type progress
    final typeProgressUpdated = typeProgressMap;
    typeStats.forEach((type, count) {
      typeProgressUpdated[type] = (typeProgressUpdated[type] ?? 0) + count;
    });
    
    // Update difficulty progress
    final difficultyProgressUpdated = difficultyProgressMap;
    difficultyStats.forEach((difficulty, count) {
      difficultyProgressUpdated[difficulty] = (difficultyProgressUpdated[difficulty] ?? 0) + count;
    });

    return copyWith(
      totalProblemsAttempted: newTotalAttempted,
      totalCorrectAnswers: newTotalCorrect,
      totalIncorrectAnswers: newTotalIncorrect,
      averageScore: newAverageScore,
      currentStreak: newCurrentStreak,
      bestStreak: newBestStreak,
      lastStudyDate: now,
      totalStudyTimeMinutes: totalStudyTimeMinutes + studyTimeMinutes,
      subjectProgress: jsonEncode(subjectProgressUpdated),
      typeProgress: jsonEncode(typeProgressUpdated),
      difficultyProgress: jsonEncode(difficultyProgressUpdated),
      updatedAt: now,
    );
  }

  /// Add achievement
  UserProgress addAchievement(String achievement) {
    final achievementsList = this.achievementsList;
    if (!achievementsList.contains(achievement)) {
      achievementsList.add(achievement);
      return copyWith(
        achievements: jsonEncode(achievementsList),
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  /// Update preferences
  UserProgress updatePreferences(Map<String, dynamic> newPreferences) {
    final preferencesUpdated = preferencesMap;
    preferencesUpdated.addAll(newPreferences);
    
    return copyWith(
      preferences: jsonEncode(preferencesUpdated),
      updatedAt: DateTime.now(),
    );
  }

  /// Copy with method for updating fields
  UserProgress copyWith({
    String? userId,
    int? totalProblemsAttempted,
    int? totalCorrectAnswers,
    int? totalIncorrectAnswers,
    double? averageScore,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastStudyDate,
    int? totalStudyTimeMinutes,
    String? subjectProgress,
    String? difficultyProgress,
    String? typeProgress,
    String? studyGoals,
    String? achievements,
    String? preferences,
    String? weakAreas,
    String? strongAreas,
    String? studySchedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final progress = UserProgress()
      ..id = id
      ..userId = userId ?? this.userId
      ..totalProblemsAttempted = totalProblemsAttempted ?? this.totalProblemsAttempted
      ..totalCorrectAnswers = totalCorrectAnswers ?? this.totalCorrectAnswers
      ..totalIncorrectAnswers = totalIncorrectAnswers ?? this.totalIncorrectAnswers
      ..averageScore = averageScore ?? this.averageScore
      ..currentStreak = currentStreak ?? this.currentStreak
      ..bestStreak = bestStreak ?? this.bestStreak
      ..lastStudyDate = lastStudyDate ?? this.lastStudyDate
      ..totalStudyTimeMinutes = totalStudyTimeMinutes ?? this.totalStudyTimeMinutes
      ..subjectProgress = subjectProgress ?? this.subjectProgress
      ..difficultyProgress = difficultyProgress ?? this.difficultyProgress
      ..typeProgress = typeProgress ?? this.typeProgress
      ..studyGoals = studyGoals ?? this.studyGoals
      ..achievements = achievements ?? this.achievements
      ..preferences = preferences ?? this.preferences
      ..weakAreas = weakAreas ?? this.weakAreas
      ..strongAreas = strongAreas ?? this.strongAreas
      ..studySchedule = studySchedule ?? this.studySchedule
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
    return progress;
  }

  @override
  String toString() {
    return 'UserProgress{id: $id, userId: $userId, accuracy: ${accuracy.toStringAsFixed(1)}%, streak: $currentStreak}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgress && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}