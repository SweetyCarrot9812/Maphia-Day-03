// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '아름핏';

  @override
  String get loading => '로딩 중...';

  @override
  String get error => '오류';

  @override
  String get retry => '다시 시도';

  @override
  String get refresh => '새로고침';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get back => '뒤로';

  @override
  String get next => '다음';

  @override
  String get done => '완료';

  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

  @override
  String get tomorrow => '내일';

  @override
  String get navRecommendation => '추천';

  @override
  String get navWorkout => '운동';

  @override
  String get navCalendar => '캘린더';

  @override
  String get navChat => '채팅';

  @override
  String get navProfile => '프로필';

  @override
  String get recommendationTitle => '오늘의 운동';

  @override
  String get analyzingWorkout => '오늘의 운동을 분석하고 있습니다...';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String get cannotLoadWorkout => '운동 계획을 불러올 수 없습니다';

  @override
  String get restDay => '오늘은 휴식일입니다';

  @override
  String get restDayMessage => '근육 회복과 성장을 위해 충분한 휴식을 취하세요.';

  @override
  String get targetMuscleGroups => '오늘의 타겟 근육군';

  @override
  String get recommendedExercises => '추천 운동';

  @override
  String get todaysTips => '오늘의 팁';

  @override
  String get viewDetails => '상세 보기';

  @override
  String get startExercise => '시작하기';

  @override
  String get dailyReasoning => '일일 분석';

  @override
  String restTime(int seconds) {
    return '휴식: $seconds초';
  }

  @override
  String exerciseStarted(String exerciseName) {
    return '$exerciseName 운동을 시작합니다!';
  }

  @override
  String get workoutTitle => '운동 기록';

  @override
  String get currentSession => '현재 세션';

  @override
  String get startSession => '세션 시작';

  @override
  String get endSession => '세션 종료';

  @override
  String get addExercise => '운동 추가';

  @override
  String get exerciseName => '운동명';

  @override
  String get weight => '중량';

  @override
  String get reps => '횟수';

  @override
  String get sets => '세트';

  @override
  String get rpe => 'RPE';

  @override
  String get logSet => '세트 기록';

  @override
  String get sessionNotes => '세션 메모';

  @override
  String get totalVolume => '총 볼륨';

  @override
  String get totalSets => '총 세트';

  @override
  String get calendarTitle => '운동 캘린더';

  @override
  String get workoutHistory => '운동 기록';

  @override
  String get noWorkoutsOnDate => '이 날짜에는 운동 기록이 없습니다';

  @override
  String get chatTitle => 'AI 코치';

  @override
  String get typeMessage => '메시지를 입력하세요...';

  @override
  String get send => '전송';

  @override
  String get quickQuestions => '빠른 질문';

  @override
  String get howToImproveForm => '폼을 개선하려면 어떻게 해야 하나요?';

  @override
  String get whatToEatPostWorkout => '운동 후 무엇을 먹어야 하나요?';

  @override
  String get howToIncreaseStrength => '근력을 늘리려면 어떻게 해야 하나요?';

  @override
  String get restDayActivities => '휴식일에는 무엇을 해야 하나요?';

  @override
  String get profileTitle => '프로필';

  @override
  String get personalInfo => '개인 정보';

  @override
  String get fitnessGoals => '피트니스 목표';

  @override
  String get preferences => '선택사항';

  @override
  String get settings => '설정';

  @override
  String get name => '이름';

  @override
  String get age => '나이';

  @override
  String get height => '키';

  @override
  String get currentWeight => '현재 체중';

  @override
  String get targetWeight => '목표 체중';

  @override
  String get experienceLevel => '경험 수준';

  @override
  String get beginner => '초보자';

  @override
  String get intermediate => '중급자';

  @override
  String get advanced => '고급자';

  @override
  String get primaryGoal => '주요 목표';

  @override
  String get muscleGain => '근육 증가';

  @override
  String get weightLoss => '체중 감량';

  @override
  String get strengthBuilding => '근력 강화';

  @override
  String get enduranceImprovement => '지구력 향상';

  @override
  String get workoutFrequency => '운동 빈도';

  @override
  String timesPerWeek(int times) {
    return '주 $times회';
  }

  @override
  String get networkError => '인터넷 연결을 확인해주세요';

  @override
  String get aiServiceError => 'AI 서비스 연결에 문제가 있습니다';

  @override
  String get unknownError => '알 수 없는 오류가 발생했습니다';

  @override
  String get pleaseEnterExerciseName => '운동명을 입력해주세요';

  @override
  String get pleaseEnterValidWeight => '유효한 중량을 입력해주세요';

  @override
  String get pleaseEnterValidReps => '유효한 횟수를 입력해주세요';

  @override
  String get kg => 'kg';

  @override
  String get lbs => '파운드';

  @override
  String get cm => 'cm';

  @override
  String get ft => '피트';

  @override
  String get seconds => '초';

  @override
  String get minutes => '분';

  @override
  String get high => '높음';

  @override
  String get medium => '보통';

  @override
  String get low => '낮음';
}
