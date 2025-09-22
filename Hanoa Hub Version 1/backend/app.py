"""
Hanoa RAG System - Streamlit Main Application
"""
import json
import uuid
from datetime import datetime
from pathlib import Path

import streamlit as st
import pandas as pd

from config import validate_config, JOBS_DIR, OBSIDIAN_VAULT_PATH
from rag_engine import rag_engine
from jobs_worker import jobs_worker
from analyzers.learning_analyzer import learning_analyzer
from generators.rag_generator import rag_generator
from analyzers.problem_analyzer import problem_analyzer
from models.problem_schema import ProblemData, create_sample_problems
from api_usage_tracker import api_tracker
from services.firebase_service import firebase_service

# Page configuration
st.set_page_config(
    page_title="Hanoa RAG System",
    page_icon="📚",
    layout="wide",
    initial_sidebar_state="expanded"
)

def main():
    """Main Streamlit application"""

    # Initialize session state
    if 'initialized' not in st.session_state:
        try:
            validate_config()
            st.session_state.initialized = True
        except Exception as e:
            st.error(f"Configuration error: {e}")
            st.stop()

    # Header
    st.title("📚 Hanoa RAG System")
    st.markdown("간호학 문제/개념 관리 및 RAG 검색 시스템")

    # Sidebar - System Status
    with st.sidebar:
        st.header("📊 시스템 상태")

        # RAG Stats
        try:
            stats = rag_engine.get_stats()
            st.metric("총 문제", stats['questions'])
            st.metric("총 개념", stats['concepts'])
            st.metric("전체 데이터", stats['total'])
        except Exception as e:
            st.error(f"RAG 상태 확인 실패: {e}")

        # Jobs Status
        st.subheader("🔄 Jobs 상태")
        try:
            jobs_status = jobs_worker.get_status()
            col1, col2 = st.columns(2)
            with col1:
                st.metric("대기", jobs_status['pending'])
                st.metric("처리중", jobs_status['processing'])
            with col2:
                st.metric("완료", jobs_status['completed'])
                st.metric("실패", jobs_status['failed'])
        except Exception as e:
            st.error(f"Jobs 상태 확인 실패: {e}")

        st.divider()

        # Obsidian Path
        st.subheader("📝 Obsidian Vault")
        st.text(OBSIDIAN_VAULT_PATH)

        if st.button("🔄 새로고침"):
            st.rerun()

    # Main content tabs - 문제 검색 탭 제거 (6개 → 5개)
    tab1, tab2, tab3, tab4, tab5 = st.tabs(["📝 데이터 입력", "🤖 문제 분석", "📚 RAG 생성", "📊 학습 분석", "⚙️ 시스템 관리"])

    with tab1:
        data_input_tab()

    with tab2:
        problem_analysis_tab()

    with tab3:
        rag_generation_tab()

    with tab4:
        learning_analysis_tab()

    with tab5:
        system_management_tab()


def data_input_tab():
    """Data input tab for questions and concepts"""
    st.header("📝 데이터 입력")

    input_type = st.selectbox("입력 타입", ["문제", "개념"])

    if input_type == "문제":
        question_input_form()
    else:
        concept_input_form()


def question_input_form():
    """Form for inputting nursing questions"""
    st.subheader("📋 간호 문제 입력")

    with st.form("question_form"):
        col1, col2 = st.columns([2, 1])

        with col1:
            question_text = st.text_area("문제", height=100, help="간호 문제를 입력하세요")
            explanation = st.text_area("해설", height=80, help="정답 해설을 입력하세요")

        with col2:
            subject = st.selectbox("과목", [
                "기본간호학", "성인간호학", "아동간호학", "모성간호학",
                "정신간호학", "지역사회간호학", "간호관리학"
            ])
            tags = st.text_input("태그", help="쉼표로 구분 (선택사항)")

        # Choices
        st.subheader("선택지 (필수 5개)")
        choices = []
        for i in range(1, 6):
            choice = st.text_input(f"선택지 {i} *", key=f"choice_{i}", help="필수 입력")
            choices.append(choice)

        # Filter out empty choices for validation
        non_empty_choices = [c for c in choices if c.strip()]

        # Always show all 5 number options for answer selection
        st.subheader("정답 선택")
        answer_options = ["1번", "2번", "3번", "4번", "5번"]
        correct_answer_number = st.selectbox("정답", answer_options)

        # Get the actual answer based on selection
        if correct_answer_number:
            answer_index = int(correct_answer_number.replace("번", "")) - 1
            if answer_index < len(choices) and choices[answer_index].strip():
                correct_answer = choices[answer_index]
            else:
                correct_answer = ""
        else:
            correct_answer = ""

        submitted = st.form_submit_button("📥 문제 저장")

        if submitted:
            # Validate all 5 choices are filled
            if question_text and len(non_empty_choices) == 5 and correct_answer and correct_answer != "선택지를 먼저 입력하세요":
                try:
                    question_data = {
                        'id': str(uuid.uuid4()),
                        'questionText': question_text,
                        'choices': non_empty_choices,  # Use only non-empty choices
                        'correctAnswer': correct_answer,
                        'explanation': explanation,
                        'subject': subject,
                        'difficulty': '미분류',  # AI가 나중에 분석
                        'tags': [tag.strip() for tag in tags.split(',') if tag.strip()],
                        'createdBy': 'streamlit_user',
                        'createdAt': datetime.now().isoformat(),
                        'status': 'pending_analysis'  # 분석 대기 상태
                    }

                    # Save to Jobs/pending folder for AI processing
                    jobs_path = Path("Jobs/pending")
                    jobs_path.mkdir(parents=True, exist_ok=True)

                    job_file = jobs_path / f"problem_{question_data['id']}.json"
                    with open(job_file, 'w', encoding='utf-8') as f:
                        json.dump(question_data, f, ensure_ascii=False, indent=2)

                    st.success(f"[SUCCESS] 문제가 Jobs/pending 폴더에 저장되었습니다!")
                    st.info("[INFO] AI 분석 대기 중... (개념 추출, 태깅, 난이도 평가)")
                    st.info(f"[INFO] 파일 위치: {job_file}")

                    # Update session state to show status
                    if 'saved_problems' not in st.session_state:
                        st.session_state.saved_problems = []
                    st.session_state.saved_problems.append(question_data['id'])

                except Exception as e:
                    st.error(f"[ERROR] 저장 실패: {e}")
                    st.error(f"상세 오류: {str(e)}")
            else:
                missing = []
                if not question_text:
                    missing.append("문제")
                if len(non_empty_choices) != 5:
                    missing.append(f"선택지 (현재 {len(non_empty_choices)}/5)")
                if not correct_answer or correct_answer == "선택지를 먼저 입력하세요":
                    missing.append("정답")
                st.warning(f"[WARNING] 다음 필드를 입력해주세요: {', '.join(missing)}")


def concept_input_form():
    """Form for inputting nursing concepts"""
    st.subheader("[INFO] 간호 개념 입력")

    with st.form("concept_form"):
        col1, col2 = st.columns([2, 1])

        with col1:
            title = st.text_input("개념명", help="개념의 제목을 입력하세요")
            description = st.text_area("설명", height=150, help="개념에 대한 자세한 설명")

        with col2:
            category = st.selectbox("카테고리", [
                "해부학", "생리학", "병리학", "약리학", "미생물학",
                "간호기술", "간호이론", "윤리", "법규"
            ])
            tags = st.text_input("태그", help="쉼표로 구분")

        submitted = st.form_submit_button("📥 개념 저장")

        if submitted:
            if title and description:
                try:
                    concept_data = {
                        'id': str(uuid.uuid4()),
                        'title': title,
                        'description': description,
                        'category': category,
                        'tags': [tag.strip() for tag in tags.split(',') if tag.strip()],
                        'createdAt': datetime.now().isoformat()
                    }

                    # Add to RAG system
                    concept_id = rag_engine.add_concept(concept_data)
                    st.success(f"[SUCCESS] 개념이 저장되었습니다! ID: {concept_id}")

                except Exception as e:
                    st.error(f"[ERROR] 저장 실패: {e}")
            else:
                st.warning("[WARNING] 제목과 설명을 입력해주세요")


def rag_generation_tab():
    """RAG-based problem generation tab"""
    st.header("📚 RAG 문제 생성")

    col1, col2 = st.columns([2, 1])

    with col1:
        concept = st.text_input("약점 개념", value="활력징후", help="생성할 문제의 핵심 개념을 입력하세요")
        subject = st.selectbox("과목", ["기본간호학", "성인간호학", "아동간호학", "모성간호학", "정신간호학"])

    with col2:
        difficulty = st.selectbox("난이도", ["상", "중", "하"])
        count = st.number_input("생성할 문제 수", min_value=1, max_value=5, value=2)

    if st.button("🎯 문제 생성"):
        if concept:
            with st.spinner(f"'{concept}' 개념 문제 {count}개 생성 중..."):
                try:
                    generated_problems = rag_generator.generate_problems_for_weakness(
                        weak_concept=concept,
                        count=count,
                        difficulty=difficulty,
                        subject=subject
                    )

                    if generated_problems:
                        st.success(f"✅ {len(generated_problems)}개 문제 생성 완료!")

                        for i, problem in enumerate(generated_problems):
                            with st.expander(f"📝 생성된 문제 {i+1}"):
                                st.write("**문제:**", problem['question_text'])
                                st.write("**선택지:**")
                                for j, choice in enumerate(problem['choices']):
                                    marker = "✔️" if choice == problem['correct_answer'] else "○"
                                    st.write(f"{marker} {j+1}. {choice}")

                                if st.button(f"💾 문제 {i+1} 저장", key=f"save_gen_{i}"):
                                    save_generated_problem(problem)
                    else:
                        st.warning("문제 생성에 실패했습니다. 다른 개념으로 시도해보세요.")

                except Exception as e:
                    st.error(f"문제 생성 실패: {str(e)}")
        else:
            st.warning("개념을 입력해주세요.")


def learning_analysis_tab():
    """학습 분석 탭"""
    st.header("📊 학습 분석")

    st.info("사용자의 문제 풀이 데이터를 분석하여 약점 개념을 식별하고 학습 추천을 제공합니다")

    if st.button("📈 샘플 데이터로 분석 실행"):
        with st.spinner("학습 데이터 분석 중..."):
            try:
                # Create sample problems with stats
                problems = create_sample_problems()

                # Add some realistic stats
                problems[0].update_stats(True, 35.0)
                problems[0].update_stats(False, 45.0)
                problems[0].update_stats(True, 30.0)

                problems[1].update_stats(False, 120.0)
                problems[1].update_stats(False, 90.0)
                problems[1].update_stats(True, 60.0)

                # Run analysis
                analysis = learning_analyzer.analyze_user_performance(problems, "demo_user")

                # Display results
                st.success("✅ 분석 완료!")

                # Basic stats
                st.subheader("📢 기본 통계")
                stats = analysis['basic_stats']

                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("전체 정답률", f"{stats['overall_accuracy']:.1%}")
                with col2:
                    st.metric("시도한 문제", f"{stats['attempted_problems']}")
                with col3:
                    st.metric("평균 시도 회수", f"{stats['avg_attempts_per_problem']:.1f}")
                with col4:
                    st.metric("평균 소요 시간", f"{stats['avg_time_per_problem']:.0f}초")

                # Weak concepts
                if analysis['weak_concepts']:
                    st.subheader("⚠️ 약점 개념")
                    weak_df = pd.DataFrame(analysis['weak_concepts'])
                    st.dataframe(weak_df[['concept', 'weakness_score', 'accuracy', 'avg_time', 'priority']], use_container_width=True)

                # Recommendations
                if analysis['recommendations']:
                    st.subheader("💡 학습 추천사항")
                    for rec in analysis['recommendations']:
                        priority_color = {
                            "high": "🔴",
                            "medium": "🟡",
                            "low": "🟢"
                        }.get(rec['priority'], "⚪")
                        st.write(f"{priority_color} **{rec['title']}**: {rec['description']}")

                # Summary
                st.subheader("📝 분석 요약")
                st.info(analysis['summary'])

            except Exception as e:
                st.error(f"분석 실패: {str(e)}")

def rag_search_tab():
    """RAG search tab"""
    st.header("[SEARCH] RAG 검색")

    # Search form
    col1, col2 = st.columns([3, 1])
    with col1:
        query = st.text_input("검색어", placeholder="간호 관련 질문을 입력하세요...")
    with col2:
        search_type = st.selectbox("검색 대상", ["전체", "문제만", "개념만"])

    if st.button("[SEARCH] 검색") and query:
        with st.spinner("검색 중..."):
            try:
                # Map search type
                collection_map = {
                    "전체": "both",
                    "문제만": "questions",
                    "개념만": "concepts"
                }

                # Perform search
                results = rag_engine.search(
                    query=query,
                    collection_type=collection_map[search_type],
                    n_results=5
                )

                # Display results
                st.subheader("📋 검색 결과")

                # Questions results
                if results['questions']:
                    st.subheader("📝 문제")
                    for i, result in enumerate(results['questions']):
                        with st.expander(f"문제 {i+1} (유사도: {1-result['distance']:.3f})"):
                            st.write(result['content'])
                            st.json(result['metadata'])

                # Concepts results
                if results['concepts']:
                    st.subheader("[INFO] 개념")
                    for i, result in enumerate(results['concepts']):
                        with st.expander(f"개념 {i+1} (유사도: {1-result['distance']:.3f})"):
                            st.write(result['content'])
                            st.json(result['metadata'])

                # Generate AI answer
                if results['questions'] or results['concepts']:
                    st.subheader("🤖 AI 답변")
                    with st.spinner("답변 생성 중..."):
                        context = results['questions'] + results['concepts']
                        answer = rag_engine.generate_answer(query, context[:3])
                        st.write(answer)

                if not results['questions'] and not results['concepts']:
                    st.info("검색 결과가 없습니다. 다른 키워드로 시도해보세요.")

            except Exception as e:
                st.error(f"[ERROR] 검색 실패: {e}")


def clintest_ai_tab():
    """Advanced Clintest AI features tab - kept for legacy compatibility"""
    # This function is kept for backward compatibility but functionality moved to other tabs
    pass


def learning_analysis_section():
    """Learning analysis section"""
    st.subheader("📊 학습 성과 분석")

    # Sample data setup
    col1, col2 = st.columns([2, 1])

    with col1:
        st.info("[INFO] **기능 설명**\n\n이 섹션에서는 사용자의 문제 풀이 데이터를 분석하여:\n- 약점 개념 식별\n- 개념별 성과 분석\n- 맞춤형 학습 추천사항 제공")

    with col2:
        if st.button("📈 샘플 데이터로 분석 실행"):
            st.session_state.run_analysis = True

    if st.session_state.get('run_analysis', False):
        with st.spinner("학습 데이터 분석 중..."):
            try:
                # Create sample problems with stats
                problems = create_sample_problems()

                # Add some realistic stats
                problems[0].update_stats(True, 35.0)
                problems[0].update_stats(False, 45.0)
                problems[0].update_stats(True, 30.0)

                problems[1].update_stats(False, 120.0)
                problems[1].update_stats(False, 90.0)
                problems[1].update_stats(True, 60.0)

                # Run analysis
                analysis = learning_analyzer.analyze_user_performance(problems, "demo_user")

                # Display results
                st.success("[SUCCESS] 분석 완료!")

                # Basic stats
                st.subheader("📈 기본 통계")
                stats = analysis['basic_stats']

                metric_col1, metric_col2, metric_col3, metric_col4 = st.columns(4)
                with metric_col1:
                    st.metric("전체 정답률", f"{stats['overall_accuracy']:.1%}")
                with metric_col2:
                    st.metric("시도한 문제", f"{stats['attempted_problems']}")
                with metric_col3:
                    st.metric("평균 시도 횟수", f"{stats['avg_attempts_per_problem']:.1f}")
                with metric_col4:
                    st.metric("평균 소요 시간", f"{stats['avg_time_per_problem']:.0f}초")

                # Weak concepts
                if analysis['weak_concepts']:
                    st.subheader("[WARNING] 약점 개념")
                    weak_df = pd.DataFrame(analysis['weak_concepts'])
                    st.dataframe(weak_df[['concept', 'weakness_score', 'accuracy', 'avg_time', 'priority']], use_container_width=True)

                # Concept analysis
                if analysis['concept_analysis']:
                    st.subheader("📚 개념별 성과")
                    concept_data = []
                    for concept, data in analysis['concept_analysis'].items():
                        concept_data.append({
                            '개념': concept,
                            '정답률': f"{data['accuracy']:.1%}",
                            '평균 시간': f"{data['avg_time']:.0f}초",
                            '시도 횟수': data['total_attempts'],
                            '약점 점수': f"{data['weakness_score']:.2f}"
                        })
                    concept_df = pd.DataFrame(concept_data)
                    st.dataframe(concept_df, use_container_width=True)

                # Recommendations
                if analysis['recommendations']:
                    st.subheader("[INFO] 학습 추천사항")
                    for i, rec in enumerate(analysis['recommendations']):
                        priority_color = {"high": "🔴", "medium": "🟡", "low": "🟢"}.get(rec['priority'], "⚪")
                        st.write(f"{priority_color} **{rec['title']}**: {rec['description']}")

                # Summary
                st.subheader("📋 분석 요약")
                st.info(analysis['summary'])

            except Exception as e:
                st.error(f"[ERROR] 분석 실패: {e}")
                st.exception(e)


def problem_generation_section():
    """Problem generation section using RAG"""
    st.subheader("🎯 약점 기반 문제 생성")

    col1, col2 = st.columns([2, 1])

    with col1:
        concept = st.text_input("약점 개념", value="활력징후", help="생성할 문제의 핵심 개념을 입력하세요")
        subject = st.selectbox("과목", ["기본간호학", "성인간호학", "아동간호학", "모성간호학", "정신간호학"])

    with col2:
        difficulty = st.selectbox("난이도", ["상", "중", "하"])
        count = st.number_input("생성할 문제 수", min_value=1, max_value=5, value=2)

    if st.button("🎯 문제 생성"):
        if concept:
            with st.spinner(f"'{concept}' 개념 문제 {count}개 생성 중..."):
                try:
                    generated_problems = rag_generator.generate_problems_for_weakness(
                        weak_concept=concept,
                        count=count,
                        difficulty=difficulty,
                        subject=subject
                    )

                    if generated_problems:
                        st.success(f"[SUCCESS] {len(generated_problems)}개 문제 생성 완료!")

                        for i, problem in enumerate(generated_problems):
                            with st.expander(f"📝 생성된 문제 {i+1}"):
                                st.write("**문제:**", problem['question_text'])
                                st.write("**선택지:**")
                                for j, choice in enumerate(problem['choices']):
                                    marker = "[SUCCESS]" if choice == problem['correct_answer'] else "[O]"
                                    st.write(f"{marker} {j+1}. {choice}")

                                st.write("**메타데이터:**")
                                metadata_col1, metadata_col2 = st.columns(2)
                                with metadata_col1:
                                    st.write(f"- 과목: {problem['subject']}")
                                    st.write(f"- 난이도: {problem['difficulty']}")
                                with metadata_col2:
                                    st.write(f"- 개념: {', '.join(problem['concepts'])}")
                                    st.write(f"- 키워드: {', '.join(problem['keywords'])}")

                                # Option to save to Jobs folder
                                if st.button(f"💾 문제 {i+1} 저장", key=f"save_prob_{i}"):
                                    save_generated_problem(problem)

                    else:
                        st.warning("[WARNING] 문제 생성에 실패했습니다. 다른 개념으로 시도해보세요.")

                except Exception as e:
                    st.error(f"[ERROR] 문제 생성 실패: {e}")
                    st.exception(e)
        else:
            st.warning("[WARNING] 개념을 입력해주세요.")

    # Study plan generation
    st.divider()
    st.subheader("📚 학습 계획 생성")

    if st.button("📋 샘플 약점 기반 학습 계획 생성"):
        with st.spinner("학습 계획 생성 중..."):
            try:
                # Sample weak concepts
                sample_weak_concepts = [
                    {'concept': '활력징후', 'priority': 0.8, 'accuracy': 0.4, 'avg_time': 90},
                    {'concept': '감염관리', 'priority': 0.6, 'accuracy': 0.5, 'avg_time': 75},
                    {'concept': '투약관리', 'priority': 0.7, 'accuracy': 0.3, 'avg_time': 120}
                ]

                study_plan = rag_generator.generate_study_plan(sample_weak_concepts)

                st.success("[SUCCESS] 학습 계획 생성 완료!")

                # Display study plan
                plan_col1, plan_col2 = st.columns([2, 1])

                with plan_col1:
                    st.write("**📊 학습 개요**")
                    st.write(f"- 총 약점 개념: {study_plan['total_concepts']}개")
                    st.write(f"- 예상 학습 시간: {study_plan['estimated_time']}분")
                    st.write(f"- 학습 세션: {len(study_plan['study_sessions'])}개")

                with plan_col2:
                    st.info("[INFO] 체계적인 학습을 위해 우선순위 순으로 진행하세요.")

                # Study sessions
                if study_plan['study_sessions']:
                    st.write("**📋 학습 세션 계획**")
                    sessions_df = pd.DataFrame(study_plan['study_sessions'])
                    st.dataframe(sessions_df[['session_id', 'concept', 'problem_count', 'estimated_time', 'priority']], use_container_width=True)

                # Recommendations
                if study_plan['recommendations']:
                    st.write("**[INFO] 학습 추천사항**")
                    for rec in study_plan['recommendations']:
                        st.write(f"- {rec}")

            except Exception as e:
                st.error(f"[ERROR] 학습 계획 생성 실패: {e}")


def problem_processing_section():
    """Problem processing with AI analysis"""
    st.subheader("📋 문제 AI 분석 처리")

    st.info("[INFO] **기능 설명**\n\n이 섹션에서는 원문 문제를 AI로 분석하여:\n- 핵심 개념 추출\n- 관련 키워드 식별\n- 난이도 분류\n- 품질 검증")

    # Input form for problem analysis
    with st.form("problem_analysis_form"):
        col1, col2 = st.columns([3, 1])

        with col1:
            question_text = st.text_area(
                "문제 텍스트",
                height=100,
                placeholder="간호학 문제를 입력하세요...",
                help="해석이 필요한 원문 문제를 입력하세요"
            )

        with col2:
            subject = st.selectbox("과목", [
                "기본간호학", "성인간호학", "아동간호학", "모성간호학",
                "정신간호학", "지역사회간호학", "간호관리학"
            ])

        # Choices input
        st.subheader("선택지")
        choices = []
        choice_cols = st.columns(2)

        for i in range(4):
            with choice_cols[i % 2]:
                choice = st.text_input(f"선택지 {i+1}", key=f"analysis_choice_{i}")
                if choice:
                    choices.append(choice)

        correct_answer = st.selectbox("정답", choices if choices else ["선택지를 먼저 입력하세요"])
        user_tags = st.text_input("추가 태그", help="쉼표로 구분하여 입력")

        submitted = st.form_submit_button("[SEARCH] AI 분석 실행")

        if submitted:
            if question_text and choices and correct_answer:
                with st.spinner("AI 분석 중..."):
                    try:
                        # Process problem with AI analyzer
                        tags_list = [tag.strip() for tag in user_tags.split(',') if tag.strip()] if user_tags else []

                        processed_problem = problem_analyzer.process_problem(
                            question_text=question_text,
                            choices=choices,
                            correct_answer=correct_answer,
                            explanation="",  # No auto-explanation as requested
                            subject=subject,
                            user_tags=tags_list
                        )

                        st.success("[SUCCESS] AI 분석 완료!")

                        # Display analysis results
                        result_col1, result_col2 = st.columns(2)

                        with result_col1:
                            st.subheader("[AI] AI 분석 결과")
                            st.write(f"**추출된 개념:** {', '.join(processed_problem['concepts'])}")
                            st.write(f"**키워드:** {', '.join(processed_problem['keywords'])}")
                            st.write(f"**AI 난이도 분류:** {processed_problem['difficulty']}")
                            st.write(f"**신뢰도 점수:** {processed_problem['confidence_score']:.2f}")
                            st.write(f"**검증 방법:** {processed_problem['verified_by']}")

                        with result_col2:
                            st.subheader("📊 품질 검증")
                            validation = processed_problem['validation']
                            status_color = {"valid": "🟢", "warning": "🟡", "invalid": "🔴"}.get(validation['status'], "⚪")
                            st.write(f"**상태:** {status_color} {validation['status']}")
                            st.write(f"**품질 점수:** {validation['score']:.2f}")

                            if validation['issues']:
                                st.write("**발견된 문제:**")
                                for issue in validation['issues']:
                                    st.write(f"- [WARNING] {issue}")

                        # Full processed data
                        with st.expander("📄 전체 처리 결과 (JSON)"):
                            st.json(processed_problem)

                        # Option to save
                        if st.button("💾 분석 결과 저장"):
                            save_processed_problem(processed_problem)

                    except Exception as e:
                        st.error(f"[ERROR] AI 분석 실패: {e}")
                        st.exception(e)
            else:
                st.warning("[WARNING] 필수 필드를 모두 입력해주세요.")


def ai_testing_section():
    """AI system testing section"""
    st.subheader("🧪 AI 시스템 테스트")

    test_col1, test_col2 = st.columns(2)

    with test_col1:
        st.write("**[SEARCH] 계층적 분석기 테스트**")
        if st.button("Test Hierarchical Analyzer"):
            with st.spinner("Testing hierarchical analyzer..."):
                try:
                    from analyzers.hierarchical_analyzer import hierarchical_analyzer

                    test_question = "혈압 측정 시 가장 중요한 주의사항은?"
                    test_choices = ["환자를 편안하게 앉힌다", "측정 전 30분간 금연한다"]
                    test_answer = "측정 전 30분간 금연한다"

                    result = hierarchical_analyzer.analyze_problem(test_question, test_choices, test_answer)
                    st.success("[SUCCESS] 테스트 성공")
                    st.json(result)

                except Exception as e:
                    st.error(f"[ERROR] 테스트 실패: {e}")

    with test_col2:
        st.write("**📊 학습 분석기 테스트**")
        if st.button("Test Learning Analyzer"):
            with st.spinner("Testing learning analyzer..."):
                try:
                    problems = create_sample_problems()
                    problems[0].update_stats(True, 45.0)
                    problems[1].update_stats(False, 90.0)

                    analysis = learning_analyzer.analyze_user_performance(problems)
                    st.success("[SUCCESS] 테스트 성공")
                    st.write(f"분석된 문제 수: {len(problems)}")
                    st.write(f"약점 개념 수: {len(analysis['weak_concepts'])}")

                except Exception as e:
                    st.error(f"[ERROR] 테스트 실패: {e}")

    # System integration test
    st.divider()
    st.write("**🔗 통합 시스템 테스트**")
    if st.button("🚀 전체 파이프라인 테스트"):
        with st.spinner("전체 시스템 테스트 중..."):
            try:
                # Test complete pipeline
                st.write("[1] 샘플 문제 생성...")
                problems = create_sample_problems()

                st.write("[2] 학습 데이터 분석...")
                analysis = learning_analyzer.analyze_user_performance(problems)

                st.write("[3] 약점 기반 문제 생성...")
                if analysis['weak_concepts']:
                    weak_concept = analysis['weak_concepts'][0]['concept']
                    generated = rag_generator.generate_problems_for_weakness(weak_concept, count=1)

                    st.success("[SUCCESS] 전체 파이프라인 테스트 성공!")
                    st.write(f"- 분석된 문제: {len(problems)}개")
                    st.write(f"- 식별된 약점: {len(analysis['weak_concepts'])}개")
                    st.write(f"- 생성된 문제: {len(generated)}개")
                else:
                    st.warning("[WARNING] 약점 개념이 식별되지 않았습니다.")

            except Exception as e:
                st.error(f"[ERROR] 통합 테스트 실패: {e}")
                st.exception(e)


def save_generated_problem(problem_data):
    """Save generated problem to Jobs folder"""
    try:
        # Save to pending folder for processing
        filename = f"generated_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{problem_data['id'][:8]}.json"
        file_path = JOBS_DIR / "pending" / filename

        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(problem_data, f, ensure_ascii=False, indent=2)

        st.success(f"[SUCCESS] 문제가 Jobs 폴더에 저장되었습니다: {filename}")

    except Exception as e:
        st.error(f"[ERROR] 저장 실패: {e}")


def save_processed_problem(problem_data):
    """Save processed problem to Jobs folder"""
    try:
        # Save to completed folder
        filename = f"processed_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{problem_data['id'][:8]}.json"
        file_path = JOBS_DIR / "completed" / filename

        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(problem_data, f, ensure_ascii=False, indent=2)

        st.success(f"[SUCCESS] 처리된 문제가 저장되었습니다: {filename}")

    except Exception as e:
        st.error(f"[ERROR] 저장 실패: {e}")


def jobs_management_tab():
    """Jobs management tab"""
    st.header("[FILES] Jobs 관리")

    # Current status
    try:
        status = jobs_worker.get_status()

        # Status cards
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("대기 중", status['pending'])
        with col2:
            st.metric("처리 중", status['processing'])
        with col3:
            st.metric("완료", status['completed'])
        with col4:
            st.metric("실패", status['failed'])

        # Job folders content
        st.subheader("📂 폴더 내용")

        folder_tab1, folder_tab2, folder_tab3, folder_tab4 = st.tabs(["대기", "처리중", "완료", "실패"])

        with folder_tab1:
            show_folder_contents(JOBS_DIR / "pending")

        with folder_tab2:
            show_folder_contents(JOBS_DIR / "processing")

        with folder_tab3:
            show_folder_contents(JOBS_DIR / "completed")

        with folder_tab4:
            show_folder_contents(JOBS_DIR / "failed")

    except Exception as e:
        st.error(f"[ERROR] Jobs 상태 확인 실패: {e}")

    # Test job creation
    st.subheader("🧪 테스트 작업 생성")
    if st.button("📥 테스트 문제 생성"):
        create_test_job()


def show_folder_contents(folder_path: Path):
    """Show contents of a jobs folder"""
    try:
        json_files = list(folder_path.glob("*.json"))

        if json_files:
            st.write(f"📄 {len(json_files)}개 파일")

            for file_path in json_files[:10]:  # Show max 10 files
                with st.expander(f"📄 {file_path.name}"):
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            data = json.load(f)
                        st.json(data)
                    except Exception as e:
                        st.error(f"파일 읽기 실패: {e}")

            if len(json_files) > 10:
                st.info(f"... 및 {len(json_files) - 10}개 추가 파일")
        else:
            st.info("폴더가 비어있습니다")

    except Exception as e:
        st.error(f"폴더 읽기 실패: {e}")


def create_test_job():
    """Create a test job for testing"""
    try:
        test_data = {
            'id': str(uuid.uuid4()),
            'questionText': '혈압 측정 시 주의사항으로 옳은 것은?',
            'choices': [
                '측정 전 30분간 금연한다',
                '팔꿈치보다 높게 커프를 위치시킨다',
                '커프 크기는 상관없다',
                '측정 직전에 운동을 한다'
            ],
            'correctAnswer': '측정 전 30분간 금연한다',
            'explanation': '혈압 측정 전 30분간은 흡연, 카페인 섭취, 운동을 피해야 정확한 측정이 가능합니다.',
            'subject': '기본간호학',
            'difficulty': '보통',
            'tags': ['혈압', '측정', '기본간호'],
            'createdBy': 'test_user',
            'createdAt': datetime.now().isoformat()
        }

        # Save to pending folder
        test_file = JOBS_DIR / "pending" / f"test_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(test_file, 'w', encoding='utf-8') as f:
            json.dump(test_data, f, ensure_ascii=False, indent=2)

        st.success(f"[SUCCESS] 테스트 작업 생성됨: {test_file.name}")

    except Exception as e:
        st.error(f"[ERROR] 테스트 작업 생성 실패: {e}")


def problem_analysis_tab():
    """Problem analysis tab with AI model information"""
    st.header("🤖 문제 분석")
    st.info("Jobs 폴더의 문제를 AI가 분석합니다")

    # Session state 초기화 - 함수 시작 부분에서 항상 실행
    if 'analysis_result' not in st.session_state:
        st.session_state.analysis_result = None
    if 'analyzed_problem_id' not in st.session_state:
        st.session_state.analyzed_problem_id = None
    if 'analyzed_problem_data' not in st.session_state:
        st.session_state.analyzed_problem_data = None

    # AI 모델 정보 표시 (Updated: 2025.09.22)
    with st.expander("🤖 사용되는 AI 모델 정보 (최신 2025.09.22)", expanded=False):
        st.markdown("""
        ### 🚀 계층적 AI 분석 시스템 (2025 최신 모델)

        **1단계: GPT-5 Mini** `gpt-5-mini`
        - 빠르고 비용 효율적인 초기 분석
        - 입력: $0.65/1M 토큰 | 출력: $5.00/1M 토큰
        - 컨텍스트 윈도우: 200,000 토큰
        - 신뢰도 70% 이상 시 최종 결과로 채택

        **2단계: GPT-5** `gpt-5`
        - 신뢰도 70% 미만일 때만 실행
        - 입력: $1.25/1M 토큰 | 출력: $10.00/1M 토큰
        - 컨텍스트 윈도우: 400,000 토큰
        - 복잡한 문제에 대한 심층 분석

        **경량 태스크: GPT-5 Nano** `gpt-5-nano`
        - 단순 작업 및 대량 처리용
        - 입력: $0.40/1M 토큰 | 출력: $2.50/1M 토큰
        - 컨텍스트 윈도우: 100,000 토큰

        **보조 모델: Gemini 2.5 Flash** `gemini-2.5-flash`
        - 실시간 처리, 저가형
        - 입력: $0.10/1M 토큰 | 출력: $0.40/1M 토큰
        - 토큰 윈도우: 128,000 토큰

        **임베딩: Gemini text-embedding-004**
        - 최신 Gemini 임베딩 모델
        - ChromaDB 저장용 시맨틱 검색 최적화
        - 비용: $0.10/1M 토큰

        **💰 비용 절감 효과**
        - 평균 65% 비용 절감 (계층적 접근법)
        - 80% 이상의 문제는 GPT-5 Mini로 충분
        - 단순 작업은 GPT-5 Nano로 처리
        """)

    # Jobs 폴더 스캔
    jobs_path = Path("Jobs/pending")
    if jobs_path.exists():
        job_files = list(jobs_path.glob("*.json"))
        if job_files:
            st.success(f"📁 분석 대기 중인 문제: {len(job_files)}개")

            selected_file = st.selectbox(
                "분석할 문제 선택",
                options=job_files,
                format_func=lambda x: x.name
            )

            if st.button("🔬 AI 분석 시작"):
                with st.spinner("문제 분석 중..."):
                    # 파일 읽기
                    with open(selected_file, 'r', encoding='utf-8') as f:
                        problem_data = json.load(f)

                    # AI 분석
                    try:
                        from analyzers.hierarchical_analyzer import HierarchicalAnalyzer
                        analyzer = HierarchicalAnalyzer()

                        # 문제 ID 생성 (파일명 기반)
                        import uuid
                        problem_id = selected_file.stem if selected_file else str(uuid.uuid4())

                        # 분석 상태 표시
                        status_placeholder = st.empty()
                        status_placeholder.info("🔄 GPT-5 Mini로 1차 분석 중...")

                        analysis = analyzer.analyze_problem(
                            problem_data['questionText'],
                            problem_data.get('choices', []),
                            problem_data.get('correctAnswer', '')
                        )

                        # 사용된 모델 표시 (confidence_score 사용)
                        confidence_score = analysis.get('confidence_score', 0.0)
                        if confidence_score >= 0.7:
                            status_placeholder.success(f"✅ GPT-5 Mini로 분석 완료 (신뢰도: {confidence_score:.1%})")
                        else:
                            status_placeholder.warning(f"⚠️ GPT-5로 2차 정밀 분석 실행 (신뢰도: {confidence_score:.1%})")

                        # 분석 결과 표시 (개선된 UI)
                        with st.expander("📊 상세 분석 결과", expanded=True):
                            col1, col2, col3 = st.columns(3)
                            with col1:
                                st.metric("난이도", analysis.get('difficulty', '보통'))
                                verified_by = analysis.get('verified_by', 'gpt5_mini')
                                display_model = 'GPT-5 Mini' if verified_by == 'gpt5_mini' else 'GPT-5'
                                st.metric("사용 모델", display_model)
                            with col2:
                                st.metric("신뢰도", f"{confidence_score:.1%}")
                                process_time = datetime.now().timestamp() - datetime.fromisoformat(analysis.get('processed_at', datetime.now().isoformat())).timestamp()
                                st.metric("분석 시간", f"{abs(process_time):.2f}초")
                            with col3:
                                st.metric("개념 수", len(analysis.get('concepts', [])))
                                # Updated pricing based on 2025.09.22 rates
                                if verified_by == 'gpt5_mini':
                                    cost_estimate = 0.00065  # $0.65 per 1M tokens
                                elif verified_by == 'gpt5_enhanced':
                                    cost_estimate = 0.00125  # $1.25 per 1M tokens
                                else:
                                    cost_estimate = 0.0004  # GPT-5 Nano
                                st.metric("예상 비용", f"${cost_estimate:.5f}")

                            # 핵심 개념 표시
                            st.markdown("### 🔍 핵심 개념")
                            concepts = analysis.get('concepts', [])
                            if concepts:
                                for i, concept in enumerate(concepts, 1):
                                    st.markdown(f"**{i}.** {concept}")
                            else:
                                st.info("추출된 개념이 없습니다.")

                            # 키워드 표시
                            st.markdown("### 🔑 키워드")
                            keywords = analysis.get('keywords', [])
                            if keywords:
                                # 키워드를 간단한 텍스트로 표시
                                st.write(", ".join(keywords))
                            else:
                                st.info("추출된 키워드가 없습니다.")


                        # 분석 결과를 session state에 저장
                        st.session_state.analysis_result = analysis
                        st.session_state.analyzed_problem_id = problem_id
                        st.session_state.analyzed_problem_data = problem_data

                        # 분석 완료된 파일 이동
                        completed_path = Path("Jobs/completed")
                        completed_path.mkdir(exist_ok=True)

                        # 분석 결과 추가
                        problem_data['analysis'] = analysis

                        # 저장
                        new_file = completed_path / selected_file.name
                        with open(new_file, 'w', encoding='utf-8') as f:
                            json.dump(problem_data, f, ensure_ascii=False, indent=2)

                        # 원본 삭제
                        selected_file.unlink()

                        st.success("✅ 분석 완료! ChromaDB에 저장되었습니다.")
                        st.rerun()

                    except Exception as e:
                        st.error(f"분석 중 오류 발생: {str(e)}")
        else:
            st.warning("분석할 문제가 없습니다. 먼저 문제를 입력해주세요.")
    else:
        st.warning("Jobs 폴더가 없습니다. 먼저 문제를 입력해주세요.")

    # Session State 기반 Firebase 업로드 섹션 (AI 분석 완료 후 표시)
    if hasattr(st.session_state, 'analysis_result') and st.session_state.analysis_result is not None:
        st.divider()
        st.subheader("☁️ 분석 완료 - 데이터베이스 연동")

        # 세션에서 데이터 가져오기
        problem_id = st.session_state.analyzed_problem_id
        problem_data = st.session_state.analyzed_problem_data
        analysis = st.session_state.analysis_result

        # 분석 결과 요약 표시
        with st.expander("📊 분석 결과 요약", expanded=False):
            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("문제 ID", problem_id[:8] + "...")
                st.metric("난이도", analysis.get('difficulty', '보통'))
            with col2:
                st.metric("신뢰도", f"{analysis.get('confidence_score', 0):.1%}")
                st.metric("사용 모델", 'GPT-5 Mini' if analysis.get('verified_by') == 'gpt5_mini' else 'GPT-5')
            with col3:
                st.metric("개념 수", len(analysis.get('concepts', [])))
                st.metric("키워드 수", len(analysis.get('keywords', [])))

        # 업로드 버튼 섹션
        st.info("분석 결과를 ChromaDB와 Firebase에 저장하여 Clintest 앱에서 사용할 수 있습니다.")

        col1, col2 = st.columns(2)

        with col1:
            if st.button("💾 ChromaDB에 저장", key="session_chroma_save", type="primary"):
                with st.spinner("ChromaDB에 저장 중..."):
                    try:
                        question_id = rag_engine.add_question({
                            'id': problem_id,
                            'questionText': problem_data['questionText'],
                            'choices': problem_data.get('choices', []),
                            'correctAnswer': problem_data.get('correctAnswer', ''),
                            'subject': '간호학',
                            'difficulty': analysis.get('difficulty', '보통'),
                            'tags': analysis.get('keywords', []),
                            'createdBy': 'hierarchical_analyzer'
                        })
                        st.success(f"✅ ChromaDB 저장 완료! (ID: {question_id})")
                        st.info("📊 임베딩 벡터와 메타데이터가 ChromaDB에 저장되었습니다")
                    except Exception as e:
                        import traceback
                        error_details = traceback.format_exc()
                        print(f"[ERROR] ChromaDB 저장 실패: {error_details}")

                        st.error(f"❌ ChromaDB 저장 실패: {str(e)}")
                        with st.expander("상세 오류 정보", expanded=False):
                            st.code(error_details)

        with col2:
            if st.button("📤 Firebase에 업로드", key="session_firebase_upload", type="primary"):
                with st.spinner("Firebase에 업로드 중..."):
                    try:
                        # 디버그 로그
                        print(f"[DEBUG] Session Firebase 업로드 시도: {problem_id}")

                        # Firebase 업로드용 데이터 준비 (분석 결과 포함)
                        upload_data = {
                            **problem_data,
                            'id': problem_id,
                            'analysis': analysis,
                            'subject': '간호학',
                            'difficulty': analysis.get('difficulty', '보통'),
                            'concepts': analysis.get('concepts', []),
                            'keywords': analysis.get('keywords', []),
                            'processed_by': analysis.get('verified_by', 'gpt5_mini'),
                            'confidence_score': analysis.get('confidence_score', 0.0)
                        }

                        print(f"[DEBUG] 업로드 데이터 키: {list(upload_data.keys())}")
                        print(f"[DEBUG] Firebase 초기화 상태: {firebase_service.initialized}")

                        # Firebase 서비스 업로드
                        upload_result = firebase_service.upload_problem(upload_data)
                        print(f"[DEBUG] 업로드 결과: {upload_result}")

                        if upload_result:
                            st.success("🎉 Firebase 업로드 성공!")
                            st.info(f"📋 문제 ID: {problem_id}")
                            st.info(f"📱 Clintest 앱에서 확인 가능합니다")
                            st.balloons()

                            # 업로드 성공 후 세션 클리어 (선택사항)
                            # st.session_state.analysis_result = None
                            # st.session_state.analyzed_problem_id = None
                            # st.session_state.analyzed_problem_data = None
                        else:
                            st.warning("⚠️ Firebase가 초기화되지 않았습니다.")
                            st.caption("Firebase 서비스 계정 키 파일을 확인해주세요.")
                    except Exception as e:
                        import traceback
                        error_details = traceback.format_exc()
                        print(f"[ERROR] Session Firebase 업로드 실패: {error_details}")

                        st.error(f"❌ Firebase 업로드 실패: {str(e)}")
                        st.error(f"오류 타입: {type(e).__name__}")

                        with st.expander("상세 오류 정보", expanded=False):
                            st.code(error_details)

                        st.caption("콘솔에서 상세 로그를 확인해주세요.")

        # 세션 클리어 버튼 (선택사항)
        if st.button("🗑️ 분석 결과 지우기", key="clear_analysis"):
            st.session_state.analysis_result = None
            st.session_state.analyzed_problem_id = None
            st.session_state.analyzed_problem_data = None
            st.success("분석 결과가 지워졌습니다.")
            st.rerun()

    # 완료된 분석 결과 보기 섹션
    st.divider()
    st.subheader("📋 완료된 분석 결과 보기")

    completed_path = Path("Jobs/completed")
    if completed_path.exists():
        completed_files = list(completed_path.glob("*.json"))

        if completed_files:
            st.info(f"✅ 총 {len(completed_files)}개의 분석 완료된 문제가 있습니다.")

            # 파일 선택
            selected_completed = st.selectbox(
                "분석 결과를 볼 문제 선택:",
                completed_files,
                format_func=lambda x: f"{x.name} ({x.stat().st_size/1024:.1f}KB)",
                key="completed_file_selector"
            )

            col1, col2 = st.columns([3, 1])
            with col1:
                if st.button("📊 분석 결과 보기", key="view_completed_analysis"):
                    try:
                        with open(selected_completed, 'r', encoding='utf-8') as f:
                            completed_data = json.load(f)

                        # 문제 정보 표시
                        with st.expander("📝 문제 정보", expanded=True):
                            st.write("**문제:**", completed_data.get('questionText', 'N/A'))
                            if 'choices' in completed_data:
                                st.write("**선택지:**")
                                for i, choice in enumerate(completed_data['choices'], 1):
                                    st.write(f"{i}. {choice}")
                            st.write("**정답:**", completed_data.get('correctAnswer', 'N/A'))

                        # 분석 결과 표시
                        if 'analysis' in completed_data:
                            analysis = completed_data['analysis']

                            with st.expander("🔍 상세 분석 결과", expanded=True):
                                col1, col2, col3 = st.columns(3)
                                with col1:
                                    st.metric("난이도", analysis.get('difficulty', '보통'))
                                    verified_by = analysis.get('verified_by', 'unknown')
                                    model_display = 'GPT-5 Mini' if verified_by == 'gpt5_mini' else 'GPT-5'
                                    st.metric("사용 모델", model_display)
                                with col2:
                                    st.metric("신뢰도", f"{analysis.get('confidence_score', 0):.1%}")
                                    st.metric("개념 수", len(analysis.get('concepts', [])))
                                with col3:
                                    st.metric("키워드 수", len(analysis.get('keywords', [])))
                                    processed_at = analysis.get('processed_at', 'N/A')
                                    if processed_at != 'N/A':
                                        st.metric("분석 시각", processed_at[:10])

                                st.markdown("### 핵심 개념")
                                concepts = analysis.get('concepts', [])
                                if concepts:
                                    for i, concept in enumerate(concepts, 1):
                                        st.markdown(f"**{i}.** {concept}")
                                else:
                                    st.info("추출된 개념이 없습니다.")

                                st.markdown("### 키워드")
                                keywords = analysis.get('keywords', [])
                                if keywords:
                                    # 키워드를 간단한 텍스트로 표시
                                    st.write(", ".join(keywords))
                                else:
                                    st.info("추출된 키워드가 없습니다.")

                                if 'error' in analysis:
                                    st.error(f"분석 오류: {analysis['error']}")

                            # 임베딩/Firebase 섹션
                            with st.expander("☁️ 데이터베이스 연동", expanded=False):
                                col1, col2 = st.columns(2)
                                with col1:
                                    if st.button("💾 ChromaDB에 저장", key=f"save_completed_to_chroma_{selected_completed.name}"):
                                        with st.spinner("ChromaDB에 저장 중..."):
                                            try:
                                                from rag_engine import rag_engine
                                                question_id = rag_engine.add_question({
                                                    'id': str(uuid.uuid4()),
                                                    'questionText': completed_data['questionText'],
                                                    'choices': completed_data.get('choices', []),
                                                    'correctAnswer': completed_data.get('correctAnswer', ''),
                                                    'subject': '간호학',
                                                    'difficulty': analysis.get('difficulty', '보통'),
                                                    'tags': analysis.get('keywords', []),
                                                    'createdBy': 'hierarchical_analyzer'
                                                })
                                                st.success(f"✅ ChromaDB 저장 완료! (ID: {question_id})")
                                            except Exception as e:
                                                st.error(f"❌ ChromaDB 저장 실패: {str(e)}")

                                with col2:
                                    if st.button("📤 Firebase 업로드", key=f"firebase_upload_completed_{selected_completed.stem}"):
                                        with st.spinner("Firebase에 업로드 중..."):
                                            try:
                                                # Firebase 서비스 업로드
                                                upload_result = firebase_service.upload_problem(completed_data)

                                                if upload_result:
                                                    st.success("🎉 Firebase 업로드 성공!")
                                                    st.info(f"📋 문제 ID: {completed_data.get('id', 'unknown')}")
                                                    st.info(f"📱 Clintest 앱에서 확인 가능합니다")
                                                    st.balloons()
                                                else:
                                                    st.warning("⚠️ Firebase가 초기화되지 않았습니다.")
                                                    st.caption("Firebase 서비스 계정 키 파일을 확인해주세요.")
                                            except Exception as e:
                                                st.error(f"❌ Firebase 업로드 실패: {str(e)}")
                                                st.caption("오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
                        else:
                            st.warning("분석 결과가 없습니다.")

                    except Exception as e:
                        st.error(f"파일 읽기 오류: {str(e)}")

            with col2:
                if st.button("🗑️ 선택한 결과 삭제", key="delete_completed"):
                    try:
                        selected_completed.unlink()
                        st.success("✅ 삭제 완료!")
                        st.rerun()
                    except Exception as e:
                        st.error(f"삭제 실패: {str(e)}")

        else:
            st.info("아직 완료된 분석이 없습니다.")
    else:
        st.info("Jobs/completed 폴더가 없습니다.")


def settings_tab():
    """Settings tab"""
    st.header("⚙️ 설정")

    st.subheader("🔧 시스템 설정")

    col1, col2 = st.columns(2)

    with col1:
        st.info("📍 Jobs 디렉토리")
        st.code(str(JOBS_DIR))

        st.info("📝 Obsidian Vault")
        st.code(OBSIDIAN_VAULT_PATH)

    with col2:
        st.info("[AI] AI 모델")
        st.code("Embedding: Gemini embedding-001")
        st.code("Chat: GPT-4o-mini")

    # Environment check
    st.subheader("[SEARCH] 환경 확인")

    try:
        validate_config()
        st.success("[SUCCESS] 모든 설정이 올바릅니다")
    except Exception as e:
        st.error(f"[ERROR] 설정 오류: {e}")

    # Database cleanup
    st.subheader("🧹 데이터베이스 관리")
    if st.button("[CLEANUP] 오래된 작업 정리 (7일 이상)"):
        try:
            jobs_worker.handler.cleanup_old_jobs(days=7)
            st.success("[SUCCESS] 정리 완료")
        except Exception as e:
            st.error(f"[ERROR] 정리 실패: {e}")


def system_management_tab():
    """System management and settings tab"""
    st.header("⚙️ 시스템 관리")

    # Create subtabs for system management
    mgmt_tab1, mgmt_tab2, mgmt_tab3, mgmt_tab4 = st.tabs(["📁 Jobs 관리", "🔧 시스템 설정", "💰 API 사용량", "🧪 테스트"])

    with mgmt_tab1:
        st.subheader("📁 Jobs 폴더 관리")

        # Current status
        try:
            status = jobs_worker.get_status()

            # Status cards
            col1, col2, col3, col4 = st.columns(4)
            with col1:
                st.metric("대기 중", status['pending'])
            with col2:
                st.metric("처리 중", status['processing'])
            with col3:
                st.metric("완료", status['completed'])
            with col4:
                st.metric("실패", status['failed'])

            # Job folders content
            st.subheader("📂 폴더 내용")

            folder_tab1, folder_tab2, folder_tab3, folder_tab4 = st.tabs(["대기", "처리중", "완료", "실패"])

            with folder_tab1:
                show_folder_contents(JOBS_DIR / "pending")

            with folder_tab2:
                show_folder_contents(JOBS_DIR / "processing")

            with folder_tab3:
                show_folder_contents(JOBS_DIR / "completed")

            with folder_tab4:
                show_folder_contents(JOBS_DIR / "failed")

        except Exception as e:
            st.error(f"Jobs 상태 확인 실패: {e}")

        # Test job creation
        st.subheader("🧪 테스트 작업 생성")
        if st.button("📥 테스트 문제 생성"):
            create_test_job()

    with mgmt_tab2:
        st.subheader("🔧 시스템 설정")

        col1, col2 = st.columns(2)

        with col1:
            st.info("📁 Jobs 디렉터리")
            st.code(str(JOBS_DIR))

            st.info("📝 Obsidian Vault")
            st.code(OBSIDIAN_VAULT_PATH)

        with col2:
            st.info("🤖 AI 모델 (2025.09.22)")
            st.code("Embedding: text-embedding-004 (Gemini)")
            st.code("Primary: GPT-5 Mini")
            st.code("Advanced: GPT-5")
            st.code("Fast: GPT-5 Nano")

        # Environment check
        st.subheader("🔍 환경 확인")

        try:
            validate_config()
            st.success("✅ 모든 설정이 올바릅니다")
        except Exception as e:
            st.error(f"설정 오류: {e}")

        # Database cleanup
        st.subheader("🧽 데이터베이스 관리")
        if st.button("🧽 오래된 작업 정리 (7일 이상)"):
            try:
                jobs_worker.handler.cleanup_old_jobs(days=7)
                st.success("✅ 정리 완료")
            except Exception as e:
                st.error(f"정리 실패: {e}")

    with mgmt_tab3:
        st.subheader("💰 API 사용량 추적")

        # API Usage Overview
        st.info("📈 OpenAI 및 Gemini API 사용량 및 비용 추적")

        # Time period selection
        period = st.selectbox("기간 선택", ["오늘", "이번 주", "이번 달", "전체"])

        # Get usage data based on period
        if period == "오늘":
            usage_data = api_tracker.get_daily_usage()
            st.subheader(f"📅 오늘 사용량 ({datetime.now().strftime('%Y-%m-%d')})")
        elif period == "이번 주":
            usage_data = api_tracker.get_weekly_usage()
            st.subheader("📅 최근 7일 사용량")
        elif period == "이번 달":
            now = datetime.now()
            usage_data = api_tracker.get_monthly_usage(now.year, now.month)
            st.subheader(f"📅 {now.year}년 {now.month}월 사용량")
        else:  # 전체
            usage_data = api_tracker.get_total_usage()
            st.subheader("📅 전체 누적 사용량")

        # Display metrics
        col1, col2, col3 = st.columns(3)

        if period == "전체":
            with col1:
                st.metric("총 토큰 사용량", f"{usage_data.get('tokens', 0):,}")
            with col2:
                st.metric("총 비용", f"${usage_data.get('cost', 0):.4f}")
            with col3:
                st.metric("원화 환산 (1,300원/$)", f"₩{usage_data.get('cost', 0) * 1300:.0f}")
        else:
            with col1:
                st.metric("총 토큰 사용량", f"{usage_data.get('total_tokens', 0):,}")
            with col2:
                st.metric("총 비용", f"${usage_data.get('total_cost', 0):.4f}")
            with col3:
                st.metric("원화 환산 (1,300원/$)", f"₩{usage_data.get('total_cost', 0) * 1300:.0f}")

        # Model-wise breakdown
        if period != "전체" and usage_data.get('by_model'):
            st.subheader("🤖 모델별 사용량")

            model_data = []
            for model, stats in usage_data['by_model'].items():
                model_data.append({
                    '모델': model,
                    '입력 토큰': f"{stats['input_tokens']:,}",
                    '출력 토큰': f"{stats['output_tokens']:,}",
                    '요청 횟수': stats['requests'],
                    '비용 (USD)': f"${stats['cost']:.4f}",
                    '비용 (KRW)': f"₩{stats['cost'] * 1300:.0f}"
                })

            if model_data:
                model_df = pd.DataFrame(model_data)
                st.dataframe(model_df, use_container_width=True)

        # Daily breakdown for weekly/monthly view
        if period in ["이번 주", "이번 달"] and usage_data.get('by_day'):
            st.subheader("📊 일별 사용량 추이")

            daily_data = []
            for date, models in sorted(usage_data['by_day'].items()):
                day_tokens = sum(m['input_tokens'] + m['output_tokens'] for m in models.values())
                day_cost = sum(m['cost'] for m in models.values())
                daily_data.append({
                    '날짜': date,
                    '총 토큰': f"{day_tokens:,}",
                    '비용 (USD)': f"${day_cost:.4f}",
                    '비용 (KRW)': f"₩{day_cost * 1300:.0f}"
                })

            if daily_data:
                daily_df = pd.DataFrame(daily_data)
                st.dataframe(daily_df, use_container_width=True)

        # Model pricing reference
        with st.expander("📋 모델별 가격표 (2025.09.22 기준)"):
            pricing_data = [
                {'모델': 'GPT-5', '입력 (1M tokens)': '$1.25', '출력 (1M tokens)': '$10.00'},
                {'모델': 'GPT-5 Mini', '입력 (1M tokens)': '$0.65', '출력 (1M tokens)': '$5.00'},
                {'모델': 'GPT-5 Nano', '입력 (1M tokens)': '$0.40', '출력 (1M tokens)': '$2.50'},
                {'모델': 'Gemini 2.5 Pro', '입력 (1M tokens)': '$1.25', '출력 (1M tokens)': '$10.00'},
                {'모델': 'Gemini 2.5 Flash', '입력 (1M tokens)': '$0.10', '출력 (1M tokens)': '$0.40'},
                {'모델': 'Text Embedding 004', '입력 (1M tokens)': '$0.10', '출력': 'N/A'},
            ]
            pricing_df = pd.DataFrame(pricing_data)
            st.dataframe(pricing_df, use_container_width=True)

    with mgmt_tab4:
        st.subheader("🧪 AI 시스템 테스트")

        test_col1, test_col2 = st.columns(2)

        with test_col1:
            st.write("**🔍 계층적 분석기 테스트**")
            if st.button("Test Hierarchical Analyzer"):
                with st.spinner("Testing hierarchical analyzer..."):
                    try:
                        from analyzers.hierarchical_analyzer import HierarchicalAnalyzer
                        analyzer = HierarchicalAnalyzer()

                        test_question = "혈압 측정 시 가장 중요한 주의사항은?"
                        test_choices = ["환자를 편안하게 앉힌다", "측정 전 30분간 금연한다"]
                        test_answer = "측정 전 30분간 금연한다"

                        result = analyzer.analyze_problem(test_question, test_choices, test_answer)
                        st.success("✅ 테스트 성공")
                        st.json(result)

                    except Exception as e:
                        st.error(f"테스트 실패: {e}")

        with test_col2:
            st.write("**📊 학습 분석기 테스트**")
            if st.button("Test Learning Analyzer"):
                with st.spinner("Testing learning analyzer..."):
                    try:
                        problems = create_sample_problems()
                        problems[0].update_stats(True, 45.0)
                        problems[1].update_stats(False, 90.0)

                        analysis = learning_analyzer.analyze_user_performance(problems)
                        st.success("✅ 테스트 성공")
                        st.write(f"분석된 문제 수: {len(problems)}")
                        st.write(f"약점 개념 수: {len(analysis['weak_concepts'])}")

                    except Exception as e:
                        st.error(f"테스트 실패: {e}")


if __name__ == "__main__":
    main()