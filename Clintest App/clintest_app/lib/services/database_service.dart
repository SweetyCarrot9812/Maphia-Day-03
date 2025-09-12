import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// 데이터 모델 import
import '../models/user.dart';
import '../models/medical_subject.dart';
import '../models/medical_exam.dart';
import '../models/nursing_subject.dart';
import '../models/nursing_exam.dart';
import '../models/study_progress.dart';
import '../models/wrong_answer.dart';
import '../models/srs_card.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;
  
  DatabaseService._internal();
  
  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }
  
  static Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call DatabaseService.init() first.');
    }
    return _isar!;
  }
  
  // 데이터베이스 초기화
  static Future<void> init() async {
    if (_isar != null) return; // 이미 초기화된 경우
    
    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [
        UserSchema,
        MedicalSubjectSchema,
        MedicalExamSchema,
        NursingSubjectSchema,
        NursingExamSchema,
        StudyProgressSchema,
        WrongAnswerSchema,
        SRSCardSchema,
      ],
      directory: dir.path,
      name: 'clintest_db',
    );
  }
  
  // 데이터베이스 종료
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
  
  // =================
  // User 관련 메서드
  // =================
  
  Future<User?> getCurrentUser() async {
    return await isar.users.where().findFirst();
  }
  
  Future<User> createUser({
    required String name,
    required String email,
    required String studentId,
    required String school,
    required int grade,
    String? selectedField,
  }) async {
    final user = User.create(
      name: name,
      email: email,
      studentId: studentId,
      school: school,
      grade: grade,
      selectedField: selectedField,
    );
    
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
    
    return user;
  }
  
  // =================
  // Subject 관련 메서드  
  // =================
  
  Future<List<MedicalSubject>> getAllMedicalSubjects() async {
    return await isar.medicalSubjects
        .where()
        .filter()
        .activeEqualTo(true)
        .sortByOrder()
        .findAll();
  }
  
  Future<List<NursingSubject>> getAllNursingSubjects() async {
    return await isar.nursingSubjects
        .where()
        .filter()
        .activeEqualTo(true)
        .sortByOrder()
        .findAll();
  }
  
  // =================
  // Exam 관련 메서드
  // =================
  
  Future<List<MedicalExam>> getMedicalExamsBySubject(String subjectCode) async {
    return await isar.medicalExams
        .where()
        .filter()
        .subjectCodeEqualTo(subjectCode)
        .findAll();
  }
  
  Future<List<NursingExam>> getNursingExamsBySubject(String subjectCode) async {
    return await isar.nursingExams
        .where()
        .filter()
        .subjectCodeEqualTo(subjectCode)
        .findAll();
  }
  
  // 문제 업데이트 (정답/오답 처리)
  Future<void> updateMedicalExamResult(int examId, bool isCorrect) async {
    await isar.writeTxn(() async {
      final exam = await isar.medicalExams.get(examId);
      if (exam != null) {
        exam.attempts++;
        if (isCorrect) {
          exam.correctCount++;
        }
        exam.lastAttempted = DateTime.now();
        await isar.medicalExams.put(exam);
      }
    });
  }
  
  Future<void> updateNursingExamResult(int examId, bool isCorrect) async {
    await isar.writeTxn(() async {
      final exam = await isar.nursingExams.get(examId);
      if (exam != null) {
        exam.attempts++;
        if (isCorrect) {
          exam.correctCount++;
        }
        exam.lastAttempted = DateTime.now();
        await isar.nursingExams.put(exam);
      }
    });
  }
  
  // =================
  // StudyProgress 관련 메서드
  // =================
  
  Future<StudyProgress?> getStudyProgress(String userId, String subjectCode) async {
    return await isar.studyProgress
        .where()
        .filter()
        .userIdEqualTo(userId)
        .and()
        .subjectCodeEqualTo(subjectCode)
        .findFirst();
  }
  
  Future<List<StudyProgress>> getAllStudyProgress(String userId) async {
    return await isar.studyProgress
        .where()
        .filter()
        .userIdEqualTo(userId)
        .findAll();
  }
  
  Future<void> updateStudyProgress({
    required String userId,
    required String subjectCode,
    required bool isCorrect,
    required int studyTimeSeconds,
  }) async {
    await isar.writeTxn(() async {
      StudyProgress? progress = await getStudyProgress(userId, subjectCode);
      
      progress ??= StudyProgress.create(
          userId: userId,
          subjectCode: subjectCode,
        );
      
      progress.attemptedQuestions++;
      if (isCorrect) {
        progress.correctAnswers++;
      }
      progress.accuracyRate = progress.correctAnswers / progress.attemptedQuestions;
      progress.studyTimeSeconds += studyTimeSeconds;
      progress.lastStudyDate = DateTime.now();
      progress.updatedAt = DateTime.now();
      
      // 연속 학습일 계산
      final now = DateTime.now();
      final lastStudy = progress.lastStudyDate;
      if (lastStudy != null) {
        final difference = now.difference(lastStudy).inDays;
        if (difference == 1) {
          progress.streakDays++;
        } else if (difference > 1) {
          progress.streakDays = 1; // 연속 학습 중단, 다시 시작
        }
      } else {
        progress.streakDays = 1; // 첫 학습
      }
      
      await isar.studyProgress.put(progress);
    });
  }
}