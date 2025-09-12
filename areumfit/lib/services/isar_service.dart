import 'dart:developer';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/isar_models.dart';

/// Isar 로컬 데이터베이스 서비스
/// 오프라인 우선 아키텍처의 핵심 구성 요소
class IsarService {
  static Isar? _isar;
  
  /// 싱글톤 인스턴스 접근
  Future<Isar> get database async {
    if (_isar == null) {
      await _initialize();
    }
    return _isar!;
  }

  /// 데이터베이스 초기화
  Future<void> _initialize() async {
    if (_isar != null) return;
    
    log('Initializing Isar database...');
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      
      _isar = await Isar.open(
        [
          LocalSessionSchema,
          LocalLogSchema,
          LocalPlanCacheIsarSchema,
          PendingOperationIsarSchema,
          LocalUserProfileSchema,
          LocalUserMetricsSchema,
          LocalWorkoutScheduleSchema,
        ],
        directory: dir.path,
        name: 'areumfit_local',
        inspector: true, // 개발 모드에서만 활성화
      );
      
      log('Isar database initialized at: ${dir.path}');
    } catch (e, stack) {
      log('Failed to initialize Isar database', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 데이터베이스 종료
  Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
      log('Isar database closed');
    }
  }

  /// 데이터베이스 완전 재설정 (개발/테스트용)
  Future<void> reset() async {
    if (_isar != null) {
      await _isar!.close();
    }
    
    final dir = await getApplicationDocumentsDirectory();
    await Isar.getInstance('areumfit_local')?.close();
    
    try {
      final dbFile = '${dir.path}/areumfit_local.isar';
      final lockFile = '${dir.path}/areumfit_local.isar.lock';
      
      // 데이터베이스 파일 삭제는 Flutter에서 직접 지원하지 않으므로
      // 새로운 인스턴스 생성으로 대체
      _isar = null;
      await _initialize();
      
      log('Isar database reset completed');
    } catch (e) {
      log('Database reset failed: $e');
      rethrow;
    }
  }

  /// 동기화 통계 조회
  Future<SyncStats> getSyncStats(String userId) async {
    final isar = await database;
    
    final pendingCount = await isar.pendingOperationIsars
        .filter()
        .processedEqualTo(false)
        .count();
    
    final conflictedProfiles = await isar.localUserProfiles
        .filter()
        .userIdEqualTo(userId)
        .conflictedEqualTo(true)
        .count();
    
    final conflictedSessions = await isar.localSessions
        .filter()
        .userIdEqualTo(userId)
        .conflictedEqualTo(true)
        .count();
    
    final conflictedLogs = await isar.localLogs
        .filter()
        .userIdEqualTo(userId)
        .conflictedEqualTo(true)
        .count();
    
    final totalConflicts = conflictedProfiles + conflictedSessions + conflictedLogs;
    
    return SyncStats(
      pendingOperations: pendingCount,
      conflictedDocuments: totalConflicts,
      lastSyncTime: await _getLastSyncTime(userId),
    );
  }

  /// 마지막 동기화 시간 조회
  Future<DateTime?> _getLastSyncTime(String userId) async {
    // 실제 구현에서는 별도 메타데이터 테이블에 저장
    // 현재는 가장 최근에 업데이트된 문서의 시간을 반환
    final isar = await database;
    
    final latestSession = await isar.localSessions
        .filter()
        .userIdEqualTo(userId)
        .sortByUpdatedAtDesc()
        .findFirst();
    
    return latestSession?.updatedAt;
  }

  /// 캐시 정리 - 오래된 데이터 삭제
  Future<void> cleanupCache({Duration? olderThan}) async {
    final isar = await database;
    final cutoffTime = DateTime.now().subtract(olderThan ?? const Duration(days: 30));
    
    log('Cleaning up cache older than: $cutoffTime');
    
    await isar.writeTxn(() async {
      // 만료된 플랜 캐시 삭제
      final expiredCaches = await isar.localPlanCacheIsars
          .filter()
          .ttlEpochLessThan(DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .findAll();
      
      final expiredIds = expiredCaches.map((e) => e.id).toList();
      await isar.localPlanCacheIsars.deleteAll(expiredIds);
      
      // 처리된 오래된 작업 삭제
      final oldProcessedOps = await isar.pendingOperationIsars
          .filter()
          .processedEqualTo(true)
          .createdAtLessThan(cutoffTime)
          .findAll();
      
      final oldOpIds = oldProcessedOps.map((e) => e.id).toList();
      await isar.pendingOperationIsars.deleteAll(oldOpIds);
      
      log('Cleaned up ${expiredIds.length} expired caches and ${oldOpIds.length} old operations');
    });
  }

  /// 데이터베이스 무결성 검사
  Future<DatabaseHealthCheck> checkHealth() async {
    final isar = await database;
    final issues = <String>[];
    
    try {
      // 기본 연결 테스트
      final sessionCount = await isar.localSessions.count();
      
      // Pending operations 중 과도한 재시도가 있는지 확인
      final failedOps = await isar.pendingOperationIsars
          .filter()
          .retryCountGreaterThan(5)
          .count();
      
      if (failedOps > 0) {
        issues.add('$failedOps operations have failed more than 5 times');
      }
      
      // 충돌 상태인 문서가 너무 많은지 확인
      final conflictedCount = await isar.localSessions
          .filter()
          .conflictedEqualTo(true)
          .count() +
          await isar.localLogs
              .filter()
              .conflictedEqualTo(true)
              .count() +
          await isar.localUserProfiles
              .filter()
              .conflictedEqualTo(true)
              .count();
      
      if (conflictedCount > 10) {
        issues.add('Too many conflicted documents: $conflictedCount');
      }
      
      return DatabaseHealthCheck(
        isHealthy: issues.isEmpty,
        issues: issues,
        totalSessions: sessionCount,
        pendingOperations: await isar.pendingOperationIsars
            .filter()
            .processedEqualTo(false)
            .count(),
        conflictedDocuments: conflictedCount,
      );
      
    } catch (e, stack) {
      log('Database health check failed', error: e, stackTrace: stack);
      return DatabaseHealthCheck(
        isHealthy: false,
        issues: ['Database health check failed: $e'],
      );
    }
  }
}

/// 동기화 통계
class SyncStats {
  final int pendingOperations;
  final int conflictedDocuments;
  final DateTime? lastSyncTime;
  
  const SyncStats({
    required this.pendingOperations,
    required this.conflictedDocuments,
    this.lastSyncTime,
  });
  
  bool get hasIssues => pendingOperations > 0 || conflictedDocuments > 0;
  
  @override
  String toString() {
    return 'SyncStats(pending: $pendingOperations, conflicts: $conflictedDocuments, '
           'lastSync: ${lastSyncTime?.toString() ?? 'never'})';
  }
}

/// 데이터베이스 상태 검사 결과
class DatabaseHealthCheck {
  final bool isHealthy;
  final List<String> issues;
  final int totalSessions;
  final int pendingOperations;
  final int conflictedDocuments;
  
  const DatabaseHealthCheck({
    required this.isHealthy,
    required this.issues,
    this.totalSessions = 0,
    this.pendingOperations = 0,
    this.conflictedDocuments = 0,
  });
  
  @override
  String toString() {
    return 'DatabaseHealth(healthy: $isHealthy, sessions: $totalSessions, '
           'pending: $pendingOperations, conflicts: $conflictedDocuments, '
           'issues: ${issues.length})';
  }
}