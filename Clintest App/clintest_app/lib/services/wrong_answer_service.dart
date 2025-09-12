import 'package:isar/isar.dart';
import 'database_service.dart';
import '../models/wrong_answer.dart';
import '../models/medical_exam.dart';
import '../models/nursing_exam.dart';

class WrongAnswerService {
  static final Isar _isar = DatabaseService.isar;
  
  // =================
  // 오답 수집 메서드
  // =================
  
  // 의학 문제 오답 수집
  static Future<void> addMedicalWrongAnswer({
    required String userId,
    required MedicalExam exam,
    required String userAnswer,
  }) async {
    // 이미 있는 오답인지 확인
    final existing = await _isar.wrongAnswers
        .where()
        .filter()
        .userIdEqualTo(userId)
        .and()
        .questionIdEqualTo(exam.id.toString())
        .findFirst();
    
    if (existing != null) {
      // 기존 오답 업데이트
      await _isar.writeTxn(() async {
        existing.userAnswer = userAnswer;
        existing.wrongDate = DateTime.now();
        existing.totalAttempts++;
        existing.nextReviewDate = existing.calculateNextReviewDate();
        await _isar.wrongAnswers.put(existing);
      });
    } else {
      // 새 오답 추가
      final wrongAnswer = WrongAnswer.create(
        userId: userId,
        questionId: exam.id.toString(),
        questionType: 'medical',
        subjectCode: exam.subjectCode,
        question: exam.question,
        choices: exam.choices,
        correctAnswer: exam.answer ?? '',
        userAnswer: userAnswer,
        explanation: exam.explanation,
        tags: exam.tags,
        difficulty: exam.difficulty,
      );
      
      await _isar.writeTxn(() async {
        await _isar.wrongAnswers.put(wrongAnswer);
      });
    }
  }
  
  // 간호학 문제 오답 수집
  static Future<void> addNursingWrongAnswer({
    required String userId,
    required NursingExam exam,
    required String userAnswer,
  }) async {
    // 이미 있는 오답인지 확인
    final existing = await _isar.wrongAnswers
        .where()
        .filter()
        .userIdEqualTo(userId)
        .and()
        .questionIdEqualTo(exam.id.toString())
        .findFirst();
    
    if (existing != null) {
      // 기존 오답 업데이트
      await _isar.writeTxn(() async {
        existing.userAnswer = userAnswer;
        existing.wrongDate = DateTime.now();
        existing.totalAttempts++;
        existing.nextReviewDate = existing.calculateNextReviewDate();
        await _isar.wrongAnswers.put(existing);
      });
    } else {
      // 새 오답 추가
      final wrongAnswer = WrongAnswer.create(
        userId: userId,
        questionId: exam.id.toString(),
        questionType: 'nursing',
        subjectCode: exam.subjectCode,
        question: exam.question,
        choices: exam.choices,
        correctAnswer: exam.answer ?? '',
        userAnswer: userAnswer,
        explanation: exam.explanation,
        tags: exam.tags,
        difficulty: exam.difficulty,
      );
      
      await _isar.writeTxn(() async {
        await _isar.wrongAnswers.put(wrongAnswer);
      });
    }
  }
  
  // =================
  // 오답 조회 메서드
  // =================
  
  // 모든 오답 노트 조회
  static Future<List<WrongAnswer>> getAllWrongAnswers(String userId) async {
    return await _isar.wrongAnswers
        .where()
        .filter()
        .userIdEqualTo(userId)
        .sortByWrongDateDesc()
        .findAll();
  }
  
  // 과목별 오답 노트 조회
  static Future<List<WrongAnswer>> getWrongAnswersBySubject(
    String userId,
    String subjectCode,
  ) async {
    return await _isar.wrongAnswers
        .where()
        .filter()
        .userIdEqualTo(userId)
        .and()
        .subjectCodeEqualTo(subjectCode)
        .sortByWrongDateDesc()
        .findAll();
  }
  
  // 복습이 필요한 오답들 조회
  static Future<List<WrongAnswer>> getWrongAnswersForReview(String userId) async {
    final allWrongs = await _isar.wrongAnswers
        .where()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    
    // 복습이 필요한 것들만 필터링
    return allWrongs.where((wrong) => wrong.needsReview).toList();
  }
  
  // 해결된 오답들 조회
  static Future<List<WrongAnswer>> getResolvedWrongAnswers(String userId) async {
    return await _isar.wrongAnswers
        .where()
        .filter()
        .userIdEqualTo(userId)
        .and()
        .isResolvedEqualTo(true)
        .sortByLastReviewDateDesc()
        .findAll();
  }
  
  // =================
  // 오답 복습 처리
  // =================
  
  // 오답 복습 완료
  static Future<void> completeWrongAnswerReview(
    int wrongAnswerId,
    bool wasCorrect,
  ) async {
    await _isar.writeTxn(() async {
      final wrong = await _isar.wrongAnswers.get(wrongAnswerId);
      if (wrong != null) {
        wrong.completeReview(wasCorrect);
        await _isar.wrongAnswers.put(wrong);
      }
    });
  }
  
  // 오답 삭제
  static Future<void> deleteWrongAnswer(int wrongAnswerId) async {
    await _isar.writeTxn(() async {
      await _isar.wrongAnswers.delete(wrongAnswerId);
    });
  }
  
  // =================
  // 통계 메서드
  // =================
  
  // 오답 통계 조회
  static Future<WrongAnswerStats> getWrongAnswerStats(String userId) async {
    final allWrongs = await getAllWrongAnswers(userId);
    final resolved = allWrongs.where((w) => w.isResolved).length;
    final needsReview = allWrongs.where((w) => w.needsReview).length;
    
    // 과목별 통계
    Map<String, int> subjectStats = {};
    for (final wrong in allWrongs) {
      subjectStats[wrong.subjectCode] = (subjectStats[wrong.subjectCode] ?? 0) + 1;
    }
    
    // 난이도별 통계
    Map<String, int> difficultyStats = {};
    for (final wrong in allWrongs) {
      difficultyStats[wrong.difficulty] = (difficultyStats[wrong.difficulty] ?? 0) + 1;
    }
    
    return WrongAnswerStats(
      totalWrongs: allWrongs.length,
      resolvedCount: resolved,
      needsReviewCount: needsReview,
      subjectStats: subjectStats,
      difficultyStats: difficultyStats,
    );
  }
  
  // 약점 분야 분석 
  static Future<List<String>> getWeakSubjects(String userId) async {
    final stats = await getWrongAnswerStats(userId);
    
    // 오답이 많은 과목 순으로 정렬
    final sorted = stats.subjectStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // 상위 3개 과목 반환
    return sorted.take(3).map((e) => e.key).toList();
  }
}

// 오답 통계 클래스
class WrongAnswerStats {
  final int totalWrongs;
  final int resolvedCount;
  final int needsReviewCount;
  final Map<String, int> subjectStats;
  final Map<String, int> difficultyStats;
  
  WrongAnswerStats({
    required this.totalWrongs,
    required this.resolvedCount,
    required this.needsReviewCount,
    required this.subjectStats,
    required this.difficultyStats,
  });
  
  double get resolvedRate {
    if (totalWrongs == 0) return 0.0;
    return resolvedCount / totalWrongs;
  }
}