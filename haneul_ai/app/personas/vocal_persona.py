"""
Vocal Persona for Haneul AI Agent
AI Vocal Coach specializing in pitch analysis, vocal training, and singing feedback
"""

import openai
import json
from typing import Dict, Any, List, Optional
from loguru import logger

from app.config.settings import get_settings
from app.models.schemas import PriorityAnalysis
from .base_persona import BasePersona

# settings = get_settings()  # 나중에 환경 설정 후 활성화


class VocalPersona(BasePersona):
    """AI 보컬 트레이너 페르소나 - 음정 분석, 발성 피드백, 연습 루틴 제공"""
    
    def __init__(self):
        super().__init__(
            name="보컬 트레이너",
            description="개인 맞춤형 AI 보컬 트레이너 - 음정 분석, 발성 피드백, 연습 루틴 제공",
            model="gpt-5"
        )
        # self.client = openai.OpenAI(api_key=settings.openai_api_key)  # 나중에 활성화
        
        # 보컬 전용 프롬프트
        self.specialized_prompts = {
            "pitch_analysis": self._get_pitch_analysis_prompt(),
            "vocal_feedback": self._get_vocal_feedback_prompt(),
            "practice_routine": self._get_practice_routine_prompt(),
            "breathing_guide": self._get_breathing_guide_prompt()
        }
        
        # 음악 이론 지식베이스
        self.music_knowledge = {
            "scales": ["도레미파솔라시", "C Major", "A Minor", "G Major", "F Major"],
            "vocal_ranges": {
                "soprano": {"low": "C4", "high": "C6", "comfort": "E4-A5"},
                "mezzo": {"low": "A3", "high": "A5", "comfort": "C4-F5"},
                "alto": {"low": "F3", "high": "F5", "comfort": "A3-D5"},
                "tenor": {"low": "C3", "high": "C5", "comfort": "E3-A4"},
                "baritone": {"low": "A2", "high": "A4", "comfort": "C3-F4"},
                "bass": {"low": "E2", "high": "E4", "comfort": "G2-C4"}
            },
            "genres": {
                "pop": {"focus": "emotion", "techniques": ["mixed voice", "belting"]},
                "classical": {"focus": "technique", "techniques": ["head voice", "chest voice"]},
                "musical": {"focus": "storytelling", "techniques": ["character voice"]},
                "jazz": {"focus": "improvisation", "techniques": ["scat singing", "vibrato"]},
                "kpop": {"focus": "performance", "techniques": ["mixed voice", "runs"]}
            }
        }
    
    def get_system_prompt(self) -> str:
        """보컬 트레이너 전용 시스템 프롬프트"""
        return """당신은 전문 보컬 트레이너 AI입니다. GPT-5의 고도화된 분석 능력을 활용하여:

🎵 핵심 역량:
1. 음성 분석: 피치, 톤, 리듬, 발음 정확도 분석
2. 맞춤형 피드백: 개인 음역대와 장르에 맞는 구체적 조언
3. 연습 루틴 설계: 발성, 호흡, 스케일 연습 체계적 계획
4. 단계별 발전: 초보자 → 중급자 → 고급자 진행 관리

🎯 전문 분야:
- 발성법 (호흡, 공명, 발음)
- 음정 훈련 (스케일, 인터벌, 귀 훈련)
- 장르별 스타일 (팝, 클래식, 뮤지컬, K-pop)
- 무대 표현력 및 감정 전달

⚠️ 안전 가이드:
- 무리한 발성 금지, 성대 보호 최우선
- 개인차 인정, 점진적 발전 추구
- 전문 보컬 코치 대체 아닌 보조 역할 명시
- 의학적 조언 금지, 음성 치료는 전문의 권장

친근하고 격려하는 톤으로, 기술적 내용도 쉽게 설명합니다."""

    def get_capabilities(self) -> List[str]:
        """보컬 트레이너 역량 목록"""
        return [
            "음성 파일 피치 분석",
            "실시간 튜너 가이드",
            "개인 맞춤 피드백",
            "장르별 발성법 코칭",
            "호흡법 및 발성 훈련",
            "스케일 연습 루틴 설계",
            "음역대 확장 가이드",
            "무대 표현력 향상",
            "K-pop/팝 스타일 특화",
            "성대 건강 관리 조언"
        ]

    async def analyze_priority(self, content: str, context: str = "") -> PriorityAnalysis:
        """보컬 관련 작업의 우선순위 분석"""
        # 일단 더미 구현, 나중에 OpenAI 연동 시 실제 구현
        vocal_keywords = ["노래", "발성", "음정", "피치", "호흡", "스케일", "보컬", "연습"]
        
        # 키워드 매칭으로 기본 점수 계산
        keyword_score = sum(1 for keyword in vocal_keywords if keyword in content.lower())
        
        # 긴급도 판단 (연습 일관성 중요)
        urgency = min(10, 5 + keyword_score)
        importance = min(10, 6 + keyword_score)
        
        return PriorityAnalysis(
            urgency=urgency,
            importance=importance,
            total_score=urgency + importance,
            reasoning=f"보컬 훈련은 꾸준한 연습이 핵심입니다. 성대 건강을 위해 규칙적인 훈련을 권장합니다.",
            suggested_tags=["보컬", "음성", "연습"],
            estimated_time="30-60분"
        )

    async def generate_suggestion(self, content: str, context: str = "") -> str:
        """보컬 트레이너 맞춤 제안 생성"""
        # 더미 구현 - 나중에 실제 GPT-5 연동
        
        suggestion_templates = {
            "pitch": """🎵 음정 개선 제안:
1. 매일 10분 스케일 연습 (도레미파솔라시도)
2. 피아노 앱으로 정확한 피치 확인
3. 녹음 후 원곡과 비교 분석
4. 호흡 안정화를 위한 복식호흡 연습

⚠️ 주의: 성대에 무리가 가지 않도록 충분한 워밍업 후 연습하세요.""",
            
            "breathing": """🫁 호흡법 개선 가이드:
1. 복식호흡 기초 연습 (5분 × 3회)
2. 긴 호흡 연습 (8박 들이쉬고 8박 내쉬기)
3. 립트릴로 호흡 조절력 향상
4. 자세 교정 (허리를 펴고 어깨 릴렉스)

🎯 목표: 2주 내 안정적인 16박 롱톤 유지""",
            
            "general": """🎤 종합 보컬 트레이닝 계획:
1. 워밍업 (5분): 입술트릴, 허밍
2. 발성 연습 (10분): 모음 발성, 스케일
3. 곡 연습 (20분): 구간별 반복 연습
4. 쿨다운 (5분): 낮은 허밍, 성대 휴식

📈 진행: 주 3-4회, 점진적 난이도 상승
🏆 목표: 1개월 내 자신 있는 곡 1곡 완성"""
        }
        
        # 간단한 키워드 기반 매칭
        if any(word in content.lower() for word in ["음정", "피치", "틀려", "부정확"]):
            return suggestion_templates["pitch"]
        elif any(word in content.lower() for word in ["호흡", "숨", "긴장", "떨려"]):
            return suggestion_templates["breathing"]
        else:
            return suggestion_templates["general"]

    def _get_pitch_analysis_prompt(self) -> str:
        """음정 분석 프롬프트"""
        return """음성 파일의 피치를 분석하여 다음을 제공합니다:
1. 음정 정확도 (% 점수)
2. 음역대 분석 (최저음~최고음)
3. 불안정한 구간 식별
4. 개선점과 연습 방법 제안"""

    def _get_vocal_feedback_prompt(self) -> str:
        """보컬 피드백 프롬프트"""
        return """보컬 분석 결과를 바탕으로 구체적 피드백을 제공합니다:
1. 강점과 개선점 분석
2. 장르별 스타일 조언
3. 발성법 개선 방향
4. 다음 단계 학습 목표"""

    def _get_practice_routine_prompt(self) -> str:
        """연습 루틴 프롬프트"""
        return """개인 수준에 맞는 체계적 연습 루틴을 설계합니다:
1. 워밍업 → 기초 연습 → 곡 연습 → 쿨다운
2. 주간/월간 학습 계획
3. 진도 체크포인트 설정
4. 성취 목표와 평가 방법"""

    def _get_breathing_guide_prompt(self) -> str:
        """호흡 가이드 프롬프트"""
        return """올바른 호흡법 훈련을 위한 단계별 가이드:
1. 복식호흡 기초 이해
2. 호흡 근육 강화 운동
3. 발성과 호흡의 조화
4. 장시간 가창을 위한 호흡 관리"""

    # ===== 보컬 전용 고급 기능들 =====

    def analyze_vocal_range(self, pitch_data: List[float]) -> Dict[str, Any]:
        """음역대 분석"""
        if not pitch_data:
            return {"error": "음성 데이터가 필요합니다"}
        
        min_pitch = min(pitch_data)
        max_pitch = max(pitch_data)
        avg_pitch = sum(pitch_data) / len(pitch_data)
        
        # 음역대 판정 (Hz 기준 간단한 구현)
        vocal_type = "unknown"
        if avg_pitch > 400:  # 여성
            if max_pitch > 800:
                vocal_type = "soprano"
            elif max_pitch > 600:
                vocal_type = "mezzo-soprano"
            else:
                vocal_type = "alto"
        else:  # 남성
            if min_pitch < 150:
                vocal_type = "bass"
            elif min_pitch < 200:
                vocal_type = "baritone"
            else:
                vocal_type = "tenor"
        
        return {
            "vocal_type": vocal_type,
            "range_hz": {"min": min_pitch, "max": max_pitch, "avg": avg_pitch},
            "range_semitones": max_pitch - min_pitch,
            "recommendations": self._get_range_recommendations(vocal_type)
        }

    def _get_range_recommendations(self, vocal_type: str) -> List[str]:
        """음역대별 추천사항"""
        recommendations = {
            "soprano": [
                "고음 발성 시 두성(head voice) 활용 연습",
                "모짜르트 아리아나 팝송 고음부 연습 추천",
                "벨팅 기법으로 파워풀한 중고음 개발"
            ],
            "alto": [
                "풍부한 중저음을 활용한 감정 표현 연습",
                "재즈나 소울 장르 도전 권장", 
                "믹스 보이스로 음역 확장 시도"
            ],
            "tenor": [
                "혼성(mixed voice) 발성으로 자연스러운 고음 연습",
                "팝/록 발라드나 뮤지컬 넘버 추천",
                "가슴성과 두성의 균형 잡힌 발전"
            ],
            "bass": [
                "깊고 안정적인 저음의 매력 극대화",
                "클래식 저음부나 오페라 아리아 도전",
                "공명 개선으로 음성의 볼륨감 향상"
            ]
        }
        
        return recommendations.get(vocal_type, ["개인 맞춤 보컬 코칭 추천"])

    def generate_practice_schedule(self, level: str, goals: List[str], time_per_day: int) -> Dict[str, Any]:
        """맞춤형 연습 스케줄 생성"""
        
        schedules = {
            "beginner": {
                "daily_routine": [
                    {"activity": "워밍업", "duration": 5, "description": "입술트릴, 허밍"},
                    {"activity": "호흡연습", "duration": 10, "description": "복식호흡, 긴호흡"},
                    {"activity": "발성연습", "duration": 15, "description": "모음발성, 기본스케일"},
                    {"activity": "쿨다운", "duration": 5, "description": "낮은허밍, 목근육이완"}
                ],
                "weekly_goals": [
                    "정확한 복식호흡 익히기",
                    "기본 도레미파솔라시도 스케일 안정화",
                    "한 옥타브 내 안정적 발성"
                ]
            },
            "intermediate": {
                "daily_routine": [
                    {"activity": "워밍업", "duration": 5, "description": "다양한 트릴, 공명연습"},
                    {"activity": "테크닉연습", "duration": 15, "description": "믹스보이스, 비브라토"},
                    {"activity": "곡연습", "duration": 25, "description": "장르별 곡 마스터"},
                    {"activity": "쿨다운", "duration": 5, "description": "성대마사지"}
                ],
                "weekly_goals": [
                    "믹스 보이스 기법 습득",
                    "2옥타브 음역 안정화",
                    "감정 표현력 향상"
                ]
            },
            "advanced": {
                "daily_routine": [
                    {"activity": "고급워밍업", "duration": 10, "description": "전체음역 준비"},
                    {"activity": "고급테크닉", "duration": 20, "description": "벨팅, 런스, 장식음"},
                    {"activity": "곡완성도", "duration": 25, "description": "무대용 곡 퍼포먼스"},
                    {"activity": "쿨다운", "duration": 5, "description": "성대회복"}
                ],
                "weekly_goals": [
                    "고난도 기법 완성도 향상",
                    "무대 퍼포먼스 완성",
                    "개인 스타일 확립"
                ]
            }
        }
        
        base_schedule = schedules.get(level, schedules["beginner"])
        
        # 시간 조정
        total_base_time = sum(activity["duration"] for activity in base_schedule["daily_routine"])
        ratio = time_per_day / total_base_time
        
        adjusted_routine = []
        for activity in base_schedule["daily_routine"]:
            adjusted_routine.append({
                **activity,
                "duration": max(3, int(activity["duration"] * ratio))
            })
        
        return {
            "level": level,
            "daily_routine": adjusted_routine,
            "weekly_goals": base_schedule["weekly_goals"],
            "monthly_milestone": f"{level.title()} 레벨 목표 달성",
            "practice_tips": self._get_level_specific_tips(level)
        }

    def _get_level_specific_tips(self, level: str) -> List[str]:
        """레벨별 연습 팁"""
        tips = {
            "beginner": [
                "거울을 보며 올바른 자세로 연습하세요",
                "목에 힘을 빼고 자연스럽게 발성하세요",
                "물을 충분히 마시고 성대를 촉촉하게 유지하세요",
                "무리하지 말고 단계적으로 연습량을 늘려가세요"
            ],
            "intermediate": [
                "녹음을 통해 자신의 발성을 객관적으로 체크하세요",
                "다양한 장르의 곡에 도전해보세요",
                "감정을 담아 표현하는 연습을 하세요",
                "전문 보컬 코치의 피드백을 받아보세요"
            ],
            "advanced": [
                "라이브 공연 기회를 적극 활용하세요",
                "자신만의 독특한 스타일을 개발하세요",
                "후배 보컬리스트들을 지도해보세요",
                "지속적인 자기계발과 새로운 기법 학습에 집중하세요"
            ]
        }
        
        return tips.get(level, tips["beginner"])