"""
Haneul AI Agent - AI Service
OpenAI GPT-4 integration for priority analysis and content processing
"""

import openai
import json
from typing import Dict, Any, List
from loguru import logger

from app.config.settings import get_settings
from app.config.prompts import PRIORITY_SCORING_PROMPT, TAG_CLASSIFICATION_PROMPT
from app.models.schemas import PriorityAnalysis, TagSuggestion

settings = get_settings()


class AIService:
    """AI service for task analysis and content processing"""
    
    def __init__(self):
        """Initialize AI service with OpenAI client"""
        self.client = openai.OpenAI(api_key=settings.openai_api_key)
        self.model = "gpt-5"  # Premium model for personal AI agent
    
    async def analyze_priority(self, content: str, context: str = "") -> PriorityAnalysis:
        """
        Analyze task priority using AI
        
        Args:
            content: Task content to analyze
            context: Additional context for better analysis
            
        Returns:
            PriorityAnalysis object with scores and reasoning
        """
        try:
            prompt = PRIORITY_SCORING_PROMPT.format(
                content=content,
                context=context
            )
            
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "당신은 개인 AI 에이전트로서 최고 수준의 분석 능력을 가진 생산성 전문가입니다. 작업의 우선순위를 깊이 있게 분석하고, 사용자의 개인적 맥락까지 고려하여 정확한 JSON 형식으로 응답합니다. GPT-5의 고도화된 추론 능력을 활용하여 미묘한 패턴과 우선순위를 파악해주세요."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.2,  # GPT-5는 더 정확하므로 낮은 temperature
                max_tokens=1000   # GPT-5의 더 상세한 분석을 위해 증가
            )
            
            # Parse JSON response
            content_str = response.choices[0].message.content
            
            # Extract JSON from response (handling markdown code blocks)
            if "```json" in content_str:
                json_start = content_str.find("```json") + 7
                json_end = content_str.find("```", json_start)
                json_str = content_str[json_start:json_end].strip()
            else:
                # Try to find JSON object
                start = content_str.find("{")
                end = content_str.rfind("}") + 1
                json_str = content_str[start:end]
            
            result = json.loads(json_str)
            
            # Validate and create PriorityAnalysis object
            analysis = PriorityAnalysis(
                urgency=max(1, min(10, result.get("urgency", 5))),
                importance=max(1, min(10, result.get("importance", 5))),
                total_score=result.get("urgency", 5) + result.get("importance", 5),
                reasoning=result.get("reasoning", "AI 분석 결과"),
                suggested_tags=result.get("suggested_tags", []),
                estimated_time=result.get("estimated_time", "미정")
            )
            
            logger.info(f"AI priority analysis completed: {analysis.total_score}/20")
            return analysis
            
        except json.JSONDecodeError as e:
            logger.error(f"JSON parsing failed in priority analysis: {e}")
            # Return default analysis
            return PriorityAnalysis(
                urgency=5,
                importance=5,
                total_score=10,
                reasoning="AI 분석 중 오류가 발생하여 기본값을 제공합니다.",
                suggested_tags=["일반"],
                estimated_time="미정"
            )
            
        except Exception as e:
            logger.error(f"Priority analysis failed: {e}")
            # Return default analysis
            return PriorityAnalysis(
                urgency=5,
                importance=5,
                total_score=10,
                reasoning="AI 분석 중 오류가 발생하여 기본값을 제공합니다.",
                suggested_tags=["일반"],
                estimated_time="미정"
            )
    
    async def suggest_tags(self, content: str) -> TagSuggestion:
        """
        Suggest appropriate tags for content using AI
        
        Args:
            content: Content to analyze for tags
            
        Returns:
            TagSuggestion object with recommended tags
        """
        try:
            prompt = TAG_CLASSIFICATION_PROMPT.format(content=content)
            
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "당신은 콘텐츠 분류 전문가입니다. 주어진 내용에 적절한 태그를 JSON 형식으로 제안합니다."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.4,
                max_tokens=300
            )
            
            # Parse JSON response
            content_str = response.choices[0].message.content
            
            # Extract JSON from response
            if "```json" in content_str:
                json_start = content_str.find("```json") + 7
                json_end = content_str.find("```", json_start)
                json_str = content_str[json_start:json_end].strip()
            else:
                start = content_str.find("{")
                end = content_str.rfind("}") + 1
                json_str = content_str[start:end]
            
            result = json.loads(json_str)
            
            # Create TagSuggestion object
            suggestion = TagSuggestion(
                recommended_tags=result.get("recommended_tags", ["일반"]),
                category=result.get("category", "기타"),
                confidence=max(0.0, min(1.0, result.get("confidence", 0.7)))
            )
            
            logger.info(f"AI tag suggestion completed: {len(suggestion.recommended_tags)} tags")
            return suggestion
            
        except json.JSONDecodeError as e:
            logger.error(f"JSON parsing failed in tag suggestion: {e}")
            return TagSuggestion(
                recommended_tags=["일반"],
                category="기타",
                confidence=0.5
            )
            
        except Exception as e:
            logger.error(f"Tag suggestion failed: {e}")
            return TagSuggestion(
                recommended_tags=["일반"],
                category="기타",
                confidence=0.5
            )
    
    async def generate_daily_summary(
        self, 
        completed_tasks: List[Dict[str, Any]], 
        in_progress_tasks: List[Dict[str, Any]], 
        top_priorities: List[Dict[str, Any]]
    ) -> str:
        """
        Generate daily summary for email notifications
        
        Args:
            completed_tasks: List of completed tasks
            in_progress_tasks: List of tasks in progress
            top_priorities: List of top priority tasks
            
        Returns:
            Formatted summary string
        """
        try:
            from app.config.prompts import DAILY_SUMMARY_PROMPT
            
            prompt = DAILY_SUMMARY_PROMPT.format(
                completed_tasks=completed_tasks,
                in_progress_tasks=in_progress_tasks,
                top_priorities=top_priorities
            )
            
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "당신은 생산성 코치입니다. 하루의 작업 현황을 요약하고 동기부여하는 메시지를 작성합니다."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.7,
                max_tokens=800
            )
            
            summary = response.choices[0].message.content
            logger.info("Daily summary generated successfully")
            return summary
            
        except Exception as e:
            logger.error(f"Daily summary generation failed: {e}")
            return """
📊 **오늘의 진행 상황**
✅ 완료된 작업들이 있습니다
🔄 진행 중인 작업들이 있습니다

🎯 **오늘 집중할 작업들**
우선순위가 높은 작업들을 확인해보세요!

💡 **한 줄 조언**
작은 진전도 큰 성과의 시작입니다! 🌟
"""
    
    def get_model_info(self) -> Dict[str, str]:
        """Get current AI model information"""
        return {
            "model": self.model,
            "provider": "OpenAI",
            "status": "active" if self.client.api_key else "inactive"
        }
    
    def health_check(self) -> bool:
        """Check if AI service is healthy"""
        try:
            # Simple test call
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": "test"}],
                max_tokens=1
            )
            return True
        except Exception as e:
            logger.error(f"AI service health check failed: {e}")
            return False