import 'dart:math' as math;

class OneRmCalculator {
  /// Calculate 1RM using Epley formula
  static double epley(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30.0);
  }

  /// Calculate 1RM using Brzycki formula
  static double brzycki(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    if (reps > 36) return weight; // Brzycki는 37+ reps에서 부정확
    return weight * (36.0 / (37.0 - reps));
  }

  /// Calculate 1RM using Lombardi formula
  static double lombardi(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    return weight * math.pow(reps, 0.10);
  }

  /// Calculate 1RM using McGlothin formula
  static double mcglothin(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    return (100 * weight) / (101.3 - 2.67123 * reps);
  }

  /// RPE 기반 1RM 계산 (가장 정확한 방법)
  /// RPE 8 = 2-3 reps left, RPE 9 = 1 rep left, RPE 10 = 0 reps left
  static double calculateWithRPE(double weight, int reps, double rpe) {
    if (reps <= 0) return 0;
    if (reps == 1 && rpe == 10) return weight;
    
    // RPE to percentage mapping (Helms et al. 2016)
    final Map<double, double> rpeToPercentage = {
      6.0: 0.705, 6.5: 0.723, 7.0: 0.741, 7.5: 0.760,
      8.0: 0.779, 8.5: 0.797, 9.0: 0.816, 9.5: 0.834,
      10.0: 0.853,
    };
    
    // 1RM% 추정
    final percentage = rpeToPercentage[rpe] ?? _interpolateRPE(rpe);
    
    // RPE 기반 조정
    return weight / percentage;
  }
  
  /// RPE 보간 계산
  static double _interpolateRPE(double rpe) {
    if (rpe < 6.0) return 0.68;
    if (rpe > 10.0) return 0.85;
    
    // 선형 보간
    return 0.68 + (rpe - 6.0) * 0.0425;
  }

  /// 통합 1RM 계산 (여러 공식 + RPE 가중 평균)
  static double calculateAdvanced(double weight, int reps, {double? rpe}) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    
    final List<double> results = [];
    
    // 기본 공식들
    results.add(epley(weight, reps));
    if (reps <= 36) results.add(brzycki(weight, reps));
    results.add(mcglothin(weight, reps));
    results.add(lombardi(weight, reps));
    
    // RPE 기반 계산 (가중치 높음)
    if (rpe != null && rpe >= 6.0 && rpe <= 10.0) {
      final rpeResult = calculateWithRPE(weight, reps, rpe);
      results.addAll([rpeResult, rpeResult, rpeResult]); // 3배 가중
    }
    
    // 가중 평균
    return results.reduce((a, b) => a + b) / results.length;
  }

  /// Calculate mean 1RM from three formulas (하위 호환)
  static double mean1RM(double weight, int reps) {
    return (epley(weight, reps) + brzycki(weight, reps) + lombardi(weight, reps)) / 3.0;
  }

  /// Calculate 1RM with confidence band (±2%)
  static Map<String, double> oneRmWithBand(double weight, int reps) {
    final mean = mean1RM(weight, reps);
    return {
      'mean': mean,
      'low': mean * 0.98,
      'high': mean * 1.02,
    };
  }
  
  /// 1RM에서 특정 rep range의 무게 계산
  static double calculateWorkingWeight(double oneRM, int targetReps, {double? targetRPE}) {
    if (targetReps <= 0) return 0;
    if (targetReps == 1) return oneRM;
    
    if (targetRPE != null) {
      // RPE 기반 계산
      final percentage = _interpolateRPE(targetRPE);
      return oneRM * percentage;
    } else {
      // Epley 역산
      return oneRM / (1 + targetReps / 30);
    }
  }
  
  /// 진도 추이 분석용 1RM 변화율 계산
  static double calculateProgress({
    required double previousOneRM,
    required double currentOneRM,
  }) {
    if (previousOneRM <= 0) return 0;
    return ((currentOneRM - previousOneRM) / previousOneRM) * 100;
  }
  
  /// 운동별 1RM 예상 달성일 계산 (선형 회귀 기반)
  static DateTime? estimateGoalDate({
    required List<OneRMHistory> history,
    required double targetOneRM,
  }) {
    if (history.length < 3) return null; // 최소 3개 데이터 포인트 필요
    
    // 최근 8주 데이터만 사용 (너무 과거 데이터는 제외)
    final recentHistory = history
        .where((h) => h.date.isAfter(DateTime.now().subtract(const Duration(days: 56))))
        .toList();
    
    if (recentHistory.length < 3) return null;
    
    // 선형 회귀로 주간 증가율 계산
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    final baseDate = recentHistory.first.date;
    
    for (int i = 0; i < recentHistory.length; i++) {
      final x = recentHistory[i].date.difference(baseDate).inDays.toDouble();
      final y = recentHistory[i].oneRM;
      
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumXX += x * x;
    }
    
    final n = recentHistory.length.toDouble();
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    if (slope <= 0) return null; // 진도가 없거나 후퇴하는 경우
    
    // 목표 달성일 계산
    final daysToTarget = ((targetOneRM - intercept) / slope).round();
    return baseDate.add(Duration(days: daysToTarget));
  }
}

/// 1RM 기록 이력 모델
class OneRMHistory {
  final DateTime date;
  final double oneRM;
  final String exerciseKey;

  OneRMHistory({
    required this.date,
    required this.oneRM,
    required this.exerciseKey,
  });
  
  factory OneRMHistory.fromJson(Map<String, dynamic> json) {
    return OneRMHistory(
      date: DateTime.parse(json['date']),
      oneRM: (json['oneRM'] as num).toDouble(),
      exerciseKey: json['exerciseKey'] as String,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'oneRM': oneRM,
    'exerciseKey': exerciseKey,
  };
}

enum Unit { kg, lb }

class PlateCalculator {
  /// Round weight to nearest plate increment
  static double snapToPlates(double target, Unit unit) {
    switch (unit) {
      case Unit.kg:
        return (target / 2.5).round() * 2.5;
      case Unit.lb:
        return (target / 5.0).round() * 5.0;
    }
  }
}

class RestCalculator {
  /// Suggest rest time based on RPE and velocity
  static int suggestRestSec({
    required int baseMin,
    required int baseMax,
    required double rpe,
    double? velocity,
  }) {
    final bias = (rpe >= 8.5) ? 1.0 : (rpe <= 7.5 ? -0.5 : 0.0);
    final vAdj = (velocity != null && velocity < 0.25) ? 0.5 : 0.0;
    final k = (bias + vAdj).clamp(-1.0, 1.0);
    final val = baseMin + ((baseMax - baseMin) * (0.5 + 0.5 * k));
    return val.round();
  }
}