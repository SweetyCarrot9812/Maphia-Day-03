import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../services/isar_service.dart';
import '../services/sync_service.dart';
import '../services/calendar_service.dart';
import '../services/ai_coach_service.dart';
import '../services/advanced_coach_service.dart';
import '../repositories/workout_repository.dart';
import '../repositories/user_repository.dart';
import '../providers/auth_provider.dart' as auth_provider;
import '../models/base_model.dart';
import '../models/workout_plan.dart';
import '../models/workout_log.dart';
import '../models/user_profile.dart';

/// 앱 전체 의존성 주입 설정
/// Provider 패턴으로 서비스들을 관리
class AppProviders extends StatelessWidget {
  final Widget child;
  
  const AppProviders({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 기본 서비스 레이어
        Provider<IsarService>(
          create: (_) => IsarService(),
        ),
        
        // 동기화 서비스 (Isar 의존성)
        ProxyProvider<IsarService, SyncService>(
          create: (_) => throw UnimplementedError(),
          update: (_, isarService, __) => SyncService(isarService),
        ),
        
        // 캘린더 서비스 (Isar + Sync 의존성)
        ProxyProvider2<IsarService, SyncService, CalendarService>(
          create: (_) => throw UnimplementedError(),
          update: (_, isarService, syncService, __) => 
              CalendarService(isarService, syncService),
        ),
        
        // AI 코치 서비스들
        Provider<AICoachService>(
          create: (_) => AICoachService(),
        ),
        
        ProxyProvider2<IsarService, AICoachService, AdvancedCoachService>(
          create: (_) => throw UnimplementedError(),
          update: (_, isarService, aiCoachService, __) => 
              AdvancedCoachService(isarService, aiCoachService),
        ),
        
        // Repository 레이어
        ProxyProvider2<IsarService, SyncService, WorkoutRepository>(
          create: (_) => throw UnimplementedError(),
          update: (_, isarService, syncService, __) => 
              WorkoutRepository(isarService, syncService),
        ),
        
        ProxyProvider2<IsarService, SyncService, UserRepository>(
          create: (_) => throw UnimplementedError(),
          update: (_, isarService, syncService, __) => 
              UserRepository(isarService, syncService),
        ),
        
        // 인증 상태 관리  
        ChangeNotifierProvider<auth_provider.AuthProvider>(
          create: (_) => auth_provider.AuthProvider(),
        ),
        
        // 앱 상태 관리 Provider들
        ChangeNotifierProxyProvider2<WorkoutRepository, UserRepository, WorkoutProvider>(
          create: (_) => throw UnimplementedError(),
          update: (_, workoutRepository, userRepository, workoutProvider) =>
              workoutProvider ?? WorkoutProvider(
                workoutRepository: workoutRepository,
                userRepository: userRepository,
              ),
        ),
        
        ChangeNotifierProxyProvider2<SyncService, IsarService, SyncProvider>(
          create: (_) => throw UnimplementedError(),
          update: (_, syncService, isarService, syncProvider) =>
              syncProvider ?? SyncProvider(
                syncService: syncService,
                isarService: isarService,
              ),
        ),
        
        ChangeNotifierProxyProvider<UserRepository, UserProvider>(
          create: (_) => throw UnimplementedError(),
          update: (_, userRepository, userProvider) => 
              userProvider ?? UserProvider(userRepository: userRepository),
        ),
      ],
      child: child,
    );
  }
}

/// 운동 세션 상태 관리
class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final UserRepository _userRepository;
  
  WorkoutProvider({
    required WorkoutRepository workoutRepository,
    required UserRepository userRepository,
  }) : _workoutRepository = workoutRepository,
       _userRepository = userRepository;

  // 현재 활성 세션
  WorkoutSession? _currentSession;
  WorkoutSession? get currentSession => _currentSession;
  
  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // 오늘의 세션들
  List<WorkoutSession> _todaySessions = [];
  List<WorkoutSession> get todaySessions => _todaySessions;

  /// 새로운 운동 세션 시작
  Future<void> startNewSession({
    required String userId,
    required String planId,
    required List<Exercise> exercises,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final session = await _workoutRepository.createSession(
        userId: userId,
        planId: planId,
        date: DateTime.now(),
        exercises: exercises,
      );
      
      _currentSession = await _workoutRepository.startSession(session.id);
      await loadTodaySessions(userId);
      
    } catch (e) {
      print('Failed to start session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 세션 완료
  Future<void> completeCurrentSession() async {
    if (_currentSession == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final completedSession = await _workoutRepository.completeSession(_currentSession!.id);
      _currentSession = null;
      
      // 사용자 통계 업데이트
      final userId = completedSession.userId;
      await loadTodaySessions(userId);
      
    } catch (e) {
      print('Failed to complete session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 운동 세트 기록
  Future<WorkoutLog?> logSet({
    required String exerciseKey,
    required int setIndex,
    required double weight,
    required int reps,
    required int rpe,
    String? note,
  }) async {
    if (_currentSession == null) return null;
    
    try {
      final log = await _workoutRepository.logSet(
        sessionId: _currentSession!.id,
        exerciseKey: exerciseKey,
        setIndex: setIndex,
        weight: weight,
        reps: reps,
        rpe: rpe,
        note: note,
      );
      
      // PR 달성 시 사용자 메트릭스 업데이트
      if (log.isPR && log.estimated1RM != null) {
        await _userRepository.updateOneRMFromPR(
          _currentSession!.userId,
          exerciseKey,
          log.estimated1RM!,
        );
      }
      
      notifyListeners();
      return log;
      
    } catch (e) {
      print('Failed to log set: $e');
      return null;
    }
  }
  
  /// 오늘의 세션들 로드
  Future<void> loadTodaySessions(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      _todaySessions = await _workoutRepository.getUserSessions(
        userId,
        startDate: startOfDay,
        endDate: endOfDay,
      );
      
      // 진행 중인 세션 찾기
      _currentSession = _todaySessions
          .where((s) => s.status == SessionStatus.inProgress)
          .cast<WorkoutSession?>()
          .firstOrNull;
      
      notifyListeners();
    } catch (e) {
      print('Failed to load today sessions: $e');
    }
  }
}

/// 동기화 상태 관리
class SyncProvider extends ChangeNotifier {
  final SyncService _syncService;
  final IsarService _isarService;
  
  SyncProvider({
    required SyncService syncService,
    required IsarService isarService,
  }) : _syncService = syncService,
       _isarService = isarService;

  // 동기화 상태
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  
  SyncStats? _syncStats;
  SyncStats? get syncStats => _syncStats;
  
  SyncResult? _lastSyncResult;
  SyncResult? get lastSyncResult => _lastSyncResult;
  
  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// 수동 동기화 실행
  Future<void> performSync(String userId) async {
    if (_isSyncing) return;
    
    try {
      _isSyncing = true;
      notifyListeners();
      
      _lastSyncResult = await _syncService.performSync(userId);
      _lastSyncTime = DateTime.now();
      
      // 동기화 통계 업데이트
      await loadSyncStats(userId);
      
    } catch (e) {
      print('Sync failed: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// 동기화 통계 로드
  Future<void> loadSyncStats(String userId) async {
    try {
      _syncStats = await _isarService.getSyncStats(userId);
      notifyListeners();
    } catch (e) {
      print('Failed to load sync stats: $e');
    }
  }
  
  /// 백그라운드 자동 동기화 (앱 시작 시 또는 주기적 실행)
  Future<void> performBackgroundSync(String userId) async {
    // UI 업데이트 없이 조용히 동기화
    try {
      await _syncService.performSync(userId);
      await loadSyncStats(userId);
    } catch (e) {
      print('Background sync failed: $e');
    }
  }
  
  /// 데이터베이스 상태 체크
  Future<DatabaseHealthCheck?> checkDatabaseHealth() async {
    try {
      return await _isarService.checkHealth();
    } catch (e) {
      print('Database health check failed: $e');
      return null;
    }
  }
  
  /// 캐시 정리
  Future<void> cleanupCache() async {
    try {
      await _isarService.cleanupCache();
      notifyListeners();
    } catch (e) {
      print('Cache cleanup failed: $e');
    }
  }
}

/// 사용자 프로필 상태 관리  
class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  
  UserProvider({required UserRepository userRepository})
      : _userRepository = userRepository;

  UserProfile? _currentProfile;
  UserProfile? get currentProfile => _currentProfile;
  
  UserMetrics? _currentMetrics;
  UserMetrics? get currentMetrics => _currentMetrics;
  
  UserWorkoutStats? _workoutStats;
  UserWorkoutStats? get workoutStats => _workoutStats;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 사용자 프로필 로드
  Future<void> loadUserProfile(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _currentProfile = await _userRepository.getProfile(userId);
      _currentMetrics = await _userRepository.getMetrics(userId);
      _workoutStats = await _userRepository.getWorkoutStats(userId);
      
    } catch (e) {
      print('Failed to load user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 프로필 저장
  Future<void> saveProfile(UserProfile profile) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _currentProfile = await _userRepository.saveProfile(profile);
      
    } catch (e) {
      print('Failed to save profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 메트릭스 업데이트
  Future<void> updateMetrics({
    required String userId,
    Map<String, double>? oneRM,
    int? fatigueScore,
    double? sleepHours,
  }) async {
    try {
      _currentMetrics = await _userRepository.updateMetrics(
        userId: userId,
        oneRM: oneRM,
        fatigueScore: fatigueScore,
        sleepHours: sleepHours,
      );
      notifyListeners();
    } catch (e) {
      print('Failed to update metrics: $e');
    }
  }
}

