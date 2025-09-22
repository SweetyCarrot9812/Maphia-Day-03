"""
학습 분석기
사용자의 풀이 데이터를 분석하여 부족한 개념을 진단하고
맞춤형 학습 경로를 제안
"""
from typing import Dict, List, Any, Tuple
from datetime import datetime, timedelta
from collections import defaultdict, Counter
import json

from models.problem_schema import ProblemData

class LearningAnalyzer:
    """학습 패턴 분석 및 약점 진단"""

    def __init__(self):
        self.weakness_threshold = 0.6  # 약점 기준점
        self.min_attempts = 2  # 최소 시도 횟수

    def analyze_user_performance(self, problems: List[ProblemData], user_id: str = "default") -> Dict[str, Any]:
        """
        사용자의 전체 학습 성과 분석

        Args:
            problems: 문제 데이터 리스트
            user_id: 사용자 ID

        Returns:
            종합 분석 결과
        """
        if not problems:
            return self._empty_analysis(user_id)

        # 1. 기본 통계
        basic_stats = self._calculate_basic_stats(problems)

        # 2. 개념별 성과 분석
        concept_analysis = self._analyze_by_concepts(problems)

        # 3. 난이도별 성과 분석
        difficulty_analysis = self._analyze_by_difficulty(problems)

        # 4. 시간 패턴 분석
        time_analysis = self._analyze_time_patterns(problems)

        # 5. 약점 개념 진단
        weak_concepts = self._identify_weak_concepts(concept_analysis)

        # 6. 학습 추천사항
        recommendations = self._generate_recommendations(
            basic_stats, concept_analysis, difficulty_analysis, weak_concepts
        )

        return {
            "user_id": user_id,
            "analysis_date": datetime.now().isoformat(),
            "basic_stats": basic_stats,
            "concept_analysis": concept_analysis,
            "difficulty_analysis": difficulty_analysis,
            "time_analysis": time_analysis,
            "weak_concepts": weak_concepts,
            "recommendations": recommendations,
            "summary": self._generate_summary(basic_stats, weak_concepts)
        }

    def _calculate_basic_stats(self, problems: List[ProblemData]) -> Dict[str, Any]:
        """기본 통계 계산"""
        attempted_problems = [p for p in problems if p.stats.attempts > 0]

        if not attempted_problems:
            return {
                "total_problems": len(problems),
                "attempted_problems": 0,
                "overall_accuracy": 0.0,
                "avg_attempts_per_problem": 0.0,
                "avg_time_per_problem": 0.0,
                "completion_rate": 0.0
            }

        total_attempts = sum(p.stats.attempts for p in attempted_problems)
        total_time = sum(p.stats.avg_time * p.stats.attempts for p in attempted_problems)
        accuracy_sum = sum(p.stats.correct_rate for p in attempted_problems)

        return {
            "total_problems": len(problems),
            "attempted_problems": len(attempted_problems),
            "overall_accuracy": accuracy_sum / len(attempted_problems),
            "avg_attempts_per_problem": total_attempts / len(attempted_problems),
            "avg_time_per_problem": total_time / total_attempts if total_attempts > 0 else 0.0,
            "completion_rate": len(attempted_problems) / len(problems)
        }

    def _analyze_by_concepts(self, problems: List[ProblemData]) -> Dict[str, Dict[str, Any]]:
        """개념별 성과 분석"""
        concept_stats = defaultdict(lambda: {
            "problems": [],
            "total_attempts": 0,
            "correct_answers": 0,
            "total_time": 0.0,
            "accuracy": 0.0,
            "avg_time": 0.0,
            "weakness_score": 0.0
        })

        # 개념별 데이터 수집
        for problem in problems:
            if problem.stats.attempts == 0:
                continue

            for concept in problem.concepts:
                stats = concept_stats[concept]
                stats["problems"].append(problem.id)
                stats["total_attempts"] += problem.stats.attempts

                # 정답 수 계산
                correct_answers = int(problem.stats.correct_rate * problem.stats.attempts)
                stats["correct_answers"] += correct_answers

                # 총 시간 계산
                total_time = problem.stats.avg_time * problem.stats.attempts
                stats["total_time"] += total_time

        # 통계 계산
        for concept, stats in concept_stats.items():
            if stats["total_attempts"] > 0:
                stats["accuracy"] = stats["correct_answers"] / stats["total_attempts"]
                stats["avg_time"] = stats["total_time"] / stats["total_attempts"]

                # 약점 점수 계산 (낮은 정답률 + 긴 소요시간)
                accuracy_weakness = 1.0 - stats["accuracy"]
                time_weakness = min(stats["avg_time"] / 60.0, 1.0)  # 60초 기준
                stats["weakness_score"] = accuracy_weakness * 0.7 + time_weakness * 0.3

        return dict(concept_stats)

    def _analyze_by_difficulty(self, problems: List[ProblemData]) -> Dict[str, Dict[str, Any]]:
        """난이도별 성과 분석"""
        difficulty_stats = defaultdict(lambda: {
            "problem_count": 0,
            "attempted_count": 0,
            "total_attempts": 0,
            "correct_answers": 0,
            "total_time": 0.0,
            "accuracy": 0.0,
            "avg_time": 0.0
        })

        for problem in problems:
            difficulty = problem.difficulty
            stats = difficulty_stats[difficulty]
            stats["problem_count"] += 1

            if problem.stats.attempts > 0:
                stats["attempted_count"] += 1
                stats["total_attempts"] += problem.stats.attempts

                correct_answers = int(problem.stats.correct_rate * problem.stats.attempts)
                stats["correct_answers"] += correct_answers

                total_time = problem.stats.avg_time * problem.stats.attempts
                stats["total_time"] += total_time

        # 통계 계산
        for difficulty, stats in difficulty_stats.items():
            if stats["total_attempts"] > 0:
                stats["accuracy"] = stats["correct_answers"] / stats["total_attempts"]
                stats["avg_time"] = stats["total_time"] / stats["total_attempts"]

        return dict(difficulty_stats)

    def _analyze_time_patterns(self, problems: List[ProblemData]) -> Dict[str, Any]:
        """시간 패턴 분석"""
        attempted_problems = [p for p in problems if p.stats.attempts > 0]

        if not attempted_problems:
            return {
                "fast_problems": [],
                "slow_problems": [],
                "avg_time_by_difficulty": {},
                "time_trend": "no_data"
            }

        # 시간 기준 분류
        times = [p.stats.avg_time for p in attempted_problems]
        avg_time = sum(times) / len(times)

        fast_problems = [p for p in attempted_problems if p.stats.avg_time < avg_time * 0.7]
        slow_problems = [p for p in attempted_problems if p.stats.avg_time > avg_time * 1.5]

        # 난이도별 평균 시간
        difficulty_times = defaultdict(list)
        for problem in attempted_problems:
            difficulty_times[problem.difficulty].append(problem.stats.avg_time)

        avg_time_by_difficulty = {
            diff: sum(times) / len(times) for diff, times in difficulty_times.items()
        }

        return {
            "fast_problems": [p.id for p in fast_problems[:5]],  # 상위 5개
            "slow_problems": [p.id for p in slow_problems[:5]],   # 상위 5개
            "avg_time_by_difficulty": avg_time_by_difficulty,
            "overall_avg_time": avg_time,
            "time_efficiency": "good" if avg_time < 45 else "needs_improvement"
        }

    def _identify_weak_concepts(self, concept_analysis: Dict[str, Dict[str, Any]]) -> List[Dict[str, Any]]:
        """약점 개념 식별"""
        weak_concepts = []

        for concept, stats in concept_analysis.items():
            # 최소 시도 횟수 확인
            if stats["total_attempts"] < self.min_attempts:
                continue

            weakness_score = stats["weakness_score"]
            if weakness_score >= self.weakness_threshold:
                weak_concepts.append({
                    "concept": concept,
                    "weakness_score": weakness_score,
                    "accuracy": stats["accuracy"],
                    "avg_time": stats["avg_time"],
                    "problem_count": len(stats["problems"]),
                    "priority": self._calculate_priority(stats)
                })

        # 우선순위로 정렬
        weak_concepts.sort(key=lambda x: x["priority"], reverse=True)
        return weak_concepts

    def _calculate_priority(self, stats: Dict[str, Any]) -> float:
        """약점 개념의 우선순위 계산"""
        # 약점 점수 (50%) + 문제 수 (30%) + 시도 횟수 (20%)
        weakness_weight = stats["weakness_score"] * 0.5
        problem_count_weight = min(len(stats["problems"]) / 10, 1.0) * 0.3
        attempts_weight = min(stats["total_attempts"] / 20, 1.0) * 0.2

        return weakness_weight + problem_count_weight + attempts_weight

    def _generate_recommendations(self,
                                basic_stats: Dict[str, Any],
                                concept_analysis: Dict[str, Dict[str, Any]],
                                difficulty_analysis: Dict[str, Dict[str, Any]],
                                weak_concepts: List[Dict[str, Any]]) -> List[Dict[str, str]]:
        """맞춤형 학습 추천사항 생성"""
        recommendations = []

        # 전체 정답률 기반 추천
        overall_accuracy = basic_stats["overall_accuracy"]
        if overall_accuracy < 0.6:
            recommendations.append({
                "type": "accuracy",
                "title": "기초 개념 복습 필요",
                "description": f"전체 정답률이 {overall_accuracy:.1%}로 낮습니다. 기본 개념부터 차근차근 복습하세요.",
                "priority": "high"
            })

        # 약점 개념 기반 추천
        if weak_concepts:
            top_weak = weak_concepts[0]
            recommendations.append({
                "type": "weak_concept",
                "title": f"'{top_weak['concept']}' 집중 학습",
                "description": f"가장 약한 개념입니다. 관련 문제를 더 풀어보세요. (정답률: {top_weak['accuracy']:.1%})",
                "priority": "high"
            })

        # 난이도별 추천
        for difficulty, stats in difficulty_analysis.items():
            if stats["attempted_count"] > 0 and stats["accuracy"] < 0.5:
                recommendations.append({
                    "type": "difficulty",
                    "title": f"'{difficulty}' 난이도 보강",
                    "description": f"{difficulty} 난이도 문제의 정답률이 {stats['accuracy']:.1%}입니다.",
                    "priority": "medium"
                })

        # 시간 효율성 추천
        avg_time = basic_stats["avg_time_per_problem"]
        if avg_time > 60:
            recommendations.append({
                "type": "time",
                "title": "시간 관리 개선",
                "description": f"평균 풀이 시간이 {avg_time:.0f}초입니다. 시간 단축 연습이 필요합니다.",
                "priority": "medium"
            })

        return recommendations[:5]  # 최대 5개

    def _generate_summary(self, basic_stats: Dict[str, Any], weak_concepts: List[Dict[str, Any]]) -> str:
        """분석 요약 생성"""
        accuracy = basic_stats["overall_accuracy"]
        completion = basic_stats["completion_rate"]

        summary = f"전체 정답률 {accuracy:.1%}, 완료율 {completion:.1%}"

        if weak_concepts:
            summary += f", 주요 약점: {weak_concepts[0]['concept']}"

        if accuracy >= 0.8:
            summary += " - 우수한 성과!"
        elif accuracy >= 0.6:
            summary += " - 양호한 수준"
        else:
            summary += " - 추가 학습 필요"

        return summary

    def _empty_analysis(self, user_id: str) -> Dict[str, Any]:
        """빈 분석 결과"""
        return {
            "user_id": user_id,
            "analysis_date": datetime.now().isoformat(),
            "basic_stats": {
                "total_problems": 0,
                "attempted_problems": 0,
                "overall_accuracy": 0.0,
                "completion_rate": 0.0
            },
            "concept_analysis": {},
            "difficulty_analysis": {},
            "time_analysis": {"time_trend": "no_data"},
            "weak_concepts": [],
            "recommendations": [{
                "type": "start",
                "title": "학습 시작",
                "description": "문제 풀이를 시작해보세요!",
                "priority": "high"
            }],
            "summary": "아직 풀이 데이터가 없습니다."
        }

# 전역 인스턴스
learning_analyzer = LearningAnalyzer()

if __name__ == "__main__":
    # 테스트용 샘플 데이터
    from models.problem_schema import create_sample_problems

    problems = create_sample_problems()

    # 임의의 풀이 데이터 추가
    problems[0].update_stats(True, 35.0)
    problems[0].update_stats(False, 45.0)
    problems[1].update_stats(False, 120.0)
    problems[1].update_stats(False, 90.0)

    analysis = learning_analyzer.analyze_user_performance(problems, "test_user")
    print(json.dumps(analysis, ensure_ascii=False, indent=2))