import '../models/medical_exam.dart';
import '../models/nursing_exam.dart';
import '../models/wrong_answer.dart';
import 'database_service.dart';
import 'wrong_answer_service.dart';
import 'ai_study_optimizer.dart';
import 'storage_service.dart';

/// GPT-5 Standard 기반 스마트 학습 시스템
/// 새 문제 + 복습 문제 AI 최적화 혼합
class SmartStudyService {
  
  /// GPT-5 Standard 최적화 의학 학습 세트 생성
  static Future<List<StudyQuestion>> generateMedicalStudySet({
    required String userId,
    required String subjectCode,
    int? questionCount, // null이면 AI가 최적값 결정
  }) async {
    // 1. GPT-5 Standard로 최적 학습 비율 분석
    final studyRatio = await AIStudyOptimizer.calculateOptimalRatio(
      userId: userId,
      subjectCode: subjectCode,
    );
    
    final totalCount = questionCount ?? studyRatio.totalQuestionCount;
    final reviewCount = (totalCount * studyRatio.reviewRatio).round();
    final newCount = totalCount - reviewCount;
    
    // 1. 복습 문제 가져오기
    final reviewQuestions = await _getMedicalReviewQuestions(
      userId,
      subjectCode,
      reviewCount,
    );
    
    // 2. 새로운 문제 가져오기 (이미 푼 문제 제외)
    final newQuestions = await _getNewMedicalQuestions(
      userId,
      subjectCode,
      newCount,
    );
    
    // 3. 문제 섞기
    final allQuestions = <StudyQuestion>[];
    allQuestions.addAll(reviewQuestions);
    allQuestions.addAll(newQuestions);
    allQuestions.shuffle();
    
    return allQuestions;
  }
  
  /// GPT-5 Standard 최적화 간호학 학습 세트 생성
  static Future<List<StudyQuestion>> generateNursingStudySet({
    required String userId,
    required String subjectCode,
    int? questionCount, // null이면 AI가 최적값 결정
  }) async {
    // 1. GPT-5 Standard로 최적 학습 비율 분석
    final studyRatio = await AIStudyOptimizer.calculateOptimalRatio(
      userId: userId,
      subjectCode: subjectCode,
    );
    
    final totalCount = questionCount ?? studyRatio.totalQuestionCount;
    final reviewCount = (totalCount * studyRatio.reviewRatio).round();
    final newCount = totalCount - reviewCount;
    
    // 1. 복습 문제 가져오기
    final reviewQuestions = await _getNursingReviewQuestions(
      userId,
      subjectCode,
      reviewCount,
    );
    
    // 2. 새로운 문제 가져오기 (이미 푼 문제 제외)
    final newQuestions = await _getNewNursingQuestions(
      userId,
      subjectCode,
      newCount,
    );
    
    // 3. 문제 섞기
    final allQuestions = <StudyQuestion>[];
    allQuestions.addAll(reviewQuestions);
    allQuestions.addAll(newQuestions);
    allQuestions.shuffle();
    
    return allQuestions;
  }
  
  // ===================
  // 복습 문제 가져오기
  // ===================
  
  static Future<List<StudyQuestion>> _getMedicalReviewQuestions(
    String userId,
    String subjectCode,
    int count,
  ) async {
    if (count <= 0) return [];
    
    // 복습이 필요한 오답 문제들
    final wrongAnswers = await WrongAnswerService.getWrongAnswersForReview(userId);
    final subjectWrongs = wrongAnswers
        .where((w) => w.subjectCode == subjectCode && w.questionType == 'medical')
        .toList();
    
    // 우선순위: 복습 날짜가 지난 것부터
    subjectWrongs.sort((a, b) {
      if (a.nextReviewDate == null) return -1;
      if (b.nextReviewDate == null) return 1;
      return a.nextReviewDate!.compareTo(b.nextReviewDate!);
    });
    
    // 필요한 만큼만 가져오기
    final selected = subjectWrongs.take(count).toList();
    
    return selected.map((wrong) => StudyQuestion.fromWrongAnswer(wrong)).toList();
  }
  
  static Future<List<StudyQuestion>> _getNursingReviewQuestions(
    String userId,
    String subjectCode,
    int count,
  ) async {
    if (count <= 0) return [];
    
    // 복습이 필요한 오답 문제들
    final wrongAnswers = await WrongAnswerService.getWrongAnswersForReview(userId);
    final subjectWrongs = wrongAnswers
        .where((w) => w.subjectCode == subjectCode && w.questionType == 'nursing')
        .toList();
    
    // 우선순위: 복습 날짜가 지난 것부터
    subjectWrongs.sort((a, b) {
      if (a.nextReviewDate == null) return -1;
      if (b.nextReviewDate == null) return 1;
      return a.nextReviewDate!.compareTo(b.nextReviewDate!);
    });
    
    // 필요한 만큼만 가져오기
    final selected = subjectWrongs.take(count).toList();
    
    return selected.map((wrong) => StudyQuestion.fromWrongAnswer(wrong)).toList();
  }
  
  // ===================
  // 새로운 문제 가져오기
  // ===================
  
  static Future<List<StudyQuestion>> _getNewMedicalQuestions(
    String userId,
    String subjectCode,
    int count,
  ) async {
    if (count <= 0) return [];
    
    // 전체 문제 가져오기
    final allExams = await DatabaseService.instance.getMedicalExamsBySubject(subjectCode);
    
    // 아직 안 푼 문제들 필터링
    final unsolvedExams = allExams.where((exam) => exam.attempts == 0).toList();
    
    // 랜덤 섞기 후 필요한 만큼 가져오기
    unsolvedExams.shuffle();
    final selected = unsolvedExams.take(count).toList();
    
    return selected.map((exam) => StudyQuestion.fromMedicalExam(exam)).toList();
  }
  
  static Future<List<StudyQuestion>> _getNewNursingQuestions(
    String userId,
    String subjectCode,
    int count,
  ) async {
    if (count <= 0) return [];
    
    // 전체 문제 가져오기
    final allExams = await DatabaseService.instance.getNursingExamsBySubject(subjectCode);
    
    // 아직 안 푼 문제들 필터링
    final unsolvedExams = allExams.where((exam) => exam.attempts == 0).toList();
    
    // 랜덤 섞기 후 필요한 만큼 가져오기
    unsolvedExams.shuffle();
    final selected = unsolvedExams.take(count).toList();
    
    return selected.map((exam) => StudyQuestion.fromNursingExam(exam)).toList();
  }
  
  // ===================
  // 학습 결과 처리
  // ===================
  
  /// 학습 결과 처리 (정답/오답 모두)
  static Future<void> processStudyResult({
    required String userId,
    required StudyQuestion question,
    required String userAnswer,
    required bool isCorrect,
    required int studyTimeSeconds,
  }) async {
    // 1. 원본 문제 통계 업데이트
    if (question.questionType == 'medical' && question.originalId != null) {
      await DatabaseService.instance.updateMedicalExamResult(
        question.originalId!,
        isCorrect,
      );
    } else if (question.questionType == 'nursing' && question.originalId != null) {
      await DatabaseService.instance.updateNursingExamResult(
        question.originalId!,
        isCorrect,
      );
    }
    
    // 2. 학습 진도 업데이트
    await DatabaseService.instance.updateStudyProgress(
      userId: userId,
      subjectCode: question.subjectCode,
      isCorrect: isCorrect,
      studyTimeSeconds: studyTimeSeconds,
    );
    
    // 2-1. 일일 통계 업데이트 (통계 화면을 위한 실제 데이터)
    await _updateDailyStatistics(isCorrect);
    
    // 3. 복습 문제인 경우 복습 완료 처리
    if (question.isReview && question.wrongAnswerId != null) {
      await WrongAnswerService.completeWrongAnswerReview(
        question.wrongAnswerId!,
        isCorrect,
      );
    }
    
    // 4. 틀린 경우 오답 노트에 추가
    if (!isCorrect) {
      if (question.questionType == 'medical') {
        // MedicalExam 객체 생성 후 오답 추가
        final exam = MedicalExam.create(
          subject: question.subjectCode, // subject 필드 추가
          subjectCode: question.subjectCode,
          question: question.question,
          choices: question.choices,
          correctAnswer: question.choices.indexOf(question.correctAnswer), // correctAnswer 인덱스
          difficulty: question.difficulty,
          explanation: question.explanation ?? '',
          tags: question.tags,
        );
        exam.id = question.originalId ?? 0;
        
        await WrongAnswerService.addMedicalWrongAnswer(
          userId: userId,
          exam: exam,
          userAnswer: userAnswer,
        );
      } else if (question.questionType == 'nursing') {
        // NursingExam 객체 생성 후 오답 추가
        final exam = NursingExam.create(
          subject: question.subjectCode, // subject 필드 추가
          subjectCode: question.subjectCode,
          question: question.question,
          choices: question.choices,
          correctAnswer: question.choices.indexOf(question.correctAnswer), // correctAnswer 인덱스
          difficulty: question.difficulty,
          explanation: question.explanation ?? '',
          tags: question.tags,
        );
        exam.id = question.originalId ?? 0;
        
        await WrongAnswerService.addNursingWrongAnswer(
          userId: userId,
          exam: exam,
          userAnswer: userAnswer,
        );
      }
    }
  }
  
  /// 일일 통계 업데이트 (통계 화면용 실제 데이터)
  static Future<void> _updateDailyStatistics(bool isCorrect) async {
    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // 오늘의 총 문제 수 증가
      final currentProblems = StorageService.getInt('daily_problems_$dateKey', defaultValue: 0);
      await StorageService.setInt('daily_problems_$dateKey', currentProblems + 1);
      
      // 정답인 경우 정답 수 증가
      if (isCorrect) {
        final currentCorrect = StorageService.getInt('daily_correct_$dateKey', defaultValue: 0);
        await StorageService.setInt('daily_correct_$dateKey', currentCorrect + 1);
      }
      
      print('일일 통계 업데이트: $dateKey, 정답여부: $isCorrect');
    } catch (e) {
      print('일일 통계 업데이트 실패: $e');
    }
  }
}

/// 통합 학습용 문제 클래스
class StudyQuestion {
  final String question;
  final List<String> choices;
  final String correctAnswer;
  final String? explanation;
  final List<String> tags;
  final String difficulty;
  final String subjectCode;
  final String questionType; // 'medical' 또는 'nursing'
  final bool isReview; // 복습 문제인지 여부
  
  // 원본 데이터 참조
  final int? originalId; // MedicalExam 또는 NursingExam의 ID
  final int? wrongAnswerId; // 복습 문제인 경우 WrongAnswer ID
  
  StudyQuestion({
    required this.question,
    required this.choices,
    required this.correctAnswer,
    this.explanation,
    this.tags = const [],
    required this.difficulty,
    required this.subjectCode,
    required this.questionType,
    this.isReview = false,
    this.originalId,
    this.wrongAnswerId,
  });
  
  // MedicalExam으로부터 생성 (새 문제)
  factory StudyQuestion.fromMedicalExam(MedicalExam exam) {
    return StudyQuestion(
      question: exam.question,
      choices: exam.choices,
      correctAnswer: exam.answer ?? '',
      explanation: exam.explanation,
      tags: exam.tags,
      difficulty: exam.difficulty,
      subjectCode: exam.subjectCode,
      questionType: 'medical',
      isReview: false,
      originalId: exam.id,
    );
  }
  
  // NursingExam으로부터 생성 (새 문제)
  factory StudyQuestion.fromNursingExam(NursingExam exam) {
    return StudyQuestion(
      question: exam.question,
      choices: exam.choices,
      correctAnswer: exam.answer ?? '',
      explanation: exam.explanation,
      tags: exam.tags,
      difficulty: exam.difficulty,
      subjectCode: exam.subjectCode,
      questionType: 'nursing',
      isReview: false,
      originalId: exam.id,
    );
  }
  
  // WrongAnswer로부터 생성 (복습 문제)
  factory StudyQuestion.fromWrongAnswer(WrongAnswer wrong) {
    return StudyQuestion(
      question: wrong.question,
      choices: wrong.choices,
      correctAnswer: wrong.correctAnswer,
      explanation: wrong.explanation,
      tags: wrong.tags,
      difficulty: wrong.difficulty,
      subjectCode: wrong.subjectCode,
      questionType: wrong.questionType,
      isReview: true,
      originalId: int.tryParse(wrong.questionId),
      wrongAnswerId: wrong.id,
    );
  }
}