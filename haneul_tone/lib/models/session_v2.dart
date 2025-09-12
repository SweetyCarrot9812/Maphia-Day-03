import 'dart:convert';
import '../core/metrics/metrics_calculator.dart';
import '../core/alignment/dtw_aligner.dart';

/// 세션 모델 V2 (확장된 메트릭 포함)
/// 
/// HaneulTone v1 고도화 - 새로운 분석 결과를 포함한 세션 데이터
class SessionV2 {
  final String id;
  final String referenceId;
  final DateTime createdAt;
  
  // 기존 필드들
  final String? userRecordingPath;
  final String? pitchDataPath;
  
  // V2 확장 필드들
  final Metrics? metrics;
  final List<SegmentAdvice> segments;
  final CalibrationData? calibration;
  final String? dtwResultJson; // DTW 결과를 JSON으로 저장
  final Map<String, dynamic>? additionalData; // 향후 확장용

  SessionV2({
    required this.id,
    required this.referenceId,
    required this.createdAt,
    this.userRecordingPath,
    this.pitchDataPath,
    this.metrics,
    this.segments = const [],
    this.calibration,
    this.dtwResultJson,
    this.additionalData,
  });

  /// V1에서 V2로 마이그레이션
  factory SessionV2.fromV1({
    required String id,
    required String referenceId,
    required DateTime createdAt,
    String? userRecordingPath,
    String? pitchDataPath,
    double? accuracyMean,
    double? stabilitySd,
    String? weakSteps,
    String? aiFeedback,
  }) {
    // 기존 V1 데이터를 V2 형식으로 변환
    Metrics? convertedMetrics;
    if (accuracyMean != null && stabilitySd != null) {
      convertedMetrics = Metrics(
        accuracyCents: accuracyMean,
        stabilityCents: stabilitySd,
        vibratoRateHz: 0.0, // V1에서는 없던 데이터
        vibratoExtentCents: 0.0,
        voicedRatio: 1.0, // 기본값
        overallScore: _calculateLegacyScore(accuracyMean, stabilitySd),
      );
    }

    List<SegmentAdvice> convertedSegments = [];
    if (weakSteps != null && weakSteps.isNotEmpty) {
      // 기존 weakSteps 문자열을 파싱하여 SegmentAdvice로 변환
      convertedSegments = _parseWeakSteps(weakSteps);
    }

    return SessionV2(
      id: id,
      referenceId: referenceId,
      createdAt: createdAt,
      userRecordingPath: userRecordingPath,
      pitchDataPath: pitchDataPath,
      metrics: convertedMetrics,
      segments: convertedSegments,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referenceId': referenceId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userRecordingPath': userRecordingPath,
      'pitchDataPath': pitchDataPath,
      'metrics': metrics?.toJson(),
      'segments': segments.map((s) => s.toJson()).toList(),
      'calibration': calibration?.toJson(),
      'dtwResultJson': dtwResultJson,
      'additionalData': additionalData,
    };
  }

  /// JSON에서 역직렬화
  factory SessionV2.fromJson(Map<String, dynamic> json) {
    return SessionV2(
      id: json['id'] as String,
      referenceId: json['referenceId'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      userRecordingPath: json['userRecordingPath'] as String?,
      pitchDataPath: json['pitchDataPath'] as String?,
      metrics: json['metrics'] != null 
          ? Metrics.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      segments: (json['segments'] as List? ?? [])
          .map((s) => SegmentAdvice.fromJson(s as Map<String, dynamic>))
          .toList(),
      calibration: json['calibration'] != null
          ? CalibrationData.fromJson(json['calibration'] as Map<String, dynamic>)
          : null,
      dtwResultJson: json['dtwResultJson'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  /// SQLite 테이블로 변환
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'reference_id': referenceId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'user_recording_path': userRecordingPath,
      'pitch_data_path': pitchDataPath,
      'metrics_json': metrics != null ? jsonEncode(metrics!.toJson()) : null,
      'segments_json': jsonEncode(segments.map((s) => s.toJson()).toList()),
      'calibration_json': calibration != null ? jsonEncode(calibration!.toJson()) : null,
      'dtw_result_json': dtwResultJson,
      'additional_data_json': additionalData != null ? jsonEncode(additionalData!) : null,
      'schema_version': 2,
    };
  }

  /// SQLite에서 역직렬화
  factory SessionV2.fromSqlite(Map<String, dynamic> row) {
    return SessionV2(
      id: row['id'] as String,
      referenceId: row['reference_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      userRecordingPath: row['user_recording_path'] as String?,
      pitchDataPath: row['pitch_data_path'] as String?,
      metrics: row['metrics_json'] != null
          ? Metrics.fromJson(jsonDecode(row['metrics_json']) as Map<String, dynamic>)
          : null,
      segments: row['segments_json'] != null
          ? (jsonDecode(row['segments_json']) as List)
              .map((s) => SegmentAdvice.fromJson(s as Map<String, dynamic>))
              .toList()
          : [],
      calibration: row['calibration_json'] != null
          ? CalibrationData.fromJson(jsonDecode(row['calibration_json']) as Map<String, dynamic>)
          : null,
      dtwResultJson: row['dtw_result_json'] as String?,
      additionalData: row['additional_data_json'] != null
          ? jsonDecode(row['additional_data_json']) as Map<String, dynamic>?
          : null,
    );
  }

  /// 복사본 생성 (불변성 유지)
  SessionV2 copyWith({
    String? id,
    String? referenceId,
    DateTime? createdAt,
    String? userRecordingPath,
    String? pitchDataPath,
    Metrics? metrics,
    List<SegmentAdvice>? segments,
    CalibrationData? calibration,
    String? dtwResultJson,
    Map<String, dynamic>? additionalData,
  }) {
    return SessionV2(
      id: id ?? this.id,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      userRecordingPath: userRecordingPath ?? this.userRecordingPath,
      pitchDataPath: pitchDataPath ?? this.pitchDataPath,
      metrics: metrics ?? this.metrics,
      segments: segments ?? this.segments,
      calibration: calibration ?? this.calibration,
      dtwResultJson: dtwResultJson ?? this.dtwResultJson,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // ========== 헬퍼 메서드들 ==========

  /// 기존 점수 계산 (V1 호환용)
  static double _calculateLegacyScore(double accuracy, double stability) {
    final accuracyScore = (100 - accuracy * 2).clamp(0, 100);
    final stabilityScore = (100 - stability * 3).clamp(0, 100);
    return (accuracyScore + stabilityScore) / 2;
  }

  /// 기존 weakSteps 문자열 파싱
  static List<SegmentAdvice> _parseWeakSteps(String weakSteps) {
    // 예: "1,3,5" -> 1번, 3번, 5번 스텝이 약점
    try {
      final steps = weakSteps.split(',').map((s) => int.parse(s.trim())).toList();
      return steps.map((step) => SegmentAdvice(
        startTimeMs: step * 1000.0, // 대략적인 시간
        endTimeMs: (step + 1) * 1000.0,
        errorType: 'pitch',
        severity: 'medium',
        suggestion: '$step번 구간 연습이 필요합니다',
        confidence: 0.7,
      )).toList();
    } catch (e) {
      return [];
    }
  }
}

/// 구간별 조언 정보
class SegmentAdvice {
  /// 시작 시간 (밀리초)
  final double startTimeMs;
  
  /// 종료 시간 (밀리초)
  final double endTimeMs;
  
  /// 오차 유형 (pitch, rhythm, stability, vibrato)
  final String errorType;
  
  /// 심각도 (low, medium, high, critical)
  final String severity;
  
  /// 개선 제안
  final String suggestion;
  
  /// AI 신뢰도 (0.0-1.0)
  final double confidence;
  
  /// 추가 메타데이터
  final Map<String, dynamic>? metadata;

  const SegmentAdvice({
    required this.startTimeMs,
    required this.endTimeMs,
    required this.errorType,
    required this.severity,
    required this.suggestion,
    this.confidence = 1.0,
    this.metadata,
  });

  /// 구간 길이 (밀리초)
  double get durationMs => endTimeMs - startTimeMs;

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'startTimeMs': startTimeMs,
      'endTimeMs': endTimeMs,
      'errorType': errorType,
      'severity': severity,
      'suggestion': suggestion,
      'confidence': confidence,
      'metadata': metadata,
    };
  }

  /// JSON에서 역직렬화
  factory SegmentAdvice.fromJson(Map<String, dynamic> json) {
    return SegmentAdvice(
      startTimeMs: (json['startTimeMs'] as num).toDouble(),
      endTimeMs: (json['endTimeMs'] as num).toDouble(),
      errorType: json['errorType'] as String,
      severity: json['severity'] as String,
      suggestion: json['suggestion'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// 캘리브레이션 데이터
class CalibrationData {
  /// 노이즈 바닥 (dBFS)
  final double noiseFloorDb;
  
  /// LUFS 추정값 (음량 표준화)
  final double? lufs;
  
  /// 마이크 감도 보정값
  final double? micSensitivity;
  
  /// 주파수 응답 보정 (Hz -> dB gain)
  final Map<double, double>? frequencyResponse;
  
  /// 캘리브레이션 타임스탬프
  final DateTime calibratedAt;

  const CalibrationData({
    required this.noiseFloorDb,
    this.lufs,
    this.micSensitivity,
    this.frequencyResponse,
    required this.calibratedAt,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'noiseFloorDb': noiseFloorDb,
      'lufs': lufs,
      'micSensitivity': micSensitivity,
      'frequencyResponse': frequencyResponse?.map((k, v) => MapEntry(k.toString(), v)),
      'calibratedAt': calibratedAt.millisecondsSinceEpoch,
    };
  }

  /// JSON에서 역직렬화
  factory CalibrationData.fromJson(Map<String, dynamic> json) {
    Map<double, double>? freqResp;
    if (json['frequencyResponse'] != null) {
      final respMap = json['frequencyResponse'] as Map<String, dynamic>;
      freqResp = respMap.map((k, v) => MapEntry(double.parse(k), (v as num).toDouble()));
    }

    return CalibrationData(
      noiseFloorDb: (json['noiseFloorDb'] as num).toDouble(),
      lufs: (json['lufs'] as num?)?.toDouble(),
      micSensitivity: (json['micSensitivity'] as num?)?.toDouble(),
      frequencyResponse: freqResp,
      calibratedAt: DateTime.fromMillisecondsSinceEpoch(json['calibratedAt'] as int),
    );
  }
}