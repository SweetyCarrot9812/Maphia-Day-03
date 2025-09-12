// SessionStatus는 base_model.dart에서 정의됨 - 중복 제거

class RecentLogsSummary {
  final int totalSets;
  final double averageRPE;
  final Map<String, int> exerciseFrequency;
  final DateTime? lastWorkout;

  const RecentLogsSummary({
    required this.totalSets,
    required this.averageRPE,
    required this.exerciseFrequency,
    this.lastWorkout,
  });
}

// Sex와 WeightUnit은 base_model.dart에서 정의됨 - 중복 제거