import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import '../models/pitch_data.dart';
import '../models/audio_reference.dart';
import '../services/database_service.dart';
import '../services/progress_tracking_service.dart';
import 'package:sqflite/sqflite.dart';

/// 세션 리플레이 데이터
class SessionReplay {
  final int sessionId;
  final String userId;
  final DateTime recordedAt;
  final int durationMs;
  final String audioFilePath;
  final PitchData pitchData;
  final AudioReference audioReference;
  final List<ReplayTimestamp> timestamps;
  final Map<String, dynamic> analysisData;
  final SessionMetadata metadata;
  
  SessionReplay({
    required this.sessionId,
    required this.userId,
    required this.recordedAt,
    required this.durationMs,
    required this.audioFilePath,
    required this.pitchData,
    required this.audioReference,
    required this.timestamps,
    required this.analysisData,
    required this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'user_id': userId,
    'recorded_at': recordedAt.toIso8601String(),
    'duration_ms': durationMs,
    'audio_file_path': audioFilePath,
    'pitch_data': pitchData.toJson(),
    'audio_reference': audioReference.toJson(),
    'timestamps': timestamps.map((t) => t.toJson()).toList(),
    'analysis_data': analysisData,
    'metadata': metadata.toJson(),
  };
  
  factory SessionReplay.fromJson(Map<String, dynamic> json) {
    return SessionReplay(
      sessionId: json['session_id'] as int,
      userId: json['user_id'] as String,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      durationMs: json['duration_ms'] as int,
      audioFilePath: json['audio_file_path'] as String,
      pitchData: PitchData.fromJson(json['pitch_data'] as Map<String, dynamic>),
      audioReference: AudioReference.fromJson(json['audio_reference'] as Map<String, dynamic>),
      timestamps: (json['timestamps'] as List)
          .map((t) => ReplayTimestamp.fromJson(t as Map<String, dynamic>))
          .toList(),
      analysisData: json['analysis_data'] as Map<String, dynamic>,
      metadata: SessionMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }
}

/// 리플레이 타임스탬프 (특정 시점의 이벤트)
class ReplayTimestamp {
  final int timeMs;
  final String eventType; // 'note_start', 'note_end', 'feedback', 'improvement'
  final Map<String, dynamic> eventData;
  
  ReplayTimestamp({
    required this.timeMs,
    required this.eventType,
    required this.eventData,
  });
  
  Map<String, dynamic> toJson() => {
    'time_ms': timeMs,
    'event_type': eventType,
    'event_data': eventData,
  };
  
  factory ReplayTimestamp.fromJson(Map<String, dynamic> json) {
    return ReplayTimestamp(
      timeMs: json['time_ms'] as int,
      eventType: json['event_type'] as String,
      eventData: json['event_data'] as Map<String, dynamic>,
    );
  }
}

/// 세션 메타데이터
class SessionMetadata {
  final String deviceInfo;
  final String appVersion;
  final Map<String, dynamic> audioSettings;
  final List<String> tags;
  final double temperature; // 연습 환경
  final double humidity;
  final String notes; // 사용자 노트
  
  SessionMetadata({
    required this.deviceInfo,
    required this.appVersion,
    required this.audioSettings,
    required this.tags,
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.notes = '',
  });
  
  Map<String, dynamic> toJson() => {
    'device_info': deviceInfo,
    'app_version': appVersion,
    'audio_settings': audioSettings,
    'tags': tags,
    'temperature': temperature,
    'humidity': humidity,
    'notes': notes,
  };
  
  factory SessionMetadata.fromJson(Map<String, dynamic> json) {
    return SessionMetadata(
      deviceInfo: json['device_info'] as String,
      appVersion: json['app_version'] as String,
      audioSettings: json['audio_settings'] as Map<String, dynamic>,
      tags: List<String>.from(json['tags'] as List),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? '',
    );
  }
}

/// 진도 추세 분석 결과
class ProgressTrendAnalysis {
  final String userId;
  final DateTime analysisDate;
  final Map<String, TrendData> skillTrends; // 기술별 추세
  final double overallImprovement; // -1.0 to 1.0
  final List<String> improvingAreas;
  final List<String> decliningAreas;
  final List<String> stagnantAreas;
  final Map<String, dynamic> predictions; // 향후 예측
  final List<Achievement> newAchievements;
  
  ProgressTrendAnalysis({
    required this.userId,
    required this.analysisDate,
    required this.skillTrends,
    required this.overallImprovement,
    required this.improvingAreas,
    required this.decliningAreas,
    required this.stagnantAreas,
    required this.predictions,
    required this.newAchievements,
  });
}

/// 기술별 추세 데이터
class TrendData {
  final List<DataPoint> dataPoints;
  final double slope; // 기울기 (개선률)
  final double correlation; // 상관관계
  final String trendDescription;
  final double confidence; // 신뢰도
  
  TrendData({
    required this.dataPoints,
    required this.slope,
    required this.correlation,
    required this.trendDescription,
    required this.confidence,
  });
}

class DataPoint {
  final DateTime date;
  final double value;
  
  DataPoint({required this.date, required this.value});
}

/// 성취 기록
class Achievement {
  final String id;
  final String title;
  final String description;
  final String category; // 'accuracy', 'consistency', 'range', 'technique'
  final DateTime unlockedAt;
  final int points;
  final String iconName;
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.unlockedAt,
    required this.points,
    required this.iconName,
  });
}

/// 세션 리플레이 및 진도 추적 서비스
class SessionReplayService {
  static const String _sessionReplayTable = 'session_replays';
  static const String _progressTrendsTable = 'progress_trends';
  static const String _achievementsTable = 'achievements';
  
  final DatabaseService _databaseService = DatabaseService();
  final ProgressTrackingService _progressService = ProgressTrackingService();
  
  // 실시간 리플레이 상태
  final StreamController<ReplayState> _replayStateController = 
      StreamController<ReplayState>.broadcast();
  
  SessionReplay? _currentReplay;
  Timer? _replayTimer;
  int _currentReplayPosition = 0;
  
  Stream<ReplayState> get replayStateStream => _replayStateController.stream;
  
  /// 데이터베이스 테이블 생성
  static Future<void> createTables(Database db) async {
    // 세션 리플레이 테이블
    await db.execute('''
      CREATE TABLE $_sessionReplayTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        recorded_at TEXT NOT NULL,
        duration_ms INTEGER NOT NULL,
        audio_file_path TEXT NOT NULL,
        pitch_data_json TEXT NOT NULL,
        audio_reference_json TEXT NOT NULL,
        timestamps_json TEXT NOT NULL,
        analysis_data_json TEXT NOT NULL,
        metadata_json TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES progress_tracking (id)
      )
    ''');
    
    // 진도 추세 테이블
    await db.execute('''
      CREATE TABLE $_progressTrendsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        skill_trends_json TEXT NOT NULL,
        overall_improvement REAL NOT NULL,
        improving_areas_json TEXT NOT NULL,
        declining_areas_json TEXT NOT NULL,
        stagnant_areas_json TEXT NOT NULL,
        predictions_json TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    
    // 성취 테이블
    await db.execute('''
      CREATE TABLE $_achievementsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        achievement_id TEXT NOT NULL UNIQUE,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        unlocked_at TEXT NOT NULL,
        points INTEGER NOT NULL,
        icon_name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    
    // 인덱스 생성
    await db.execute('CREATE INDEX idx_replays_user_date ON $_sessionReplayTable(user_id, recorded_at)');
    await db.execute('CREATE INDEX idx_trends_user_date ON $_progressTrendsTable(user_id, analysis_date)');
    await db.execute('CREATE INDEX idx_achievements_user ON $_achievementsTable(user_id, unlocked_at)');
  }
  
  /// 세션 리플레이 기록 시작
  Future<int> startRecording({
    required int sessionId,
    required String userId,
    required AudioReference audioReference,
    required Map<String, dynamic> audioSettings,
    List<String> tags = const [],
    String notes = '',
  }) async {
    final db = await _databaseService.database;
    
    // 임시 파일 경로 생성
    final directory = await getApplicationDocumentsDirectory();
    final audioFilePath = '${directory.path}/recordings/session_${sessionId}_${DateTime.now().millisecondsSinceEpoch}.wav';
    
    final metadata = SessionMetadata(
      deviceInfo: 'Flutter Device', // TODO: 실제 디바이스 정보 획득
      appVersion: '1.0.0',
      audioSettings: audioSettings,
      tags: tags,
      notes: notes,
    );
    
    final replayData = {
      'session_id': sessionId,
      'user_id': userId,
      'recorded_at': DateTime.now().toIso8601String(),
      'duration_ms': 0,
      'audio_file_path': audioFilePath,
      'pitch_data_json': '{}',
      'audio_reference_json': jsonEncode(audioReference.toJson()),
      'timestamps_json': '[]',
      'analysis_data_json': '{}',
      'metadata_json': jsonEncode(metadata.toJson()),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
    
    return await db.insert(_sessionReplayTable, replayData);
  }
  
  /// 세션 리플레이 완료 및 저장
  Future<void> saveReplay({
    required int replayId,
    required int durationMs,
    required PitchData pitchData,
    required List<ReplayTimestamp> timestamps,
    required Map<String, dynamic> analysisData,
  }) async {
    final db = await _databaseService.database;
    
    final updateData = {
      'duration_ms': durationMs,
      'pitch_data_json': jsonEncode(pitchData.toJson()),
      'timestamps_json': jsonEncode(timestamps.map((t) => t.toJson()).toList()),
      'analysis_data_json': jsonEncode(analysisData),
    };
    
    await db.update(
      _sessionReplayTable,
      updateData,
      where: 'id = ?',
      whereArgs: [replayId],
    );
  }
  
  /// 세션 리플레이 불러오기
  Future<SessionReplay?> loadReplay(int replayId) async {
    final db = await _databaseService.database;
    
    final result = await db.query(
      _sessionReplayTable,
      where: 'id = ?',
      whereArgs: [replayId],
    );
    
    if (result.isEmpty) return null;
    
    final row = result.first;
    
    return SessionReplay(
      sessionId: row['session_id'] as int,
      userId: row['user_id'] as String,
      recordedAt: DateTime.parse(row['recorded_at'] as String),
      durationMs: row['duration_ms'] as int,
      audioFilePath: row['audio_file_path'] as String,
      pitchData: PitchData.fromJson(jsonDecode(row['pitch_data_json'] as String)),
      audioReference: AudioReference.fromJson(jsonDecode(row['audio_reference_json'] as String)),
      timestamps: (jsonDecode(row['timestamps_json'] as String) as List)
          .map((t) => ReplayTimestamp.fromJson(t as Map<String, dynamic>))
          .toList(),
      analysisData: jsonDecode(row['analysis_data_json'] as String),
      metadata: SessionMetadata.fromJson(jsonDecode(row['metadata_json'] as String)),
    );
  }
  
  /// 사용자의 세션 리플레이 목록 조회
  Future<List<Map<String, dynamic>>> getUserReplays(String userId, {int limit = 20}) async {
    final db = await _databaseService.database;
    
    final result = await db.query(
      _sessionReplayTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'recorded_at DESC',
      limit: limit,
    );
    
    return result.map((row) => {
      'id': row['id'],
      'session_id': row['session_id'],
      'recorded_at': row['recorded_at'],
      'duration_ms': row['duration_ms'],
      'metadata': jsonDecode(row['metadata_json'] as String),
    }).toList();
  }
  
  /// 리플레이 재생 시작
  Future<void> startReplay(SessionReplay replay) async {
    _currentReplay = replay;
    _currentReplayPosition = 0;
    
    // 초기 상태 전송
    _replayStateController.add(ReplayState(
      isPlaying: true,
      currentPosition: 0,
      totalDuration: replay.durationMs,
      currentTimestamp: null,
      pitchData: [],
      analysisSnapshot: {},
    ));
    
    // 리플레이 타이머 시작 (50ms 간격으로 업데이트)
    _replayTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      _updateReplayState();
    });
  }
  
  /// 리플레이 일시정지/재생
  void toggleReplay() {
    if (_replayTimer?.isActive == true) {
      _replayTimer?.cancel();
      _broadcastReplayState(isPlaying: false);
    } else if (_currentReplay != null) {
      _replayTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
        _updateReplayState();
      });
      _broadcastReplayState(isPlaying: true);
    }
  }
  
  /// 리플레이 정지
  void stopReplay() {
    _replayTimer?.cancel();
    _currentReplay = null;
    _currentReplayPosition = 0;
    
    _replayStateController.add(ReplayState(
      isPlaying: false,
      currentPosition: 0,
      totalDuration: 0,
      currentTimestamp: null,
      pitchData: [],
      analysisSnapshot: {},
    ));
  }
  
  /// 리플레이 위치 변경 (시크)
  void seekReplay(int positionMs) {
    if (_currentReplay != null) {
      _currentReplayPosition = positionMs.clamp(0, _currentReplay!.durationMs);
      _updateReplayState();
    }
  }
  
  /// 진도 추세 분석 수행
  Future<ProgressTrendAnalysis> analyzeProgressTrends(
    String userId, {
    int daysPast = 30,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysPast));
      
      // 기간별 세션 데이터 수집
      final sessions = await _progressService.getSessionsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      
      if (sessions.length < 3) {
        // 데이터가 부족한 경우 기본 분석 반환
        return _createDefaultTrendAnalysis(userId);
      }
      
      // 기술별 추세 분석
      final skillTrends = _analyzeSkillTrends(sessions);
      
      // 전반적인 개선도 계산
      final overallImprovement = _calculateOverallImprovement(sessions);
      
      // 영역별 분류
      final improvingAreas = <String>[];
      final decliningAreas = <String>[];
      final stagnantAreas = <String>[];
      
      skillTrends.forEach((skill, trend) {
        if (trend.slope > 0.1) {
          improvingAreas.add(_getSkillDisplayName(skill));
        } else if (trend.slope < -0.1) {
          decliningAreas.add(_getSkillDisplayName(skill));
        } else {
          stagnantAreas.add(_getSkillDisplayName(skill));
        }
      });
      
      // 향후 예측 생성
      final predictions = _generatePredictions(skillTrends, sessions);
      
      // 새로운 성취 확인
      final newAchievements = await _checkNewAchievements(userId, sessions);
      
      final analysis = ProgressTrendAnalysis(
        userId: userId,
        analysisDate: DateTime.now(),
        skillTrends: skillTrends,
        overallImprovement: overallImprovement,
        improvingAreas: improvingAreas,
        decliningAreas: decliningAreas,
        stagnantAreas: stagnantAreas,
        predictions: predictions,
        newAchievements: newAchievements,
      );
      
      // 분석 결과 저장
      await _saveTrendAnalysis(analysis);
      
      return analysis;
      
    } catch (e) {
      print('진도 추세 분석 오류: $e');
      return _createDefaultTrendAnalysis(userId);
    }
  }
  
  /// 사용자 진행 상황 요약
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      final stats = await _progressService.getProgressStats();
      final recentTrend = await _getRecentTrendAnalysis(userId);
      
      return {
        'sessions_completed': stats.totalSessions,
        'total_practice_time': stats.totalPracticeTime,
        'improvement_trend': recentTrend?['overall_trend'] ?? 'stable',
        'streak_days': await _calculateStreakDays(userId),
        'next_milestone': _getNextMilestone(stats),
        'recent_achievements': await _getRecentAchievements(userId, limit: 3),
        'skill_levels': await _getCurrentSkillLevels(userId),
      };
    } catch (e) {
      print('사용자 진행 상황 조회 오류: $e');
      return {
        'sessions_completed': 0,
        'total_practice_time': 0,
        'improvement_trend': 'stable',
        'streak_days': 0,
        'next_milestone': '첫 번째 연습 세션 완료',
      };
    }
  }
  
  /// 세션 기록 (개인화 코치와 통합)
  Future<void> recordSession({
    required String userId,
    required Map<String, dynamic> sessionData,
  }) async {
    // 기존 진도 추적 서비스에 기록
    await _progressService.updateSessionProgress(
      sessionId: sessionData['session_id'] ?? 0,
      durationSeconds: ((sessionData['duration_ms'] ?? 0) / 1000).round(),
      accuracyScores: List<double>.from(sessionData['accuracy_scores'] ?? []),
      stabilityScores: List<double>.from(sessionData['stability_scores'] ?? []),
    );
    
    // 추가적인 고급 분석 데이터 저장 (필요시)
    // 예: 비브라토 점수, 포먼트 분석 결과, 멜로디 정렬 점수 등
  }
  
  // Private helper methods
  
  void _updateReplayState() {
    if (_currentReplay == null) return;
    
    _currentReplayPosition += 50; // 50ms씩 증가
    
    if (_currentReplayPosition >= _currentReplay!.durationMs) {
      // 리플레이 완료
      stopReplay();
      return;
    }
    
    // 현재 시점의 타임스탬프 찾기
    final currentTimestamp = _currentReplay!.timestamps
        .where((t) => t.timeMs <= _currentReplayPosition)
        .lastOrNull;
    
    // 현재 시점의 피치 데이터 계산
    final pitchIndex = (_currentReplayPosition * 
        _currentReplay!.pitchData.pitchCurve.length / 
        _currentReplay!.durationMs).round();
    
    final currentPitchData = _currentReplay!.pitchData.pitchCurve
        .take(pitchIndex.clamp(0, _currentReplay!.pitchData.pitchCurve.length))
        .toList();
    
    _replayStateController.add(ReplayState(
      isPlaying: true,
      currentPosition: _currentReplayPosition,
      totalDuration: _currentReplay!.durationMs,
      currentTimestamp: currentTimestamp,
      pitchData: currentPitchData,
      analysisSnapshot: _getAnalysisSnapshot(_currentReplayPosition),
    ));
  }
  
  void _broadcastReplayState({required bool isPlaying}) {
    if (_currentReplay == null) return;
    
    _replayStateController.add(ReplayState(
      isPlaying: isPlaying,
      currentPosition: _currentReplayPosition,
      totalDuration: _currentReplay!.durationMs,
      currentTimestamp: null,
      pitchData: [],
      analysisSnapshot: {},
    ));
  }
  
  Map<String, dynamic> _getAnalysisSnapshot(int timeMs) {
    // 현재 시점의 분석 데이터 스냅샷 반환
    return {
      'current_accuracy': 75.0, // TODO: 실제 계산
      'stability': 85.0,
      'current_note': 'C4',
      'target_note': 'C4',
      'pitch_error_cents': 5.0,
    };
  }
  
  Map<String, TrendData> _analyzeSkillTrends(List<ProgressSession> sessions) {
    final trends = <String, TrendData>{};
    
    // 각 기술별로 추세 분석
    final skills = ['accuracy', 'stability', 'completion_rate'];
    
    for (final skill in skills) {
      final dataPoints = sessions.map((session) {
        double value = 0.0;
        switch (skill) {
          case 'accuracy':
            value = session.averageAccuracy;
            break;
          case 'stability':
            value = session.averageStability;
            break;
          case 'completion_rate':
            value = session.completionRate * 100;
            break;
        }
        return DataPoint(date: session.createdAt, value: value);
      }).toList();
      
      final slope = _calculateSlope(dataPoints);
      final correlation = _calculateCorrelation(dataPoints);
      
      trends[skill] = TrendData(
        dataPoints: dataPoints,
        slope: slope,
        correlation: correlation,
        trendDescription: _describeTrend(slope),
        confidence: math.min(1.0, correlation.abs()),
      );
    }
    
    return trends;
  }
  
  double _calculateSlope(List<DataPoint> points) {
    if (points.length < 2) return 0.0;
    
    final xValues = points.asMap().keys.map((i) => i.toDouble()).toList();
    final yValues = points.map((p) => p.value).toList();
    
    final n = points.length;
    final sumX = xValues.reduce((a, b) => a + b);
    final sumY = yValues.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => xValues[i] * yValues[i]).reduce((a, b) => a + b);
    final sumXX = xValues.map((x) => x * x).reduce((a, b) => a + b);
    
    final denominator = n * sumXX - sumX * sumX;
    if (denominator == 0) return 0.0;
    
    return (n * sumXY - sumX * sumY) / denominator;
  }
  
  double _calculateCorrelation(List<DataPoint> points) {
    if (points.length < 2) return 0.0;
    
    final xValues = points.asMap().keys.map((i) => i.toDouble()).toList();
    final yValues = points.map((p) => p.value).toList();
    
    final meanX = xValues.reduce((a, b) => a + b) / xValues.length;
    final meanY = yValues.reduce((a, b) => a + b) / yValues.length;
    
    double numerator = 0.0;
    double sumSqX = 0.0;
    double sumSqY = 0.0;
    
    for (int i = 0; i < points.length; i++) {
      final diffX = xValues[i] - meanX;
      final diffY = yValues[i] - meanY;
      
      numerator += diffX * diffY;
      sumSqX += diffX * diffX;
      sumSqY += diffY * diffY;
    }
    
    final denominator = math.sqrt(sumSqX * sumSqY);
    if (denominator == 0) return 0.0;
    
    return numerator / denominator;
  }
  
  String _describeTrend(double slope) {
    if (slope > 0.5) return '빠르게 향상';
    if (slope > 0.1) return '점진적 향상';
    if (slope > -0.1) return '안정적 유지';
    if (slope > -0.5) return '약간 하락';
    return '개선 필요';
  }
  
  double _calculateOverallImprovement(List<ProgressSession> sessions) {
    if (sessions.length < 2) return 0.0;
    
    final recent = sessions.take(sessions.length ~/ 3).toList();
    final older = sessions.skip(sessions.length * 2 ~/ 3).toList();
    
    final recentAvg = recent.map((s) => s.averageAccuracy).reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.map((s) => s.averageAccuracy).reduce((a, b) => a + b) / older.length;
    
    return ((recentAvg - olderAvg) / 100.0).clamp(-1.0, 1.0);
  }
  
  Map<String, dynamic> _generatePredictions(
    Map<String, TrendData> skillTrends,
    List<ProgressSession> sessions,
  ) {
    final predictions = <String, dynamic>{};
    
    skillTrends.forEach((skill, trend) {
      if (trend.dataPoints.isNotEmpty) {
        final lastValue = trend.dataPoints.last.value;
        final predictedValue = lastValue + (trend.slope * 7); // 7일 후 예측
        
        predictions['${skill}_prediction'] = {
          'current': lastValue,
          'predicted_7_days': predictedValue,
          'confidence': trend.confidence,
          'trend': trend.trendDescription,
        };
      }
    });
    
    return predictions;
  }
  
  Future<List<Achievement>> _checkNewAchievements(
    String userId,
    List<ProgressSession> sessions,
  ) async {
    final achievements = <Achievement>[];
    
    // 간단한 성취 예시들
    if (sessions.length == 1) {
      achievements.add(Achievement(
        id: 'first_session',
        title: '첫 번째 연습',
        description: '첫 번째 보컬 연습 세션을 완료했습니다!',
        category: 'milestone',
        unlockedAt: DateTime.now(),
        points: 100,
        iconName: 'first_note',
      ));
    }
    
    if (sessions.length >= 10) {
      achievements.add(Achievement(
        id: 'dedicated_learner',
        title: '헌신적인 학습자',
        description: '10회 이상 연습 세션을 완료했습니다!',
        category: 'consistency',
        unlockedAt: DateTime.now(),
        points: 500,
        iconName: 'trophy',
      ));
    }
    
    final avgAccuracy = sessions.isNotEmpty
        ? sessions.map((s) => s.averageAccuracy).reduce((a, b) => a + b) / sessions.length
        : 0.0;
    
    if (avgAccuracy >= 90.0) {
      achievements.add(Achievement(
        id: 'accuracy_master',
        title: '정확도 마스터',
        description: '평균 정확도 90% 이상을 달성했습니다!',
        category: 'accuracy',
        unlockedAt: DateTime.now(),
        points: 1000,
        iconName: 'bullseye',
      ));
    }
    
    return achievements;
  }
  
  String _getSkillDisplayName(String skill) {
    switch (skill) {
      case 'accuracy':
        return '피치 정확도';
      case 'stability':
        return '발성 안정성';
      case 'completion_rate':
        return '완주율';
      default:
        return skill;
    }
  }
  
  ProgressTrendAnalysis _createDefaultTrendAnalysis(String userId) {
    return ProgressTrendAnalysis(
      userId: userId,
      analysisDate: DateTime.now(),
      skillTrends: {},
      overallImprovement: 0.0,
      improvingAreas: [],
      decliningAreas: [],
      stagnantAreas: ['데이터 수집 중'],
      predictions: {},
      newAchievements: [],
    );
  }
  
  Future<void> _saveTrendAnalysis(ProgressTrendAnalysis analysis) async {
    final db = await _databaseService.database;
    
    final data = {
      'user_id': analysis.userId,
      'analysis_date': analysis.analysisDate.toIso8601String(),
      'skill_trends_json': jsonEncode({}), // TODO: TrendData 직렬화
      'overall_improvement': analysis.overallImprovement,
      'improving_areas_json': jsonEncode(analysis.improvingAreas),
      'declining_areas_json': jsonEncode(analysis.decliningAreas),
      'stagnant_areas_json': jsonEncode(analysis.stagnantAreas),
      'predictions_json': jsonEncode(analysis.predictions),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
    
    await db.insert(_progressTrendsTable, data);
  }
  
  Future<Map<String, dynamic>?> _getRecentTrendAnalysis(String userId) async {
    final db = await _databaseService.database;
    
    final result = await db.query(
      _progressTrendsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'analysis_date DESC',
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    
    final row = result.first;
    final overallImprovement = (row['overall_improvement'] as double?) ?? 0.0;
    return {
      'overall_trend': overallImprovement > 0.1 ? 'improving' : 
                     overallImprovement < -0.1 ? 'declining' : 'stable',
      'analysis_date': row['analysis_date'],
    };
  }
  
  Future<int> _calculateStreakDays(String userId) async {
    // TODO: 연속 연습일 계산 구현
    return 5; // 임시값
  }
  
  String _getNextMilestone(ProgressStats stats) {
    if (stats.totalSessions == 0) return '첫 번째 연습 세션 완료';
    if (stats.totalSessions < 5) return '5회 연습 달성';
    if (stats.totalSessions < 10) return '10회 연습 달성';
    if (stats.totalSessions < 25) return '25회 연습 달성';
    return '50회 연습 달성';
  }
  
  Future<List<Map<String, dynamic>>> _getRecentAchievements(String userId, {int limit = 5}) async {
    final db = await _databaseService.database;
    
    final result = await db.query(
      _achievementsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'unlocked_at DESC',
      limit: limit,
    );
    
    return result;
  }
  
  Future<Map<String, String>> _getCurrentSkillLevels(String userId) async {
    // TODO: 실제 기술 레벨 계산 구현
    return {
      'pitch_accuracy': '초급',
      'stability': '초급',
      'vibrato_quality': '입문',
      'timing_alignment': '초급',
      'tone_quality': '입문',
    };
  }
  
  /// 리소스 정리
  void dispose() {
    _replayTimer?.cancel();
    _replayStateController.close();
  }
}

/// 리플레이 상태
class ReplayState {
  final bool isPlaying;
  final int currentPosition; // ms
  final int totalDuration; // ms
  final ReplayTimestamp? currentTimestamp;
  final List<double> pitchData;
  final Map<String, dynamic> analysisSnapshot;
  
  ReplayState({
    required this.isPlaying,
    required this.currentPosition,
    required this.totalDuration,
    this.currentTimestamp,
    required this.pitchData,
    required this.analysisSnapshot,
  });
  
  double get progressRatio => totalDuration > 0 ? currentPosition / totalDuration : 0.0;
  
  String get formattedCurrentTime {
    final minutes = currentPosition ~/ 60000;
    final seconds = (currentPosition % 60000) ~/ 1000;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String get formattedTotalTime {
    final minutes = totalDuration ~/ 60000;
    final seconds = (totalDuration % 60000) ~/ 1000;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

extension _ListExtension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}