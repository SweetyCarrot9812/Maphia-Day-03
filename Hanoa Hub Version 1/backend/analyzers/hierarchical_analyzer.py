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

def _parse_json_content(content: str):
    content = content.strip()
    if content.startswith("```json"):
        content = content.replace("```json", "").replace("```", "").strip()
    import json, re
    try:
        return json.loads(content)
    except Exception:
        m = re.search(r"\{[\s\S]*\}", content)
        if m:
            return json.loads(m.group(0))
        raise


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
        # 실제 사용 가능한 GPT-5 시리즈 모델 (2025년 확인됨)
        self.gpt5_mini_model = "gpt-5-mini"  # GPT-5 Mini (비용 효율적)
        self.gpt5_model = "gpt-5"  # GPT-5 Full (고품질 리뷰용)
        self.confidence_threshold = 0.70

    def detect_field(self, question_text: str) -> str:
        """문제 내용으로 의학/간호학 자동 판단"""
        medical_keywords = ["수술", "처방", "진단", "병리", "약물동력학", "감별진단", "예후", "병인", "치료"]
        nursing_keywords = ["간호진단", "간호과정", "환자교육", "간호중재", "간호사정", "간호계획", "간호평가"]

        question_lower = question_text.lower()
        medical_score = sum(1 for kw in medical_keywords if kw in question_text)
        nursing_score = sum(1 for kw in nursing_keywords if kw in question_text)

        if medical_score > nursing_score:
            return "medical"
        elif nursing_score > medical_score:
            return "nursing"
        else:
            return "both"

    def analyze_concept(self, concept_description: str, tags: List[str] = None) -> Dict[str, Any]:
        """
        개념 분석 - 유사도 검색에 최적화된 키워드/태그 추출
        난이도는 제외하고 검색 효율성에 집중
        GPT-5 Mini → GPT-5 에스컬레이션 포함
        """
        try:
            # 분야 자동 감지
            field = self.detect_field(concept_description)

            # GPT-5-mini로 개념 분석 (키워드/태그 중심)
            result = self._analyze_concept_with_mini(concept_description, tags, field)

            # 신뢰도 평가 (키워드 수와 품질 기반)
            confidence = self._evaluate_concept_confidence(result)
            result['confidence'] = confidence

            # 신뢰도가 낮으면 GPT-5로 리뷰
            if confidence < self.confidence_threshold:
                print(f"[INFO] 개념 분석 신뢰도 낮음 ({confidence:.1%}), GPT-5로 에스컬레이션")
                enhanced_result = self._review_concept_with_gpt5(concept_description, tags, field, result)

                # GPT-5 결과 병합
                result['keywords'] = list(set(result.get('keywords', []) + enhanced_result.get('keywords', [])))[:15]
                result['search_terms'] = list(set(result.get('search_terms', []) + enhanced_result.get('search_terms', [])))[:20]
                result['related_concepts'] = list(set(result.get('related_concepts', []) + enhanced_result.get('related_concepts', [])))[:5]
                result['gpt5_review'] = True
                result['confidence'] = min(confidence + 0.2, 0.95)  # GPT-5 리뷰 후 신뢰도 상승
            else:
                result['gpt5_review'] = False

            # 페르소나 정보 추가 (UI 표시용)
            result['personas'] = self._extract_concept_personas(result)

            # 최종 결과 구성 (난이도 제외, 검색 최적화)
            return {
                "keywords": result.get("keywords", []),
                "search_terms": result.get("search_terms", []),  # 다양한 표현
                "related_concepts": result.get("related_concepts", []),
                "category": result.get("category", ""),
                "field_detected": field,
                "tags": result.get("tags", tags or []),
                "confidence": result.get("confidence", 0.8),
                "gpt5_review": result.get("gpt5_review", False),
                "personas": result.get("personas", []),
                "processed_at": datetime.now().isoformat()
            }

        except Exception as e:
            print(f"[ERROR] 개념 분석 실패: {e}")
            return {
                "keywords": tags or [],
                "search_terms": [],
                "related_concepts": [],
                "category": "",
                "field_detected": "both",
                "tags": tags or [],
                "confidence": 0.0,
                "error": str(e)
            }

    def _analyze_concept_with_mini(self, concept_description: str, tags: List[str], field: str) -> Dict[str, Any]:
        """개념을 4명의 전문가가 분석 - 유사도 검색 최적화"""

        prompt = f"""
의료 개념을 4명의 전문가가 검색 최적화 관점에서 분석합니다.
분야: {field}

개념 설명: {concept_description}
사용자 태그: {tags or []}

4명의 전문가가 각자 다른 관점에서 키워드를 추출합니다:
1. 학술전문가: 의학/간호학 전문용어, 학술 용어
2. 임상전문가: 실무에서 사용하는 용어, 임상 표현
3. 시험전문가: 시험에 자주 나오는 표현, 문제 키워드
4. 최근합격자: 학생들이 사용하는 표현, 암기용 키워드

목적: 이 개념과 관련된 문제를 검색할 때 매칭될 수 있는 모든 표현 추출

{{
    "academic_keywords": ["학술 용어", "전문 의학용어", "표준 용어"],
    "clinical_keywords": ["임상 현장 용어", "실무 표현", "약어"],
    "exam_keywords": ["시험 빈출 표현", "문제에 나오는 키워드"],
    "student_keywords": ["학생들 표현", "쉬운 말", "암기법"],
    "merged": {{
        "keywords": ["중복 제거된 핵심 키워드 10-15개"],
        "search_terms": ["검색에 사용될 다양한 표현 15-20개"],
        "related_concepts": ["함께 학습해야 할 연관 개념 3-5개"],
        "category": "주요 카테고리",
        "tags": ["분류 태그들"]
    }}
}}

요구사항:
1. 동의어, 약어, 다양한 표현 모두 포함
2. 한국어/영어 모두 포함
3. 검색 매칭률을 높이기 위한 다양성 확보
4. 난이도나 학습시간은 불필요
"""

        try:
            response = openai.chat.completions.create(
                model=self.gpt5_mini_model,
                messages=[
                    {"role": "system", "content": "의료 개념 분석 및 검색 최적화 전문가"},
                    {"role": "user", "content": prompt}
                ],
                max_completion_tokens=800
            )

            content = response.choices[0].message.content.strip()
            result = _parse_json_content(content)

            # merged 부분 반환
            if "merged" in result:
                return result["merged"]
            else:
                return result

        except Exception as e:
            print(f"[ERROR] 개념 분석 실패: {e}")
            return {
                "keywords": [],
                "search_terms": [],
                "related_concepts": [],
                "category": "",
                "tags": tags or []
            }

    def _evaluate_concept_confidence(self, result: Dict[str, Any]) -> float:
        """개념 분석 결과의 신뢰도 평가"""
        confidence = 0.5  # 기본값

        # 키워드 수 기반 평가
        keyword_count = len(result.get("keywords", []))
        if keyword_count >= 10:
            confidence += 0.2
        elif keyword_count >= 5:
            confidence += 0.1

        # 검색어 다양성 평가
        search_term_count = len(result.get("search_terms", []))
        if search_term_count >= 15:
            confidence += 0.2
        elif search_term_count >= 10:
            confidence += 0.1

        # 연관 개념 존재 여부
        if len(result.get("related_concepts", [])) >= 3:
            confidence += 0.1

        # 카테고리 분류 여부
        if result.get("category"):
            confidence += 0.05

        return min(confidence, 0.95)

    def _review_concept_with_gpt5(self, concept_description: str, tags: List[str], field: str, initial_result: Dict[str, Any]) -> Dict[str, Any]:
        """GPT-5로 개념 분석 리뷰 및 보강"""
        prompt = f"""
이전 GPT-5 Mini 분석 결과를 검토하고 보강하세요.

개념 설명: {concept_description}
분야: {field}
사용자 태그: {tags or []}

이전 분석 결과:
- 키워드: {initial_result.get('keywords', [])}
- 검색어: {initial_result.get('search_terms', [])}
- 연관 개념: {initial_result.get('related_concepts', [])}

요구사항:
1. 누락된 중요 키워드 추가
2. 더 다양한 검색 표현 제안
3. 중요한 연관 개념 보충
4. 검색 매칭률을 높이기 위한 동의어/약어 추가

{{
    "keywords": ["보강된 키워드들"],
    "search_terms": ["추가 검색 표현들"],
    "related_concepts": ["추가 연관 개념들"],
    "review_comment": "검토 의견"
}}
"""
        try:
            response = openai.chat.completions.create(
                model=self.gpt5_model,
                messages=[
                    {"role": "system", "content": "의료 개념 검색 최적화 전문가"},
                    {"role": "user", "content": prompt}
                ],
                max_completion_tokens=500
            )

            content = response.choices[0].message.content.strip()
            return _parse_json_content(content)

        except Exception as e:
            print(f"[ERROR] GPT-5 개념 리뷰 실패: {e}")
            return initial_result

    def _extract_concept_personas(self, result: Dict[str, Any]) -> List[Dict[str, Any]]:
        """개념 분석 결과에서 페르소나별 관점 추출"""
        # 원래 결과에서 페르소나별 키워드가 있다면 추출
        personas = []

        if "academic_keywords" in result:
            personas.append({
                "name": "학술전문가",
                "role": "의학/간호학 전문용어",
                "keywords": result.get("academic_keywords", []),
                "search_expressions": result.get("academic_keywords", [])[:3]
            })

        if "clinical_keywords" in result:
            personas.append({
                "name": "임상전문가",
                "role": "실무 표현",
                "keywords": result.get("clinical_keywords", []),
                "search_expressions": result.get("clinical_keywords", [])[:3]
            })

        if "exam_keywords" in result:
            personas.append({
                "name": "시험전문가",
                "role": "시험 빈출 표현",
                "keywords": result.get("exam_keywords", []),
                "search_expressions": result.get("exam_keywords", [])[:3]
            })

        if "student_keywords" in result:
            personas.append({
                "name": "최근합격자",
                "role": "학습자 표현",
                "keywords": result.get("student_keywords", []),
                "search_expressions": result.get("student_keywords", [])[:3]
            })

        return personas

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
                try:
                    final_result = self._enhance_with_gpt5(question_text, choices, correct_answer, mini_result)
                    verified_by = "gpt5_enhanced"
                except Exception as gpt5_error:
                    print(f"[CRITICAL] GPT-5 검수 최종 실패: {gpt5_error}")
                    # GPT-5 실패 시 전체 분석 실패로 처리 (오류 상태로 저장하지 않음)
                    raise Exception(f"Problem analysis failed: GPT-5 enhancement failed after retries - {gpt5_error}")
            else:
                print(f"[SUCCESS] 신뢰도 {confidence_score:.2%} - GPT-5-mini 결과 승인")
                final_result = mini_result
                verified_by = "gpt5_mini"

            # 최종 결과 구성
            return {
                "concepts": final_result.get("concepts", []),
                "keywords": final_result.get("keywords", []),
                "difficulty": final_result.get("difficulty", "중"),
                "confidence_score": confidence_score,
                "verified_by": verified_by,
                "processed_at": datetime.now().isoformat()
            }

        except Exception as e:
            print(f"[ERROR] 분석 실패: {e}")
            return {
                "concepts": [],
                "keywords": [],
                "difficulty": "중",
                "confidence_score": 0.0,
                "verified_by": "error",
                "error": str(e)
            }

    def _analyze_with_mini(self, question_text: str, choices: List[str], correct_answer: str) -> Dict[str, Any]:
        """GPT-5-mini로 초기 분석 - 의학/간호학 범용 페르소나"""

        # 분야 자동 감지
        field = self.detect_field(question_text)

        # 분야별 페르소나 조정
        if field == "medical":
            academic = "의과대학 교수 (내과학 전공, 20년 경력)"
            clinical = "전문의 (대학병원 15년 경력)"
            exam = "의사 국시 전문 강사"
            recent = "인턴 (최근 국시 합격)"
        elif field == "nursing":
            academic = "간호대학 교수 (성인간호학 전공, 20년 경력)"
            clinical = "수간호사 (3차 병원 15년 경력)"
            exam = "간호사 국시 전문 강사"
            recent = "신규간호사 (최근 국시 합격)"
        else:  # both
            academic = "의료계열 교수 (20년 경력)"
            clinical = "임상 전문가 (15년 경력)"
            exam = "의료 국시 전문 강사"
            recent = "의료계열 최근 합격자"

        prompt = f"""
의료 분야 문제를 4명의 전문가가 분석합니다.
분야: {field} (medical/nursing/both)

문제: {question_text}
선택지: {', '.join(choices)}
정답: {correct_answer}

4명의 전문가 구성:
1. [학술전문가] - {academic}: 이론과 학술 개념 중심
2. [임상전문가] - {clinical}: 실무와 환자 케어 중심
3. [시험전문가] - {exam}: 출제 포인트와 빈출 유형 중심
4. [최근합격자] - {recent}: 효과적 학습법과 암기 팁 중심

다음 형식으로 JSON 응답해주세요:
{{
    "academic_view": {{
        "concepts": ["학술적 핵심 개념 2-3개"],
        "keywords": ["이론 관련 키워드 3-4개"],
        "clinical_relevance": "임상적 중요도 설명"
    }},
    "clinical_view": {{
        "concepts": ["실무 핵심 개념 2-3개"],
        "keywords": ["임상 용어 3-4개"],
        "common_mistakes": ["자주 하는 실수 1-2개"]
    }},
    "exam_view": {{
        "concepts": ["시험 빈출 개념 2-3개"],
        "keywords": ["출제 키워드 3-4개"],
        "test_strategy": "시험 전략"
    }},
    "recent_view": {{
        "concepts": ["암기 필수 개념 2-3개"],
        "keywords": ["기억하기 쉬운 키워드 3-4개"],
        "study_tip": "효과적 학습법"
    }},
    "merged": {{
        "concepts": ["통합된 핵심 개념 3-5개"],
        "keywords": ["중복 제거된 전체 키워드 5-8개"],
        "difficulty": {{
            "cognitive_load": 1-5,  # 인지적 부담
            "prerequisite_count": 0-10,  # 선행학습 필요 개수
            "study_hours": 0.5-10,  # 예상 학습시간
            "learning_stage": "foundation/development/application/mastery"  # 학습 단계
        }},
        "field_detected": "{field}",  # 감지된 분야
        "reasoning": "종합 분석 근거"
    }}
}}

요구사항:
1. 각 전문가는 자신의 관점에서 독특한 통찰 제공
2. merged에는 모든 관점을 통합하되 중복 제거
3. 키워드는 구체적이고 검색/학습에 유용하게
4. difficulty는 학습자 관점에서 평가 (국시 기준 아님)
5. 의학/간호학 구분 없이 범용적으로 적용"""

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

            
            try:
                result = _parse_json_content(content)
            except json.JSONDecodeError:
                import re
                m = re.search(r'\{[\s\S]*\}', content)
                if m:
                    result = json.loads(m.group(0))
                else:
                    raise

            # 페르소나 통합 결과에서 merged 부분 처리
            if "merged" in result:
                # 페르소나별 뷰도 저장 (디버깅/분석용)
                merged = result["merged"]
                merged["persona_views"] = {
                    "academic": result.get("academic_view", {}),
                    "clinical": result.get("clinical_view", {}),
                    "exam": result.get("exam_view", {}),
                    "recent": result.get("recent_view", {})
                }
                # difficulty가 딕셔너리가 아니면 변환 (하위 호환성)
                if isinstance(merged.get("difficulty"), str):
                    diff_map = {"상": 4, "중": 3, "하": 2}
                    merged["difficulty"] = {
                        "cognitive_load": diff_map.get(merged["difficulty"], 3),
                        "prerequisite_count": 3,
                        "study_hours": 2,
                        "learning_stage": "development"
                    }
                return merged
            else:
                # 구형 포맷 호환성
                return result

        except Exception as e:
            print(f"[ERROR] GPT-5-mini 분석 실패: {e}")
            return {
                "concepts": ["분석실패"],
                "keywords": ["오류"],
                "difficulty": "중",
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
        """GPT-5로 검수 - 의학/간호학 범용 페르소나 적용 (실패 시 재시도)"""

        # 분야 자동 감지
        field = self.detect_field(question_text)

        # 분야별 페르소나 조정
        if field == "medical":
            academic = "의대 교수"
            clinical = "전문의"
            exam = "의사 국시 강사"
            recent = "인턴"
        elif field == "nursing":
            academic = "간호대 교수"
            clinical = "수간호사"
            exam = "간호사 국시 강사"
            recent = "신규간호사"
        else:
            academic = "의료계열 교수"
            clinical = "임상 전문가"
            exam = "의료 국시 강사"
            recent = "최근 합격자"

        prompt = f"""
4명의 전문가가 GPT-5-mini 분석 결과를 검수하고 개선합니다.
분야: {field}

문제: {question_text}
선택지: {', '.join(choices)}
정답: {correct_answer}

GPT-5-mini 초기 분석:
- 개념: {mini_result.get('concepts', [])}
- 키워드: {mini_result.get('keywords', [])}
- 난이도: {mini_result.get('difficulty', {})}

[전문가 검수 회의]
{academic}: "이론적으로 더 정확한 개념은..."
{clinical}: "임상에서 중요한 포인트가 빠졌네요..."
{exam}: "최근 출제 경향상 이 부분도 추가해야..."
{recent}: "실제 시험에서는 이렇게 나왔어요..."

{{
    "review_process": {{
        "academic_review": {{
            "added_concepts": ["{academic}가 추가/수정한 학술 개념"],
            "comment": "학술적 검토 의견"
        }},
        "clinical_review": {{
            "added_concepts": ["{clinical}가 추가한 임상 개념"],
            "comment": "임상적 검토 의견"
        }},
        "exam_review": {{
            "added_concepts": ["{exam}가 추가한 시험 핵심"],
            "comment": "시험 관점 검토"
        }},
        "recent_review": {{
            "added_concepts": ["{recent}가 추가한 암기 포인트"],
            "comment": "학습 경험 공유"
        }}
    }},
    "merged": {{
        "concepts": ["4명이 합의한 최종 핵심 개념 3-5개"],
        "keywords": ["최종 선별 키워드 5-8개"],
        "difficulty": {{
            "cognitive_load": 1-5,
            "prerequisite_count": 0-10,
            "study_hours": 0.5-10,
            "learning_stage": "foundation/development/application/mastery"
        }},
        "improvements": "초기 분석 대비 개선 사항",
        "consensus_reached": true
    }}
}}

요구사항:
1. 각 전문가는 자신의 관점에서 누락/오류 지적
2. 검토 과정을 투명하게 기록
3. merged에는 4명 합의로 개선된 최종 결과
4. 학습자 관점의 난이도 재평가
"""

        # GPT-5 재시도 로직 (최대 3회)
        max_retries = 3
        for attempt in range(max_retries):
            try:
                if attempt > 0:
                    print(f"[RETRY] GPT-5 분석 재시도 {attempt}/{max_retries-1}")

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

                enhanced_result = _parse_json_content(content)

                # review_process가 있으면 merged로 통합
                if "review_process" in enhanced_result:
                    # 검토 과정을 persona_views에 저장
                    merged = enhanced_result.get("merged", {})
                    merged["review_process"] = enhanced_result["review_process"]
                    merged["field_detected"] = field
                    result = merged
                else:
                    # 구형 포맷 호환성
                    result = enhanced_result

                if attempt > 0:
                    print(f"[SUCCESS] GPT-5 검수 {attempt}회째에서 성공")
                return result

            except Exception as e:
                print(f"[ERROR] GPT-5 시도 {attempt+1}회차 실패: {e}")

                # 마지막 시도였다면 에러와 함께 처리 중단
                if attempt == max_retries - 1:
                    print(f"[CRITICAL] GPT-5 최대 재시도 횟수 {max_retries}회 도달. 분석 실패로 처리.")
                    # 에러가 있는 상태로 저장하지 않고 예외를 다시 발생시킴
                    raise Exception(f"GPT-5 analysis failed after {max_retries} attempts: {e}")

                # 다음 시도를 위해 계속 진행
                continue

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
