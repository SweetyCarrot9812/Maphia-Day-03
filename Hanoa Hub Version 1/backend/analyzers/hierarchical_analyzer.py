"""
계층적 AI 분석기
GPT-5-mini 우선 사용 → 신뢰도 70% 미만 시 GPT-5 검수
해설 자동생성 제외, 개념/키워드/난이도만 분석
"""
import json
import openai
from typing import Dict, List, Tuple, Any
from datetime import datetime

from config import OPENAI_API_KEY

# OpenAI 클라이언트 설정
openai.api_key = OPENAI_API_KEY

# API 사용량 추적
try:
    from api_usage_tracker import api_tracker
except ImportError:
    api_tracker = None

class HierarchicalAnalyzer:
    """계층적 문제 분석기 - 비용 효율성과 품질 보장"""

    def __init__(self):
        # 2025년 기준 실제 사용 가능한 GPT-5 시리즈 모델
        self.gpt5_mini_model = "gpt-5-mini"  # GPT-5 Mini (확인됨)
        self.gpt5_model = "gpt-5"  # GPT-5 Full (확인됨)
        self.confidence_threshold = 0.70

    def analyze_problem(self, question_text: str, choices: List[str], correct_answer: str) -> Dict[str, Any]:
        """
        문제 분석 메인 함수
        해설 제외하고 개념/키워드/난이도만 분석
        """
        try:
            # Step 1: GPT-5-mini로 초기 분석
            mini_result = self._analyze_with_mini(question_text, choices, correct_answer)
            confidence_score = self._calculate_confidence(mini_result)

            # Step 2: 신뢰도 체크 및 GPT-5 검수
            if confidence_score < self.confidence_threshold:
                print(f"[WARNING] 신뢰도 {confidence_score:.2%} - GPT-5 검수 진행")
                final_result = self._enhance_with_gpt5(question_text, choices, correct_answer, mini_result)
                verified_by = "gpt5_enhanced"
            else:
                print(f"[SUCCESS] 신뢰도 {confidence_score:.2%} - GPT-5-mini 결과 승인")
                final_result = mini_result
                verified_by = "gpt5_mini"

            # 최종 결과 구성
            return {
                "concepts": final_result.get("concepts", []),
                "keywords": final_result.get("keywords", []),
                "difficulty": final_result.get("difficulty", "보통"),
                "confidence_score": confidence_score,
                "verified_by": verified_by,
                "processed_at": datetime.now().isoformat()
            }

        except Exception as e:
            print(f"[ERROR] 분석 실패: {e}")
            return {
                "concepts": [],
                "keywords": [],
                "difficulty": "보통",
                "confidence_score": 0.0,
                "verified_by": "error",
                "error": str(e)
            }

    def _analyze_with_mini(self, question_text: str, choices: List[str], correct_answer: str) -> Dict[str, Any]:
        """GPT-5-mini로 초기 분석"""

        prompt = f"""
다음 간호학/의학 문제를 분석해주세요:

문제: {question_text}
선택지: {', '.join(choices)}
정답: {correct_answer}

다음 형식으로 JSON 응답해주세요:
{{
    "concepts": ["핵심 개념1", "핵심 개념2", "핵심 개념3"],
    "keywords": ["키워드1", "키워드2", "키워드3", "키워드4", "키워드5"],
    "difficulty": "상|중|하",
    "reasoning": "분석 근거"
}}

요구사항:
1. concepts: 최소 2개, 최대 5개의 핵심 의학/간호학 개념
2. keywords: 최소 3개, 최대 8개의 관련 키워드
3. difficulty: 간호사/의사 국가고시 기준 난이도
4. reasoning: 분류 근거 간단히 설명
"""

        try:
            response = openai.chat.completions.create(
                model=self.gpt5_mini_model,
                messages=[
                    {"role": "system", "content": "당신은 의학/간호학 교육 전문가입니다. 문제를 정확히 분석하여 구조화된 데이터를 제공합니다."},
                    {"role": "user", "content": prompt}
                ],
                max_completion_tokens=1000  # GPT-5 uses max_completion_tokens
                # temperature parameter removed - GPT-5 only supports default value
            )

            # API 사용량 추적
            if api_tracker:
                input_tokens = response.usage.prompt_tokens if hasattr(response, 'usage') else len(prompt) // 4
                output_tokens = response.usage.completion_tokens if hasattr(response, 'usage') else 1000
                api_tracker.track_usage(self.gpt5_mini_model, input_tokens, output_tokens)

            content = response.choices[0].message.content.strip()
            # JSON 파싱 시도
            if content.startswith("```json"):
                content = content.replace("```json", "").replace("```", "").strip()

            result = json.loads(content)
            return result

        except Exception as e:
            print(f"[ERROR] GPT-5-mini 분석 실패: {e}")
            return {
                "concepts": ["분석실패"],
                "keywords": ["오류"],
                "difficulty": "보통",
                "reasoning": f"분석 실패: {str(e)}"
            }

    def _calculate_confidence(self, result: Dict[str, Any]) -> float:
        """분석 결과의 신뢰도 계산"""
        scores = []

        # 1. 개념 개수 및 품질 (40%)
        concepts = result.get("concepts", [])
        if len(concepts) >= 2:
            concept_score = min(len(concepts) / 4, 1.0)  # 최대 4개 기준
        else:
            concept_score = 0.3
        scores.append(concept_score * 0.4)

        # 2. 키워드 개수 및 품질 (30%)
        keywords = result.get("keywords", [])
        if len(keywords) >= 3:
            keyword_score = min(len(keywords) / 6, 1.0)  # 최대 6개 기준
        else:
            keyword_score = 0.2
        scores.append(keyword_score * 0.3)

        # 3. 난이도 분류 유효성 (20%)
        difficulty = result.get("difficulty", "")
        if difficulty in ["상", "중", "하"]:
            difficulty_score = 1.0
        else:
            difficulty_score = 0.0
        scores.append(difficulty_score * 0.2)

        # 4. 분석 근거 제공 여부 (10%)
        reasoning = result.get("reasoning", "")
        if len(reasoning) > 10:
            reasoning_score = 1.0
        else:
            reasoning_score = 0.0
        scores.append(reasoning_score * 0.1)

        return sum(scores)

    def _enhance_with_gpt5(self, question_text: str, choices: List[str], correct_answer: str, mini_result: Dict[str, Any]) -> Dict[str, Any]:
        """GPT-5로 검수 및 개선"""

        prompt = f"""
다음 간호학/의학 문제의 GPT-5-mini 분석 결과를 검수하고 개선해주세요:

문제: {question_text}
선택지: {', '.join(choices)}
정답: {correct_answer}

GPT-5-mini 분석 결과:
- 개념: {mini_result.get('concepts', [])}
- 키워드: {mini_result.get('keywords', [])}
- 난이도: {mini_result.get('difficulty', '')}

문제점 분석 및 개선된 결과를 다음 형식으로 제공해주세요:
{{
    "concepts": ["개선된 핵심 개념들"],
    "keywords": ["개선된 키워드들"],
    "difficulty": "상|중|하",
    "improvements": "어떤 부분을 개선했는지 설명"
}}

검수 기준:
1. 의학/간호학적 정확성
2. 개념의 완성도 (누락된 핵심 개념 추가)
3. 키워드의 관련성 및 충분성
4. 난이도 분류의 적절성
"""

        try:
            response = openai.chat.completions.create(
                model=self.gpt5_model,
                messages=[
                    {"role": "system", "content": "당신은 의학/간호학 교육 전문가입니다. GPT-5-mini 결과를 검토하고 전문적 관점에서 개선합니다."},
                    {"role": "user", "content": prompt}
                ],
                max_completion_tokens=1200  # GPT-5 uses max_completion_tokens
                # temperature parameter removed - GPT-5 only supports default value
            )

            # API 사용량 추적
            if api_tracker:
                input_tokens = response.usage.prompt_tokens if hasattr(response, 'usage') else len(prompt) // 4
                output_tokens = response.usage.completion_tokens if hasattr(response, 'usage') else 1200
                api_tracker.track_usage(self.gpt5_model, input_tokens, output_tokens)

            content = response.choices[0].message.content.strip()
            if content.startswith("```json"):
                content = content.replace("```json", "").replace("```", "").strip()

            enhanced_result = json.loads(content)
            return enhanced_result

        except Exception as e:
            print(f"[ERROR] GPT-5 검수 실패, mini 결과 사용: {e}")
            return mini_result

# 전역 인스턴스
hierarchical_analyzer = HierarchicalAnalyzer()

if __name__ == "__main__":
    # 테스트
    test_question = "혈압 측정 시 가장 중요한 주의사항은?"
    test_choices = [
        "환자를 편안하게 앉힌다",
        "측정 전 30분간 금연한다",
        "커프 크기는 상관없다",
        "측정 직후 바로 운동한다"
    ]
    test_answer = "측정 전 30분간 금연한다"

    result = hierarchical_analyzer.analyze_problem(test_question, test_choices, test_answer)
    print("\n📋 분석 결과:")
    print(json.dumps(result, ensure_ascii=False, indent=2))