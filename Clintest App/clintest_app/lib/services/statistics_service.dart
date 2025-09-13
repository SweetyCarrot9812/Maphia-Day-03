import 'database_service.dart';
import 'wrong_answer_service.dart';
import 'storage_service.dart';
import 'desktop_integration_service.dart';

/// 통계 데이터 계산 서비스
class StatisticsService {

  /// 사용자 전체 통계 데이터
  static Future<UserStatistics> getUserStatistics(String userId) async {
    try {
      // 우선순위 1: Desktop API에서 실제 통계 가져오기 (임시 비활성화)
      // final desktopStats = await DesktopIntegrationService.getRealUserStatistics();
      // if (desktopStats != null) {
      //   print('Desktop API에서 실제 사용자 통계 로드됨');
      //   return desktopStats;
      // }
      
      // 우선순위 2: 로컬 데이터베이스 통계 (fallback)
      print('Desktop API 실패, 로컬 데이터 사용');
      final allProgress = await DatabaseService.instance.getAllStudyProgress(userId);
      
      // 오답 노트 통계
      final wrongStats = await WrongAnswerService.getWrongAnswerStats(userId);
      
      // 계산
      final totalQuestions = allProgress.fold<int>(0, (sum, progress) => sum + progress.attemptedQuestions);
      final totalCorrect = allProgress.fold<int>(0, (sum, progress) => sum + progress.correctAnswers);
      final dbStudyTime = allProgress.fold<int>(0, (sum, progress) => sum + progress.studyTimeSeconds);
      
      // 타이머로 저장된 학습시간도 포함
      final timerStudyTime = StorageService.getInt('total_study_time_seconds', defaultValue: 0);
      final totalStudyTime = dbStudyTime + timerStudyTime;
      
      final maxStreakDays = allProgress.isNotEmpty 
          ? allProgress.map((p) => p.streakDays).reduce((a, b) => a > b ? a : b)
          : 0;
      
      final overallAccuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions) : 0.0;
      
      return UserStatistics(
        totalQuestions: totalQuestions,
        correctAnswers: totalCorrect,
        overallAccuracy: overallAccuracy,
        totalStudyTimeHours: (totalStudyTime / 3600).round(),
        streakDays: maxStreakDays,
        wrongAnswersCount: wrongStats.totalWrongs,
        resolvedWrongAnswers: wrongStats.resolvedCount,
        pendingReviewCount: wrongStats.needsReviewCount,
      );
    } catch (e) {
      print('사용자 통계 계산 오류: $e');
      return UserStatistics.empty();
    }
  }

  /// 과목별 통계 데이터
  static Future<List<SubjectStatistics>> getSubjectStatistics(String userId) async {
    try {
      // 우선순위 1: Desktop API에서 실제 과목별 통계 가져오기 (임시 비활성화)
      // final desktopSubjectStats = await DesktopIntegrationService.getRealSubjectStatistics();
      // if (desktopSubjectStats.isNotEmpty) {
      //   print('Desktop API에서 과목별 통계 로드됨: ${desktopSubjectStats.length}개 과목');
      //   return desktopSubjectStats;
      // }
      
      // 우선순위 2: 로컬 데이터베이스 통계 (fallback)
      print('Desktop API 실패, 로컬 과목별 데이터 사용');
      final allProgress = await DatabaseService.instance.getAllStudyProgress(userId);
      final subjectStats = <SubjectStatistics>[];

      for (final progress in allProgress) {
        // 과목별 오답 데이터
        final subjectWrongs = await WrongAnswerService.getWrongAnswersBySubject(userId, progress.subjectCode);
        
        final subjectStat = SubjectStatistics(
          subjectCode: progress.subjectCode,
          subjectName: await _getSubjectName(progress.subjectCode),
          totalQuestions: progress.attemptedQuestions,
          correctAnswers: progress.correctAnswers,
          accuracyRate: progress.accuracyRate,
          studyTimeHours: (progress.studyTimeSeconds / 3600),
          lastStudyDate: progress.lastStudyDate,
          wrongAnswersCount: subjectWrongs.length,
          resolvedCount: subjectWrongs.where((w) => w.isResolved).length,
          pendingReviewCount: subjectWrongs.where((w) => w.needsReview).length,
        );
        
        subjectStats.add(subjectStat);
      }

      // 정확도순으로 정렬 (낮은 것부터 - 약점 과목 우선)
      subjectStats.sort((a, b) => a.accuracyRate.compareTo(b.accuracyRate));
      
      return subjectStats;
    } catch (e) {
      print('과목별 통계 계산 오류: $e');
      return [];
    }
  }

  /// 주간 학습 패턴 데이터 (최근 7일) - 실제 모바일 타이머 데이터 사용
  static Future<List<DailyStudyData>> getWeeklyStudyPattern(String userId) async {
    try {
      final now = DateTime.now();
      final weeklyData = <DailyStudyData>[];
      
      // 지난 7일 실제 데이터 가져오기
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        // 실제 학습 시간 가져오기 (StudyTimer에서 저장한 데이터)
        final dailyStudySeconds = StorageService.getInt('daily_study_$dateKey', defaultValue: 0);
        final studyMinutes = (dailyStudySeconds / 60).round();
        
        // 해당 날짜의 과목별 학습 통계에서 문제 수 계산
        final questionsCount = await _getRealQuestionsCountForDate(date);
        
        // 정답률 계산 (실제 데이터 기반)
        final accuracyRate = await _getRealAccuracyForDate(date);
        
        weeklyData.add(DailyStudyData(
          date: date,
          studyMinutes: studyMinutes,
          questionsCount: questionsCount,
          accuracyRate: accuracyRate,
        ));
      }
      
      return weeklyData;
    } catch (e) {
      print('주간 학습 패턴 계산 오류: $e');
      return [];
    }
  }

  /// 약점 분석 데이터
  static Future<List<WeaknessAnalysis>> getWeaknessAnalysis(String userId) async {
    try {
      final subjectStats = await getSubjectStatistics(userId);
      final weaknesses = <WeaknessAnalysis>[];
      
      for (final stat in subjectStats) {
        if (stat.accuracyRate < 0.7) { // 70% 미만인 과목들
          final improvement = _calculateImprovementSuggestion(stat);
          
          weaknesses.add(WeaknessAnalysis(
            subjectCode: stat.subjectCode,
            subjectName: stat.subjectName,
            currentAccuracy: stat.accuracyRate,
            targetAccuracy: 0.8, // 목표: 80%
            priority: _calculatePriority(stat),
            improvementSuggestions: improvement,
          ));
        }
      }
      
      // 우선순위순으로 정렬
      weaknesses.sort((a, b) => b.priority.compareTo(a.priority));
      
      return weaknesses;
    } catch (e) {
      print('약점 분석 계산 오류: $e');
      return [];
    }
  }

  /// 과목명 가져오기 (임시 구현)
  static Future<String> _getSubjectName(String subjectCode) async {
    final nameMap = {
      'MED_ANATOMY': '해부학',
      'MED_PHYSIOLOGY': '생리학', 
      'MED_PHARMACOLOGY': '약리학',
      'MED_INTERNAL': '내과학',
      'MED_SURGERY': '외과학',
      'NUR_FUNDAMENTAL': '기본간호학',
      'NUR_ADULT': '성인간호학',
      'NUR_PEDIATRIC': '아동간호학',
      'NUR_MATERNAL': '모성간호학',
      'NUR_PSYCHIATRIC': '정신간호학',
    };
    return nameMap[subjectCode] ?? subjectCode;
  }

  /// 날짜별 실제 문제 수 계산 (SmartStudyService 기록 기반)
  static Future<int> _getRealQuestionsCountForDate(DateTime date) async {
    try {
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      // 해당 날짜에 푼 문제 수 조회 (추후 SmartStudyService와 연동 예정)
      return StorageService.getInt('daily_problems_$dateKey', defaultValue: 0);
    } catch (e) {
      return 0;
    }
  }

  /// 날짜별 실제 정답률 계산 (SmartStudyService 기록 기반)
  static Future<double> _getRealAccuracyForDate(DateTime date) async {
    try {
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final correctAnswers = StorageService.getInt('daily_correct_$dateKey', defaultValue: 0);
      final totalProblems = StorageService.getInt('daily_problems_$dateKey', defaultValue: 0);
      
      return totalProblems > 0 ? (correctAnswers / totalProblems) : 0.0;
    } catch (e) {
      return 0.0;
    }
  }
  
  /// 날짜별 학습 시간 계산 (임시 데이터 - fallback용)
  static int _getStudyTimeForDate(DateTime date) {
    final dayOfWeek = date.weekday;
    // 주말에 더 많이 공부하는 패턴 시뮬레이션
    if (dayOfWeek == 6 || dayOfWeek == 7) { // 토, 일
      return 45 + (date.day % 30); // 45-75분
    } else {
      return 20 + (date.day % 25); // 20-45분  
    }
  }

  /// 날짜별 문제 수 계산 (임시 데이터 - fallback용)
  static int _getQuestionsCountForDate(DateTime date) {
    final studyTime = _getStudyTimeForDate(date);
    return (studyTime / 3).round(); // 평균 3분당 1문제
  }

  /// 개선 제안 계산
  static List<String> _calculateImprovementSuggestion(SubjectStatistics stat) {
    final suggestions = <String>[];
    
    if (stat.accuracyRate < 0.5) {
      suggestions.add('기본 개념 복습이 시급합니다');
      suggestions.add('오답 노트를 통한 집중 복습 필요');
    } else if (stat.accuracyRate < 0.7) {
      suggestions.add('약점 유형 집중 학습 권장');
      suggestions.add('복습 비율을 늘려보세요');
    }
    
    if (stat.pendingReviewCount > 5) {
      suggestions.add('복습할 문제가 ${stat.pendingReviewCount}개 쌓여있습니다');
    }
    
    return suggestions;
  }

  /// 우선순위 계산 (0.0-1.0)
  static double _calculatePriority(SubjectStatistics stat) {
    double priority = 0.0;
    
    // 정확도가 낮을수록 우선순위 높음
    priority += (1.0 - stat.accuracyRate) * 0.6;
    
    // 복습 대기 문제가 많을수록 우선순위 높음
    priority += (stat.pendingReviewCount / 20.0) * 0.3;
    
    // 최근 학습이 오래된 과목일수록 우선순위 높음
    if (stat.lastStudyDate != null) {
      final daysSinceLastStudy = DateTime.now().difference(stat.lastStudyDate!).inDays;
      priority += (daysSinceLastStudy / 7.0) * 0.1;
    }
    
    return priority.clamp(0.0, 1.0);
  }
}

/// 사용자 전체 통계 데이터 클래스
class UserStatistics {
  final int totalQuestions;
  final int correctAnswers;
  final double overallAccuracy;
  final int totalStudyTimeHours;
  final int streakDays;
  final int wrongAnswersCount;
  final int resolvedWrongAnswers;
  final int pendingReviewCount;

  UserStatistics({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.overallAccuracy,
    required this.totalStudyTimeHours,
    required this.streakDays,
    required this.wrongAnswersCount,
    required this.resolvedWrongAnswers,
    required this.pendingReviewCount,
  });

  factory UserStatistics.empty() {
    return UserStatistics(
      totalQuestions: 0,
      correctAnswers: 0,
      overallAccuracy: 0.0,
      totalStudyTimeHours: 0,
      streakDays: 0,
      wrongAnswersCount: 0,
      resolvedWrongAnswers: 0,
      pendingReviewCount: 0,
    );
  }
}

/// 과목별 통계 데이터 클래스
class SubjectStatistics {
  final String subjectCode;
  final String subjectName;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracyRate;
  final double studyTimeHours;
  final DateTime? lastStudyDate;
  final int wrongAnswersCount;
  final int resolvedCount;
  final int pendingReviewCount;

  SubjectStatistics({
    required this.subjectCode,
    required this.subjectName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracyRate,
    required this.studyTimeHours,
    this.lastStudyDate,
    required this.wrongAnswersCount,
    required this.resolvedCount,
    required this.pendingReviewCount,
  });
}

/// 일일 학습 데이터 클래스
class DailyStudyData {
  final DateTime date;
  final int studyMinutes;
  final int questionsCount;
  final double accuracyRate;

  DailyStudyData({
    required this.date,
    required this.studyMinutes,
    required this.questionsCount,
    required this.accuracyRate,
  });
}

/// 약점 분석 데이터 클래스
class WeaknessAnalysis {
  final String subjectCode;
  final String subjectName;
  final double currentAccuracy;
  final double targetAccuracy;
  final double priority;
  final List<String> improvementSuggestions;

  WeaknessAnalysis({
    required this.subjectCode,
    required this.subjectName,
    required this.currentAccuracy,
    required this.targetAccuracy,
    required this.priority,
    required this.improvementSuggestions,
  });
}