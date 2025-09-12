import 'dart:math' as math;
import '../models/wrong_answer.dart';
import 'wrong_answer_service.dart';
import 'database_service.dart';

/// GPT-5 기반 스마트 학습 최적화 시스템
class AIStudyOptimizer {
  
  /// 사용자별 최적 학습 비율 계산 (GPT-5 분석 기반)
  static Future<StudyRatio> calculateOptimalRatio({
    required String userId,
    required String subjectCode,
  }) async {
    // 1. 사용자 학습 데이터 수집
    final studyData = await _collectUserStudyData(userId, subjectCode);
    
    // 2. GPT-5 분석 요청
    final analysis = await _analyzeWithGPT5(studyData);
    
    // 3. 최적 비율 반환
    return analysis;
  }
  
  /// 사용자 학습 데이터 수집
  static Future<UserStudyData> _collectUserStudyData(
    String userId, 
    String subjectCode,
  ) async {
    // 학습 진도 정보
    final progress = await DatabaseService.instance.getStudyProgress(userId, subjectCode);
    
    // 오답 노트 통계
    final wrongStats = await WrongAnswerService.getWrongAnswerStats(userId);
    final subjectWrongs = await WrongAnswerService.getWrongAnswersBySubject(userId, subjectCode);
    
    // 최근 학습 패턴 (지난 7일)
    final recentWrongs = subjectWrongs
        .where((w) => w.wrongDate != null && 
               w.wrongDate!.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();
    
    // 복습 성공률 계산
    final reviewSuccessRate = _calculateReviewSuccessRate(subjectWrongs);
    
    return UserStudyData(
      userId: userId,
      subjectCode: subjectCode,
      accuracyRate: progress?.accuracyRate ?? 0.0,
      streakDays: progress?.streakDays ?? 0,
      totalWrongCount: subjectWrongs.length,
      pendingReviewCount: subjectWrongs.where((w) => w.needsReview).length,
      resolvedCount: subjectWrongs.where((w) => w.isResolved).length,
      recentWrongCount: recentWrongs.length,
      reviewSuccessRate: reviewSuccessRate,
      studyTimeHours: (progress?.studyTimeSeconds ?? 0) / 3600,
      lastStudyDaysAgo: progress?.lastStudyDate != null 
          ? DateTime.now().difference(progress!.lastStudyDate!).inDays
          : 999,
    );
  }
  
  /// GPT-5 Standard 분석 호출 (Desktop API 연동)
  static Future<StudyRatio> _analyzeWithGPT5(UserStudyData data) async {
    // GPT-5 멀티 모델 오케스트레이션 시스템 활용
    final prompt = _buildAnalysisPrompt(data);
    
    try {
      // Desktop API를 통해 GPT-5 Standard 분석 요청
      // GPT-5 Standard = 최종 심사관, 학습 최적화 확정
      final response = await _callDesktopAPI('/api/ai/study-optimization', {
        'prompt': prompt,
        'model': 'gpt-5-standard', // 최고 품질 분석
        'user_data': data.toJson(),
      });
      
      return StudyRatio.fromJson(response);
    } catch (e) {
      print('GPT-5 Standard 분석 실패, 규칙 기반으로 폴백: $e');
      // 폴백: 규칙 기반 로직
      return _ruleBasedAnalysis(data);
    }
  }
  
  /// 사용자 대화용 GPT-5 mini 모델 호출
  static Future<String> chatWithUser({
    required String message,
    String? context,
  }) async {
    try {
      // Desktop API를 통해 GPT-5 mini 사용자 대화 요청
      final response = await _callDesktopAPI('/api/ai/user-chat', {
        'prompt': message,
        'model': 'gpt-5-mini', // 사용자 설정/대화용 경량 모델
        'context': context,
        'type': 'user_setup',
      });
      
      return response['response'] ?? '죄송합니다. 응답을 생성할 수 없습니다.';
    } catch (e) {
      print('GPT-5 mini 사용자 대화 실패: $e');
      // 폴백: 기본 응답
      return '안녕하세요! Clintest 설정에 대해 도움을 드리겠습니다. 무엇을 도와드릴까요?';
    }
  }
  
  /// Desktop API 호출 (임시 구현)
  static Future<Map<String, dynamic>> _callDesktopAPI(String endpoint, Map<String, dynamic> data) async {
    // TODO: 실제 Desktop API 호출 구현
    throw Exception('Desktop API 연동 미구현');
  }
  
  /// GPT-5 Standard 분석용 프롬프트 생성
  static String _buildAnalysisPrompt(UserStudyData data) {
    return '''
[GPT-5 Standard 의료 학습 최적화 분석]

의학/간호학 전문 학습 패턴 분석 및 개인화 추천 요청:

== 사용자 학습 프로필 ==
과목: ${data.subjectCode}
현재 정답률: ${(data.accuracyRate * 100).toStringAsFixed(1)}%
학습 연속성: ${data.streakDays}일 연속
누적 오답: ${data.totalWrongCount}개
복습 대기 중: ${data.pendingReviewCount}개  
복습 성공률: ${(data.reviewSuccessRate * 100).toStringAsFixed(1)}%
최근 실수 패턴: ${data.recentWrongCount}개 (7일간)
총 학습 투자시간: ${data.studyTimeHours.toStringAsFixed(1)}시간
학습 공백: ${data.lastStudyDaysAgo}일

== GPT-5 Standard 분석 요구사항 ==
의료진 국가고시 준비를 위한 최적 학습 전략 도출:

1. 학습 효율성 분석: 현재 패턴의 강점/약점
2. 복습 vs 신규 문제 최적 비율 결정 (정밀 계산)
3. 1회 세션 문제 수 최적화 (인지 부하 고려)  
4. 복습 우선순위 레벨 판정
5. 의학적 지식 습득 패턴 진단
6. 개인화된 학습 개선 전략

== 출력 형식 (JSON) ==
{
  "reviewRatio": 0.0-1.0,
  "questionCount": 5-20,
  "priority": "urgent|normal|low", 
  "analysis": "전문적 분석 및 구체적 개선 방안",
  "confidence": 0.0-1.0,
  "recommendations": ["구체적 실행 가능한 제안들"]
}

GPT-5 Standard 품질로 정확한 의료 교육학적 분석을 요청합니다.
''';
  }
  
  /// 임시 규칙 기반 분석 (GPT-5 대체용)
  static StudyRatio _ruleBasedAnalysis(UserStudyData data) {
    double reviewRatio = 0.3; // 기본 30%
    int questionCount = 10; // 기본 10문제
    String priority = 'normal';
    
    // 정답률에 따른 조정
    if (data.accuracyRate < 0.5) {
      // 정답률 50% 미만: 복습 비중 증가
      reviewRatio = 0.6;
      questionCount = 8; // 적은 문제로 집중
      priority = 'urgent';
    } else if (data.accuracyRate > 0.8) {
      // 정답률 80% 이상: 새 문제 비중 증가
      reviewRatio = 0.1;
      questionCount = 12; // 더 많은 새 문제
      priority = 'low';
    }
    
    // 복습 대기 문제 수에 따른 조정
    if (data.pendingReviewCount > 20) {
      reviewRatio = math.min(reviewRatio + 0.2, 0.8);
      priority = 'urgent';
    } else if (data.pendingReviewCount < 5) {
      reviewRatio = math.max(reviewRatio - 0.2, 0.1);
    }
    
    // 최근 학습 패턴에 따른 조정
    if (data.recentWrongCount > data.totalWrongCount * 0.3) {
      // 최근에 실수가 많음: 복습 강화
      reviewRatio = math.min(reviewRatio + 0.1, 0.7);
    }
    
    // 연속 학습일에 따른 조정
    if (data.streakDays > 7) {
      // 꾸준히 학습 중: 도전적인 문제 증가
      questionCount = math.min(questionCount + 2, 15);
    } else if (data.streakDays == 0) {
      // 첫 학습이거나 중단 후 재시작: 부담 줄이기
      questionCount = math.max(questionCount - 2, 5);
    }
    
    return StudyRatio(
      reviewRatio: reviewRatio,
      newQuestionRatio: 1.0 - reviewRatio,
      totalQuestionCount: questionCount,
      priority: priority,
      analysis: _generateAnalysisText(data, reviewRatio, questionCount, priority),
    );
  }
  
  /// 복습 성공률 계산
  static double _calculateReviewSuccessRate(List<WrongAnswer> wrongs) {
    final reviewedWrongs = wrongs.where((w) => w.reviewCount > 0).toList();
    if (reviewedWrongs.isEmpty) return 0.0;
    
    final successCount = reviewedWrongs.where((w) => w.isResolved).length;
    return successCount / reviewedWrongs.length;
  }
  
  /// 분석 텍스트 생성
  static String _generateAnalysisText(
    UserStudyData data,
    double reviewRatio,
    int questionCount,
    String priority,
  ) {
    final buffer = StringBuffer();
    
    if (data.accuracyRate < 0.5) {
      buffer.write('정답률이 낮아 기초 개념 복습이 필요합니다. ');
    } else if (data.accuracyRate > 0.8) {
      buffer.write('높은 정답률을 보이고 있어 새로운 문제에 도전해보세요. ');
    }
    
    if (data.pendingReviewCount > 10) {
      buffer.write('복습할 문제가 많이 쌓여있습니다. ');
    }
    
    if (data.streakDays > 7) {
      buffer.write('꾸준한 학습 습관이 훌륭합니다! ');
    }
    
    buffer.write('복습 ${(reviewRatio * 100).toInt()}% + 새 문제 ${((1-reviewRatio) * 100).toInt()}%로 학습하세요.');
    
    return buffer.toString();
  }
}

/// 사용자 학습 데이터 클래스
class UserStudyData {
  final String userId;
  final String subjectCode;
  final double accuracyRate;
  final int streakDays;
  final int totalWrongCount;
  final int pendingReviewCount;
  final int resolvedCount;
  final int recentWrongCount;
  final double reviewSuccessRate;
  final double studyTimeHours;
  final int lastStudyDaysAgo;
  
  UserStudyData({
    required this.userId,
    required this.subjectCode,
    required this.accuracyRate,
    required this.streakDays,
    required this.totalWrongCount,
    required this.pendingReviewCount,
    required this.resolvedCount,
    required this.recentWrongCount,
    required this.reviewSuccessRate,
    required this.studyTimeHours,
    required this.lastStudyDaysAgo,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'subjectCode': subjectCode,
      'accuracyRate': accuracyRate,
      'streakDays': streakDays,
      'totalWrongCount': totalWrongCount,
      'pendingReviewCount': pendingReviewCount,
      'resolvedCount': resolvedCount,
      'recentWrongCount': recentWrongCount,
      'reviewSuccessRate': reviewSuccessRate,
      'studyTimeHours': studyTimeHours,
      'lastStudyDaysAgo': lastStudyDaysAgo,
    };
  }
}

/// 학습 비율 결과 클래스
class StudyRatio {
  final double reviewRatio; // 복습 문제 비율 (0.0-1.0)
  final double newQuestionRatio; // 새 문제 비율 (0.0-1.0)
  final int totalQuestionCount; // 총 문제 수
  final String priority; // urgent/normal/low
  final String analysis; // 분석 결과 텍스트
  
  StudyRatio({
    required this.reviewRatio,
    required this.newQuestionRatio,
    required this.totalQuestionCount,
    required this.priority,
    required this.analysis,
  });
  
  factory StudyRatio.fromJson(Map<String, dynamic> json) {
    return StudyRatio(
      reviewRatio: (json['reviewRatio'] ?? 0.3).toDouble(),
      newQuestionRatio: 1.0 - (json['reviewRatio'] ?? 0.3).toDouble(),
      totalQuestionCount: json['questionCount'] ?? 10,
      priority: json['priority'] ?? 'normal',
      analysis: json['analysis'] ?? '',
    );
  }
  
  @override
  String toString() {
    return 'StudyRatio(review: ${(reviewRatio*100).toInt()}%, '
           'new: ${(newQuestionRatio*100).toInt()}%, '
           'total: $totalQuestionCount, '
           'priority: $priority)';
  }
}