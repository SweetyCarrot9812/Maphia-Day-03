import '../models/user.dart';
import '../models/medical_subject.dart';
import '../models/medical_exam.dart';
import '../models/nursing_subject.dart';
import '../models/nursing_exam.dart';
import '../models/wrong_answer.dart';
import 'database_service.dart';

/// 샘플 데이터 생성 서비스
class SampleDataService {
  
  /// 모든 샘플 데이터 초기화
  static Future<void> initializeSampleData() async {
    try {
      // 이미 데이터가 있는지 확인
      final existingSubjects = await DatabaseService.instance.getAllMedicalSubjects();
      if (existingSubjects.isNotEmpty) {
        print('샘플 데이터가 이미 존재합니다.');
        return;
      }

      print('샘플 데이터 생성 시작...');

      // 1. 의료 과목 데이터
      await _createMedicalSubjects();
      
      // 2. 간호 과목 데이터  
      await _createNursingSubjects();

      print('샘플 데이터 생성 완료!');
      
    } catch (e) {
      print('샘플 데이터 생성 오류: $e');
    }
  }

  /// 테스트 사용자 생성
  static Future<User> createTestUser() async {
    final user = await DatabaseService.instance.createUser(
      name: '김의료',
      email: 'test@clintest.com', 
      studentId: '2024001',
      school: '한국의료대학교',
      grade: 3,
      selectedField: '간호학과',
    );
    
    print('테스트 사용자 생성: ${user.name} (ID: ${user.id})');
    return user;
  }

  /// 의료 과목 데이터 생성
  static Future<void> _createMedicalSubjects() async {
    final subjects = [
      MedicalSubject.create(
        code: 'MED_ANATOMY',
        name: '해부학',
        description: '인체 구조와 해부학적 지식',
        category: '기초의학',
        order: 1,
      ),
      MedicalSubject.create(
        code: 'MED_PHYSIOLOGY', 
        name: '생리학',
        description: '인체 기능과 생리학적 원리',
        category: '기초의학',
        order: 2,
      ),
      MedicalSubject.create(
        code: 'MED_PHARMACOLOGY',
        name: '약리학', 
        description: '약물의 작용과 상호작용',
        category: '기초의학',
        order: 3,
      ),
      MedicalSubject.create(
        code: 'MED_INTERNAL',
        name: '내과학',
        description: '내과 질환의 진단과 치료', 
        category: '임상의학',
        order: 4,
      ),
      MedicalSubject.create(
        code: 'MED_SURGERY',
        name: '외과학',
        description: '수술적 치료와 외과 질환',
        category: '임상의학', 
        order: 5,
      ),
    ];

    for (final subject in subjects) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.medicalSubjects.put(subject);
      });
    }
  }

  /// 간호 과목 데이터 생성
  static Future<void> _createNursingSubjects() async {
    final subjects = [
      NursingSubject.create(
        code: 'NUR_FUNDAMENTAL',
        name: '기본간호학',
        description: '간호의 기본 원리와 기술',
        category: '기초간호',
        order: 1,
      ),
      NursingSubject.create(
        code: 'NUR_ADULT',
        name: '성인간호학', 
        description: '성인 대상 간호 이론과 실무',
        category: '임상간호',
        order: 2,
      ),
      NursingSubject.create(
        code: 'NUR_PEDIATRIC',
        name: '아동간호학',
        description: '아동과 청소년 간호',
        category: '임상간호',
        order: 3,
      ),
      NursingSubject.create(
        code: 'NUR_MATERNAL',
        name: '모성간호학',
        description: '임산부와 여성 건강 간호',
        category: '임상간호', 
        order: 4,
      ),
      NursingSubject.create(
        code: 'NUR_PSYCHIATRIC', 
        name: '정신간호학',
        description: '정신 건강과 정신간호',
        category: '임상간호',
        order: 5,
      ),
    ];

    for (final subject in subjects) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.nursingSubjects.put(subject);
      });
    }
  }

  /// 의료 문제 데이터 생성
  static Future<void> _createMedicalExams() async {
    // 해부학 문제들
    final anatomyExams = [
      MedicalExam.create(
        subject: '해부학',
        subjectCode: 'MED_ANATOMY',
        question: '심장의 4개 방은 무엇인가?',
        choices: ['우심방, 우심실, 좌심방, 좌심실', '우심방, 좌심방만 있다', '우심실, 좌심실만 있다', '심방 2개, 심실 1개'],
        correctAnswer: 0,
        difficulty: 'easy',
        explanation: '심장은 우심방(right atrium), 우심실(right ventricle), 좌심방(left atrium), 좌심실(left ventricle)의 4개 방으로 구성되어 있습니다.',
        tags: ['심장', '해부', '순환계'],
      ),
      MedicalExam.create(
        subject: '해부학',
        subjectCode: 'MED_ANATOMY', 
        question: '인체에서 가장 긴 뼈는?',
        choices: ['대퇴골', '정강이뼈', '팔뼈', '갈비뼈'],
        correctAnswer: 0,
        explanation: '대퇴골(femur)은 인체에서 가장 길고 강한 뼈입니다.',
        difficulty: 'easy',
        tags: ['뼈', '골격계'],
      ),
      MedicalExam.create(
        subject: '해부학',
        subjectCode: 'MED_ANATOMY',
        question: '뇌의 어느 부분이 균형과 조정을 담당하는가?',
        choices: ['대뇌', '소뇌', '뇌줄기', '간뇌'],
        correctAnswer: 1,
        explanation: '소뇌(cerebellum)는 균형, 자세, 운동 조정을 담당하는 뇌 부위입니다.',
        difficulty: 'medium',
        tags: ['뇌', '신경계', '소뇌'],
      ),
    ];

    // 생리학 문제들
    final physiologyExams = [
      MedicalExam.create(
        subject: '생리학',
        subjectCode: 'MED_PHYSIOLOGY',
        question: '정상 성인의 휴식 시 심박수는?',
        choices: ['40-60회/분', '60-100회/분', '100-120회/분', '120-140회/분'],
        correctAnswer: 1, // 2번. 60-100회/분
        explanation: '정상 성인의 휴식 시 심박수는 분당 60-100회입니다.',
        difficulty: 'easy',
        tags: ['심박수', '순환계', '생체징후'],
      ),
      MedicalExam.create(
        subject: '생리학',
        subjectCode: 'MED_PHYSIOLOGY',
        question: '혈압에서 수축기압과 이완기압의 차이를 무엇이라 하는가?',
        choices: ['평균동맥압', '맥압', '중심정맥압', '폐동맥압'], 
        correctAnswer: 1, // 2번. 맥압
        explanation: '맥압(pulse pressure)은 수축기압에서 이완기압을 뺀 값입니다.',
        difficulty: 'medium',
        tags: ['혈압', '맥압', '순환계'],
      ),
    ];

    // 약리학 문제들  
    final pharmacologyExams = [
      MedicalExam.create(
        subject: '약리학',
        subjectCode: 'MED_PHARMACOLOGY',
        question: '아스피린의 주요 작용 기전은?',
        choices: ['COX 억제', 'ACE 억제', '칼슘채널 차단', '베타수용체 차단'],
        correctAnswer: 0, // 1번. COX 억제
        explanation: '아스피린은 cyclooxygenase(COX) 효소를 억제하여 항염, 해열, 진통 효과를 나타냅니다.',
        difficulty: 'medium',
        tags: ['아스피린', 'COX억제제', '항염제'],
      ),
    ];

    final allExams = [...anatomyExams, ...physiologyExams, ...pharmacologyExams];

    for (final exam in allExams) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.medicalExams.put(exam);
      });
    }
  }

  /// 간호 문제 데이터 생성  
  static Future<void> _createNursingExams() async {
    // 기본간호학 문제들
    final fundamentalExams = [
      NursingExam.create(
        subject: '기본간호학',
        subjectCode: 'NUR_FUNDAMENTAL',
        question: '손위생을 시행해야 하는 5가지 시점 중 해당하지 않는 것은?',
        choices: ['환자 접촉 전', '청결/무균술 전', '체액 노출 위험 후', '환자 접촉 후', '환자와 대화 후'],
        correctAnswer: 4, // 5번. 환자와 대화 후
        explanation: 'WHO의 손위생 5시점은 환자 접촉 전/후, 청결/무균술 전, 체액 노출 위험 후, 환자 주변 환경 접촉 후입니다.',
        difficulty: 'easy',
        tags: ['손위생', '감염관리', '기본간호'],
      ),
      NursingExam.create(
        subject: '기본간호학',
        subjectCode: 'NUR_FUNDAMENTAL', 
        question: '활력징후 측정 시 정확한 방법은?',
        choices: ['체온은 식사 직후 측정', '맥박은 30초간 측정하여 2배', '혈압은 팔을 심장보다 높게', '호흡수는 환자가 모르게 측정'],
        correctAnswer: 3, // 4번. 호흡수는 환자가 모르게 측정
        explanation: '호흡수는 환자가 의식하지 않을 때 정확하게 측정됩니다. 의식하면 호흡 패턴이 변할 수 있습니다.',
        difficulty: 'medium',
        tags: ['활력징후', '호흡수', '측정법'],
      ),
    ];

    // 성인간호학 문제들
    final adultExams = [
      NursingExam.create(
        subject: '성인간호학',
        subjectCode: 'NUR_ADULT',
        question: '당뇨병 환자의 혈당 목표치는?',
        choices: ['70-100 mg/dL', '80-130 mg/dL', '140-180 mg/dL', '200 mg/dL 이하'],
        correctAnswer: 1, // 2번. 80-130 mg/dL
        explanation: '당뇨병 환자의 식전 혈당 목표치는 일반적으로 80-130 mg/dL입니다.',
        difficulty: 'easy',
        tags: ['당뇨병', '혈당관리', '성인간호'],
      ),
      NursingExam.create(
        subject: '성인간호학',
        subjectCode: 'NUR_ADULT',
        question: '심근경색의 전형적인 흉통 특징은?',
        choices: ['찌르는 듯한 날카로운 통증', '압박감과 쥐어짜는 듯한 통증', '콕콕 찌르는 통증', '숨쉴 때만 아픈 통증'],
        correctAnswer: 1, // 2번. 압박감과 쥐어짜는 듯한 통증
        explanation: '심근경색의 전형적인 흉통은 압박감, 쥐어짜는 듯한 통증으로 묘사됩니다.',
        difficulty: 'medium', 
        tags: ['심근경색', '흉통', '심혈관'],
      ),
    ];

    // 아동간호학 문제들
    final pediatricExams = [
      NursingExam.create(
        subject: '아동간호학',
        subjectCode: 'NUR_PEDIATRIC',
        question: '영아의 정상 호흡수는?',
        choices: ['12-20회/분', '20-30회/분', '30-60회/분', '60-80회/분'],
        correctAnswer: 2, // 3번. 30-60회/분
        explanation: '영아(1세 미만)의 정상 호흡수는 분당 30-60회입니다.',
        difficulty: 'easy',
        tags: ['영아', '호흡수', '정상수치'],
      ),
    ];

    final allExams = [...fundamentalExams, ...adultExams, ...pediatricExams];

    for (final exam in allExams) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.nursingExams.put(exam);
      });
    }
  }

  /// 테스트 오답 데이터 생성 (스마트 학습 시스템 테스트용)
  static Future<void> createTestWrongAnswers(String userId) async {
    // 의료 문제 오답 데이터
    final medicalExams = await DatabaseService.instance.getMedicalExamsBySubject('MED_ANATOMY');
    if (medicalExams.isNotEmpty) {
      final wrongAnswer = WrongAnswer.create(
        userId: userId,
        questionId: medicalExams.first.id.toString(),
        questionType: 'medical',
        subjectCode: 'MED_ANATOMY',
        question: medicalExams.first.question,
        choices: medicalExams.first.choices,
        correctAnswer: medicalExams.first.choices[0], // 첫 번째 선택지를 정답으로
        userAnswer: medicalExams.first.choices[2], // 세 번째 선택지를 오답으로
        explanation: medicalExams.first.explanation,
        difficulty: medicalExams.first.difficulty,
      );

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.wrongAnswers.put(wrongAnswer);
      });
    }

    // 간호 문제 오답 데이터
    final nursingExams = await DatabaseService.instance.getNursingExamsBySubject('NUR_FUNDAMENTAL');
    if (nursingExams.isNotEmpty) {
      final wrongAnswer = WrongAnswer.create(
        userId: userId,
        questionId: nursingExams.first.id.toString(),
        questionType: 'nursing', 
        subjectCode: 'NUR_FUNDAMENTAL',
        question: nursingExams.first.question,
        choices: nursingExams.first.choices,
        correctAnswer: nursingExams.first.choices[4], // 다섯 번째 선택지를 정답으로
        userAnswer: nursingExams.first.choices[1], // 두 번째 선택지를 오답으로
        explanation: nursingExams.first.explanation,
        difficulty: nursingExams.first.difficulty,
      );

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.wrongAnswers.put(wrongAnswer);
      });
    }
  }

  /// 테스트 학습 진도 데이터 생성
  static Future<void> createTestStudyProgress(String userId) async {
    // 실제 데이터만 사용하므로 더미 데이터 생성하지 않음
    // 사용자가 실제로 문제를 풀면 그때 데이터가 생성됨
    print('실제 학습 데이터만 사용 - 더미 데이터 생성 안함');
  }

  /// 데이터베이스 초기화 (개발/테스트용)
  static Future<void> clearAllData() async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.clear();
    });
    print('모든 데이터 삭제 완료');
  }
}