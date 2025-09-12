import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 시스템 통계 조회
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      // 총 문제수 조회
      final questionsSnapshot = await _firestore
          .collection('nursing_questions')
          .count()
          .get();
      final totalQuestions = questionsSnapshot.count ?? 0;

      // 총 개념수 조회  
      final conceptsSnapshot = await _firestore
          .collection('nursing_concepts')
          .count()
          .get();
      final totalConcepts = conceptsSnapshot.count ?? 0;

      // 활성 사용자 수 (최근 30일)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final activeUsersSnapshot = await _firestore
          .collection('users')
          .where('lastLogin', isGreaterThan: thirtyDaysAgo)
          .count()
          .get();
      final activeUsers = activeUsersSnapshot.count ?? 0;

      // 오늘 생성된 데이터
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final todayQuestionsSnapshot = await _firestore
          .collection('nursing_questions')
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .count()
          .get();
      final todayQuestions = todayQuestionsSnapshot.count ?? 0;

      final todayConceptsSnapshot = await _firestore
          .collection('nursing_concepts') 
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .count()
          .get();
      final todayConcepts = todayConceptsSnapshot.count ?? 0;

      return {
        'totalQuestions': totalQuestions,
        'totalConcepts': totalConcepts,
        'activeUsers': activeUsers,
        'todayQuestions': todayQuestions,
        'todayConcepts': todayConcepts,
        'systemStatus': 'Firebase 연결됨',
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      print('Firebase 데이터 로드 오류: $e');
      return {
        'totalQuestions': 0,
        'totalConcepts': 0,
        'activeUsers': 0,
        'todayQuestions': 0,
        'todayConcepts': 0,
        'systemStatus': 'Firebase 연결 오류: ${e.toString()}',
        'lastUpdated': DateTime.now(),
      };
    }
  }

  // 최근 활동 조회
  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    try {
      final snapshot = await _firestore
          .collection('activity_logs')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('최근 활동 로드 오류: $e');
      return [];
    }
  }

  // 과목별 문제 분포 조회
  Future<Map<String, int>> getSubjectDistribution() async {
    try {
      final snapshot = await _firestore
          .collection('nursing_questions')
          .get();

      final Map<String, int> distribution = {};
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final subject = data['subject'] as String? ?? '미분류';
        distribution[subject] = (distribution[subject] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      print('과목별 분포 로드 오류: $e');
      return {};
    }
  }

  // Firebase 연결 상태 확인
  Future<bool> checkConnection() async {
    try {
      await _firestore.collection('_health_check').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 실시간 통계 스트림
  Stream<Map<String, dynamic>> getRealtimeStats() {
    return Stream.periodic(const Duration(seconds: 30), (i) => i)
        .asyncMap((_) => getSystemStats());
  }
}

// Riverpod Provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// 시스템 통계 Provider
final systemStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getSystemStats();
});

// 실시간 통계 Stream Provider
final realtimeStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getRealtimeStats();
});

// 과목별 분포 Provider
final subjectDistributionProvider = FutureProvider<Map<String, int>>((ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getSubjectDistribution();
});

// Firebase 연결 상태 Provider
final firebaseConnectionProvider = FutureProvider<bool>((ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.checkConnection();
});