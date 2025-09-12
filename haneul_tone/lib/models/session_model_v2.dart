import 'dart:convert';

/// 세션 모델 v2
/// 
/// HaneulTone v1 고도화 - 개선된 세션 데이터 모델
class SessionModelV2 {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> metadata;
  final List<PitchData> pitchData;
  final SessionStats? stats;
  
  SessionModelV2({
    required this.id,
    required this.startTime,
    this.endTime,
    this.metadata = const {},
    this.pitchData = const [],
    this.stats,
  });
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'metadata': metadata,
      'pitchData': pitchData.map((e) => e.toJson()).toList(),
      'stats': stats?.toJson(),
    };
  }
  
  /// JSON에서 생성
  factory SessionModelV2.fromJson(Map<String, dynamic> json) {
    return SessionModelV2(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      metadata: json['metadata'] ?? {},
      pitchData: (json['pitchData'] as List?)
          ?.map((e) => PitchData.fromJson(e))
          .toList() ?? [],
      stats: json['stats'] != null ? SessionStats.fromJson(json['stats']) : null,
    );
  }
  
  /// 세션이 활성 상태인지 확인
  bool get isActive => endTime == null;
  
  /// 세션 지속 시간 (밀리초)
  int get durationMs {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inMilliseconds;
  }
}

/// 피치 데이터
class PitchData {
  final double timeMs;
  final double f0Hz;
  final double confidence;
  final bool isVoiced;
  
  PitchData({
    required this.timeMs,
    required this.f0Hz,
    required this.confidence,
    required this.isVoiced,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'timeMs': timeMs,
      'f0Hz': f0Hz,
      'confidence': confidence,
      'isVoiced': isVoiced,
    };
  }
  
  factory PitchData.fromJson(Map<String, dynamic> json) {
    return PitchData(
      timeMs: json['timeMs'].toDouble(),
      f0Hz: json['f0Hz'].toDouble(),
      confidence: json['confidence'].toDouble(),
      isVoiced: json['isVoiced'],
    );
  }
}

/// 세션 통계
class SessionStats {
  final double averageF0;
  final double f0StdDev;
  final double voicedRatio;
  final double confidenceScore;
  
  SessionStats({
    required this.averageF0,
    required this.f0StdDev,
    required this.voicedRatio,
    required this.confidenceScore,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'averageF0': averageF0,
      'f0StdDev': f0StdDev,
      'voicedRatio': voicedRatio,
      'confidenceScore': confidenceScore,
    };
  }
  
  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      averageF0: json['averageF0'].toDouble(),
      f0StdDev: json['f0StdDev'].toDouble(),
      voicedRatio: json['voicedRatio'].toDouble(),
      confidenceScore: json['confidenceScore'].toDouble(),
    );
  }
}