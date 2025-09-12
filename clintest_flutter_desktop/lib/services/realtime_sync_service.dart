import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../shared/models/ai_models.dart';

/// 실시간 동기화 서비스 v3.1
/// Firestore onSnapshot + 오프라인 큐 + 충돌 해결
class RealtimeSyncService {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();
  
  // 오프라인 큐
  final List<SyncOperation> _offlineQueue = [];
  final Map<String, StreamSubscription> _activeListeners = {};
  
  bool _isOnline = true;
  late final StreamController<SyncEvent> _syncEventController;

  RealtimeSyncService({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _syncEventController = StreamController<SyncEvent>.broadcast();
    _setupConnectivityListener();
  }

  Stream<SyncEvent> get syncEvents => _syncEventController.stream;

  /// 세션 시작
  Future<String> startSession({
    required String userId,
    required String deviceId,
    required String subject,
  }) async {
    final sessionId = _uuid.v4();
    final session = SessionInfo(
      sessionId: sessionId,
      userId: userId,
      deviceId: deviceId,
      subject: subject,
      startedAt: DateTime.now(),
      status: SessionStatus.active,
      lastEventAt: DateTime.now(),
    );

    try {
      await _firestore
          .collection('sessions')
          .doc(sessionId)
          .set(session.toJson());

      // 실시간 리스너 시작
      _startSessionListener(sessionId);
      
      _syncEventController.add(SyncEvent.sessionStarted(sessionId));
      return sessionId;
      
    } catch (e) {
      if (!_isOnline) {
        // 오프라인 큐에 추가
        _offlineQueue.add(SyncOperation.createSession(session));
        _syncEventController.add(SyncEvent.sessionStarted(sessionId));
        return sessionId;
      }
      rethrow;
    }
  }

  /// 세션 종료
  Future<void> finishSession(String sessionId) async {
    final operation = SyncOperation.updateSession(
      sessionId,
      {'status': SessionStatus.finished.name, 'lastEventAt': FieldValue.serverTimestamp()},
    );

    try {
      await _executeOperation(operation);
      _stopSessionListener(sessionId);
      _syncEventController.add(SyncEvent.sessionFinished(sessionId));
    } catch (e) {
      _addToOfflineQueue(operation);
    }
  }

  /// 답안 제출/업데이트
  Future<void> submitAnswer({
    required String sessionId,
    required String questionId,
    required String selectedChoice,
    required bool isCorrect,
    required int latencyMs,
  }) async {
    final requestId = _uuid.v4();
    final attempt = AttemptRecord(
      sessionId: sessionId,
      questionId: questionId,
      selectedChoice: selectedChoice,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
      latencyMs: latencyMs,
      updatedAt: DateTime.now(),
      version: 1,
      requestId: requestId,
    );

    final operation = SyncOperation.submitAttempt(attempt);

    try {
      await _executeOperation(operation);
      _syncEventController.add(SyncEvent.attemptSubmitted(attempt));
    } catch (e) {
      _addToOfflineQueue(operation);
      _syncEventController.add(SyncEvent.attemptQueued(attempt));
    }
  }

  /// 세션 실시간 리스너 시작
  void _startSessionListener(String sessionId) {
    // 세션 문서 리스너
    _activeListeners['session_$sessionId'] = _firestore
        .collection('sessions')
        .doc(sessionId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final session = SessionInfo.fromJson(snapshot.data()!);
        _syncEventController.add(SyncEvent.sessionUpdated(session));
      }
    });

    // 시도 컬렉션 리스너
    _activeListeners['attempts_$sessionId'] = _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('attempts')
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final attempt = AttemptRecord.fromJson(change.doc.data()!);
        
        switch (change.type) {
          case DocumentChangeType.added:
            _syncEventController.add(SyncEvent.attemptAdded(attempt));
            break;
          case DocumentChangeType.modified:
            _syncEventController.add(SyncEvent.attemptUpdated(attempt));
            break;
          case DocumentChangeType.removed:
            _syncEventController.add(SyncEvent.attemptRemoved(attempt));
            break;
        }
      }
    });
  }

  /// 세션 리스너 중지
  void _stopSessionListener(String sessionId) {
    _activeListeners['session_$sessionId']?.cancel();
    _activeListeners['attempts_$sessionId']?.cancel();
    _activeListeners.removeWhere((key, _) => key.contains(sessionId));
  }

  /// 작업 실행
  Future<void> _executeOperation(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.createSession:
        await _firestore
            .collection('sessions')
            .doc(operation.data['sessionId'])
            .set(operation.data);
        break;

      case SyncOperationType.updateSession:
        await _firestore
            .collection('sessions')
            .doc(operation.sessionId!)
            .update(operation.data);
        break;

      case SyncOperationType.submitAttempt:
        final attempt = operation.data as Map<String, dynamic>;
        await _firestore
            .collection('sessions')
            .doc(attempt['sessionId'])
            .collection('attempts')
            .doc(attempt['questionId'])
            .set(attempt, SetOptions(merge: true));
        break;

      case SyncOperationType.updateAttempt:
        final attempt = operation.data as Map<String, dynamic>;
        await _firestore
            .collection('sessions')
            .doc(operation.sessionId!)
            .collection('attempts')
            .doc(attempt['questionId'])
            .update(attempt);
        break;
    }
  }

  /// 오프라인 큐에 추가
  void _addToOfflineQueue(SyncOperation operation) {
    _offlineQueue.add(operation);
    _syncEventController.add(SyncEvent.operationQueued(operation));
  }

  /// 오프라인 큐 처리
  Future<void> _processOfflineQueue() async {
    if (!_isOnline || _offlineQueue.isEmpty) return;

    final failedOperations = <SyncOperation>[];

    for (final operation in List.from(_offlineQueue)) {
      try {
        await _executeOperation(operation);
        _offlineQueue.remove(operation);
        _syncEventController.add(SyncEvent.operationSynced(operation));
      } catch (e) {
        failedOperations.add(operation);
      }
    }

    // 실패한 작업들은 큐에 유지
    if (failedOperations.isNotEmpty) {
      _syncEventController.add(SyncEvent.syncPartialFailure(failedOperations));
    }
  }

  /// 연결성 리스너 설정
  void _setupConnectivityListener() {
    _firestore.enableNetwork().then((_) {
      _isOnline = true;
      _processOfflineQueue();
    }).catchError((_) {
      _isOnline = false;
    });

    // Firestore 연결 상태 모니터링
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// 충돌 해결
  Future<AttemptRecord> resolveConflict({
    required AttemptRecord local,
    required AttemptRecord remote,
  }) async {
    // Latest Write Wins + Version 기반 해결
    if (remote.version > local.version) {
      return remote;
    } else if (local.version > remote.version) {
      return local;
    } else {
      // 버전이 같으면 타임스탬프 기준
      return local.updatedAt.isAfter(remote.updatedAt) ? local : remote;
    }
  }

  /// 리소스 정리
  void dispose() {
    for (final listener in _activeListeners.values) {
      listener.cancel();
    }
    _activeListeners.clear();
    _syncEventController.close();
  }
}

/// 동기화 작업
class SyncOperation {
  final SyncOperationType type;
  final String? sessionId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final String operationId;

  SyncOperation({
    required this.type,
    this.sessionId,
    required this.data,
    DateTime? createdAt,
    String? operationId,
  }) : createdAt = createdAt ?? DateTime.now(),
        operationId = operationId ?? const Uuid().v4();

  factory SyncOperation.createSession(SessionInfo session) {
    return SyncOperation(
      type: SyncOperationType.createSession,
      sessionId: session.sessionId,
      data: session.toJson(),
    );
  }

  factory SyncOperation.updateSession(String sessionId, Map<String, dynamic> updates) {
    return SyncOperation(
      type: SyncOperationType.updateSession,
      sessionId: sessionId,
      data: updates,
    );
  }

  factory SyncOperation.submitAttempt(AttemptRecord attempt) {
    return SyncOperation(
      type: SyncOperationType.submitAttempt,
      sessionId: attempt.sessionId,
      data: attempt.toJson(),
    );
  }

  factory SyncOperation.updateAttempt(AttemptRecord attempt) {
    return SyncOperation(
      type: SyncOperationType.updateAttempt,
      sessionId: attempt.sessionId,
      data: attempt.toJson(),
    );
  }
}

enum SyncOperationType {
  createSession,
  updateSession,
  submitAttempt,
  updateAttempt,
}

/// 동기화 이벤트
class SyncEvent {
  final SyncEventType type;
  final dynamic data;
  final DateTime timestamp;

  SyncEvent(this.type, this.data) : timestamp = DateTime.now();

  factory SyncEvent.sessionStarted(String sessionId) =>
      SyncEvent(SyncEventType.sessionStarted, sessionId);
  
  factory SyncEvent.sessionFinished(String sessionId) =>
      SyncEvent(SyncEventType.sessionFinished, sessionId);
  
  factory SyncEvent.sessionUpdated(SessionInfo session) =>
      SyncEvent(SyncEventType.sessionUpdated, session);
  
  factory SyncEvent.attemptSubmitted(AttemptRecord attempt) =>
      SyncEvent(SyncEventType.attemptSubmitted, attempt);
  
  factory SyncEvent.attemptQueued(AttemptRecord attempt) =>
      SyncEvent(SyncEventType.attemptQueued, attempt);
  
  factory SyncEvent.attemptAdded(AttemptRecord attempt) =>
      SyncEvent(SyncEventType.attemptAdded, attempt);
  
  factory SyncEvent.attemptUpdated(AttemptRecord attempt) =>
      SyncEvent(SyncEventType.attemptUpdated, attempt);
  
  factory SyncEvent.attemptRemoved(AttemptRecord attempt) =>
      SyncEvent(SyncEventType.attemptRemoved, attempt);
  
  factory SyncEvent.operationQueued(SyncOperation operation) =>
      SyncEvent(SyncEventType.operationQueued, operation);
  
  factory SyncEvent.operationSynced(SyncOperation operation) =>
      SyncEvent(SyncEventType.operationSynced, operation);
  
  factory SyncEvent.syncPartialFailure(List<SyncOperation> operations) =>
      SyncEvent(SyncEventType.syncPartialFailure, operations);

  factory SyncEvent.connectionLost() =>
      SyncEvent(SyncEventType.connectionLost, null);
  
  factory SyncEvent.connectionRestored() =>
      SyncEvent(SyncEventType.connectionRestored, null);
}

enum SyncEventType {
  sessionStarted,
  sessionFinished,
  sessionUpdated,
  attemptSubmitted,
  attemptQueued,
  attemptAdded,
  attemptUpdated,
  attemptRemoved,
  operationQueued,
  operationSynced,
  syncPartialFailure,
  connectionLost,
  connectionRestored,
}

/// 벡터 데이터베이스 동기화 서비스
class VectorDbSyncService {
  final String apiEndpoint;
  final String apiKey;

  VectorDbSyncService({
    required this.apiEndpoint,
    required this.apiKey,
  });

  /// 벡터 임베딩 저장
  Future<void> storeVector({
    required String id,
    required List<double> embedding,
    required Map<String, dynamic> metadata,
  }) async {
    // Qdrant/Pinecone API 호출
    // 실제 구현에서는 선택한 벡터 DB의 API 사용
  }

  /// 벡터 검색
  Future<List<VectorSearchResult>> searchVectors({
    required List<double> queryVector,
    required int limit,
    double threshold = 0.8,
  }) async {
    // 벡터 검색 구현
    return [];
  }

  /// 벡터 삭제
  Future<void> deleteVector(String id) async {
    // 벡터 삭제 구현
  }
}

/// 동기화 상태 관리
class SyncStateNotifier extends StateNotifier<SyncState> {
  final RealtimeSyncService _syncService;
  late final StreamSubscription _eventSubscription;

  SyncStateNotifier(this._syncService) : super(SyncState.initial()) {
    _eventSubscription = _syncService.syncEvents.listen(_handleSyncEvent);
  }

  void _handleSyncEvent(SyncEvent event) {
    switch (event.type) {
      case SyncEventType.sessionStarted:
        state = state.copyWith(
          currentSessionId: event.data,
          isSessionActive: true,
        );
        break;
        
      case SyncEventType.sessionFinished:
        state = state.copyWith(
          isSessionActive: false,
          completedSessions: state.completedSessions + 1,
        );
        break;
        
      case SyncEventType.attemptSubmitted:
        state = state.copyWith(
          submittedAttempts: state.submittedAttempts + 1,
        );
        break;
        
      case SyncEventType.attemptQueued:
        state = state.copyWith(
          queuedOperations: state.queuedOperations + 1,
        );
        break;
        
      case SyncEventType.operationSynced:
        state = state.copyWith(
          queuedOperations: state.queuedOperations - 1,
          syncedOperations: state.syncedOperations + 1,
        );
        break;
        
      case SyncEventType.connectionLost:
        state = state.copyWith(isOnline: false);
        break;
        
      case SyncEventType.connectionRestored:
        state = state.copyWith(isOnline: true);
        break;
        
      default:
        break;
    }
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    super.dispose();
  }
}

class SyncState {
  final String? currentSessionId;
  final bool isSessionActive;
  final bool isOnline;
  final int completedSessions;
  final int submittedAttempts;
  final int queuedOperations;
  final int syncedOperations;

  SyncState({
    this.currentSessionId,
    required this.isSessionActive,
    required this.isOnline,
    required this.completedSessions,
    required this.submittedAttempts,
    required this.queuedOperations,
    required this.syncedOperations,
  });

  factory SyncState.initial() {
    return SyncState(
      isSessionActive: false,
      isOnline: true,
      completedSessions: 0,
      submittedAttempts: 0,
      queuedOperations: 0,
      syncedOperations: 0,
    );
  }

  SyncState copyWith({
    String? currentSessionId,
    bool? isSessionActive,
    bool? isOnline,
    int? completedSessions,
    int? submittedAttempts,
    int? queuedOperations,
    int? syncedOperations,
  }) {
    return SyncState(
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isOnline: isOnline ?? this.isOnline,
      completedSessions: completedSessions ?? this.completedSessions,
      submittedAttempts: submittedAttempts ?? this.submittedAttempts,
      queuedOperations: queuedOperations ?? this.queuedOperations,
      syncedOperations: syncedOperations ?? this.syncedOperations,
    );
  }

  /// 동기화 진행률 (0.0 ~ 1.0)
  double get syncProgress {
    final total = queuedOperations + syncedOperations;
    return total > 0 ? syncedOperations / total : 1.0;
  }

  /// 동기화 대기 중인지
  bool get hasPendingSync => queuedOperations > 0;
}

// === Riverpod Providers ===

final realtimeSyncServiceProvider = Provider<RealtimeSyncService>((ref) {
  return RealtimeSyncService();
});

final syncStateProvider = StateNotifierProvider<SyncStateNotifier, SyncState>((ref) {
  final syncService = ref.read(realtimeSyncServiceProvider);
  return SyncStateNotifier(syncService);
});

final vectorDbSyncServiceProvider = Provider<VectorDbSyncService>((ref) {
  return VectorDbSyncService(
    apiEndpoint: 'https://api.qdrant.io', // 또는 Pinecone
    apiKey: 'your-api-key',
  );
});

/// 벡터 검색 결과
class VectorSearchResult {
  final String id;
  final List<double> vector;
  final double score;
  final Map<String, dynamic> metadata;

  VectorSearchResult({
    required this.id,
    required this.vector,
    required this.score,
    this.metadata = const {},
  });

  factory VectorSearchResult.fromJson(Map<String, dynamic> json) {
    return VectorSearchResult(
      id: json['id'],
      vector: List<double>.from(json['vector']),
      score: json['score']?.toDouble() ?? 0.0,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vector': vector,
    'score': score,
    'metadata': metadata,
  };
}