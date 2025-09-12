import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import '../models/user_profile.dart' show UserProfile, UserMetrics, UserWorkoutStats;
import '../models/isar_models.dart';
import '../models/workout_log.dart';
import '../models/workout_plan.dart';
import '../models/base_model.dart'; // SessionStatus, Sex, WeightUnit
import '../services/isar_service.dart';
import '../services/sync_service.dart';

/// 사용자 데이터 Repository
/// 프로필, 메트릭스, 설정 관리를 담당
class UserRepository {
  final IsarService _isarService;
  final SyncService _syncService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserRepository(this._isarService, this._syncService);

  // ===== 프로필 관리 =====

  /// 사용자 프로필 생성/업데이트
  Future<UserProfile> saveProfile(UserProfile profile) async {
    final now = DateTime.now();
    final updatedProfile = profile.copyWith(
      updatedAt: now,
      createdAt: profile.createdAt == DateTime.fromMillisecondsSinceEpoch(0) 
          ? now 
          : profile.createdAt,
    );

    // 1. 로컬에 저장
    await _saveProfileLocally(updatedProfile);
    
    // 2. 원격 동기화 예약
    await _scheduleProfileSync(updatedProfile, SyncOperation.upsert);
    
    log('Saved user profile: ${profile.id}');
    return updatedProfile;
  }

  /// 사용자 프로필 조회
  Future<UserProfile?> getProfile(String userId) async {
    final isar = await _isarService.database;
    
    final localProfile = await isar.localUserProfiles
        .filter()
        .userIdEqualTo(userId)
        .findFirst();
    
    if (localProfile == null) return null;
    
    return _convertFromLocalProfile(localProfile);
  }

  /// 프로필 존재 여부 확인
  Future<bool> hasProfile(String userId) async {
    final profile = await getProfile(userId);
    return profile != null;
  }

  // ===== 메트릭스 관리 =====

  /// 사용자 메트릭스 업데이트
  Future<UserMetrics> updateMetrics({
    required String userId,
    Map<String, double>? oneRM,
    int? fatigueScore,
    double? sleepHours,
  }) async {
    final isar = await _isarService.database;
    final now = DateTime.now();
    
    // 기존 메트릭스 조회
    var localMetrics = await isar.localUserMetrics
        .filter()
        .userIdEqualTo(userId)
        .findFirst();
    
    // 없으면 새로 생성
    localMetrics ??= LocalUserMetrics()
      ..userId = userId
      ..oneRMJson = '{}'
      ..fatigueScore = 5
      ..sleepHours = 8.0
      ..createdAt = now
      ..updatedAt = now
      ..deviceId = await _getDeviceId()
      ..conflicted = false;
    
    // 업데이트
    if (oneRM != null) {
      localMetrics.oneRMJson = jsonEncode(oneRM);
    }
    if (fatigueScore != null) {
      localMetrics.fatigueScore = fatigueScore;
    }
    if (sleepHours != null) {
      localMetrics.sleepHours = sleepHours;
    }
    
    localMetrics.updatedAt = now;
    
    // 로컬 저장
    await isar.writeTxn(() async {
      await isar.localUserMetrics.put(localMetrics!);
    });
    
    final metrics = _convertFromLocalMetrics(localMetrics);
    
    // 원격 동기화 예약
    await _scheduleMetricsSync(metrics, SyncOperation.upsert);
    
    log('Updated user metrics: $userId');
    return metrics;
  }

  /// 사용자 메트릭스 조회
  Future<UserMetrics?> getMetrics(String userId) async {
    final isar = await _isarService.database;
    
    final localMetrics = await isar.localUserMetrics
        .filter()
        .userIdEqualTo(userId)
        .findFirst();
    
    if (localMetrics == null) return null;
    
    return _convertFromLocalMetrics(localMetrics);
  }

  /// 1RM 자동 업데이트 (PR 달성 시 호출)
  Future<void> updateOneRMFromPR(String userId, String exerciseKey, double newOneRM) async {
    final currentMetrics = await getMetrics(userId);
    final currentOneRM = currentMetrics?.oneRM ?? <String, double>{};
    
    // 기존 1RM보다 높은 경우만 업데이트
    final existingOneRM = currentOneRM[exerciseKey] ?? 0.0;
    if (newOneRM > existingOneRM) {
      currentOneRM[exerciseKey] = newOneRM;
      
      await updateMetrics(
        userId: userId,
        oneRM: currentOneRM,
      );
      
      // PR 날짜도 업데이트
      await _updateLastPRDate(userId);
      
      log('Updated 1RM for $exerciseKey: $existingOneRM -> $newOneRM');
    }
  }

  /// 마지막 PR 달성 날짜 업데이트
  Future<void> _updateLastPRDate(String userId) async {
    final isar = await _isarService.database;
    
    final localMetrics = await isar.localUserMetrics
        .filter()
        .userIdEqualTo(userId)
        .findFirst();
    
    if (localMetrics != null) {
      localMetrics.lastPRAt = DateTime.now();
      localMetrics.updatedAt = DateTime.now();
      
      await isar.writeTxn(() async {
        await isar.localUserMetrics.put(localMetrics);
      });
    }
  }

  // ===== 운동 계획 관리 =====

  /// 사용자의 활성 운동 계획 조회
  Future<List<WorkoutPlan>> getActiveWorkoutPlans(String userId) async {
    // 실제 구현에서는 별도의 WorkoutPlanRepository를 사용하거나
    // 여기서 Firestore 쿼리를 직접 실행
    try {
      final snapshot = await _firestore
          .collection('plans')
          .where('userId', isEqualTo: userId)
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .orderBy('startDate', descending: true)
          .limit(10)
          .get();
      
      return snapshot.docs
          .map((doc) => WorkoutPlan.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      log('Failed to load workout plans: $e');
      return [];
    }
  }

  // ===== 사용자 통계 =====

  /// 사용자 운동 통계 조회
  Future<UserWorkoutStats> getWorkoutStats(String userId) async {
    final isar = await _isarService.database;
    
    // 총 세션 수
    final totalSessions = await isar.localSessions
        .filter()
        .userIdEqualTo(userId)
        .statusEqualTo(SessionStatus.done.name)
        .count();
    
    // 이번 주 세션 수
    final weekStart = DateTime.now().subtract(Duration(days: 7));
    final thisWeekSessions = await isar.localSessions
        .filter()
        .userIdEqualTo(userId)
        .statusEqualTo(SessionStatus.done.name)
        .dateGreaterThan(weekStart.subtract(const Duration(days: 1)))
        .count();
    
    // TODO: 향후 필요시 세트 수, PR 수 계산 구현
    
    // 총 운동 시간 (분)
    final sessions = await isar.localSessions
        .filter()
        .userIdEqualTo(userId)
        .statusEqualTo(SessionStatus.done.name)
        .findAll();
    
    final totalMinutes = sessions
        .where((s) => s.durationMinutes != null)
        .fold<int>(0, (sum, s) => sum + s.durationMinutes!);
    
    // 평균 RPE 계산
    final logs = await isar.localLogs
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    
    final avgRPE = logs.isEmpty 
        ? 0.0 
        : logs.fold<int>(0, (sum, log) => sum + log.rpe) / logs.length;
    
    // 현재 스트릭 계산
    final currentStreak = await _calculateCurrentStreak(userId);
    
    return UserWorkoutStats(
      userId: userId,
      totalSessions: totalSessions,
      thisWeekSessions: thisWeekSessions,
      thisMonthSessions: 0, // TODO: Calculate this month sessions
      averageRPE: avgRPE,
      totalMinutes: totalMinutes,
      longestStreak: currentStreak, // TODO: Calculate longest streak
      currentStreak: currentStreak,
      achievements: [], // TODO: Calculate achievements
      bestLifts: {}, // TODO: Calculate best lifts
    );
  }

  /// 현재 연속 운동 일수 계산
  Future<int> _calculateCurrentStreak(String userId) async {
    final isar = await _isarService.database;
    
    final sessions = await isar.localSessions
        .filter()
        .userIdEqualTo(userId)
        .statusEqualTo(SessionStatus.done.name)
        .sortByDateDesc()
        .findAll();
    
    if (sessions.isEmpty) return 0;
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final session in sessions) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      
      if (lastDate == null) {
        // 첫 번째 세션
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        
        // 오늘이나 어제 운동했다면 스트릭 시작
        if (sessionDate.isAtSameMomentAs(todayDate) || 
            sessionDate.isAtSameMomentAs(todayDate.subtract(const Duration(days: 1)))) {
          streak = 1;
          lastDate = sessionDate;
        } else {
          break; // 너무 오래전이면 스트릭 중단
        }
      } else {
        // 연속된 날짜인지 확인
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (sessionDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          lastDate = sessionDate;
        } else {
          break; // 연속되지 않으면 스트릭 중단
        }
      }
    }
    
    return streak;
  }

  // ===== 내부 헬퍼 메서드 =====

  /// 로컬 프로필 저장
  Future<void> _saveProfileLocally(UserProfile profile) async {
    final isar = await _isarService.database;
    
    final localProfile = LocalUserProfile()
      ..userId = profile.id
      ..name = profile.name
      ..sex = profile.sex.name
      ..heightCm = profile.heightCm
      ..weightKg = profile.weightKg
      ..unit = profile.unit.name
      ..injuriesJson = jsonEncode(profile.injuries)
      ..preferredDaysJson = jsonEncode(profile.preferredDays)
      ..equipmentJson = jsonEncode(profile.equipment)
      ..rpeMin = profile.rpeMin
      ..rpeMax = profile.rpeMax
      ..createdAt = profile.createdAt
      ..updatedAt = profile.updatedAt
      ..deviceId = profile.deviceId
      ..conflicted = profile.conflicted;
    
    await isar.writeTxn(() async {
      await isar.localUserProfiles.put(localProfile);
    });
  }

  /// 프로필 동기화 예약
  Future<void> _scheduleProfileSync(UserProfile profile, SyncOperation op) async {
    final isar = await _isarService.database;
    
    final pendingOp = PendingOperationIsar()
      ..operationId = 'profile_${profile.id}_${DateTime.now().millisecondsSinceEpoch}'
      ..op = op.name
      ..collection = 'profiles'
      ..payload = jsonEncode(profile.toJson())
      ..createdAt = DateTime.now()
      ..retryCount = 0
      ..processed = false;
    
    await isar.writeTxn(() async {
      await isar.pendingOperationIsars.put(pendingOp);
    });
  }

  /// 메트릭스 동기화 예약
  Future<void> _scheduleMetricsSync(UserMetrics metrics, SyncOperation op) async {
    final isar = await _isarService.database;
    
    final data = {
      'id': metrics.id,
      'userId': metrics.userId,
      'oneRM': metrics.oneRM,
      'fatigueScore': metrics.fatigueScore,
      'sleepHours': metrics.sleepHours,
      'lastPRAt': metrics.lastPRAt?.toIso8601String(),
      'createdAt': metrics.createdAt.toIso8601String(),
      'updatedAt': metrics.updatedAt.toIso8601String(),
      'deviceId': metrics.deviceId,
    };
    
    final pendingOp = PendingOperationIsar()
      ..operationId = 'metrics_${metrics.id}_${DateTime.now().millisecondsSinceEpoch}'
      ..op = op.name
      ..collection = 'metrics'
      ..payload = jsonEncode(data)
      ..createdAt = DateTime.now()
      ..retryCount = 0
      ..processed = false;
    
    await isar.writeTxn(() async {
      await isar.pendingOperationIsars.put(pendingOp);
    });
  }

  /// 로컬 프로필을 UserProfile로 변환
  UserProfile _convertFromLocalProfile(LocalUserProfile local) {
    return UserProfile(
      id: local.userId,
      userId: local.userId,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      deviceId: local.deviceId,
      conflicted: local.conflicted,
      name: local.name,
      sex: Sex.values.firstWhere((s) => s.name == local.sex),
      heightCm: local.heightCm,
      weightKg: local.weightKg,
      unit: WeightUnit.values.firstWhere((u) => u.name == local.unit),
      injuries: List<String>.from(jsonDecode(local.injuriesJson)),
      preferredDays: List<String>.from(jsonDecode(local.preferredDaysJson)),
      equipment: List<String>.from(jsonDecode(local.equipmentJson)),
      rpeMin: local.rpeMin,
      rpeMax: local.rpeMax,
    );
  }

  /// 로컬 메트릭스를 UserMetrics로 변환
  UserMetrics _convertFromLocalMetrics(LocalUserMetrics local) {
    final oneRMMap = Map<String, double>.from(
      jsonDecode(local.oneRMJson).map((k, v) => MapEntry(k as String, (v as num).toDouble()))
    );
    
    return UserMetrics(
      id: local.userId,
      userId: local.userId,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      deviceId: local.deviceId,
      conflicted: false,
      oneRM: oneRMMap,
      fatigueScore: local.fatigueScore,
      sleepHours: local.sleepHours,
      lastPRAt: local.lastPRAt,
    );
  }

  /// 디바이스 ID 생성
  Future<String> _getDeviceId() async {
    return 'device_${DateTime.now().millisecondsSinceEpoch % 10000}';
  }
}

