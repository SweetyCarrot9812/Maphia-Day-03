from typing import List, Dict, Any, Optional
from datetime import datetime
import httpx
import json

from app.services.ai_coach_service import AICoachService
from app.core.config import settings


class RAGService:
    """Custom RAG (Retrieval-Augmented Generation) Service"""

    def __init__(self):
        self.vector_db_url = "http://localhost:8001"  # Your RAG service URL
        self.similarity_threshold = 0.7

    async def search_knowledge_base(self, query: str, top_k: int = 5) -> List[Dict]:
        """Search your custom knowledge base"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.vector_db_url}/search",
                    json={
                        "query": query,
                        "top_k": top_k,
                        "threshold": self.similarity_threshold
                    }
                )

                if response.status_code == 200:
                    return response.json().get("results", [])
                else:
                    print(f"RAG search failed: {response.status_code}")
                    return []

        except Exception as e:
            print(f"RAG service error: {e}")
            return []

    async def add_to_knowledge_base(self, content: str, metadata: Dict = None):
        """Add new content to knowledge base"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.vector_db_url}/add",
                    json={
                        "content": content,
                        "metadata": metadata or {}
                    }
                )
                return response.status_code == 200
        except Exception as e:
            print(f"Failed to add to knowledge base: {e}")
            return False


class HybridAIService:
    """Combines OpenAI with custom RAG for enhanced responses"""

    def __init__(self):
        self.openai_service = AICoachService()
        self.rag_service = RAGService()

    async def get_enhanced_response(
        self,
        user_query: str,
        user_context: Dict = None,
        use_rag: bool = True
    ) -> Dict[str, Any]:
        """Get AI response enhanced with RAG knowledge"""

        # 1. Search custom knowledge base first
        rag_results = []
        if use_rag:
            rag_results = await self.rag_service.search_knowledge_base(user_query)

        # 2. Build enhanced context
        context_parts = []

        if user_context:
            context_parts.append(f"User Profile: {json.dumps(user_context, indent=2)}")

        if rag_results:
            context_parts.append("Relevant Knowledge from Database:")
            for i, result in enumerate(rag_results[:3]):  # Top 3 results
                context_parts.append(f"{i+1}. {result.get('content', '')}")
                if result.get('metadata'):
                    context_parts.append(f"   Source: {result['metadata']}")

        # 3. Create enhanced prompt
        enhanced_prompt = f"""
사용자 질문: {user_query}

{chr(10).join(context_parts) if context_parts else ""}

다음 정보들을 종합하여 답변해주세요:
1. 제공된 지식 베이스 내용을 우선적으로 참고
2. 일반적인 운동/건강 상식 활용
3. 사용자 프로필에 맞는 개인화된 조언
4. 구체적이고 실행 가능한 방법 제시

답변은 친근하고 전문적인 톤으로 작성해주세요.
"""

        # 4. Get OpenAI response
        try:
            openai_response = await self.openai_service.get_coach_advice(enhanced_prompt)

            response = {
                "answer": openai_response.get("advice", ""),
                "confidence": openai_response.get("confidence", 0.8),
                "sources": {
                    "rag_results_count": len(rag_results),
                    "openai_model": settings.OPENAI_MODEL,
                    "enhanced_with_rag": use_rag and len(rag_results) > 0
                },
                "metadata": {
                    "query": user_query,
                    "timestamp": datetime.utcnow().isoformat(),
                    "rag_results": rag_results[:2] if rag_results else []  # Include top 2 for reference
                }
            }

            # 5. Learn from interaction (optional)
            if len(rag_results) == 0 and openai_response.get("advice"):
                # Add good responses to knowledge base for future use
                await self._add_interaction_to_knowledge_base(user_query, openai_response.get("advice"))

            return response

        except Exception as e:
            return {
                "answer": "죄송합니다. 현재 AI 서비스에 문제가 있습니다. 잠시 후 다시 시도해주세요.",
                "confidence": 0.0,
                "error": str(e),
                "sources": {"rag_results_count": len(rag_results), "enhanced_with_rag": False}
            }

    async def _add_interaction_to_knowledge_base(self, query: str, response: str):
        """Add successful Q&A pairs to knowledge base for learning"""
        content = f"Q: {query}\nA: {response}"
        metadata = {
            "type": "qa_pair",
            "source": "openai_interaction",
            "timestamp": datetime.utcnow().isoformat(),
            "confidence": "high"
        }

        await self.rag_service.add_to_knowledge_base(content, metadata)

    async def get_workout_recommendations(
        self,
        user_profile: Dict,
        fitness_goals: List[str],
        available_equipment: List[str] = None
    ) -> Dict[str, Any]:
        """Get workout recommendations using hybrid approach"""

        # Build search query for RAG
        goals_str = ", ".join(fitness_goals)
        equipment_str = ", ".join(available_equipment) if available_equipment else "bodyweight"

        search_query = f"workout plan {goals_str} equipment {equipment_str}"

        # Get RAG results
        rag_workouts = await self.rag_service.search_knowledge_base(search_query)

        # Build context for OpenAI
        context = {
            "profile": user_profile,
            "goals": fitness_goals,
            "equipment": available_equipment or [],
            "existing_workouts": rag_workouts[:3] if rag_workouts else []
        }

        prompt = f"""
사용자 정보:
- 목표: {goals_str}
- 사용 가능한 장비: {equipment_str}
- 경험 수준: {user_profile.get('experience_level', 'beginner')}

기존 운동 플랜 참고자료:
{json.dumps(rag_workouts[:2], ensure_ascii=False, indent=2) if rag_workouts else "없음"}

위 정보를 바탕으로 주 3-4회, 4주 운동 계획을 작성해주세요.
각 운동별 세트, 횟수, 휴식시간을 포함해주세요.
"""

        return await self.get_enhanced_response(prompt, context, use_rag=True)

    async def analyze_workout_form(
        self,
        exercise_name: str,
        user_description: str,
        video_url: Optional[str] = None
    ) -> Dict[str, Any]:
        """Analyze workout form with RAG-enhanced knowledge"""

        # Search for form tips in RAG
        form_query = f"{exercise_name} form technique tips common mistakes"
        form_knowledge = await self.rag_service.search_knowledge_base(form_query)

        context = {
            "exercise": exercise_name,
            "user_description": user_description,
            "video_provided": video_url is not None,
            "form_database": form_knowledge[:3] if form_knowledge else []
        }

        prompt = f"""
운동: {exercise_name}
사용자 설명: {user_description}

폼 가이드 데이터베이스:
{json.dumps(form_knowledge, ensure_ascii=False, indent=2) if form_knowledge else "기본 지식 활용"}

다음 내용으로 폼 분석을 해주세요:
1. 올바른 폼 포인트
2. 흔한 실수들
3. 개선 방법
4. 안전 주의사항
"""

        return await self.get_enhanced_response(prompt, context, use_rag=True)


# Global service instance
hybrid_ai_service = HybridAIService()