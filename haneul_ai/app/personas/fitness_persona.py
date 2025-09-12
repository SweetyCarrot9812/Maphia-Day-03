"""
Fitness Persona for Haneul AI Agent
AI Personal Trainer specializing in workout planning and fitness coaching
"""

import openai
import json
from typing import Dict, Any, List
from loguru import logger

from app.config.settings import get_settings
from app.models.schemas import PriorityAnalysis
from .base_persona import BasePersona

settings = get_settings()


class FitnessPersona(BasePersona):
    """AI Personal Trainer persona for workout planning and coaching"""
    
    def __init__(self):
        super().__init__(
            name="헬스 트레이너",
            description="개인 맞춤형 AI 헬스 트레이너 - 운동 루틴 설계, 진행 관리, 맞춤 피드백 제공",
            model="gpt-5"
        )
        self.client = openai.OpenAI(api_key=settings.openai_api_key)
        
        # 헬스 전용 프롬프트
        self.specialized_prompts = {
            "workout_plan": self._get_workout_plan_prompt(),
            "progress_analysis": self._get_progress_analysis_prompt(),
            "feedback_generation": self._get_feedback_prompt()
        }
    
    def get_system_prompt(self) -> str:
        """헬스 트레이너 전용 시스템 프롬프트"""
        return """당신은 전문 헬스 트레이너 AI입니다. GPT-5의 고도화된 분석 능력을 활용하여:

1. 개인별 목표와 체력 수준에 맞는 맞춤형 운동 루틴을 설계합니다
2. 바디빌딩 기초 → 크로스핏 고급 단계로 체계적 진행 관리
3. 운동 기록을 분석하여 구체적이고 실행 가능한 피드백 제공
4. 부상 방지와 효율적 진행을 위한 과학적 조언

전문적이지만 친근한 톤으로, 초보자도 이해하기 쉽게 설명합니다.
모든 응답은 안전을 최우선으로 하며, 의학적 조언은 피합니다."""

    def get_capabilities(self) -> List[str]:
        """헬스 트레이너 역량 목록"""
        return [
            "맞춤형 운동 루틴 설계",
            "진행 상황 분석 및 평가",
            "중량/횟수 증진 계획",
            "바디빌딩 → 크로스핏 단계별 전환",
            "부상 방지 가이드",
            "영양 및 휴식 기본 조언",
            "동기 부여 및 목표 설정",
            "캘린더 연동 일정 관리"
        ]

    async def analyze_priority(self, content: str, context: str = "") -> PriorityAnalysis:
        """헬스 관련 작업의 우선순위 분석"""
        try:
            prompt = f"""
다음 헬스/운동 관련 작업의 우선순위를 전문 트레이너 관점에서 분석해주세요:

작업 내용: {content}
추가 맥락: {context}

분석 기준:
1. 운동 일관성 유지 (주 3-4회 규칙성)
2. 부상 방지 및 안전성
3. 목표 달성 직접 연관성
4. 신체 회복 및 적응 주기

JSON 형식으로 응답:
{{
    "urgency": 1-10,
    "importance": 1-10,
    "total_score": urgency + importance,
    "reasoning": "트레이너 관점의 상세 분석",
    "suggested_tags": ["운동", "헬스", "관련태그"],
    "estimated_time": "예상 소요 시간",
    "fitness_advice": "헬스 전문가로서의 추가 조언"
}}
"""
            
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.get_system_prompt()},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.2,
                max_tokens=1000
            )
            
            result = json.loads(response.choices[0].message.content)
            
            return PriorityAnalysis(
                urgency=max(1, min(10, result.get("urgency", 5))),
                importance=max(1, min(10, result.get("importance", 5))),
                total_score=result.get("urgency", 5) + result.get("importance", 5),
                reasoning=result.get("reasoning", "헬스 트레이너 분석"),
                suggested_tags=result.get("suggested_tags", ["운동", "헬스"]),
                estimated_time=result.get("estimated_time", "미정")
            )
            
        except Exception as e:
            logger.error(f"Fitness persona priority analysis failed: {e}")
            return PriorityAnalysis(
                urgency=6, importance=7, total_score=13,
                reasoning="헬스 관련 작업은 일관성이 중요하므로 중상 우선순위로 설정",
                suggested_tags=["운동", "헬스"],
                estimated_time="30-60분"
            )

    async def generate_suggestion(self, content: str, context: str = "") -> str:
        """헬스 트레이너 맞춤 제안 생성"""
        try:
            prompt = f"""
다음 상황에 대해 전문 헬스 트레이너로서 구체적인 조언을 제공해주세요:

상황: {content}
맥락: {context}

다음을 포함하여 응답해주세요:
1. 즉시 실행 가능한 액션 아이템 3개
2. 단기 목표 (2-4주)
3. 장기 목표 (2-3개월)
4. 주의사항 및 안전 가이드
5. 동기 부여 메시지

친근하지만 전문적인 톤으로 작성해주세요.
"""
            
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.get_system_prompt()},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=1500
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            logger.error(f"Fitness suggestion generation failed: {e}")
            return "헬스 트레이너 조언을 생성하는 중 오류가 발생했습니다. 기본적으로 규칙적인 운동과 충분한 휴식을 권장드립니다."

    def _get_workout_plan_prompt(self) -> str:
        """운동 계획 생성 프롬프트"""
        return """사용자의 목표, 현재 체력 수준, 주당 가능 횟수를 바탕으로 체계적인 운동 계획을 수립합니다.
바디빌딩 기초 → 크로스핏 전환까지 단계별 로드맵을 제공합니다."""

    def _get_progress_analysis_prompt(self) -> str:
        """진행 상황 분석 프롬프트"""
        return """운동 기록 데이터를 분석하여 개선점과 다음 단계를 제안합니다.
중량, 횟수, 지구력 향상 패턴을 파악하고 맞춤형 피드백을 제공합니다."""

    def _get_feedback_prompt(self) -> str:
        """피드백 생성 프롬프트"""
        return """운동 성과와 기록을 바탕으로 구체적이고 실행 가능한 피드백을 제공합니다.
격려와 함께 다음 주차 목표를 제시합니다."""

    # ===== 헬스 트레이너 고급 기능들 =====

    async def create_workout_plan(self, user_profile: Dict[str, Any]) -> Dict[str, Any]:
        """맞춤형 운동 계획 생성"""
        
        level = user_profile.get("level", "beginner")
        goal = user_profile.get("goal", "general_fitness")
        days_per_week = user_profile.get("days_per_week", 3)
        time_per_session = user_profile.get("time_per_session", 60)
        equipment = user_profile.get("equipment", ["bodyweight"])
        
        # 운동 계획 템플릿
        workout_plans = {
            "beginner": {
                "bodybuilding": {
                    "week_1_2": {
                        "day_1": {"focus": "상체", "exercises": ["푸시업", "덤벨컬", "오버헤드프레스", "플랭크"]},
                        "day_2": {"focus": "하체", "exercises": ["스쿼트", "런지", "카프레이즈", "글루트브릿지"]},
                        "day_3": {"focus": "전신", "exercises": ["버피", "마운틴클라임버", "데드리프트", "풀업"]}
                    },
                    "progression": "2주마다 세트수/무게 10% 증가"
                },
                "cardio_focus": {
                    "week_1_2": {
                        "day_1": {"focus": "HIIT", "exercises": ["점핑잭", "버피", "하이니즈", "스쿼트점프"]},
                        "day_2": {"focus": "지구력", "exercises": ["조깅", "사이클", "로잉", "스텝업"]},
                        "day_3": {"focus": "코어", "exercises": ["플랭크", "크런치", "러시안트위스트", "레그레이즈"]}
                    },
                    "progression": "운동 시간 주간 5분씩 증가"
                }
            },
            "intermediate": {
                "bodybuilding": {
                    "week_1_2": {
                        "day_1": {"focus": "가슴/삼두", "exercises": ["벤치프레스", "인클라인프레스", "딥스", "트라이셉스익스텐션"]},
                        "day_2": {"focus": "등/이두", "exercises": ["데드리프트", "풀업", "로우", "바이셉컬"]},
                        "day_3": {"focus": "하체", "exercises": ["스쿼트", "레그프레스", "레그컬", "카프레이즈"]},
                        "day_4": {"focus": "어깨/코어", "exercises": ["오버헤드프레스", "레터럴레이즈", "플랭크", "크런치"]}
                    },
                    "progression": "매주 무게 2.5-5kg 증가 또는 반복수 증가"
                }
            },
            "advanced": {
                "powerlifting": {
                    "week_1": {
                        "day_1": {"focus": "스쿼트", "exercises": ["백스쿼트", "프런트스쿼트", "보조운동"]},
                        "day_2": {"focus": "벤치프레스", "exercises": ["컴페티션벤치", "인클라인프레스", "보조운동"]},
                        "day_3": {"focus": "데드리프트", "exercises": ["컨벤셔널데드", "루마니안데드", "보조운동"]},
                        "day_4": {"focus": "보조운동", "exercises": ["약점부위 집중", "부상방지운동"]}
                    },
                    "progression": "퍼센테이지 기반 프로그래밍"
                }
            }
        }
        
        plan_type = "bodybuilding" if goal in ["muscle_gain", "strength"] else "cardio_focus"
        base_plan = workout_plans.get(level, workout_plans["beginner"]).get(plan_type)
        
        return {
            "user_level": level,
            "goal": goal,
            "plan_duration": "4주",
            "frequency": f"주 {days_per_week}회",
            "session_time": f"{time_per_session}분",
            "workout_plan": base_plan,
            "nutrition_tips": self._get_nutrition_tips(goal),
            "safety_reminders": self._get_safety_reminders(level),
            "progress_tracking": self._get_tracking_metrics(goal)
        }

    async def analyze_progress(self, workout_history: List[Dict[str, Any]]) -> Dict[str, Any]:
        """운동 진행 상황 분석"""
        if not workout_history:
            return {"error": "운동 기록이 필요합니다"}
        
        # 기본 통계 계산
        total_sessions = len(workout_history)
        total_volume = sum(session.get("total_volume", 0) for session in workout_history)
        avg_duration = sum(session.get("duration", 0) for session in workout_history) / total_sessions
        
        # 최근 진전 분석
        recent_sessions = workout_history[-4:] if len(workout_history) >= 4 else workout_history
        older_sessions = workout_history[-8:-4] if len(workout_history) >= 8 else []
        
        progress_indicators = {}
        if older_sessions and recent_sessions:
            old_avg_volume = sum(s.get("total_volume", 0) for s in older_sessions) / len(older_sessions)
            new_avg_volume = sum(s.get("total_volume", 0) for s in recent_sessions) / len(recent_sessions)
            
            volume_improvement = ((new_avg_volume - old_avg_volume) / old_avg_volume * 100) if old_avg_volume > 0 else 0
            progress_indicators["volume_change"] = f"{volume_improvement:.1f}%"
        
        # 약점 분석
        exercise_performance = {}
        for session in workout_history:
            for exercise in session.get("exercises", []):
                name = exercise.get("name", "unknown")
                if name not in exercise_performance:
                    exercise_performance[name] = []
                exercise_performance[name].append(exercise.get("max_weight", 0))
        
        weak_areas = []
        strong_areas = []
        
        for exercise, weights in exercise_performance.items():
            if len(weights) >= 3:
                recent_avg = sum(weights[-3:]) / 3
                if recent_avg < sum(weights[:3]) / 3:  # 퇴보한 경우
                    weak_areas.append(exercise)
                elif len(weights) >= 6 and recent_avg > sum(weights[-6:-3]) / 3:  # 개선된 경우
                    strong_areas.append(exercise)
        
        return {
            "summary": {
                "total_sessions": total_sessions,
                "avg_duration": f"{avg_duration:.0f}분",
                "total_volume": f"{total_volume:.0f}kg",
                "consistency": self._calculate_consistency(workout_history)
            },
            "progress_indicators": progress_indicators,
            "strong_areas": strong_areas[:3],  # 상위 3개
            "improvement_needed": weak_areas[:3],  # 상위 3개
            "recommendations": self._generate_progress_recommendations(
                progress_indicators, weak_areas, strong_areas
            ),
            "next_phase_suggestion": self._suggest_next_phase(workout_history)
        }

    def _get_nutrition_tips(self, goal: str) -> List[str]:
        """목표별 영양 가이드"""
        tips = {
            "muscle_gain": [
                "체중 1kg당 1.6-2.0g의 단백질 섭취",
                "운동 후 30분 내 단백질 보충",
                "복합탄수화물로 에너지 공급 (현미, 귀리)",
                "충분한 수분 섭취 (하루 2-3L)"
            ],
            "weight_loss": [
                "칼로리 소모량 > 섭취량 (일일 300-500kcal 적자)",
                "고단백 저칼로리 식품 위주 (닭가슴살, 달걀흰자)",
                "섬유질 풍부한 채소 충분히 섭취",
                "가공식품과 당분 섭취 최소화"
            ],
            "general_fitness": [
                "균형 잡힌 영양 섭취 (탄단지 6:2:2 비율)",
                "운동 전후 적절한 탄수화물 보충",
                "규칙적인 식사 패턴 유지",
                "간식은 견과류나 과일로 건강하게"
            ]
        }
        return tips.get(goal, tips["general_fitness"])

    def _get_safety_reminders(self, level: str) -> List[str]:
        """레벨별 안전 수칙"""
        safety_tips = {
            "beginner": [
                "운동 전 충분한 워밍업 (10분 이상)",
                "올바른 자세가 무게보다 중요",
                "통증 발생 시 즉시 중단",
                "전문 트레이너 지도 권장"
            ],
            "intermediate": [
                "정기적인 디로딩 주기 적용 (4주마다)",
                "운동 강도 급격한 증가 금지",
                "충분한 휴식과 회복 시간 확보",
                "부상 징후 조기 발견 노력"
            ],
            "advanced": [
                "1RM 테스트 시 반드시 스포터 동반",
                "정기적인 신체 점검 및 평가",
                "과훈련 증후군 주의",
                "전문가 상담을 통한 프로그램 조정"
            ]
        }
        return safety_tips.get(level, safety_tips["beginner"])

    def _get_tracking_metrics(self, goal: str) -> List[str]:
        """목표별 추적 지표"""
        metrics = {
            "muscle_gain": ["총 운동량(kg)", "1RM 기록", "체중 변화", "근육량 측정"],
            "weight_loss": ["체중", "체지방률", "둘레 측정", "유산소 지구력"],
            "strength": ["1RM 기록", "총 들어올린 무게", "운동 볼륨", "기술적 향상"],
            "general_fitness": ["운동 빈도", "체력 테스트 결과", "전반적 컨디션", "일상 활동량"]
        }
        return metrics.get(goal, metrics["general_fitness"])

    def _calculate_consistency(self, workout_history: List[Dict[str, Any]]) -> str:
        """운동 일관성 계산"""
        if len(workout_history) < 4:
            return "데이터 부족"
        
        # 최근 4주간 운동 빈도 계산 (간단한 구현)
        recent_4_weeks = workout_history[-12:]  # 주 3회 기준 4주
        consistency_rate = len(recent_4_weeks) / 12 * 100
        
        if consistency_rate >= 90:
            return "매우 우수"
        elif consistency_rate >= 75:
            return "우수"
        elif consistency_rate >= 50:
            return "보통"
        else:
            return "개선 필요"

    def _generate_progress_recommendations(self, progress: Dict, weak_areas: List, strong_areas: List) -> List[str]:
        """진행 상황 기반 추천사항"""
        recommendations = []
        
        if weak_areas:
            recommendations.append(f"약점 보완: {', '.join(weak_areas[:2])} 운동에 집중하세요")
        
        if strong_areas:
            recommendations.append(f"강점 활용: {', '.join(strong_areas[:2])} 운동을 통해 자신감을 키우세요")
        
        volume_change = progress.get("volume_change", "0%")
        if "%" in volume_change and float(volume_change.replace("%", "")) < 5:
            recommendations.append("운동 강도나 볼륨을 점진적으로 증가시키세요")
        
        recommendations.extend([
            "규칙적인 운동 패턴 유지가 가장 중요합니다",
            "충분한 휴식과 영양 섭취를 병행하세요",
            "부상 방지를 위해 워밍업과 쿨다운을 소홀히 하지 마세요"
        ])
        
        return recommendations

    def _suggest_next_phase(self, workout_history: List[Dict[str, Any]]) -> str:
        """다음 단계 제안"""
        total_sessions = len(workout_history)
        
        if total_sessions < 12:  # 4주 미만
            return "현재 프로그램을 4주 더 진행하여 기초를 탄탄히 하세요"
        elif total_sessions < 24:  # 8주 미만
            return "중급 단계로 진행하여 운동 강도를 높이고 새로운 운동을 추가해보세요"
        else:
            return "고급 기법(크로스핏, 플라이오메트릭)을 도입하거나 전문 분야 특화를 고려하세요"

    # 부가 기능들
    
    def generate_meal_prep_plan(self, goal: str, days: int = 7) -> Dict[str, Any]:
        """목표별 식단 계획"""
        meal_plans = {
            "muscle_gain": {
                "breakfast": ["오트밀+단백질파우더", "계란+토스트", "그릭요거트+견과류"],
                "lunch": ["닭가슴살샐러드", "현미+연어구이", "퀴노아볼"],
                "dinner": ["스테이크+고구마", "닭가슴살스테이크", "연어구이+브로콜리"],
                "snacks": ["단백질바", "견과류", "바나나+땅콩버터"]
            },
            "weight_loss": {
                "breakfast": ["그릭요거트+베리", "달걀흰자오믈렛", "프로틴스무디"],
                "lunch": ["참치샐러드", "닭가슴살랩", "두부스테이크"],
                "dinner": ["구운닭가슴살+채소", "생선구이+샐러드", "두부김치"],
                "snacks": ["견과류 소량", "오이", "방울토마토"]
            }
        }
        
        base_plan = meal_plans.get(goal, meal_plans["muscle_gain"])
        
        return {
            "goal": goal,
            "duration": f"{days}일",
            "meal_plan": base_plan,
            "shopping_list": self._generate_shopping_list(base_plan),
            "prep_tips": [
                "주말에 일주일치 단백질 미리 조리",
                "채소는 먹기 전날 손질하여 신선도 유지",
                "간식용 견과류는 소분하여 보관"
            ]
        }

    def _generate_shopping_list(self, meal_plan: Dict) -> List[str]:
        """식단 기반 장보기 목록"""
        # 간단한 구현 - 실제로는 더 정교한 분석 필요
        common_items = [
            "닭가슴살 2kg", "계란 30개", "현미 5kg", "고구마 3kg",
            "브로콜리 5개", "시금치 3단", "견과류 믹스 500g",
            "그릭요거트 10개", "단백질파우더 1통", "올리브오일 500ml"
        ]
        return common_items

    def create_home_gym_setup_guide(self, budget: int, space: str) -> Dict[str, Any]:
        """홈짐 구성 가이드"""
        equipment_recommendations = {
            "low_budget": {  # 10만원 이하
                "essential": ["요가매트", "저항밴드", "덤벨 세트 (10-20kg)"],
                "optional": ["푸시업바", "폼롤러"],
                "total_cost": "약 8-10만원"
            },
            "medium_budget": {  # 50만원 이하
                "essential": ["조절식 덤벨", "벤치", "풀업바", "케틀벨"],
                "optional": ["바벨세트", "멀티랙"],
                "total_cost": "약 30-50만원"
            },
            "high_budget": {  # 100만원 이상
                "essential": ["파워랙", "바벨세트", "조절식 벤치", "러닝머신"],
                "optional": ["케이블머신", "레그프레스"],
                "total_cost": "약 100-200만원"
            }
        }
        
        budget_category = "low_budget" if budget < 150000 else "medium_budget" if budget < 700000 else "high_budget"
        
        return {
            "budget_category": budget_category,
            "available_space": space,
            "recommended_equipment": equipment_recommendations[budget_category],
            "workout_routines": self._get_home_gym_routines(budget_category),
            "space_optimization_tips": self._get_space_tips(space),
            "maintenance_guide": [
                "장비 정기적 청소 및 점검",
                "안전 점검 월 1회",
                "소음 방지 매트 사용 권장"
            ]
        }

    def _get_home_gym_routines(self, equipment_level: str) -> List[str]:
        """홈짐 장비별 루틴"""
        routines = {
            "low_budget": [
                "맨몸운동 중심 풀바디 루틴",
                "저항밴드 활용 근력운동",
                "덤벨을 활용한 기본 웨이트"
            ],
            "medium_budget": [
                "상하체 분할 루틴",
                "컴파운드 무브먼트 중심",
                "케틀벨 HIIT 운동"
            ],
            "high_budget": [
                "전문적인 5분할 루틴",
                "파워리프팅 3대 운동",
                "유산소와 무산소 병행 프로그램"
            ]
        }
        return routines.get(equipment_level, routines["low_budget"])

    def _get_space_tips(self, space: str) -> List[str]:
        """공간별 최적화 팁"""
        tips = {
            "small": [
                "접이식 장비 위주로 구성",
                "벽걸이 수납 시스템 활용",
                "다용도 장비 우선 선택"
            ],
            "medium": [
                "동선을 고려한 장비 배치",
                "운동별 구역 나누기",
                "환기 시설 충분히 확보"
            ],
            "large": [
                "전용 운동 공간 설계",
                "다양한 운동 존 구성",
                "음향 시설까지 고려"
            ]
        }
        return tips.get(space, tips["small"])