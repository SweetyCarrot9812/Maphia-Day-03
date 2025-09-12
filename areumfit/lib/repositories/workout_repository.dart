import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import '../models/workout_plan.dart';
import '../models/workout_log.dart';
import '../models/isar_models.dart';
import '../models/base_model.dart'; // SessionStatus
import '../models/session_status.dart'; // RecentLogsSummary
import '../services/isar_service.dart';
import '../services/sync_service.dart';

/// 운동 데이터 Repository
/// 로컬 우선 아키텍처로 Isar + Firestore 동기화 처리
class WorkoutRepository {
  final IsarService _isarService;
  final SyncService _syncService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WorkoutRepository(this._isarService, this._syncService);

  // ===== 세션 관리 =====

  /// 새로운 운동 세션 생성
  Future<WorkoutSession> createSession({
    required String userId,
    required String planId,
    required DateTime date,
    required List<Exercise> exercises,
  }) async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    
    final session = WorkoutSession(
      id: sessionId,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      deviceId: await _getDeviceId(),
      date: date,
      status: SessionStatus.planned,
      planId: planId,
      exerciseLogs: const [], // exercises was wrong, should be exerciseLogs
    );

    // 1. 로컬에 저장
    await _saveSessionLocally(session);
    
    // 2. 원격 동기화 예약
    await _scheduleSessionSync(session, SyncOperation.upsert);
    
    developer.log('Created session: ${session.id}');
    return session;
  }

  /// 세션 시작
  Future<WorkoutSession> startSession(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) throw Exception('Session not found: $sessionId');
    
    final updatedSession = session.copyWith(
      status: SessionStatus.inProgress,
      startedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _updateSessionLocally(updatedSession);
    await _scheduleSessionSync(updatedSession, SyncOperation.upsert);
    
    developer.log('Started session: $sessionId');
    return updatedSession;
  }

  /// 세션 완료
  Future<WorkoutSession> completeSession(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) throw Exception('Session not found: $sessionId');
    
    final now = DateTime.now();
    final duration = session.startedAt != null 
        ? now.difference(session.startedAt!).inMinutes
        : null;
    
    final updatedSession = session.copyWith(
      status: SessionStatus.done,
      completedAt: now,
      durationMinutes: duration,
      updatedAt: now,
    );
    
    await _updateSessionLocally(updatedSession);
    await _scheduleSessionSync(updatedSession, SyncOperation.upsert);
    
    developer.log('Completed session: $sessionId, duration: ${duration}min');
    return updatedSession;
  }

  /// 세션 조회
  Future<WorkoutSession?> getSession(String sessionId) async {
    final isar = await _isarService.database;
    
    final localSession = await isar.localSessions
        .filter()
        .sessionIdEqualTo(sessionId)
        .findFirst();
    
    if (localSession == null) return null;
    
    return _convertFromLocalSession(localSession);
  }

  /// 사용자의 모든 세션 조회
  Future<List<WorkoutSession>> getUserSessions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    SessionStatus? status,
  }) async {
    final isar = await _isarService.database;
    
    var query = isar.localSessions
        .filter()
        .userIdEqualTo(userId);
    
    if (startDate != null) {
      query = query.dateGreaterThan(startDate.subtract(const Duration(days: 1)));
    }
    
    if (endDate != null) {
      query = query.dateLessThan(endDate.add(const Duration(days: 1)));
    }
    
    if (status != null) {
      query = query.statusEqualTo(status.name);
    }
    
    final localSessions = await query
        .sortByDateDesc()
        .findAll();
    
    return localSessions.map(_convertFromLocalSession).toList();
  }

  // ===== 운동 로그 관리 =====

  /// 운동 세트 기록
  Future<WorkoutLog> logSet({
    required String sessionId,
    required String exerciseKey,
    required int setIndex,
    required double weight,
    required int reps,
    required int rpe,
    String? note,
  }) async {
    final logId = 'log_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final session = await getSession(sessionId);
    
    if (session == null) throw Exception('Session not found: $sessionId');
    
    // 1RM 계산 (Epley 공식)
    final estimated1RM = weight * (1 + reps / 30);
    
    // PR 확인 (같은 운동의 기존 최고 기록과 비교)
    final isPR = await _checkIfPersonalRecord(
      session.userId, 
      exerciseKey, 
      estimated1RM,
    );
    
    final log = WorkoutLog(
      id: logId,
      userId: session.userId,
      createdAt: now,
      updatedAt: now,
      deviceId: await _getDeviceId(),
      sessionId: sessionId,
      exerciseKey: exerciseKey,
      setIndex: setIndex,
      weight: weight,
      reps: reps,
      rpe: rpe,
      completedAt: now,
      note: note,
      isPR: isPR,
      estimated1RM: estimated1RM,
    );

    // 1. 로컬에 저장
    await _saveLogLocally(log);
    
    // 2. 원격 동기화 예약
    await _scheduleLogSync(log, SyncOperation.upsert);
    
    developer.log('Logged set: ${log.exerciseKey} ${log.weight}kg x ${log.reps} @RPE${log.rpe}${log.isPR ? ' (PR!)' : ''}');
    return log;
  }

  /// 세션의 모든 로그 조회
  Future<List<WorkoutLog>> getSessionLogs(String sessionId) async {
    final isar = await _isarService.database;
    
    final localLogs = await isar.localLogs
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortBySetIndex()
        .findAll();
    
    return localLogs.map(_convertFromLocalLog).toList();
  }

  /// 운동별 기록 히스토리 조회
  Future<List<WorkoutLog>> getExerciseHistory(
    String userId,
    String exerciseKey, {
    int limit = 50,
  }) async {
    final isar = await _isarService.database;
    
    final localLogs = await isar.localLogs
        .filter()
        .userIdEqualTo(userId)
        .exerciseKeyEqualTo(exerciseKey)
        .sortByCompletedAtDesc()
        .limit(limit)
        .findAll();
    
    return localLogs.map(_convertFromLocalLog).toList();
  }

  // ===== PR 관리 =====

  /// 개인 기록 확인
  Future<bool> _checkIfPersonalRecord(
    String userId,
    String exerciseKey,
    double estimated1RM,
  ) async {
    final isar = await _isarService.database;
    
    final bestLog = await isar.localLogs
        .filter()
        .userIdEqualTo(userId)
        .exerciseKeyEqualTo(exerciseKey)
        .sortByEstimated1RMDesc()
        .findFirst();
    
    if (bestLog == null) return true; // 첫 기록은 항상 PR
    
    return estimated1RM > (bestLog.estimated1RM ?? 0);
  }

  /// 사용자의 모든 PR 조회
  Future<Map<String, WorkoutLog>> getUserPRs(String userId) async {
    final isar = await _isarService.database;
    
    final prLogs = await isar.localLogs
        .filter()
        .userIdEqualTo(userId)
        .isPREqualTo(true)
        .findAll();
    
    // 운동별로 최고 기록만 유지
    final prMap = <String, WorkoutLog>{};
    
    for (final localLog in prLogs) {
      final log = _convertFromLocalLog(localLog);
      final existing = prMap[log.exerciseKey];
      
      if (existing == null || 
          (log.estimated1RM ?? 0) > (existing.estimated1RM ?? 0)) {
        prMap[log.exerciseKey] = log;
      }
    }
    
    return prMap;
  }

  // ===== 통계 및 분석 =====

  /// 최근 운동 요약 (AI 코치용)
  Future<RecentLogsSummary> getRecentLogsSummary(
    String userId, {
    int days = 7,
  }) async {
    final isar = await _isarService.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    // 최근 세션 수
    final recentSessions = await isar.localSessions
        .filter()
        .userIdEqualTo(userId)
        .dateGreaterThan(cutoffDate.subtract(const Duration(days: 1)))
        .statusEqualTo(SessionStatus.done.name)
        .findAll();
    
    // 최근 로그들
    final recentLogs = await isar.localLogs
        .filter()
        .userIdEqualTo(userId)
        .completedAtGreaterThan(cutoffDate.subtract(const Duration(days: 1)))
        .findAll();
    
    // 평균 RPE 계산
    final avgRpe = recentLogs.isEmpty 
        ? 0.0 
        : recentLogs.map((l) => l.rpe).reduce((a, b) => a + b) / recentLogs.length;
    
    // 근육군별 빈도 계산 (간소화된 매핑)
    final muscleGroupFreq = <String, int>{};
    for (final log in recentLogs) {
      final muscleGroup = _getMuscleGroupFromExercise(log.exerciseKey);
      muscleGroupFreq[muscleGroup] = (muscleGroupFreq[muscleGroup] ?? 0) + 1;
    }
    
    // 마지막 운동 날짜
    final lastWorkout = recentSessions.isNotEmpty
        ? recentSessions
            .map((s) => s.date)
            .reduce((a, b) => a.isAfter(b) ? a : b)
        : null;
    
    return RecentLogsSummary(
      totalSets: recentLogs.length,
      averageRPE: avgRpe,
      exerciseFrequency: muscleGroupFreq,
      lastWorkout: lastWorkout,
    );
  }

  /// 운동명에서 근육군 추출 (간소화된 매핑)
  String _getMuscleGroupFromExercise(String exerciseKey) {
    final key = exerciseKey.toLowerCase();
    
    if (key.contains('squat') || key.contains('leg')) return 'legs';
    if (key.contains('bench') || key.contains('press') || key.contains('push')) return 'chest';
    if (key.contains('row') || key.contains('pull')) return 'back';
    if (key.contains('shoulder') || key.contains('ohp')) return 'shoulders';
    if (key.contains('deadlift')) return 'posterior_chain';
    if (key.contains('curl') || key.contains('tricep')) return 'arms';
    
    return 'other';
  }

  // ===== 내부 헬퍼 메서드 =====

  /// 로컬 세션 저장
  Future<void> _saveSessionLocally(WorkoutSession session) async {
    final isar = await _isarService.database;
    
    final localSession = LocalSession()
      ..sessionId = session.id
      ..userId = session.userId
      ..date = session.date
      ..status = session.status.name
      ..planId = session.planId
      ..exercisesJson = jsonEncode(session.exerciseLogs.map((e) => e.toJson()).toList())
      ..startedAt = session.startedAt
      ..completedAt = session.completedAt
      ..durationMinutes = session.durationMinutes
      ..createdAt = session.createdAt
      ..updatedAt = session.updatedAt
      ..deviceId = session.deviceId
      ..conflicted = session.conflicted;
    
    await isar.writeTxn(() async {
      await isar.localSessions.put(localSession);
    });
  }

  /// 로컬 세션 업데이트
  Future<void> _updateSessionLocally(WorkoutSession session) async {
    await _saveSessionLocally(session); // Isar는 upsert를 자동 처리
  }

  /// 로컬 로그 저장
  Future<void> _saveLogLocally(WorkoutLog log) async {
    final isar = await _isarService.database;
    
    final localLog = LocalLog()
      ..logId = log.id
      ..userId = log.userId
      ..sessionId = log.sessionId
      ..exerciseKey = log.exerciseKey
      ..setIndex = log.setIndex
      ..weight = log.weight
      ..reps = log.reps
      ..rpe = log.rpe
      ..completedAt = log.completedAt
      ..note = log.note
      ..isPR = log.isPR
      ..estimated1RM = log.estimated1RM
      ..createdAt = log.createdAt
      ..updatedAt = log.updatedAt
      ..deviceId = log.deviceId
      ..conflicted = log.conflicted;
    
    await isar.writeTxn(() async {
      await isar.localLogs.put(localLog);
    });
  }

  /// 세션 동기화 예약
  Future<void> _scheduleSessionSync(WorkoutSession session, SyncOperation op) async {
    final isar = await _isarService.database;
    
    final pendingOp = PendingOperationIsar()
      ..operationId = 'session_${session.id}_${DateTime.now().millisecondsSinceEpoch}'
      ..op = op.name
      ..collection = 'sessions'
      ..payload = jsonEncode(session.toJson())
      ..createdAt = DateTime.now()
      ..retryCount = 0
      ..processed = false;
    
    await isar.writeTxn(() async {
      await isar.pendingOperationIsars.put(pendingOp);
    });
  }

  /// 로그 동기화 예약
  Future<void> _scheduleLogSync(WorkoutLog log, SyncOperation op) async {
    final isar = await _isarService.database;
    
    final pendingOp = PendingOperationIsar()
      ..operationId = 'log_${log.id}_${DateTime.now().millisecondsSinceEpoch}'
      ..op = op.name
      ..collection = 'logs'
      ..payload = jsonEncode(log.toJson())
      ..createdAt = DateTime.now()
      ..retryCount = 0
      ..processed = false;
    
    await isar.writeTxn(() async {
      await isar.pendingOperationIsars.put(pendingOp);
    });
  }

  /// 로컬 세션을 WorkoutSession으로 변환
  WorkoutSession _convertFromLocalSession(LocalSession local) {
    final exercises = (jsonDecode(local.exercisesJson) as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
    
    return WorkoutSession(
      id: local.sessionId,
      userId: local.userId,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      deviceId: local.deviceId,
      conflicted: local.conflicted,
      date: local.date,
      status: SessionStatus.values.firstWhere((s) => s.name == local.status),
      planId: local.planId,
      exerciseLogs: const [], // exercises was wrong, should be exerciseLogs
      startedAt: local.startedAt,
      completedAt: local.completedAt,
      durationMinutes: local.durationMinutes,
    );
  }

  /// 로컬 로그를 WorkoutLog로 변환
  WorkoutLog _convertFromLocalLog(LocalLog local) {
    return WorkoutLog(
      id: local.logId,
      userId: local.userId,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      deviceId: local.deviceId,
      conflicted: local.conflicted,
      sessionId: local.sessionId,
      exerciseKey: local.exerciseKey,
      setIndex: local.setIndex,
      weight: local.weight,
      reps: local.reps,
      rpe: local.rpe,
      completedAt: local.completedAt,
      note: local.note,
      isPR: local.isPR,
      estimated1RM: local.estimated1RM,
    );
  }

  /// 디바이스 ID 생성 (실제 구현에서는 device_info_plus 사용)
  Future<String> _getDeviceId() async {
    // 임시 구현 - 실제로는 고유한 디바이스 식별자를 사용
    return 'device_${DateTime.now().millisecondsSinceEpoch % 10000}';
  }
}