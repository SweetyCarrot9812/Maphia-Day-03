import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import '../models/isar_models.dart';
import '../models/workout_log.dart';
import '../models/user_profile.dart';
import '../models/workout_plan.dart';
import 'isar_service.dart';

/// 오프라인 우선 동기화 서비스
/// Outbox 패턴과 충돌 해결을 통한 양방향 동기화 구현
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IsarService _isarService;
  
  SyncService(this._isarService);

  /// 전체 동기화 프로세스 실행
  /// 1. Outbox 큐 처리 (로컬 → Firestore)
  /// 2. 원격 변경사항 가져오기 (Firestore → 로컬)
  /// 3. 충돌 해결
  Future<SyncResult> performSync(String userId) async {
    log('Starting sync for user: $userId');
    
    final stopwatch = Stopwatch()..start();
    var result = SyncResult();
    
    try {
      // 1단계: Outbox 큐 처리
      result = result.merge(await _processOutbox(userId));
      
      // 2단계: 원격 변경사항 동기화
      result = result.merge(await _syncFromFirestore(userId));
      
      // 3단계: 충돌 해결
      result = result.merge(await _resolveConflicts(userId));
      
      log('Sync completed in ${stopwatch.elapsedMilliseconds}ms');
      return result.copyWith(success: true);
      
    } catch (e, stack) {
      log('Sync failed: $e', error: e, stackTrace: stack);
      return result.copyWith(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Outbox 큐 처리 - 로컬 변경사항을 Firestore로 업로드
  Future<SyncResult> _processOutbox(String userId) async {
    final isar = await _isarService.database;
    final pendingOps = await isar.pendingOperationIsars
        .filter()
        .processedEqualTo(false)
        .sortByCreatedAt()
        .findAll();
    
    var successCount = 0;
    var failCount = 0;
    final failedOps = <String>[];
    
    for (final op in pendingOps) {
      try {
        await _processPendingOperation(op);
        
        // 성공한 작업은 완료 처리
        await isar.writeTxn(() async {
          op.processed = true;
          await isar.pendingOperationIsars.put(op);
        });
        
        successCount++;
        
      } catch (e) {
        log('Failed to process pending operation ${op.operationId}: $e');
        
        // 재시도 횟수 증가
        await isar.writeTxn(() async {
          op.retryCount++;
          op.lastAttemptAt = DateTime.now();
          op.errorMessage = e.toString();
          await isar.pendingOperationIsars.put(op);
        });
        
        failCount++;
        failedOps.add(op.operationId);
        
        // 3회 실패 시 에러 로깅만 하고 계속 진행
        if (op.retryCount >= 3) {
          log('Operation ${op.operationId} failed 3 times, marking as errored');
        }
      }
    }
    
    return SyncResult(
      outboxProcessed: successCount,
      outboxFailed: failCount,
      failedOperations: failedOps,
    );
  }

  /// 개별 Pending Operation 처리
  Future<void> _processPendingOperation(PendingOperationIsar op) async {
    final data = jsonDecode(op.payload) as Map<String, dynamic>;
    final docRef = _firestore.collection(op.collection).doc(data['id']);
    
    switch (op.op) {
      case 'UPSERT':
        await docRef.set(data, SetOptions(merge: true));
        break;
      case 'DELETE':
        await docRef.delete();
        break;
      default:
        throw Exception('Unknown operation: ${op.op}');
    }
  }

  /// Firestore에서 최근 변경사항 가져와서 로컬에 적용
  Future<SyncResult> _syncFromFirestore(String userId) async {
    final isar = await _isarService.database;
    var syncedCount = 0;
    var conflictCount = 0;
    final conflicts = <String>[];
    
    // 마지막 동기화 시점 가져오기 (구현 단순화를 위해 1시간 전으로 설정)
    final lastSync = DateTime.now().subtract(const Duration(hours: 1));
    
    // 각 컬렉션별로 동기화
    final collections = ['profiles', 'plans', 'sessions', 'logs'];
    
    for (final collection in collections) {
      final query = _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSync));
      
      final snapshot = await query.get();
      
      for (final doc in snapshot.docs) {
        final result = await _syncDocument(doc, collection);
        if (result.hasConflict) {
          conflictCount++;
          conflicts.add('${collection}/${doc.id}');
        } else {
          syncedCount++;
        }
      }
    }
    
    return SyncResult(
      remoteToLocalSynced: syncedCount,
      conflictsDetected: conflictCount,
      conflictedDocuments: conflicts,
    );
  }

  /// 개별 문서 동기화 및 충돌 감지
  Future<DocumentSyncResult> _syncDocument(
    QueryDocumentSnapshot doc, 
    String collection,
  ) async {
    final isar = await _isarService.database;
    final remoteData = doc.data() as Map<String, dynamic>;
    final remoteUpdatedAt = (remoteData['updatedAt'] as Timestamp).toDate();
    
    // 로컬 문서 찾기
    final localDoc = await _findLocalDocument(doc.id, collection);
    
    if (localDoc == null) {
      // 로컬에 없는 문서 - 새로 생성
      await _createLocalDocument(remoteData, collection);
      return DocumentSyncResult(synced: true);
    }
    
    final localUpdatedAt = _getLocalUpdatedAt(localDoc);
    
    // 충돌 감지: 로컬과 원격 모두 수정된 경우
    if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      // 로컬이 더 최신 - 충돌 표시하고 원격으로 푸시 예약
      await _markAsConflicted(localDoc, collection);
      await _scheduleRemoteUpdate(localDoc, collection);
      return DocumentSyncResult(hasConflict: true);
    } else {
      // 원격이 더 최신 - 로컬 업데이트
      await _updateLocalDocument(localDoc, remoteData, collection);
      return DocumentSyncResult(synced: true);
    }
  }

  /// 로컬 문서 찾기
  Future<dynamic> _findLocalDocument(String docId, String collection) async {
    final isar = await _isarService.database;
    
    switch (collection) {
      case 'profiles':
        return await isar.localUserProfiles
            .filter()
            .userIdEqualTo(docId)
            .findFirst();
      case 'sessions':
        return await isar.localSessions
            .filter()
            .sessionIdEqualTo(docId)
            .findFirst();
      case 'logs':
        return await isar.localLogs
            .filter()
            .logIdEqualTo(docId)
            .findFirst();
      default:
        return null;
    }
  }

  /// 로컬 문서의 updatedAt 가져오기
  DateTime _getLocalUpdatedAt(dynamic localDoc) {
    if (localDoc is LocalUserProfile) return localDoc.updatedAt;
    if (localDoc is LocalSession) return localDoc.updatedAt;
    if (localDoc is LocalLog) return localDoc.updatedAt;
    throw Exception('Unknown document type: ${localDoc.runtimeType}');
  }

  /// 로컬 문서를 충돌 상태로 표시
  Future<void> _markAsConflicted(dynamic localDoc, String collection) async {
    final isar = await _isarService.database;
    
    await isar.writeTxn(() async {
      if (localDoc is LocalUserProfile) {
        localDoc.conflicted = true;
        await isar.localUserProfiles.put(localDoc);
      } else if (localDoc is LocalSession) {
        localDoc.conflicted = true;
        await isar.localSessions.put(localDoc);
      } else if (localDoc is LocalLog) {
        localDoc.conflicted = true;
        await isar.localLogs.put(localDoc);
      }
    });
  }

  /// 원격 업데이트 예약
  Future<void> _scheduleRemoteUpdate(dynamic localDoc, String collection) async {
    final isar = await _isarService.database;
    final payload = _serializeLocalDocument(localDoc);
    
    final pendingOp = PendingOperationIsar()
      ..operationId = '${collection}_${DateTime.now().millisecondsSinceEpoch}'
      ..op = 'UPSERT'
      ..collection = collection
      ..payload = jsonEncode(payload)
      ..createdAt = DateTime.now()
      ..retryCount = 0
      ..processed = false;
    
    await isar.writeTxn(() async {
      await isar.pendingOperationIsars.put(pendingOp);
    });
  }

  /// 로컬 문서 직렬화
  Map<String, dynamic> _serializeLocalDocument(dynamic localDoc) {
    if (localDoc is LocalUserProfile) {
      return {
        'id': localDoc.userId,
        'userId': localDoc.userId,
        'name': localDoc.name,
        'sex': localDoc.sex,
        'heightCm': localDoc.heightCm,
        'weightKg': localDoc.weightKg,
        'unit': localDoc.unit,
        'injuries': jsonDecode(localDoc.injuriesJson),
        'preferredDays': jsonDecode(localDoc.preferredDaysJson),
        'equipment': jsonDecode(localDoc.equipmentJson),
        'rpeMin': localDoc.rpeMin,
        'rpeMax': localDoc.rpeMax,
        'createdAt': Timestamp.fromDate(localDoc.createdAt),
        'updatedAt': Timestamp.fromDate(localDoc.updatedAt),
        'deviceId': localDoc.deviceId,
      };
    }
    // 다른 문서 타입들도 필요시 추가...
    throw Exception('Unknown document type for serialization');
  }

  /// 로컬 문서 생성
  Future<void> _createLocalDocument(
    Map<String, dynamic> remoteData, 
    String collection,
  ) async {
    final isar = await _isarService.database;
    
    await isar.writeTxn(() async {
      switch (collection) {
        case 'profiles':
          final profile = _createLocalUserProfile(remoteData);
          await isar.localUserProfiles.put(profile);
          break;
        case 'sessions':
          final session = _createLocalSession(remoteData);
          await isar.localSessions.put(session);
          break;
        case 'logs':
          final log = _createLocalLog(remoteData);
          await isar.localLogs.put(log);
          break;
      }
    });
  }

  /// 로컬 문서 업데이트
  Future<void> _updateLocalDocument(
    dynamic localDoc,
    Map<String, dynamic> remoteData,
    String collection,
  ) async {
    final isar = await _isarService.database;
    
    await isar.writeTxn(() async {
      if (localDoc is LocalUserProfile) {
        _updateLocalUserProfileFromRemote(localDoc, remoteData);
        await isar.localUserProfiles.put(localDoc);
      } else if (localDoc is LocalSession) {
        _updateLocalSessionFromRemote(localDoc, remoteData);
        await isar.localSessions.put(localDoc);
      } else if (localDoc is LocalLog) {
        _updateLocalLogFromRemote(localDoc, remoteData);
        await isar.localLogs.put(localDoc);
      }
    });
  }

  /// UserProfile 로컬 객체 생성
  LocalUserProfile _createLocalUserProfile(Map<String, dynamic> data) {
    return LocalUserProfile()
      ..userId = data['userId']
      ..name = data['name']
      ..sex = data['sex']
      ..heightCm = data['heightCm']
      ..weightKg = data['weightKg'].toDouble()
      ..unit = data['unit']
      ..injuriesJson = jsonEncode(data['injuries'] ?? [])
      ..preferredDaysJson = jsonEncode(data['preferredDays'] ?? [])
      ..equipmentJson = jsonEncode(data['equipment'] ?? [])
      ..rpeMin = data['rpeMin'] ?? 6
      ..rpeMax = data['rpeMax'] ?? 9
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..deviceId = data['deviceId']
      ..conflicted = false;
  }

  /// LocalSession 객체 생성
  LocalSession _createLocalSession(Map<String, dynamic> data) {
    return LocalSession()
      ..sessionId = data['id']
      ..userId = data['userId']
      ..date = (data['date'] as Timestamp).toDate()
      ..status = data['status']
      ..planId = data['planId']
      ..exercisesJson = jsonEncode(data['exercises'] ?? [])
      ..startedAt = data['startedAt'] != null 
          ? (data['startedAt'] as Timestamp).toDate() 
          : null
      ..completedAt = data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null
      ..durationMinutes = data['durationMinutes']
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..deviceId = data['deviceId']
      ..conflicted = false;
  }

  /// LocalLog 객체 생성
  LocalLog _createLocalLog(Map<String, dynamic> data) {
    return LocalLog()
      ..logId = data['id']
      ..userId = data['userId']
      ..sessionId = data['sessionId']
      ..exerciseKey = data['exerciseKey']
      ..setIndex = data['setIndex']
      ..weight = data['weight'].toDouble()
      ..reps = data['reps']
      ..rpe = data['rpe']
      ..completedAt = (data['completedAt'] as Timestamp).toDate()
      ..note = data['note']
      ..isPR = data['isPR'] ?? false
      ..estimated1RM = data['estimated1RM']?.toDouble()
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..deviceId = data['deviceId']
      ..conflicted = false;
  }

  /// LocalUserProfile 원격 데이터로 업데이트
  void _updateLocalUserProfileFromRemote(
    LocalUserProfile local, 
    Map<String, dynamic> remote,
  ) {
    local.name = remote['name'];
    local.sex = remote['sex'];
    local.heightCm = remote['heightCm'];
    local.weightKg = remote['weightKg'].toDouble();
    local.unit = remote['unit'];
    local.injuriesJson = jsonEncode(remote['injuries'] ?? []);
    local.preferredDaysJson = jsonEncode(remote['preferredDays'] ?? []);
    local.equipmentJson = jsonEncode(remote['equipment'] ?? []);
    local.rpeMin = remote['rpeMin'] ?? 6;
    local.rpeMax = remote['rpeMax'] ?? 9;
    local.updatedAt = (remote['updatedAt'] as Timestamp).toDate();
    local.conflicted = false;
  }

  /// LocalSession 원격 데이터로 업데이트
  void _updateLocalSessionFromRemote(
    LocalSession local, 
    Map<String, dynamic> remote,
  ) {
    local.date = (remote['date'] as Timestamp).toDate();
    local.status = remote['status'];
    local.planId = remote['planId'];
    local.exercisesJson = jsonEncode(remote['exercises'] ?? []);
    local.startedAt = remote['startedAt'] != null 
        ? (remote['startedAt'] as Timestamp).toDate() 
        : null;
    local.completedAt = remote['completedAt'] != null 
        ? (remote['completedAt'] as Timestamp).toDate() 
        : null;
    local.durationMinutes = remote['durationMinutes'];
    local.updatedAt = (remote['updatedAt'] as Timestamp).toDate();
    local.conflicted = false;
  }

  /// LocalLog 원격 데이터로 업데이트
  void _updateLocalLogFromRemote(
    LocalLog local, 
    Map<String, dynamic> remote,
  ) {
    local.sessionId = remote['sessionId'];
    local.exerciseKey = remote['exerciseKey'];
    local.setIndex = remote['setIndex'];
    local.weight = remote['weight'].toDouble();
    local.reps = remote['reps'];
    local.rpe = remote['rpe'];
    local.completedAt = (remote['completedAt'] as Timestamp).toDate();
    local.note = remote['note'];
    local.isPR = remote['isPR'] ?? false;
    local.estimated1RM = remote['estimated1RM']?.toDouble();
    local.updatedAt = (remote['updatedAt'] as Timestamp).toDate();
    local.conflicted = false;
  }

  /// 충돌 해결 프로세스
  Future<SyncResult> _resolveConflicts(String userId) async {
    final isar = await _isarService.database;
    
    // 충돌 상태인 문서들 찾기
    final conflictedProfiles = await isar.localUserProfiles
        .filter()
        .conflictedEqualTo(true)
        .findAll();
    
    final conflictedSessions = await isar.localSessions
        .filter()
        .conflictedEqualTo(true)
        .findAll();
    
    final conflictedLogs = await isar.localLogs
        .filter()
        .conflictedEqualTo(true)
        .findAll();
    
    var resolvedCount = 0;
    
    // 기본 충돌 해결 전략: 로컬 우선 (사용자가 최근에 수정한 것을 우선시)
    for (final profile in conflictedProfiles) {
      await _scheduleRemoteUpdate(profile, 'profiles');
      profile.conflicted = false;
      resolvedCount++;
    }
    
    for (final session in conflictedSessions) {
      await _scheduleRemoteUpdate(session, 'sessions');
      session.conflicted = false;
      resolvedCount++;
    }
    
    for (final log in conflictedLogs) {
      await _scheduleRemoteUpdate(log, 'logs');
      log.conflicted = false;
      resolvedCount++;
    }
    
    // 충돌 상태 업데이트
    await isar.writeTxn(() async {
      await isar.localUserProfiles.putAll(conflictedProfiles);
      await isar.localSessions.putAll(conflictedSessions);
      await isar.localLogs.putAll(conflictedLogs);
    });
    
    return SyncResult(conflictsResolved: resolvedCount);
  }
}

/// 동기화 결과 클래스
class SyncResult {
  final bool success;
  final String? error;
  final int outboxProcessed;
  final int outboxFailed;
  final int remoteToLocalSynced;
  final int conflictsDetected;
  final int conflictsResolved;
  final List<String> failedOperations;
  final List<String> conflictedDocuments;
  
  const SyncResult({
    this.success = false,
    this.error,
    this.outboxProcessed = 0,
    this.outboxFailed = 0,
    this.remoteToLocalSynced = 0,
    this.conflictsDetected = 0,
    this.conflictsResolved = 0,
    this.failedOperations = const [],
    this.conflictedDocuments = const [],
  });
  
  SyncResult copyWith({
    bool? success,
    String? error,
    int? outboxProcessed,
    int? outboxFailed,
    int? remoteToLocalSynced,
    int? conflictsDetected,
    int? conflictsResolved,
    List<String>? failedOperations,
    List<String>? conflictedDocuments,
  }) {
    return SyncResult(
      success: success ?? this.success,
      error: error ?? this.error,
      outboxProcessed: outboxProcessed ?? this.outboxProcessed,
      outboxFailed: outboxFailed ?? this.outboxFailed,
      remoteToLocalSynced: remoteToLocalSynced ?? this.remoteToLocalSynced,
      conflictsDetected: conflictsDetected ?? this.conflictsDetected,
      conflictsResolved: conflictsResolved ?? this.conflictsResolved,
      failedOperations: failedOperations ?? this.failedOperations,
      conflictedDocuments: conflictedDocuments ?? this.conflictedDocuments,
    );
  }
  
  SyncResult merge(SyncResult other) {
    return SyncResult(
      success: success && other.success,
      error: error ?? other.error,
      outboxProcessed: outboxProcessed + other.outboxProcessed,
      outboxFailed: outboxFailed + other.outboxFailed,
      remoteToLocalSynced: remoteToLocalSynced + other.remoteToLocalSynced,
      conflictsDetected: conflictsDetected + other.conflictsDetected,
      conflictsResolved: conflictsResolved + other.conflictsResolved,
      failedOperations: [...failedOperations, ...other.failedOperations],
      conflictedDocuments: [...conflictedDocuments, ...other.conflictedDocuments],
    );
  }
  
  @override
  String toString() {
    return 'SyncResult(success: $success, outbox: $outboxProcessed/$outboxFailed, '
           'synced: $remoteToLocalSynced, conflicts: $conflictsDetected/$conflictsResolved)';
  }
}

/// 개별 문서 동기화 결과
class DocumentSyncResult {
  final bool synced;
  final bool hasConflict;
  
  const DocumentSyncResult({
    this.synced = false,
    this.hasConflict = false,
  });
}