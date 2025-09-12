import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/session.dart';
import 'dart:convert';

class ProgressTrackingService {
  static const String _tableName = 'progress_tracking';
  
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        session_date TEXT NOT NULL,
        session_type TEXT NOT NULL, -- 'tuner' or 'scale_practice'
        audio_reference_id INTEGER,
        target_note TEXT,
        duration_seconds INTEGER NOT NULL,
        total_notes_attempted INTEGER DEFAULT 0,
        notes_completed INTEGER DEFAULT 0,
        accuracy_scores TEXT, -- JSON array of accuracy scores
        stability_scores TEXT, -- JSON array of stability scores
        weak_sections TEXT, -- JSON array of problematic note ranges
        improvement_areas TEXT, -- JSON array of suggested improvements
        session_notes TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (audio_reference_id) REFERENCES audio_references (id)
      )
    ''');
    
    // 인덱스 생성
    await db.execute('CREATE INDEX idx_progress_user_date ON $_tableName(user_id, session_date)');
    await db.execute('CREATE INDEX idx_progress_session_type ON $_tableName(session_type)');
  }

  final DatabaseService _databaseService = DatabaseService();

  Future<int> startSession({
    required String sessionType,
    int? audioReferenceId,
    String? targetNote,
  }) async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    
    final sessionData = {
      'user_id': 'default_user',
      'session_date': now.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'session_type': sessionType,
      'audio_reference_id': audioReferenceId,
      'target_note': targetNote,
      'duration_seconds': 0,
      'total_notes_attempted': 0,
      'notes_completed': 0,
      'accuracy_scores': '[]',
      'stability_scores': '[]',
      'weak_sections': '[]',
      'improvement_areas': '[]',
      'session_notes': '',
      'created_at': now.millisecondsSinceEpoch,
    };
    
    return await db.insert(_tableName, sessionData);
  }

  Future<void> updateSessionProgress({
    required int sessionId,
    required int durationSeconds,
    int? totalNotesAttempted,
    int? notesCompleted,
    List<double>? accuracyScores,
    List<double>? stabilityScores,
    List<String>? weakSections,
    List<String>? improvementAreas,
    String? sessionNotes,
  }) async {
    final db = await _databaseService.database;
    
    final updateData = <String, dynamic>{};
    updateData['duration_seconds'] = durationSeconds;
    
    if (totalNotesAttempted != null) updateData['total_notes_attempted'] = totalNotesAttempted;
    if (notesCompleted != null) updateData['notes_completed'] = notesCompleted;
    if (accuracyScores != null) updateData['accuracy_scores'] = jsonEncode(accuracyScores);
    if (stabilityScores != null) updateData['stability_scores'] = jsonEncode(stabilityScores);
    if (weakSections != null) updateData['weak_sections'] = jsonEncode(weakSections);
    if (improvementAreas != null) updateData['improvement_areas'] = jsonEncode(improvementAreas);
    if (sessionNotes != null) updateData['session_notes'] = sessionNotes;
    
    await db.update(
      _tableName,
      updateData,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> endSession({
    required int sessionId,
    required int durationSeconds,
    List<double>? finalAccuracyScores,
    List<double>? finalStabilityScores,
    String? sessionSummary,
  }) async {
    final db = await _databaseService.database;
    
    final updateData = <String, dynamic>{
      'duration_seconds': durationSeconds,
    };
    
    if (finalAccuracyScores != null) {
      updateData['accuracy_scores'] = jsonEncode(finalAccuracyScores);
    }
    if (finalStabilityScores != null) {
      updateData['stability_scores'] = jsonEncode(finalStabilityScores);
    }
    if (sessionSummary != null) {
      updateData['session_notes'] = sessionSummary;
    }
    
    await db.update(
      _tableName,
      updateData,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<ProgressSession>> getRecentSessions({int limit = 10}) async {
    final db = await _databaseService.database;
    
    final result = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    
    return result.map((row) => ProgressSession.fromMap(row)).toList();
  }

  Future<List<ProgressSession>> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _databaseService.database;
    
    final result = await db.query(
      _tableName,
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
    );
    
    return result.map((row) => ProgressSession.fromMap(row)).toList();
  }

  Future<ProgressStats> getProgressStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseService.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (startDate != null && endDate != null) {
      whereClause = 'WHERE created_at >= ? AND created_at <= ?';
      whereArgs = [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch];
    }
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sessions,
        SUM(duration_seconds) as total_practice_time,
        AVG(duration_seconds) as avg_session_duration,
        SUM(notes_completed) as total_notes_completed,
        SUM(total_notes_attempted) as total_notes_attempted
      FROM $_tableName
      $whereClause
    ''', whereArgs);
    
    if (result.isEmpty) {
      return ProgressStats(
        totalSessions: 0,
        totalPracticeTime: 0,
        averageSessionDuration: 0,
        totalNotesCompleted: 0,
        totalNotesAttempted: 0,
        completionRate: 0.0,
      );
    }
    
    final row = result.first;
    final totalSessions = row['total_sessions'] as int;
    final totalPracticeTime = row['total_practice_time'] as int;
    final avgSessionDuration = (row['avg_session_duration'] as double?) ?? 0.0;
    final totalNotesCompleted = row['total_notes_completed'] as int;
    final totalNotesAttempted = row['total_notes_attempted'] as int;
    
    final completionRate = totalNotesAttempted > 0 
        ? (totalNotesCompleted / totalNotesAttempted) 
        : 0.0;
    
    return ProgressStats(
      totalSessions: totalSessions,
      totalPracticeTime: totalPracticeTime,
      averageSessionDuration: avgSessionDuration,
      totalNotesCompleted: totalNotesCompleted,
      totalNotesAttempted: totalNotesAttempted,
      completionRate: completionRate,
    );
  }

  Future<List<DailyProgress>> getDailyProgress({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _databaseService.database;
    
    final result = await db.rawQuery('''
      SELECT 
        session_date,
        COUNT(*) as sessions_count,
        SUM(duration_seconds) as total_duration,
        AVG(notes_completed * 100.0 / NULLIF(total_notes_attempted, 0)) as avg_completion_rate
      FROM $_tableName
      WHERE created_at >= ? AND created_at <= ?
      GROUP BY session_date
      ORDER BY session_date
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    return result.map((row) => DailyProgress(
      date: DateTime.parse(row['session_date'] as String),
      sessionsCount: row['sessions_count'] as int,
      totalDuration: row['total_duration'] as int,
      averageCompletionRate: (row['avg_completion_rate'] as double?) ?? 0.0,
    )).toList();
  }

  // 세션 기록 메서드 추가
  Future<void> recordSession(Map<String, dynamic> sessionData) async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    
    final data = {
      'user_id': sessionData['userId'] ?? 'default_user',
      'session_date': now.toIso8601String().split('T')[0],
      'session_type': sessionData['sessionType'] ?? 'unknown',
      'audio_reference_id': sessionData['audioReferenceId'],
      'target_note': sessionData['targetNote'],
      'duration_seconds': sessionData['durationSeconds'] ?? 0,
      'total_notes_attempted': sessionData['totalNotesAttempted'] ?? 0,
      'notes_completed': sessionData['notesCompleted'] ?? 0,
      'accuracy_scores': jsonEncode(sessionData['accuracyScores'] ?? []),
      'stability_scores': jsonEncode(sessionData['stabilityScores'] ?? []),
      'weak_sections': jsonEncode(sessionData['weakSections'] ?? []),
      'improvement_areas': jsonEncode(sessionData['improvementAreas'] ?? []),
      'session_notes': sessionData['sessionNotes'] ?? '',
      'created_at': now.millisecondsSinceEpoch,
    };
    
    await db.insert(_tableName, data);
  }

  // 사용자 진행 상황 가져오기 메서드 추가
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    final db = await _databaseService.database;
    
    // 최근 30일간의 통계
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    final stats = await getProgressStats(
      startDate: thirtyDaysAgo,
      endDate: DateTime.now(),
    );
    
    // 최근 세션들
    final recentSessions = await getRecentSessions(limit: 5);
    
    // 주간 진행 상황
    final weekAgo = DateTime.now().subtract(Duration(days: 7));
    final dailyProgress = await getDailyProgress(
      startDate: weekAgo,
      endDate: DateTime.now(),
    );
    
    return {
      'stats': stats,
      'recentSessions': recentSessions,
      'dailyProgress': dailyProgress,
      'userId': userId,
    };
  }
}

class ProgressSession {
  final int id;
  final String userId;
  final DateTime sessionDate;
  final String sessionType;
  final int? audioReferenceId;
  final String? targetNote;
  final int durationSeconds;
  final int totalNotesAttempted;
  final int notesCompleted;
  final List<double> accuracyScores;
  final List<double> stabilityScores;
  final List<String> weakSections;
  final List<String> improvementAreas;
  final String sessionNotes;
  final DateTime createdAt;

  ProgressSession({
    required this.id,
    required this.userId,
    required this.sessionDate,
    required this.sessionType,
    this.audioReferenceId,
    this.targetNote,
    required this.durationSeconds,
    required this.totalNotesAttempted,
    required this.notesCompleted,
    required this.accuracyScores,
    required this.stabilityScores,
    required this.weakSections,
    required this.improvementAreas,
    required this.sessionNotes,
    required this.createdAt,
  });

  factory ProgressSession.fromMap(Map<String, dynamic> map) {
    return ProgressSession(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      sessionDate: DateTime.parse(map['session_date'] as String),
      sessionType: map['session_type'] as String,
      audioReferenceId: map['audio_reference_id'] as int?,
      targetNote: map['target_note'] as String?,
      durationSeconds: map['duration_seconds'] as int,
      totalNotesAttempted: map['total_notes_attempted'] as int,
      notesCompleted: map['notes_completed'] as int,
      accuracyScores: _parseDoubleList(map['accuracy_scores'] as String?),
      stabilityScores: _parseDoubleList(map['stability_scores'] as String?),
      weakSections: _parseStringList(map['weak_sections'] as String?),
      improvementAreas: _parseStringList(map['improvement_areas'] as String?),
      sessionNotes: map['session_notes'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  static List<double> _parseDoubleList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      return [];
    }
  }

  static List<String> _parseStringList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  double get completionRate => 
      totalNotesAttempted > 0 ? (notesCompleted / totalNotesAttempted) : 0.0;

  double get averageAccuracy => 
      accuracyScores.isNotEmpty 
          ? accuracyScores.reduce((a, b) => a + b) / accuracyScores.length 
          : 0.0;

  double get averageStability => 
      stabilityScores.isNotEmpty 
          ? stabilityScores.reduce((a, b) => a + b) / stabilityScores.length 
          : 0.0;

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}분 ${seconds}초';
  }
}

class ProgressStats {
  final int totalSessions;
  final int totalPracticeTime; // in seconds
  final double averageSessionDuration; // in seconds
  final int totalNotesCompleted;
  final int totalNotesAttempted;
  final double completionRate; // percentage

  ProgressStats({
    required this.totalSessions,
    required this.totalPracticeTime,
    required this.averageSessionDuration,
    required this.totalNotesCompleted,
    required this.totalNotesAttempted,
    required this.completionRate,
  });

  String get formattedTotalTime {
    final hours = totalPracticeTime ~/ 3600;
    final minutes = (totalPracticeTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  String get formattedAverageTime {
    final minutes = averageSessionDuration.round() ~/ 60;
    final seconds = averageSessionDuration.round() % 60;
    return '${minutes}분 ${seconds}초';
  }
}

class DailyProgress {
  final DateTime date;
  final int sessionsCount;
  final int totalDuration; // in seconds
  final double averageCompletionRate; // percentage

  DailyProgress({
    required this.date,
    required this.sessionsCount,
    required this.totalDuration,
    required this.averageCompletionRate,
  });

  String get formattedDate {
    return '${date.month}/${date.day}';
  }

  String get formattedDuration {
    final minutes = totalDuration ~/ 60;
    return '${minutes}분';
  }
}