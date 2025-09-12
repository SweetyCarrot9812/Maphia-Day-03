import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'storage_service.dart';
import 'statistics_service.dart';

/// Desktop API 통합 서비스
class DesktopIntegrationService {
  static final ApiService _apiService = ApiService();
  static String? _currentUserId;
  
  // 초기화 및 연결 테스트
  static Future<bool> initialize() async {
    try {
      debugPrint('Desktop API 연결 테스트 중...');
      
      // 헬스 체크
      final isHealthy = await _apiService.checkHealth();
      if (!isHealthy) {
        debugPrint('Desktop API 서버가 응답하지 않습니다.');
        return false;
      }
      
      // 사용자 ID 설정 (테스트용)
      _currentUserId = 'mobile_user_${DateTime.now().millisecondsSinceEpoch}';
      
      debugPrint('Desktop API 연결 성공: $_currentUserId');
      return true;
    } catch (e) {
      debugPrint('Desktop API 연결 실패: $e');
      return false;
    }
  }
  
  // 현재 사용자 ID 가져오기
  static String get currentUserId => _currentUserId ?? 'default_user';
  
  // 실제 사용자 통계 가져오기
  static Future<UserStatistics?> getRealUserStatistics() async {
    try {
      // SRS 통계 가져오기
      final srsStats = await _apiService.getUserStats(currentUserId);
      
      // Mastery 정보 가져오기
      final masteryData = await _apiService.getMastery(currentUserId);
      
      return UserStatistics(
        totalQuestions: _extractTotalProblems(srsStats, masteryData),
        correctAnswers: _extractCorrectAnswers(srsStats, masteryData),
        overallAccuracy: _extractTotalProblems(srsStats, masteryData) > 0 
            ? (_extractCorrectAnswers(srsStats, masteryData) / _extractTotalProblems(srsStats, masteryData) * 100) 
            : 0.0,
        totalStudyTimeHours: _extractStudyHours(srsStats, masteryData),
        streakDays: _extractStreakDays(srsStats, masteryData),
        wrongAnswersCount: 0,
        resolvedWrongAnswers: 0,
        pendingReviewCount: 0,
      );
    } catch (e) {
      debugPrint('사용자 통계 로드 실패: $e');
      return null;
    }
  }
  
  // 실제 과목별 통계 가져오기
  static Future<List<SubjectStatistics>> getRealSubjectStatistics() async {
    try {
      // 과목 목록 가져오기
      final subjectsData = await _apiService.getSubjectStats();
      final subjects = subjectsData['subjects'] as List<dynamic>? ?? [];
      
      final List<SubjectStatistics> stats = [];
      
      for (final subject in subjects) {
        final subjectCode = subject['code'] as String? ?? '';
        final subjectName = subject['name'] as String? ?? '알 수 없는 과목';
        
        // 해당 과목의 문제 통계 가져오기
        final questionStats = await _getSubjectQuestionStats(subjectCode);
        
        final total = questionStats['total'] ?? 0;
        final correct = questionStats['correct'] ?? 0;
        stats.add(SubjectStatistics(
          subjectCode: subjectCode,
          subjectName: subjectName,
          totalQuestions: total,
          correctAnswers: correct,
          accuracyRate: total > 0 ? (correct / total * 100) : 0.0,
          studyTimeHours: 0.0,
          lastStudyDate: DateTime.now(),
          wrongAnswersCount: total - correct,
          resolvedCount: 0,
          pendingReviewCount: 0,
        ));
      }
      
      return stats;
    } catch (e) {
      debugPrint('과목별 통계 로드 실패: $e');
      return [];
    }
  }
  
  // 학습 세션 생성
  static Future<Map<String, dynamic>?> createStudySession({
    String? subject,
    int problemCount = 10,
  }) async {
    try {
      return await _apiService.buildSession(
        userId: currentUserId,
        subject: subject,
        problemCount: problemCount,
      );
    } catch (e) {
      debugPrint('학습 세션 생성 실패: $e');
      return null;
    }
  }
  
  // 문제 가져오기
  static Future<List<Map<String, dynamic>>> getProblems({
    String? subject,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.getQuestions(
        subject: subject,
        limit: limit,
      );
      
      final questions = response['questions'] as List<dynamic>? ?? [];
      return questions.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('문제 로드 실패: $e');
      return [];
    }
  }
  
  // 답안 제출
  static Future<bool> submitAnswer({
    required String questionId,
    required String answer,
  }) async {
    try {
      await _apiService.submitAnswer(
        questionId: questionId,
        answer: answer,
        userId: currentUserId,
      );
      return true;
    } catch (e) {
      debugPrint('답안 제출 실패: $e');
      return false;
    }
  }
  
  // 오늘의 복습 카드 가져오기
  static Future<List<Map<String, dynamic>>> getTodayReviewCards() async {
    try {
      final response = await _apiService.getTodayCards(currentUserId);
      final cards = response['cards'] as List<dynamic>? ?? [];
      return cards.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('오늘의 카드 로드 실패: $e');
      return [];
    }
  }
  
  // 연결 상태 확인
  static Future<bool> isConnected() async {
    try {
      return await _apiService.checkHealth();
    } catch (e) {
      return false;
    }
  }
  
  // Helper methods
  static int _extractStudyHours(Map<String, dynamic> srsStats, Map<String, dynamic> masteryData) {
    // 우선순위 1: 모바일 타이머에서 누적된 실제 학습시간
    final mobileStudyTime = _getMobileStudyTimeHours();
    if (mobileStudyTime > 0) {
      return mobileStudyTime;
    }
    
    // 우선순위 2: SRS 데이터에서 학습 시간 추출
    final totalReviews = srsStats['totalReviews'] as int? ?? 0;
    // 평균 복습당 5분 가정
    return (totalReviews * 5 / 60).round();
  }
  
  /// 모바일 타이머에서 누적된 총 학습시간 (시간 단위)
  static int _getMobileStudyTimeHours() {
    try {
      // StorageService에서 총 누적 학습시간 가져오기 (초 단위)
      final totalSeconds = StorageService.getInt('total_study_time_seconds', defaultValue: 0);
      return (totalSeconds / 3600).round(); // 시간으로 변환
    } catch (e) {
      debugPrint('모바일 학습시간 조회 실패: $e');
      return 0;
    }
  }
  
  static int _extractStreakDays(Map<String, dynamic> srsStats, Map<String, dynamic> masteryData) {
    // 우선순위 1: 모바일에서 계산된 실제 연속 학습 일수
    final mobileStreak = _calculateMobileStreakDays();
    if (mobileStreak > 0) {
      return mobileStreak;
    }
    
    // 우선순위 2: SRS 데이터에서 연속 학습 일수 추출
    return srsStats['streakDays'] as int? ?? 0;
  }
  
  /// 모바일에서 실제 학습한 날짜들을 기반으로 연속 학습 일수 계산
  static int _calculateMobileStreakDays() {
    try {
      final today = DateTime.now();
      int streakDays = 0;
      
      // 오늘부터 거꾸로 계산하면서 연속 학습 일수 확인
      for (int i = 0; i < 365; i++) { // 최대 1년
        final checkDate = today.subtract(Duration(days: i));
        final dateKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
        final dailyStudySeconds = StorageService.getInt('daily_study_$dateKey', defaultValue: 0);
        
        if (dailyStudySeconds > 300) { // 최소 5분 이상 학습한 경우
          streakDays++;
        } else if (i == 0) {
          // 오늘 학습하지 않았으면 어제까지의 스트릭 계산
          continue;
        } else {
          // 연속성이 끊어짐
          break;
        }
      }
      
      return streakDays;
    } catch (e) {
      debugPrint('연속 학습 일수 계산 실패: $e');
      return 0;
    }
  }
  
  static int _extractTotalProblems(Map<String, dynamic> srsStats, Map<String, dynamic> masteryData) {
    return srsStats['totalCards'] as int? ?? 0;
  }
  
  static int _extractCorrectAnswers(Map<String, dynamic> srsStats, Map<String, dynamic> masteryData) {
    final totalReviews = srsStats['totalReviews'] as int? ?? 0;
    final averageScore = srsStats['averageScore'] as double? ?? 0.0;
    return (totalReviews * averageScore).round();
  }
  
  static Future<Map<String, int>> _getSubjectQuestionStats(String subjectCode) async {
    try {
      // 우선순위 1: 모바일에서 실제 학습 기록 조회
      final mobileStats = await _getMobileSubjectStats(subjectCode);
      if (mobileStats['total']! > 0) {
        return mobileStats;
      }
      
      // 우선순위 2: Desktop API에서 문제들 가져오기
      final questions = await getProblems(subject: subjectCode, limit: 100);
      
      // 실제 정답률 계산 (임시로 모든 문제가 시도되었다고 가정)
      final total = questions.length;
      final correct = (total * 0.75).round(); // 75% 정답률 가정
      
      return {'total': total, 'correct': correct};
    } catch (e) {
      return {'total': 0, 'correct': 0};
    }
  }
  
  /// 모바일에서 실제 과목별 학습 기록 조회
  static Future<Map<String, int>> _getMobileSubjectStats(String subjectCode) async {
    try {
      // StorageService에서 과목별 누적 통계 조회
      final totalAnswered = StorageService.getInt('subject_${subjectCode}_total', defaultValue: 0);
      final correctAnswers = StorageService.getInt('subject_${subjectCode}_correct', defaultValue: 0);
      
      return {
        'total': totalAnswered,
        'correct': correctAnswers,
      };
    } catch (e) {
      debugPrint('모바일 과목별 통계 조회 실패: $e');
      return {'total': 0, 'correct': 0};
    }
  }
  
  /// 문제 풀이 결과를 과목별 통계에 누적 (문제 풀이 화면에서 호출)
  static Future<void> updateSubjectStats({
    required String subjectCode,
    required bool isCorrect,
  }) async {
    try {
      // 현재 통계 가져오기
      final currentTotal = StorageService.getInt('subject_${subjectCode}_total', defaultValue: 0);
      final currentCorrect = StorageService.getInt('subject_${subjectCode}_correct', defaultValue: 0);
      
      // 통계 업데이트
      await StorageService.setInt('subject_${subjectCode}_total', currentTotal + 1);
      if (isCorrect) {
        await StorageService.setInt('subject_${subjectCode}_correct', currentCorrect + 1);
      }
      
      debugPrint('과목별 통계 업데이트: $subjectCode, 정답여부: $isCorrect');
    } catch (e) {
      debugPrint('과목별 통계 업데이트 실패: $e');
    }
  }
}

// 데이터 모델들은 statistics_service.dart에서 import