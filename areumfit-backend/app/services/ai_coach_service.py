import openai
import json
import logging
from typing import Dict, Any, Optional, List
from datetime import datetime
from app.core.config import ai_config

logger = logging.getLogger(__name__)


class AICoachService:
    """AI Coach service using OpenAI GPT for personalized fitness guidance"""

    def __init__(self):
        self.client = None
        self.is_available = False

        if ai_config.is_configured:
            try:
                openai.api_key = ai_config.openai_api_key
                self.client = openai.OpenAI(api_key=ai_config.openai_api_key)
                self.is_available = True
                logger.info("✅ AI Coach service initialized successfully")
            except Exception as e:
                logger.error(f"❌ Failed to initialize AI Coach service: {e}")
                self.is_available = False
        else:
            logger.warning("⚠️  AI Coach service not configured - OpenAI API key missing")

    async def generate_workout_recommendation(
        self,
        user_id: str,
        current_condition: Optional[Dict[str, Any]] = None,
        workout_history: Optional[List[Dict[str, Any]]] = None,
        user_profile: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """Generate personalized workout recommendations"""

        if not self.is_available:
            return self._get_fallback_recommendation()

        try:
            # Build context for AI
            context = self._build_recommendation_context(user_id, current_condition, workout_history, user_profile)

            # Generate recommendation using OpenAI
            response = await self._call_openai_for_recommendation(context)

            # Parse and validate response
            recommendation = self._parse_recommendation_response(response)

            logger.info(f"Generated workout recommendation for user {user_id}")
            return recommendation

        except Exception as e:
            logger.error(f"Error generating workout recommendation: {e}")
            return self._get_fallback_recommendation()

    async def chat_with_coach(
        self,
        user_id: str,
        message: str,
        context: Optional[Dict[str, Any]] = None,
        conversation_history: Optional[List[Dict[str, str]]] = None,
    ) -> str:
        """Chat with AI fitness coach"""

        if not self.is_available:
            return "죄송합니다. AI 코치 서비스가 현재 사용할 수 없습니다. 나중에 다시 시도해주세요."

        try:
            # Build messages for chat
            messages = self._build_chat_messages(message, context, conversation_history)

            # Call OpenAI API
            response = self.client.chat.completions.create(
                model=ai_config.model,
                messages=messages,
                temperature=ai_config.temperature,
                max_tokens=ai_config.max_tokens,
            )

            reply = response.choices[0].message.content.strip()
            logger.info(f"Generated chat response for user {user_id}")
            return reply

        except Exception as e:
            logger.error(f"Error in chat with coach: {e}")
            return "죄송합니다. 일시적인 오류가 발생했습니다. 다시 시도해주세요."

    def _build_recommendation_context(
        self,
        user_id: str,
        current_condition: Optional[Dict[str, Any]],
        workout_history: Optional[List[Dict[str, Any]]],
        user_profile: Optional[Dict[str, Any]],
    ) -> str:
        """Build context string for workout recommendations"""

        context_parts = [
            "오늘의 운동 추천을 위한 사용자 정보:",
            f"사용자 ID: {user_id}",
        ]

        # Add current condition
        if current_condition:
            context_parts.extend(
                [
                    "\n현재 컨디션:",
                    f"- 에너지 레벨: {current_condition.get('energy', 'unknown')}",
                    f"- 근육 피로도: {current_condition.get('soreness', 'unknown')}",
                    f"- 수면시간: {current_condition.get('sleep', 'unknown')}시간",
                    f"- 스트레스: {current_condition.get('stress', 'unknown')}",
                ]
            )

        # Add user profile
        if user_profile:
            context_parts.extend(
                [
                    "\n사용자 프로필:",
                    f"- 경험 수준: {user_profile.get('experience_level', 'beginner')}",
                    f"- 주요 목표: {user_profile.get('primary_goal', 'general_fitness')}",
                    f"- 운동 빈도: {user_profile.get('workout_frequency', 3)}회/주",
                ]
            )

        # Add workout history summary
        if workout_history:
            context_parts.extend(
                [
                    "\n최근 운동 기록:",
                    f"- 최근 {len(workout_history)}회 세션 기록 있음",
                    "- 주로 수행한 운동: 벤치프레스, 스쿼트, 데드리프트",
                ]
            )

        context_parts.append("\n위 정보를 바탕으로 오늘의 맞춤 운동을 JSON 형식으로 추천해주세요.")

        return "\n".join(context_parts)

    async def _call_openai_for_recommendation(self, context: str) -> str:
        """Call OpenAI API for workout recommendations"""

        system_prompt = """
        당신은 전문 퍼스널 트레이너입니다. 사용자의 현재 컨디션과 운동 기록을 분석하여 
        오늘의 최적화된 운동 계획을 추천해주세요.
        
        응답은 반드시 다음 JSON 형식을 따라주세요:
        {
            "is_rest_day": false,
            "primary_muscle_groups": ["가슴", "삼두"],
            "daily_reasoning": "오늘 추천 이유 설명",
            "exercises": [
                {
                    "name": "벤치프레스",
                    "weight": 80.0,
                    "reps": 8,
                    "sets": 4,
                    "rpe": 8.0,
                    "rest_seconds": 180,
                    "priority": "high",
                    "reasoning": "추천 이유"
                }
            ],
            "tips": ["운동 팁 1", "운동 팁 2"]
        }
        """

        response = self.client.chat.completions.create(
            model=ai_config.model,
            messages=[{"role": "system", "content": system_prompt}, {"role": "user", "content": context}],
            temperature=0.3,  # Lower temperature for more consistent JSON
            max_tokens=ai_config.max_tokens,
        )

        return response.choices[0].message.content.strip()

    def _build_chat_messages(
        self, message: str, context: Optional[Dict[str, Any]], conversation_history: Optional[List[Dict[str, str]]]
    ) -> List[Dict[str, str]]:
        """Build message list for chat API"""

        messages = [{"role": "system", "content": ai_config.system_prompt}]

        # Add conversation history
        if conversation_history:
            messages.extend(conversation_history[-10:])  # Last 10 messages

        # Add context if provided
        if context:
            context_message = f"현재 컨텍스트: {json.dumps(context, ensure_ascii=False)}"
            messages.append({"role": "system", "content": context_message})

        # Add current message
        messages.append({"role": "user", "content": message})

        return messages

    def _parse_recommendation_response(self, response: str) -> Dict[str, Any]:
        """Parse AI response to extract workout recommendation"""

        try:
            # Extract JSON from response
            start = response.find("{")
            end = response.rfind("}") + 1

            if start != -1 and end != 0:
                json_str = response[start:end]
                recommendation = json.loads(json_str)

                # Validate required fields
                if self._validate_recommendation(recommendation):
                    return recommendation
                else:
                    logger.warning("AI response validation failed, using fallback")
                    return self._get_fallback_recommendation()
            else:
                logger.warning("No valid JSON found in AI response")
                return self._get_fallback_recommendation()

        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse AI recommendation JSON: {e}")
            return self._get_fallback_recommendation()

    def _validate_recommendation(self, recommendation: Dict[str, Any]) -> bool:
        """Validate recommendation structure"""

        required_fields = ["is_rest_day", "primary_muscle_groups", "daily_reasoning", "exercises", "tips"]

        # Check required fields
        for field in required_fields:
            if field not in recommendation:
                return False

        # Validate exercises if not rest day
        if not recommendation["is_rest_day"]:
            exercises = recommendation.get("exercises", [])
            if not exercises:
                return False

            for exercise in exercises:
                required_exercise_fields = ["name", "weight", "reps", "sets", "rpe", "rest_seconds", "priority"]
                for field in required_exercise_fields:
                    if field not in exercise:
                        return False

        return True

    def _get_fallback_recommendation(self) -> Dict[str, Any]:
        """Get fallback recommendation when AI is unavailable"""

        return {
            "is_rest_day": False,
            "primary_muscle_groups": ["가슴", "삼두"],
            "daily_reasoning": "AI 서비스를 사용할 수 없어 기본 운동 계획을 제공합니다. 상체 근력 향상을 위한 기본 프로그램입니다.",
            "exercises": [
                {
                    "name": "벤치프레스",
                    "weight": 60.0,
                    "reps": 10,
                    "sets": 3,
                    "rpe": 7.5,
                    "rest_seconds": 180,
                    "priority": "high",
                    "reasoning": "상체 기본 복합 운동",
                },
                {
                    "name": "인클라인 덤벨 프레스",
                    "weight": 24.0,
                    "reps": 12,
                    "sets": 3,
                    "rpe": 7.0,
                    "rest_seconds": 120,
                    "priority": "medium",
                    "reasoning": "상부 가슴 발달",
                },
                {
                    "name": "딥스",
                    "weight": 0.0,
                    "reps": 15,
                    "sets": 3,
                    "rpe": 8.0,
                    "rest_seconds": 90,
                    "priority": "medium",
                    "reasoning": "삼두근과 하부 가슴 강화",
                },
            ],
            "tips": [
                "운동 전 충분한 워밍업을 하세요",
                "올바른 자세로 운동하는 것이 중요합니다",
                "세트 간 적절한 휴식을 취하세요",
            ],
        }
