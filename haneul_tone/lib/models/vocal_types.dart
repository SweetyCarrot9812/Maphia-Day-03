/// 보컬 관련 타입 정의
enum VoiceType {
  soprano,      // 소프라노 (C4-C6)
  mezzSoprano,  // 메조소프라노 (A3-A5)
  alto,         // 알토 (G3-G5)
  tenor,        // 테너 (C3-C5)
  baritone,     // 바리톤 (A2-A4)
  bass,         // 베이스 (E2-E4)
  unknown,      // 미분류
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

enum GoalType {
  pitch,
  range,
  vibrato,
  tone,
  rhythm,
  performance,
  overall,
}

/// 사용자 프로필
class UserProfile {
  final VoiceType voiceType;
  final DifficultyLevel currentLevel;
  final GoalType goalType;
  final int practiceFrequency; // 주당 연습 횟수
  final int sessionDuration; // 세션 길이 (분)
  
  UserProfile({
    required this.voiceType,
    required this.currentLevel,
    required this.goalType,
    required this.practiceFrequency,
    required this.sessionDuration,
  });
  
  Map<String, dynamic> toJson() => {
    'voice_type': voiceType.toString(),
    'current_level': currentLevel.toString(),
    'goal_type': goalType.toString(),
    'practice_frequency': practiceFrequency,
    'session_duration': sessionDuration,
  };
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      voiceType: VoiceType.values.firstWhere(
        (e) => e.toString() == json['voice_type'],
        orElse: () => VoiceType.unknown,
      ),
      currentLevel: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == json['current_level'],
        orElse: () => DifficultyLevel.beginner,
      ),
      goalType: GoalType.values.firstWhere(
        (e) => e.toString() == json['goal_type'],
        orElse: () => GoalType.overall,
      ),
      practiceFrequency: json['practice_frequency'] as int,
      sessionDuration: json['session_duration'] as int,
    );
  }
}

// UserProfile 확장을 위한 import 추가가 필요할 수 있음