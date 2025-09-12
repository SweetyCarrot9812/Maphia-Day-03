import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/todays_workout_plan.dart';
import '../models/exercise_recommendation.dart';
import '../utils/one_rm_calculator.dart';
import 'api_client.dart';
import 'recommendation_cache.dart';

class AICoachService {
  late final Dio _dio;
  final RecommendationCache _cache = RecommendationCache();
  
  AICoachService() {
    _dio = ApiClient().dio;
  }

  /// AI가 오늘의 운동을 분석하고 추천
  Future<TodaysWorkoutPlan> generateTodaysWorkout({
    required String userId,
    Map<String, dynamic>? currentCondition,
  }) async {
    // 1) Try cache first (per day)
    final cached = await _cache.load(userId);
    if (cached != null) {
      return cached;
    }

    // 2) Build prompt and call API
    final prompt = _buildWorkoutPrompt(userId, currentCondition);
    final aiResponse = await _callOpenAI(prompt);

    // 3) Parse and post-process
    var plan = TodaysWorkoutPlan.fromJson(aiResponse);
    if (!plan.isRestDay) {
      final adjusted = plan.exercises
          .map((e) => e.restSeconds > 0
              ? e
              : e.copyWith(
                  restSeconds: RestCalculator.suggestRestSec(
                    baseMin: 120,
                    baseMax: 180,
                    rpe: e.rpe,
                  ),
                ))
          .toList();
      plan = plan.copyWith(exercises: adjusted);
    }

    // 4) Save to cache
    await _cache.save(userId, plan);
    return plan;
  }

  /// AI가 현재 상황을 분석해서 근육군 자동 선택 (헬스 & 크로스핏 통합)
  Future<List<String>> recommendMuscleGroups({
    required String userId,
    required List<Map<String, dynamic>> recentWorkouts,
  }) async {
    final prompt = '''
사용자의 최근 2주 운동 기록을 분석하여 오늘 헬스 & 크로스핏 통합 운동할 근육군을 추천해주세요.

최근 운동 기록:
${jsonEncode(recentWorkouts)}

헬스 & 크로스핏 통합 고려사항:
1. 근육군별 회복 시간 (가슴/등/다리: 48-72시간, 팔/어깨: 24-48시간)
2. 볼륨 분배 (MEV-MAV-MRV 기준)
3. 운동 빈도와 강도 패턴
4. 전체적인 균형
5. 기능성 움직임과 근력 훈련의 조합
6. 심폐지구력과 근력의 통합적 발달

통합 훈련 접근법:
- 주요 근육군(헬스) + 기능성 움직임(크로스핏)
- 근력과 컨디셔닝의 균형
- 복합 운동 우선

다음 JSON 형식으로 응답:
{
  "primaryMuscleGroups": ["가슴 & 전신 컨디셔닝", "하체 & 파워"],
  "reasoning": "헬스와 크로스핏 통합 선택 이유",
  "restDay": false,
  "alternativeGroups": ["등 & 기능성", "전신 & 코어"]
}
''';

    final response = await _callOpenAI(prompt);
    return (response['primaryMuscleGroups'] as List)
        .map((e) => e.toString())
        .toList();
  }

  /// 개별 운동에 대한 세트 추천 (헬스 & 크로스핏 통합 관점)
  Future<ExerciseRecommendation> recommendExercise({
    required String exerciseId,
    required String userId,
    required List<Map<String, dynamic>> recentSets,
  }) async {
    final prompt = '''
운동: $exerciseId
사용자의 최근 세트 기록을 분석하여 헬스와 크로스핏을 통합한 다음 세트를 추천해주세요.

최근 세트 기록:
${jsonEncode(recentSets)}

헬스 & 크로스핏 통합 고려사항:
1. 1RM 추정 및 점진적 과부하 (헬스 원리)
2. RPE 패턴 (목표: 7-8.5)
3. 성공률 (80% 이상 유지)
4. 플레이트 라운딩 (2.5kg 또는 5lb 단위)
5. 기능성 움직임과의 연계성 (크로스핏 원리)
6. 전신 통합성과 실용성
7. 심폐지구력 요소 고려

통합 접근법:
- 전통적인 헬스 운동에 기능성 요소 추가
- 크로스핏 운동에 점진적 과부하 원리 적용
- 근력과 컨디셔닝의 균형

JSON 응답:
{
  "weight": 82.5,
  "reps": 7,
  "restSeconds": 180,
  "rpe": 8.0,
  "reasoning": "헬스 근력 발달과 크로스핏 기능성을 통합한 설정"
}
''';

    final response = await _callOpenAI(prompt);
    return ExerciseRecommendation.fromJson(response);
  }

  /// GPT-5와 실제 대화 (자연어 코칭)
  Future<String> chatWithCoach({
    required String userId,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content': '''
당신은 전문 헬스 & 크로스핏 통합 트레이너입니다. 사용자의 운동 관련 질문에 친근하고 전문적으로 답변해주세요.

역할:
- 헬스와 크로스핏을 통합한 운동 프로그램 조언
- 근력 운동과 기능성 운동의 조화로운 조합
- 폼 교정 가이드 (바벨, 덤벨, 케틀벨, 체중 운동 등)  
- 영양 및 회복 조언
- 동기부여 및 격려
- 부상 예방 조언

접근방식: 헬스의 근력과 근비대 효과와 크로스핏의 기능성 및 컨디셔닝 효과를 동시에 고려하여 최적화된 운동을 추천

말투: 친근하되 전문적이고, 한국어로 응답
''',
      },
      ...?conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];

    final response = await _dio.post('/openai/chat', data: {
      'messages': messages,
      'model': dotenv.env['OPENAI_MODEL'] ?? 'gpt-5-standard',
      'temperature': 0.7,
    });

    return response.data['message'];
  }

  String _buildWorkoutPrompt(String userId, Map<String, dynamic>? condition) {
    return '''
사용자 ID: $userId
오늘의 컨디션: ${condition ?? '정보 없음'}

헬스와 크로스핏을 통합한 오늘의 운동 계획을 세워주세요:

1. 오늘 운동할 근육군 선택 (휴식일 포함)
2. 각 운동별 세부 추천 (중량, 반복, 세트, 휴식)
3. 헬스의 근력/근비대 운동과 크로스핏의 기능성 운동을 적절히 조합
4. 추천 이유와 주의사항

운동 조합 예시:
- 바벨 스쿼트(헬스) + 박스 점프(크로스핏)
- 벤치프레스(헬스) + 버피(크로스핏) 
- 데드리프트(헬스) + 케틀벨 스윙(크로스핏)

JSON 형식으로 응답해주세요:
{
  "isRestDay": false,
  "primaryMuscleGroups": ["가슴", "삼두"],
  "exercises": [
    {
      "name": "인클라인 바벨 벤치프레스 + 푸쉬업 버피",
      "weight": 82.5,
      "reps": 7,
      "sets": 3,
      "restSeconds": 150,
      "priority": "high",
      "reasoning": "헬스 근력 강화와 크로스핏 컨디셔닝을 동시에"
    }
  ],
  "dailyReasoning": "헬스와 크로스핏 통합 훈련으로 전체적인 체력과 근력 향상을 도모합니다",
  "tips": ["헬스 동작 시 정확한 폼 유지", "크로스핏 동작 시 안전한 속도 조절"]
}
''';
  }

  Future<Map<String, dynamic>> _callOpenAI(String prompt) async {
    try {
      final response = await _dio.post('/ai/generate', data: {
        'prompt': prompt,
        'model': dotenv.env['OPENAI_MODEL'] ?? 'gpt-5-standard',
        'temperature': 0.3,
        'max_tokens': 2000,
      });
      final content = response.data is Map<String, dynamic>
          ? (response.data['content'] ?? response.data['json'])
          : null;
      if (content is String) {
        return jsonDecode(content) as Map<String, dynamic>;
      } else if (content is Map<String, dynamic>) {
        return content;
      }
      // If API already returns parsed JSON
      if (response.data is Map<String, dynamic>) {
        return (response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid AI response format');
    } catch (e) {
      // Fallback to dummy data for demo
      return _getDummyRecommendation();
    }
  }

  Map<String, dynamic> _getDummyRecommendation() {
    return {
      'isRestDay': false,
      'primaryMuscleGroups': ['가슴', '코어', '전신 컨디셔닝'],
      'exercises': [
        {
          'name': '인클라인 바벨 벤치프레스 + 푸쉬업 버피',
          'weight': 82.5,
          'reps': 7,
          'sets': 3,
          'restSeconds': 180,
          'priority': 'high',
          'reasoning': '헬스의 근력 강화와 크로스핏의 전신 컨디셔닝을 통합한 최적의 조합'
        },
        {
          'name': '바벨 스쿼트 + 박스 점프',
          'weight': 100.0,
          'reps': 8,
          'sets': 4,
          'restSeconds': 200,
          'priority': 'medium',
          'reasoning': '하체 근력과 파워, 점프력을 동시에 향상시키는 복합 운동'
        },
        {
          'name': '케틀벨 스윙 + 로우',
          'weight': 24.0,
          'reps': 15,
          'sets': 3,
          'restSeconds': 120,
          'priority': 'medium',
          'reasoning': '후면 체인 강화와 심폐지구력을 함께 키우는 기능성 운동'
        },
      ],
      'dailyReasoning': '헬스와 크로스핏을 통합하여 근력, 파워, 지구력을 균형있게 발달시키는 오늘의 통합 훈련입니다',
      'tips': [
        '헬스 동작: 정확한 폼과 점진적 과부하에 집중하세요', 
        '크로스핏 동작: 안전한 속도로 움직임의 질을 우선하세요',
        '운동 간 충분한 휴식을 통해 각 세트의 품질을 유지하세요'
      ]
    };
  }
}
