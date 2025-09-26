"""
문제 분석 파이프라인
원문 문제 → 계층적 AI 분석 → 구조화된 데이터 생성
해설은 사용자 입력, AI는 개념/키워드/난이도만 분석
"""
import uuid
from datetime import datetime
from typing import Dict, List, Any

from .hierarchical_analyzer import hierarchical_analyzer

class ProblemAnalyzer:
    """통합 문제 분석 파이프라인"""

    def __init__(self):
        self.analyzer = hierarchical_analyzer

    def process_problem(self,
                       question_text: str,
                       choices: List[str],
                       correct_answer: str,
                       explanation: str = "",
                       subject: str = "기본간호학",
                       user_tags: List[str] = None) -> Dict[str, Any]:
        """
        완전한 문제 처리 파이프라인

        Args:
            question_text: 문제 텍스트
            choices: 선택지 리스트
            correct_answer: 정답
            explanation: 사용자 입력 해설 (선택)
            subject: 과목명
            user_tags: 사용자 지정 태그 (선택)

        Returns:
            구조화된 문제 데이터
        """
        try:
            # 1. AI 분석 수행
            ai_analysis = self.analyzer.analyze_problem(question_text, choices, correct_answer)

            # 2. 사용자 태그와 AI 키워드 통합
            all_keywords = list(set(
                (user_tags or []) + ai_analysis.get("keywords", [])
            ))

            # 3. 완전한 문제 데이터 구성
            problem_data = {
                # 기본 정보
                "id": str(uuid.uuid4()),
                "question_text": question_text,
                "choices": choices,
                "correct_answer": correct_answer,
                "explanation": explanation,  # 사용자 입력
                "subject": subject,

                # AI 분석 결과
                "concepts": ai_analysis.get("concepts", []),
                "keywords": all_keywords,
                "difficulty": ai_analysis.get("difficulty", "중"),

                # 메타데이터
                "confidence_score": ai_analysis.get("confidence_score", 0.0),
                "verified_by": ai_analysis.get("verified_by", "unknown"),
                "created_at": datetime.now().isoformat(),
                "created_by": "problem_analyzer",

                # 통계 초기값
                "stats": {
                    "attempts": 0,
                    "correct_rate": 0.0,
                    "avg_time": 0.0,
                    "last_attempted": None
                }
            }

            # 4. 품질 검증
            validation_result = self._validate_problem_data(problem_data)
            problem_data["validation"] = validation_result

            return problem_data

        except Exception as e:
            print(f"[ERROR] 문제 처리 실패: {e}")
            # GPT-5 재시도 실패 시 전체 처리 실패로 처리 (오류 상태로 저장하지 않음)
            if "GPT-5 enhancement failed after retries" in str(e):
                print(f"[CRITICAL] GPT-5 분석 재시도 실패 - 문제 저장을 중단합니다")
                raise Exception(f"Problem analysis critically failed: {e}")
            else:
                # 다른 오류는 기존대로 fallback 처리
                return self._create_fallback_problem(question_text, choices, correct_answer, explanation, subject)

    def _validate_problem_data(self, problem_data: Dict[str, Any]) -> Dict[str, Any]:
        """문제 데이터 품질 검증"""
        issues = []
        score = 1.0

        # 필수 필드 확인
        required_fields = ["question_text", "choices", "correct_answer"]
        for field in required_fields:
            if not problem_data.get(field):
                issues.append(f"필수 필드 누락: {field}")
                score -= 0.3

        # 선택지 개수 확인
        choices = problem_data.get("choices", [])
        if len(choices) < 2:
            issues.append("선택지가 2개 미만")
            score -= 0.2
        elif len(choices) > 6:
            issues.append("선택지가 6개 초과")

        # 정답이 선택지에 있는지 확인
        correct_answer = problem_data.get("correct_answer", "")
        if correct_answer not in choices:
            issues.append("정답이 선택지에 없음")
            score -= 0.4

        # 개념 개수 확인
        concepts = problem_data.get("concepts", [])
        if len(concepts) < 1:
            issues.append("개념이 추출되지 않음")
            score -= 0.2

        # 키워드 개수 확인
        keywords = problem_data.get("keywords", [])
        if len(keywords) < 2:
            issues.append("키워드가 부족함")
            score -= 0.1

        return {
            "score": max(0, score),
            "issues": issues,
            "status": "valid" if score > 0.7 else "warning" if score > 0.4 else "invalid"
        }

    def _create_fallback_problem(self, question_text: str, choices: List[str],
                                correct_answer: str, explanation: str, subject: str) -> Dict[str, Any]:
        """분석 실패 시 기본 구조 생성"""
        return {
            "id": str(uuid.uuid4()),
            "question_text": question_text,
            "choices": choices,
            "correct_answer": correct_answer,
            "explanation": explanation,
            "subject": subject,
            "concepts": ["분석실패"],
            "keywords": ["fallback"],
            "difficulty": "중",
            "confidence_score": 0.0,
            "verified_by": "fallback",
            "created_at": datetime.now().isoformat(),
            "created_by": "fallback",
            "stats": {
                "attempts": 0,
                "correct_rate": 0.0,
                "avg_time": 0.0,
                "last_attempted": None
            },
            "validation": {
                "score": 0.3,
                "issues": ["AI 분석 실패"],
                "status": "invalid"
            }
        }

    def batch_process(self, problems: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """여러 문제 일괄 처리"""
        results = []
        total = len(problems)

        print(f"📋 {total}개 문제 일괄 처리 시작...")

        for i, problem in enumerate(problems):
            print(f"📝 처리 중... ({i+1}/{total})")

            try:
                result = self.process_problem(
                    question_text=problem.get("question_text", ""),
                    choices=problem.get("choices", []),
                    correct_answer=problem.get("correct_answer", ""),
                    explanation=problem.get("explanation", ""),
                    subject=problem.get("subject", "기본간호학"),
                    user_tags=problem.get("tags", [])
                )
                results.append(result)

            except Exception as e:
                print(f"[ERROR] 문제 {i+1} 처리 실패: {e}")
                results.append(self._create_fallback_problem(
                    problem.get("question_text", ""),
                    problem.get("choices", []),
                    problem.get("correct_answer", ""),
                    problem.get("explanation", ""),
                    problem.get("subject", "기본간호학")
                ))

        print(f"[SUCCESS] 일괄 처리 완료: {len(results)}/{total}")
        return results

# 전역 인스턴스
problem_analyzer = ProblemAnalyzer()

if __name__ == "__main__":
    # 테스트
    test_data = {
        "question_text": "활력징후 측정 시 혈압을 가장 먼저 측정해야 하는 이유는?",
        "choices": [
            "환자가 편안한 상태에서 측정해야 정확하기 때문",
            "다른 측정으로 인한 자극이 혈압에 영향을 주기 때문",
            "혈압계 사용이 가장 간단하기 때문",
            "혈압이 가장 중요한 지표이기 때문"
        ],
        "correct_answer": "다른 측정으로 인한 자극이 혈압에 영향을 주기 때문",
        "explanation": "혈압은 환자의 심리적, 물리적 자극에 민감하게 반응하므로 다른 활력징후 측정 전 안정된 상태에서 먼저 측정해야 합니다.",
        "subject": "기본간호학",
        "tags": ["활력징후", "혈압측정"]
    }

    result = problem_analyzer.process_problem(**test_data)
    print("\n📋 처리 결과:")
    import json
    print(json.dumps(result, ensure_ascii=False, indent=2))