"""
Learning Plan Engine - 학습 플랜 자동 설계 엔진
GPT-5-mini를 사용하여 사용자의 학습 로그를 분석하고 최적화된 문제 생성 플랜을 자동으로 수립
"""

import os
import json
import openai
from typing import Dict, List, Any, Optional
from datetime import datetime, timedelta
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv
from collections import Counter
import asyncio

# Load environment variables
load_dotenv()

# Configure OpenAI
openai.api_key = os.getenv('OPENAI_API_KEY')

# Initialize Firebase if not already done
if not firebase_admin._apps:
    cred = credentials.Certificate('firebase-service-account.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()


class LearningPlanEngine:
    """학습 플랜 자동 설계 엔진"""

    def __init__(self):
        self.openai_client = openai.OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

    async def analyze_learning_history(
        self,
        user_id: str,
        days_back: int = 7
    ) -> Dict[str, Any]:
        """
        사용자의 학습 이력을 분석하여 성과 지표를 추출

        Args:
            user_id: 사용자 ID
            days_back: 분석할 과거 일수

        Returns:
            학습 분석 결과
        """
        try:
            # 날짜 계산
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days_back)

            # 1. 오답 데이터 가져오기
            wrong_answers = await self._get_wrong_answers(user_id, start_date)

            # 2. 정답 데이터 가져오기 (study_progress에서)
            correct_answers = await self._get_correct_answers(user_id, start_date)

            # 3. 분석 수행
            analysis = {
                'user_id': user_id,
                'period': {
                    'start': start_date.isoformat(),
                    'end': end_date.isoformat(),
                    'days': days_back
                },
                'total_attempts': len(wrong_answers) + len(correct_answers),
                'correct_count': len(correct_answers),
                'wrong_count': len(wrong_answers),
                'accuracy_rate': len(correct_answers) / (len(wrong_answers) + len(correct_answers)) if (len(wrong_answers) + len(correct_answers)) > 0 else 0,
                'weak_concepts': self._analyze_weak_concepts(wrong_answers),
                'difficulty_performance': self._analyze_difficulty_performance(wrong_answers, correct_answers),
                'question_type_performance': self._analyze_question_type_performance(wrong_answers, correct_answers),
                'recent_topics': self._extract_recent_topics(wrong_answers + correct_answers),
                'improvement_areas': []
            }

            # 4. 개선 영역 도출
            if analysis['accuracy_rate'] < 0.6:
                analysis['improvement_areas'].append('전반적인 정답률 향상 필요')

            if analysis['weak_concepts']:
                top_weak = list(analysis['weak_concepts'].keys())[:3]
                analysis['improvement_areas'].extend([f"{concept} 개념 보강" for concept in top_weak])

            # 난이도별 취약점
            if analysis['difficulty_performance'].get('hard', {}).get('accuracy', 0) < 0.3:
                analysis['improvement_areas'].append('고난도 문제 대비 필요')
            elif analysis['difficulty_performance'].get('easy', {}).get('accuracy', 1.0) < 0.8:
                analysis['improvement_areas'].append('기초 개념 재학습 필요')

            return analysis

        except Exception as e:
            print(f"[ERROR] 학습 이력 분석 실패: {e}")
            return {
                'error': str(e),
                'user_id': user_id,
                'total_attempts': 0
            }

    async def generate_learning_plan(
        self,
        learning_analysis: Dict[str, Any],
        target_count: int = 12
    ) -> Dict[str, Any]:
        """
        GPT-5-mini를 사용하여 학습 분석 결과를 바탕으로 최적 학습 플랜 생성

        Args:
            learning_analysis: 학습 분석 결과
            target_count: 목표 문제 수

        Returns:
            학습 플랜
        """
        try:
            # GPT-5-mini에게 전달할 프롬프트 구성
            prompt = f"""You are an expert educational planner for medical/nursing exam preparation.
Based on the following learning analysis, create an optimal study plan with specific problem type distribution.

Learning Analysis:
- Total Attempts: {learning_analysis.get('total_attempts', 0)}
- Accuracy Rate: {learning_analysis.get('accuracy_rate', 0):.1%}
- Weak Concepts: {', '.join(list(learning_analysis.get('weak_concepts', {}).keys())[:5])}
- Difficulty Performance:
  - Easy: {learning_analysis.get('difficulty_performance', {}).get('easy', {}).get('accuracy', 0):.1%}
  - Medium: {learning_analysis.get('difficulty_performance', {}).get('medium', {}).get('accuracy', 0):.1%}
  - Hard: {learning_analysis.get('difficulty_performance', {}).get('hard', {}).get('accuracy', 0):.1%}
- Improvement Areas: {', '.join(learning_analysis.get('improvement_areas', []))}
- Target Question Count: {target_count}

Create a study plan that:
1. Addresses weak concepts first
2. Balances difficulty appropriately based on current performance
3. Uses varied question types to enhance learning
4. Total questions should be exactly {target_count}

Return ONLY valid JSON in this exact format:
{{
    "problem_types": {{
        "MCQ": <number>,
        "Case": <number>,
        "Ordered": <number>,
        "Matching": <number>,
        "Branching": <number>,
        "DragDrop": <number>,
        "MultiStep": <number>,
        "Image": <number>
    }},
    "difficulty_distribution": {{
        "easy": <number>,
        "medium": <number>,
        "hard": <number>
    }},
    "concept_focus": [<list of 3-5 concepts to focus on>],
    "total_count": {target_count},
    "reasoning": "<brief explanation in Korean about why this plan was chosen>"
}}

Ensure:
- Sum of all problem_types equals {target_count}
- Sum of difficulty_distribution equals {target_count}
- Reasoning is in Korean
- If accuracy < 60%, focus more on MCQ and easy problems
- If accuracy > 80%, include more Case, Branching, MultiStep problems"""

            # GPT-5-mini 호출
            response = self.openai_client.chat.completions.create(
                model="gpt-5-mini",
                messages=[
                    {"role": "system", "content": "You are an expert educational planner. Always return valid JSON only."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=1000,
                response_format={"type": "json_object"}
            )

            # 응답 파싱
            plan = json.loads(response.choices[0].message.content)

            # 검증 및 조정
            plan = self._validate_and_adjust_plan(plan, target_count)

            # 메타데이터 추가
            plan['generated_at'] = datetime.now().isoformat()
            plan['based_on_analysis'] = {
                'accuracy_rate': learning_analysis.get('accuracy_rate', 0),
                'weak_concepts': list(learning_analysis.get('weak_concepts', {}).keys())[:3],
                'total_attempts': learning_analysis.get('total_attempts', 0)
            }

            return plan

        except Exception as e:
            print(f"[ERROR] 학습 플랜 생성 실패: {e}")
            # 기본 플랜 반환
            return self._get_default_plan(target_count)

    async def execute_learning_plan(
        self,
        plan: Dict[str, Any],
        user_id: str,
        subject: str = "nursing"
    ) -> Dict[str, Any]:
        """
        생성된 학습 플랜을 실행하여 실제 문제 생성

        Args:
            plan: 학습 플랜
            user_id: 사용자 ID
            subject: 과목

        Returns:
            생성 결과
        """
        from ai_batch_generator import BatchQuestionGenerator
        from question_types import QuestionType

        try:
            generator = BatchQuestionGenerator()
            all_questions = []
            generation_stats = {
                'requested': plan['total_count'],
                'generated': 0,
                'failed': 0,
                'by_type': {}
            }

            # 각 문제 유형별로 생성
            for problem_type, count in plan['problem_types'].items():
                if count > 0:
                    # 해당 유형의 문제들 생성
                    questions_for_type = []
                    difficulty_distribution = self._distribute_difficulty_for_type(
                        count,
                        plan['difficulty_distribution'],
                        plan['total_count']
                    )

                    for difficulty, diff_count in difficulty_distribution.items():
                        if diff_count > 0:
                            result = await generator.generate_batch(
                                count=diff_count,
                                subject=subject,
                                topics=plan.get('concept_focus', ['general']),
                                question_types=[QuestionType(problem_type)],
                                difficulty=difficulty,
                                save_to_firebase=True
                            )

                            if result['success']:
                                questions_for_type.extend(result['questions'])
                                generation_stats['generated'] += result['stats']['total_generated']
                                generation_stats['failed'] += result['stats']['failed']

                    all_questions.extend(questions_for_type)
                    generation_stats['by_type'][problem_type] = len(questions_for_type)

            # 학습 플랜 실행 기록 저장
            await self._save_plan_execution(user_id, plan, generation_stats)

            return {
                'success': True,
                'plan': plan,
                'questions': all_questions,
                'stats': generation_stats
            }

        except Exception as e:
            print(f"[ERROR] 학습 플랜 실행 실패: {e}")
            return {
                'success': False,
                'error': str(e),
                'plan': plan,
                'questions': [],
                'stats': {}
            }

    # === Helper Methods ===

    async def _get_wrong_answers(self, user_id: str, start_date: datetime) -> List[Dict]:
        """오답 데이터 조회"""
        try:
            wrong_answers = []
            docs = db.collection('users').document(user_id).collection('wrong_answers') \
                .where('createdAt', '>=', start_date) \
                .stream()

            for doc in docs:
                data = doc.to_dict()
                wrong_answers.append(data)

            return wrong_answers
        except Exception as e:
            print(f"[ERROR] 오답 조회 실패: {e}")
            return []

    async def _get_correct_answers(self, user_id: str, start_date: datetime) -> List[Dict]:
        """정답 데이터 조회"""
        try:
            correct_answers = []
            docs = db.collection('users').document(user_id).collection('study_progress') \
                .where('timestamp', '>=', start_date) \
                .where('isCorrect', '==', True) \
                .stream()

            for doc in docs:
                data = doc.to_dict()
                correct_answers.append(data)

            return correct_answers
        except Exception as e:
            print(f"[ERROR] 정답 조회 실패: {e}")
            return []

    def _analyze_weak_concepts(self, wrong_answers: List[Dict]) -> Dict[str, int]:
        """취약 개념 분석"""
        concept_counter = Counter()

        for answer in wrong_answers:
            concepts = answer.get('concepts', [])
            for concept in concepts:
                concept_counter[concept] += 1

        return dict(concept_counter.most_common(10))

    def _analyze_difficulty_performance(
        self,
        wrong_answers: List[Dict],
        correct_answers: List[Dict]
    ) -> Dict[str, Dict]:
        """난이도별 성과 분석"""
        difficulty_stats = {
            'easy': {'correct': 0, 'wrong': 0, 'accuracy': 0},
            'medium': {'correct': 0, 'wrong': 0, 'accuracy': 0},
            'hard': {'correct': 0, 'wrong': 0, 'accuracy': 0}
        }

        for answer in wrong_answers:
            diff = answer.get('difficulty', 'medium').lower()
            if diff in difficulty_stats:
                difficulty_stats[diff]['wrong'] += 1

        for answer in correct_answers:
            diff = answer.get('difficulty', 'medium').lower()
            if diff in difficulty_stats:
                difficulty_stats[diff]['correct'] += 1

        # 정답률 계산
        for diff, stats in difficulty_stats.items():
            total = stats['correct'] + stats['wrong']
            if total > 0:
                stats['accuracy'] = stats['correct'] / total

        return difficulty_stats

    def _analyze_question_type_performance(
        self,
        wrong_answers: List[Dict],
        correct_answers: List[Dict]
    ) -> Dict[str, Dict]:
        """문제 유형별 성과 분석"""
        type_stats = {}

        for answer in wrong_answers:
            q_type = answer.get('questionType', 'MCQ')
            if q_type not in type_stats:
                type_stats[q_type] = {'correct': 0, 'wrong': 0}
            type_stats[q_type]['wrong'] += 1

        for answer in correct_answers:
            q_type = answer.get('questionType', 'MCQ')
            if q_type not in type_stats:
                type_stats[q_type] = {'correct': 0, 'wrong': 0}
            type_stats[q_type]['correct'] += 1

        return type_stats

    def _extract_recent_topics(self, all_answers: List[Dict]) -> List[str]:
        """최근 학습 주제 추출"""
        topic_counter = Counter()

        for answer in all_answers:
            # 태그에서 주제 추출
            tags = answer.get('tags', [])
            for tag in tags:
                topic_counter[tag] += 1

            # 과목에서도 추출
            subject = answer.get('subject', '')
            if subject:
                topic_counter[subject] += 1

        return [topic for topic, _ in topic_counter.most_common(5)]

    def _validate_and_adjust_plan(self, plan: Dict, target_count: int) -> Dict:
        """플랜 검증 및 조정"""
        # 문제 유형 합계 조정
        type_total = sum(plan['problem_types'].values())
        if type_total != target_count:
            # 비율 유지하면서 조정
            ratio = target_count / type_total if type_total > 0 else 1
            for key in plan['problem_types']:
                plan['problem_types'][key] = round(plan['problem_types'][key] * ratio)

            # 마지막 조정
            diff = target_count - sum(plan['problem_types'].values())
            if diff != 0:
                plan['problem_types']['MCQ'] = max(0, plan['problem_types'].get('MCQ', 0) + diff)

        # 난이도 분포 합계 조정
        diff_total = sum(plan['difficulty_distribution'].values())
        if diff_total != target_count:
            ratio = target_count / diff_total if diff_total > 0 else 1
            for key in plan['difficulty_distribution']:
                plan['difficulty_distribution'][key] = round(plan['difficulty_distribution'][key] * ratio)

            # 마지막 조정
            diff = target_count - sum(plan['difficulty_distribution'].values())
            if diff != 0:
                plan['difficulty_distribution']['medium'] = max(0, plan['difficulty_distribution'].get('medium', 0) + diff)

        plan['total_count'] = target_count
        return plan

    def _get_default_plan(self, target_count: int) -> Dict:
        """기본 학습 플랜 반환"""
        return {
            'problem_types': {
                'MCQ': target_count // 2,
                'Case': target_count // 4,
                'Ordered': target_count // 8,
                'Matching': target_count // 8,
                'Branching': 0,
                'DragDrop': 0,
                'MultiStep': 0,
                'Image': 0
            },
            'difficulty_distribution': {
                'easy': target_count // 3,
                'medium': target_count // 3,
                'hard': target_count - (2 * (target_count // 3))
            },
            'concept_focus': ['기본간호', '투약', '감염관리'],
            'total_count': target_count,
            'reasoning': '학습 데이터가 부족하여 기본 플랜을 제공합니다.',
            'generated_at': datetime.now().isoformat(),
            'is_default': True
        }

    def _distribute_difficulty_for_type(
        self,
        type_count: int,
        overall_distribution: Dict[str, int],
        total_count: int
    ) -> Dict[str, int]:
        """문제 유형별 난이도 분배"""
        distribution = {}
        total_ratio = sum(overall_distribution.values())

        for difficulty, overall_count in overall_distribution.items():
            if total_ratio > 0:
                ratio = overall_count / total_ratio
                distribution[difficulty] = round(type_count * ratio)
            else:
                distribution[difficulty] = type_count // len(overall_distribution)

        # 합계 조정
        diff = type_count - sum(distribution.values())
        if diff != 0 and 'medium' in distribution:
            distribution['medium'] += diff

        return distribution

    async def _save_plan_execution(
        self,
        user_id: str,
        plan: Dict,
        stats: Dict
    ) -> None:
        """플랜 실행 기록 저장"""
        try:
            db.collection('learning_plans').add({
                'user_id': user_id,
                'plan': plan,
                'execution_stats': stats,
                'executed_at': firestore.SERVER_TIMESTAMP,
                'status': 'completed' if stats.get('generated', 0) > 0 else 'failed'
            })
        except Exception as e:
            print(f"[ERROR] 플랜 실행 기록 저장 실패: {e}")


# 사용 예시
async def main():
    """테스트 실행"""
    engine = LearningPlanEngine()

    # 1. 학습 이력 분석
    analysis = await engine.analyze_learning_history(
        user_id="test_user",
        days_back=7
    )
    print("[ANALYSIS]", json.dumps(analysis, indent=2, ensure_ascii=False))

    # 2. 학습 플랜 생성
    plan = await engine.generate_learning_plan(
        learning_analysis=analysis,
        target_count=12
    )
    print("[PLAN]", json.dumps(plan, indent=2, ensure_ascii=False))

    # 3. 플랜 실행
    result = await engine.execute_learning_plan(
        plan=plan,
        user_id="test_user",
        subject="nursing"
    )
    print("[RESULT]", f"Generated {result['stats'].get('generated', 0)} questions")


if __name__ == "__main__":
    asyncio.run(main())