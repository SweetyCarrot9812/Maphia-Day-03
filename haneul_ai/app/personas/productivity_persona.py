"""
Productivity Persona for Haneul AI Agent
Original productivity-focused AI persona for task management and prioritization
"""

import openai
import json
from typing import Dict, Any, List
from loguru import logger

from app.config.settings import get_settings
from app.models.schemas import PriorityAnalysis
from .base_persona import BasePersona

settings = get_settings()


class ProductivityPersona(BasePersona):
    """Original productivity-focused AI persona"""
    
    def __init__(self):
        super().__init__(
            name="생산성 매니저",
            description="개인 생산성 최적화 및 업무 우선순위 관리 전문 AI",
            model="gpt-5"
        )
        self.client = openai.OpenAI(api_key=settings.openai_api_key)
    
    def get_system_prompt(self) -> str:
        """생산성 매니저 전용 시스템 프롬프트"""
        return """당신은 개인 AI 에이전트로서 최고 수준의 분석 능력을 가진 생산성 전문가입니다. 
작업의 우선순위를 깊이 있게 분석하고, 사용자의 개인적 맥락까지 고려하여 정확한 JSON 형식으로 응답합니다. 
GPT-5의 고도화된 추론 능력을 활용하여 미묘한 패턴과 우선순위를 파악해주세요.

전문 영역:
1. 업무 우선순위 분석 및 시간 관리
2. 개인 목표 설정 및 진행 관리
3. 생산성 향상 전략 수립
4. 일정 최적화 및 효율성 개선"""

    def get_capabilities(self) -> List[str]:
        """생산성 매니저 역량 목록"""
        return [
            "업무 우선순위 분석",
            "시간 관리 최적화",
            "목표 설정 및 추적",
            "일정 계획 수립",
            "생산성 패턴 분석",
            "Obsidian 노트 관리",
            "이메일/캘린더 자동화",
            "태스크 분류 및 정리"
        ]

    async def analyze_priority(self, content: str, context: str = "") -> PriorityAnalysis:
        """생산성 관점에서 작업 우선순위 분석"""
        try:
            from app.config.prompts import PRIORITY_SCORING_PROMPT
            
            prompt = PRIORITY_SCORING_PROMPT.format(
                content=content,
                context=context
            )
            
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.get_system_prompt()},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.2,
                max_tokens=1000
            )
            
            # JSON 파싱 로직 (기존과 동일)
            content_str = response.choices[0].message.content
            
            if "```json" in content_str:
                json_start = content_str.find("```json") + 7
                json_end = content_str.find("```", json_start)
                json_str = content_str[json_start:json_end].strip()
            else:
                start = content_str.find("{")
                end = content_str.rfind("}") + 1
                json_str = content_str[start:end]
            
            result = json.loads(json_str)
            
            return PriorityAnalysis(
                urgency=max(1, min(10, result.get("urgency", 5))),
                importance=max(1, min(10, result.get("importance", 5))),
                total_score=result.get("urgency", 5) + result.get("importance", 5),
                reasoning=result.get("reasoning", "생산성 매니저 AI 분석 결과"),
                suggested_tags=result.get("suggested_tags", ["업무"]),
                estimated_time=result.get("estimated_time", "미정")
            )
            
        except Exception as e:
            logger.error(f"Productivity persona priority analysis failed: {e}")
            return PriorityAnalysis(
                urgency=5, importance=5, total_score=10,
                reasoning="생산성 매니저 분석 중 오류가 발생하여 기본값을 제공합니다.",
                suggested_tags=["업무"],
                estimated_time="미정"
            )

    async def generate_suggestion(self, content: str, context: str = "") -> str:
        """생산성 향상 제안 생성"""
        try:
            prompt = f"""
다음 업무/목표에 대해 생산성 전문가로서 구체적인 실행 계획을 제안해주세요:

내용: {content}
맥락: {context}

다음을 포함하여 응답해주세요:
1. 즉시 실행 가능한 첫 단계 3개
2. 시간 관리 최적화 방안
3. 예상 장애물과 해결책
4. 성과 측정 방법
5. 다음 주 목표

전문적이면서도 실용적인 조언으로 구성해주세요.
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
            logger.error(f"Productivity suggestion generation failed: {e}")
            return "생산성 매니저 제안을 생성하는 중 오류가 발생했습니다. 작은 단위로 작업을 나누어 진행하는 것을 권장드립니다."