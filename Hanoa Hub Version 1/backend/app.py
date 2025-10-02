"""
Hanoa RAG System - Streamlit Main Application (Simplified Version)
"""
import json
import os
import uuid
from datetime import datetime
from pathlib import Path

import streamlit as st
import pandas as pd

# Streamlit 폭 관련 파라미터 변경(임시 호환 셔팀): use_container_width -> width
try:
    def _map_ucw(kwargs):
        if 'use_container_width' in kwargs:
            val = kwargs.pop('use_container_width')
            kwargs.setdefault('width', 'stretch' if val else 'content')
        return kwargs

    if hasattr(st, 'button'):
        _orig_button = st.button
        def _button_shim(*args, **kwargs):
            return _orig_button(*args, **_map_ucw(kwargs))
        st.button = _button_shim

    if hasattr(st, 'form_submit_button'):
        _orig_form_submit_button = st.form_submit_button
        def _form_submit_button_shim(*args, **kwargs):
            return _orig_form_submit_button(*args, **_map_ucw(kwargs))
        st.form_submit_button = _form_submit_button_shim

    if hasattr(st, 'image'):
        _orig_image = st.image
        def _image_shim(*args, **kwargs):
            return _orig_image(*args, **_map_ucw(kwargs))
        st.image = _image_shim

    if hasattr(st, 'dataframe'):
        _orig_dataframe = st.dataframe
        def _dataframe_shim(*args, **kwargs):
            return _orig_dataframe(*args, **_map_ucw(kwargs))
        st.dataframe = _dataframe_shim
except Exception:
    # 셔팀 적용 실패시 무시(기본 동작 유지)
    pass

from config import (
    validate_config, JOBS_DIR, OBSIDIAN_VAULT_PATH,
    DOMAIN_COLLECTIONS, DEFAULT_DOMAIN, ENABLE_CROSS_DOMAIN_SEARCH,
    ENABLE_IMAGE_VECTORS, GEMINI_API_KEY, OPENAI_API_KEY,
    MAX_IMAGE_SIZE_MB
)
from rag_engine import rag_engine
from rag_engine_multi_domain import multi_domain_rag_engine
from jobs_worker import jobs_worker
from analyzers.problem_analyzer import problem_analyzer
from models.problem_schema import ProblemData, create_sample_problems
from api_usage_tracker import api_tracker
from services.firebase_service import firebase_service
from services.gemini_service import gemini_service
from analyzers.image_hierarchical_analyzer import ImageHierarchicalAnalyzer
# 기본 중복 제거 엔진 먼저 임포트
from deduplication_engine import deduplication_engine

# 고급 기능들을 안전하게 임포트
try:
    import deduplication_engine as _de
    # 고급 기능 가용성 확인
    use_advanced_deduplication = getattr(_de, 'use_advanced_deduplication', None)
    ADVANCED_DEDUP_AVAILABLE = bool(getattr(_de, 'ADVANCED_DEDUP_AVAILABLE', False)) and callable(use_advanced_deduplication)
    if not ADVANCED_DEDUP_AVAILABLE:
        # Fallback: 고급 엔진 미가용 시 기본 엔진으로 위임
        def use_advanced_deduplication(documents, domain='medical', **kwargs):
            return deduplication_engine.deduplicate(
                documents,
                domain=domain,
                return_pairs=kwargs.get('return_pairs', True)
            )
        ADVANCED_DEDUP_AVAILABLE = False
    pass  # 고급 중복 제거 기능 임포트 성공
except ImportError as e:
    pass  # 고급 중복 제거 임포트 실패, 기본 엔진 사용
    # 폴백 함수 정의
    def use_advanced_deduplication(documents, domain='medical', **kwargs):
        return deduplication_engine.deduplicate(
            documents,
            domain=domain,
            return_pairs=kwargs.get('return_pairs', True)
        )
    ADVANCED_DEDUP_AVAILABLE = False
from PIL import Image
import io
import os
import hashlib
import base64
import asyncio
from ai_batch_generator import BatchQuestionGenerator
from question_types import QuestionType

# 유사 항목 없음 사유를 간결히 표기하는 헬퍼
def show_no_similarity_reason(total_docs: int, n_requested: int) -> None:
    try:
        if total_docs <= 0:
            st.caption(f"사유: 최초 저장 (컬렉션 {total_docs}건, 요청 n={n_requested})")
        elif total_docs < n_requested:
            st.caption(f"사유: 비교 대상 부족 (컬렉션 {total_docs}건, 요청 n={n_requested})")
        else:
            st.caption(f"사유: 검색 결과 없음 (컬렉션 {total_docs}건, 요청 n={n_requested})")
    except Exception:
        pass

# Page configuration
st.set_page_config(
    page_title="Hanoa RAG System",
    page_icon="[BOOK]",
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
    st.title("[BOOK] Hanoa RAG System")
    st.markdown("간호학/의학 문제 및 개념 관리 시스템")

    # Sidebar - System Status
    with st.sidebar:
        st.header("[STATUS] 시스템 상태")

        # RAG Stats - Calculate from all collections
        try:
            from rag_engine_multi_domain import multi_domain_rag_engine

            # Count from all ChromaDB collections
            total_questions = 0
            total_concepts = 0

            collections_to_check = [
                ("nursing_questions", "question"),
                ("medical_problems", "question"),
                ("nursing_concepts", "concept"),
                ("medical_concepts", "concept"),
                ("fitness_knowledge", "concept"),
                ("lingumo_knowledge", "concept")
            ]

            for coll_name, coll_type in collections_to_check:
                try:
                    collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(coll_name)
                    count = collection.count()
                    if coll_type == "question":
                        total_questions += count
                    else:
                        total_concepts += count
                except:
                    pass

            st.metric("총 문제", total_questions)
            st.metric("총 개념", total_concepts)
            st.metric("전체 데이터", total_questions + total_concepts)
        except Exception as e:
            st.error(f"[ERROR] 상태 확인 실패: {e}")

    # Main content tabs - 6개 탭
    tab1, tab2, tab3, tab4, tab5, tab6 = st.tabs([
        "[DATA] 의료 데이터 입력",
        "🏋️ 운동/영양 입력",
        "🌍 언어 학습 입력",
        "[CHECK] 데이터 확인",
        "[AI] AI 문제 생성",
        "[SYSTEM] 시스템 관리"
    ])

    with tab1:
        data_input_tab()

    with tab2:
        fitness_data_input_tab()

    with tab3:
        lingumo_data_input_tab()

    with tab4:
        chromadb_check_tab()

    with tab5:
        ai_generation_tab()

    with tab6:
        system_management_tab()


def data_input_tab():
    """Data input tab for questions and concepts"""
    st.header("[DATA] 의료 데이터 입력")

    input_type = st.selectbox("입력 타입", ["문제", "개념"])

    if input_type == "문제":
        question_input_form()
    else:
        concept_input_form()


def question_input_form():
    """Manual form for inputting nursing/medical problems without AI analysis"""
    from problem_manual_form import problem_manual_input_form

    # Use the new manual input form
    problem_manual_input_form()


def concept_input_form():
    """Manual form for inputting medical concepts without AI analysis"""
    from concept_manual_form import concept_manual_input_form

    # Use the new manual input form
    concept_manual_input_form()
def ai_generation_tab():
    """AI batch question generation tab"""
    st.header("[AI] AI 문제 배치 생성")

    # Create subtabs - Only AUTO and HISTORY
    gen_tab1, gen_tab2 = st.tabs([
        "[AUTO] AI 자동 학습 계획",
        "[HISTORY] 생성 이력"
    ])

    with gen_tab1:
        auto_learning_plan_section()

    with gen_tab2:
        generation_history_section()


def auto_learning_plan_section():
    """AI-powered automatic learning plan generation"""
    st.subheader("[AUTO] AI 자동 학습 계획 - 실시간 모니터링")

    # Tab for monitoring mode
    monitor_tab, manual_tab = st.tabs(["[MONITOR] 자동 모니터링", "[MANUAL] 수동 생성"])

    with monitor_tab:
        st.info("[INFO] 학습 중인 사용자를 확인하고 필요한 사용자에게 맞춤 문제를 생성합니다")

        # Import monitoring service
        from user_monitor_service import monitor_instance

        # Display monitoring status
        col1, col2, col3 = st.columns(3)

        # Get current status
        status = monitor_instance.get_queue_status()

        with col1:
            st.metric("처리된 사용자", status['monitored_users'])
        with col2:
            st.metric("대기 중인 작업", status['pending'])
        with col3:
            st.metric("완료된 작업", status['completed'])

        # One-click automation button
        st.divider()
        if st.button("[AUTO] 전체 자동 처리 실행", type="primary", use_container_width=True):
            with st.spinner("[PROCESSING] 활동 사용자 분석 및 문제 자동 생성 중..."):
                try:
                    import asyncio
                    from learning_plan_engine import LearningPlanEngine

                    # Initialize engine
                    engine = LearningPlanEngine()
                    loop = asyncio.new_event_loop()
                    asyncio.set_event_loop(loop)

                    # Step 1: Get active users
                    st.info("[STEP 1] 활동 사용자 확인 중...")
                    active_users = loop.run_until_complete(
                        monitor_instance.get_active_users(hours_back=24)
                    )

                    if not active_users:
                        st.warning("[EMPTY] 최근 24시간 동안 활동한 사용자가 없습니다")
                        loop.close()
                    else:
                        st.success(f"[FOUND] {len(active_users)}명의 활동 사용자 발견")

                        # Step 2: Process users who need help
                        users_processed = 0
                        users_helped = 0

                        progress_bar = st.progress(0)
                        status_text = st.empty()

                        for i, user in enumerate(active_users):
                            progress = (i + 1) / len(active_users)
                            progress_bar.progress(progress)
                            status_text.text(f"처리 중: {user['user_id']} ({i+1}/{len(active_users)})")

                            # Check if user needs help
                            needs_help = loop.run_until_complete(
                                monitor_instance.check_user_needs_help(user)
                            )

                            if needs_help:
                                st.write(f"[HELP] {user['user_id']} - 오답 {user['wrong_count']}개, 도움 필요")

                                # Step 3: Generate learning plan for this user
                                try:
                                    # Analyze user history
                                    analysis = loop.run_until_complete(
                                        engine.analyze_user_history(user['user_id'], days_back=30)
                                    )

                                    if analysis:
                                        # Generate plan
                                        plan = loop.run_until_complete(
                                            engine.generate_learning_plan(analysis, target_count=10)
                                        )

                                        if plan:
                                            # Execute plan
                                            result = loop.run_until_complete(
                                                engine.execute_plan(plan, save_to_firebase=True)
                                            )

                                            if result['success']:
                                                st.success(f"✓ {user['user_id']}: {result['total_generated']}개 문제 생성 완료")
                                                users_helped += 1
                                            else:
                                                st.warning(f"✗ {user['user_id']}: 문제 생성 실패")
                                        else:
                                            st.warning(f"✗ {user['user_id']}: 계획 생성 실패")
                                    else:
                                        st.info(f"- {user['user_id']}: 학습 이력 없음")

                                except Exception as e:
                                    st.error(f"✗ {user['user_id']}: 오류 - {str(e)}")

                            users_processed += 1

                        loop.close()

                        # Final summary
                        st.divider()
                        st.subheader("[SUMMARY] 처리 결과")
                        col1, col2, col3 = st.columns(3)
                        with col1:
                            st.metric("전체 사용자", len(active_users))
                        with col2:
                            st.metric("도움 제공", users_helped)
                        with col3:
                            st.metric("성공률", f"{(users_helped/len(active_users)*100 if active_users else 0):.0f}%")

                except Exception as e:
                    st.error(f"[ERROR] 자동 처리 실패: {str(e)}")
                    if 'loop' in locals():
                        loop.close()

        # Active users section
        st.divider()
        st.subheader("[ACTIVE] 최근 24시간 활동 사용자")

        if st.button("[REFRESH] 활동 사용자 새로고침"):
            with st.spinner("[LOADING] 활동 사용자 확인 중..."):
                try:
                    import asyncio

                    # Get active users
                    loop = asyncio.new_event_loop()
                    asyncio.set_event_loop(loop)
                    active_users = loop.run_until_complete(
                        monitor_instance.get_active_users(hours_back=24)
                    )
                    loop.close()

                    if active_users:
                        st.success(f"[FOUND] {len(active_users)}명의 활동 사용자 발견")

                        # Display active users
                        for user in active_users:
                            with st.expander(f"사용자: {user['user_id']} (오답 {user['wrong_count']}개)"):
                                col1, col2 = st.columns(2)
                                with col1:
                                    st.write(f"**마지막 활동**: {user['last_activity']}")
                                    st.write(f"**오답 수**: {user['wrong_count']}")
                                with col2:
                                    st.write(f"**과목**: {', '.join(user['subjects'])}")
                                    # Check if needs help
                                    needs_help_loop = asyncio.new_event_loop()
                                    asyncio.set_event_loop(needs_help_loop)
                                    needs_help = needs_help_loop.run_until_complete(
                                        monitor_instance.check_user_needs_help(user)
                                    )
                                    needs_help_loop.close()

                                    if needs_help:
                                        st.error("[ALERT] 도움 필요")
                                        if st.button(f"[GENERATE] 즉시 문제 생성", key=f"gen_{user['user_id']}"):
                                            # Add to queue
                                            monitor_instance.processing_queue.append({
                                                'user_id': user['user_id'],
                                                'user_data': user,
                                                'timestamp': datetime.now(),
                                                'status': 'pending'
                                            })
                                            st.success("[QUEUED] 처리 대기열에 추가됨")
                                    else:
                                        st.success("[OK] 양호")
                    else:
                        st.info("[EMPTY] 최근 24시간 동안 활동한 사용자가 없습니다")

                except Exception as e:
                    st.error(f"[ERROR] 사용자 조회 실패: {str(e)}")

        # Processing queue section
        if status['queue_length'] > 0:
            st.divider()
            st.subheader("[QUEUE] 처리 대기열")

            # Display queue items
            for item in status['queue_details']:
                status_color = {
                    'pending': '🟡',
                    'processing': '🔵',
                    'completed': '🟢',
                    'failed': '🔴'
                }.get(item['status'], '⚪')

                with st.container():
                    col1, col2, col3 = st.columns([1, 2, 1])
                    with col1:
                        st.write(f"{status_color} {item['user_id']}")
                    with col2:
                        st.write(f"상태: {item['status']}")
                    with col3:
                        if item['status'] == 'completed':
                            st.write(f"생성: {item.get('questions_generated', 0)}개")
                        elif item['status'] == 'failed':
                            st.write(f"오류: {item.get('error', 'Unknown')}")

        # Manual refresh button
        if st.button("[REFRESH] 수동 새로고침", key="manual_refresh"):
            st.rerun()

    with manual_tab:
        st.info("[INFO] GPT-5-mini가 학습 이력을 분석하여 최적의 학습 계획을 자동으로 생성합니다")

        # User input section
        col1, col2 = st.columns(2)

        with col1:
            user_id = st.text_input("사용자 ID", value="test_user", help="Flutter 앱의 사용자 ID", key="manual_user_id")
            days_back = st.number_input("분석 기간 (일)", min_value=7, max_value=90, value=30, key="manual_days")

        with col2:
            target_count = st.number_input("생성할 문제 수", min_value=5, max_value=50, value=12, key="manual_count")
            focus_weak = st.checkbox("약점 중심 학습", value=True, help="틀린 문제가 많은 영역 집중", key="manual_weak")

        # Display current analysis
        if st.button("[ANALYZE] 학습 이력 분석", key="manual_analyze"):
            with st.spinner("[PROCESSING] Firebase에서 학습 이력을 가져오는 중..."):
                try:
                    from learning_plan_engine import LearningPlanEngine
                    import asyncio

                    # Initialize engine
                    engine = LearningPlanEngine()

                    # Run async analysis
                    loop = asyncio.new_event_loop()
                    asyncio.set_event_loop(loop)

                    analysis = loop.run_until_complete(
                        engine.analyze_user_history(user_id, days_back)
                    )

                    # Store in session state
                    st.session_state['learning_analysis'] = analysis
                    st.session_state['user_id'] = user_id

                    # Display analysis results
                    if analysis:
                        st.success("[SUCCESS] 학습 이력 분석 완료")

                        # Show metrics
                        col1, col2, col3 = st.columns(3)
                        with col1:
                            st.metric("총 문제 풀이", analysis.get('total_attempts', 0))
                        with col2:
                            accuracy = analysis.get('overall_accuracy', 0)
                            st.metric("전체 정답률", f"{accuracy:.1f}%")
                        with col3:
                            st.metric("분석 기간", f"{days_back}일")

                        # Show weak concepts
                        if analysis.get('weak_concepts'):
                            st.subheader("[WEAK] 취약 개념 Top 5")
                            for concept in analysis['weak_concepts'][:5]:
                                accuracy = concept.get('accuracy', 0)
                                attempts = concept.get('attempts', 0)
                                st.write(f"- **{concept['concept']}**: 정답률 {accuracy:.1f}% (시도 {attempts}회)")

                        # Show strong concepts
                        if analysis.get('strong_concepts'):
                            with st.expander("[STRONG] 강점 개념 보기"):
                                for concept in analysis['strong_concepts'][:5]:
                                    accuracy = concept.get('accuracy', 0)
                                    attempts = concept.get('attempts', 0)
                                    st.write(f"- {concept['concept']}: 정답률 {accuracy:.1f}% (시도 {attempts}회)")

                    else:
                        st.warning("[WARNING] 분석할 학습 이력이 없습니다")

                except Exception as e:
                    st.error(f"[ERROR] 분석 실패: {str(e)}")
                finally:
                    if 'loop' in locals():
                        loop.close()

    # Generate learning plan
    if st.session_state.get('learning_analysis'):
        st.divider()
        st.subheader("[PLAN] AI 학습 계획 생성")

        if st.button("[GENERATE] GPT-5-mini로 최적 학습 계획 생성"):
            with st.spinner("[AI] GPT-5-mini가 최적 학습 계획을 생성하는 중..."):
                try:
                    from learning_plan_engine import LearningPlanEngine
                    import asyncio

                    engine = LearningPlanEngine()
                    loop = asyncio.new_event_loop()
                    asyncio.set_event_loop(loop)

                    plan = loop.run_until_complete(
                        engine.generate_learning_plan(
                            st.session_state['learning_analysis'],
                            target_count
                        )
                    )

                    # Store plan
                    st.session_state['learning_plan'] = plan

                    # Display plan
                    if plan:
                        st.success("[SUCCESS] 학습 계획 생성 완료")

                        # Show plan overview
                        st.subheader("[OVERVIEW] 계획 개요")
                        st.write(f"**전략**: {plan.get('strategy', 'N/A')}")
                        st.write(f"**목표**: {plan.get('goal', 'N/A')}")
                        st.write(f"**총 문제 수**: {plan.get('total_questions', 0)}")

                        # Show question distribution
                        if plan.get('question_distribution'):
                            st.subheader("[DISTRIBUTION] 문제 유형 분배")
                            for item in plan['question_distribution']:
                                st.write(f"- **{item['type']}**: {item['count']}문제 ({item['reason']})")

                        # Show topic focus
                        if plan.get('topic_focus'):
                            st.subheader("[TOPICS] 주제 초점")
                            for topic in plan['topic_focus']:
                                st.write(f"- **{topic['topic']}**: {topic['count']}문제 - {topic['reason']}")

                        # Show difficulty distribution
                        if plan.get('difficulty_distribution'):
                            st.subheader("[DIFFICULTY] 난이도 분포")
                            for diff in plan['difficulty_distribution']:
                                st.write(f"- **{diff['level'].upper()}**: {diff['count']}문제 ({diff['percentage']}%)")

                    else:
                        st.error("[ERROR] 계획 생성 실패")

                except Exception as e:
                    st.error(f"[ERROR] 계획 생성 오류: {str(e)}")
                finally:
                    if 'loop' in locals():
                        loop.close()

    # Execute plan
    if st.session_state.get('learning_plan'):
        st.divider()
        st.subheader("[EXECUTE] 계획 실행")

        st.warning("[WARNING] 계획을 실행하면 실제로 문제가 생성되고 Firebase에 저장됩니다")

        if st.button("[EXECUTE] 학습 계획 실행 (문제 생성)"):
            with st.spinner("[PROCESSING] AI가 문제를 생성하는 중..."):
                try:
                    from learning_plan_engine import LearningPlanEngine
                    import asyncio

                    engine = LearningPlanEngine()
                    loop = asyncio.new_event_loop()
                    asyncio.set_event_loop(loop)

                    result = loop.run_until_complete(
                        engine.execute_plan(
                            st.session_state['learning_plan'],
                            save_to_firebase=True
                        )
                    )

                    # Display execution results
                    if result and result.get('success'):
                        st.success(f"[SUCCESS] {result['total_generated']}개 문제 생성 완료!")

                        # Show statistics
                        st.subheader("[STATS] 생성 통계")
                        col1, col2 = st.columns(2)
                        with col1:
                            st.metric("생성 성공", result['total_generated'])
                        with col2:
                            st.metric("실행 시간", f"{result.get('execution_time', 0):.1f}초")

                        # Show generated questions preview
                        if result.get('questions'):
                            st.subheader("[PREVIEW] 생성된 문제 미리보기")
                            for i, q in enumerate(result['questions'][:3], 1):
                                with st.expander(f"문제 {i}: {q.get('type', 'MCQ')}"):
                                    st.write(f"**문제**: {q['question_text']}")
                                    st.write("**선택지**:")
                                    for j, choice in enumerate(q['choices'], 1):
                                        st.write(f"  {j}. {choice}")
                                    st.write(f"**정답**: {q['correct_answer']}")
                    else:
                        st.error("[ERROR] 실행 실패")

                except Exception as e:
                    st.error(f"[ERROR] 실행 오류: {str(e)}")
                finally:
                    if 'loop' in locals():
                        loop.close()


def generation_history_section():
    """Display generation history"""
    st.subheader("[HISTORY] AI 문제 생성 이력")

    # Time period selection
    col1, col2 = st.columns(2)
    with col1:
        period = st.selectbox("기간 선택", ["오늘", "최근 7일", "최근 30일", "전체"], key="history_period")
    with col2:
        if st.button("[REFRESH] 이력 새로고침", key="refresh_history"):
            st.rerun()

    # Get generation history from Firebase
    with st.spinner("[LOADING] Firebase에서 생성 이력을 가져오는 중..."):
        try:
            import firebase_admin
            from firebase_admin import credentials, firestore
            from datetime import datetime, timedelta

            # Initialize Firebase if not already done
            if not firebase_admin._apps:
                cred = credentials.Certificate('firebase-service-account.json')
                firebase_admin.initialize_app(cred)

            db = firestore.client()

            # Calculate date range
            now = datetime.now()
            if period == "오늘":
                start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
            elif period == "최근 7일":
                start_date = now - timedelta(days=7)
            elif period == "최근 30일":
                start_date = now - timedelta(days=30)
            else:  # 전체
                start_date = datetime(2024, 1, 1)  # Arbitrary old date

            # Query generation logs from Firebase
            generation_logs = []

            # Get from nursing_problems collection (recently generated problems)
            problems_ref = db.collection('nursing_problems')
            query = problems_ref.where('generated_by', 'in', ['gpt-5-mini', 'gpt-5', 'gemini-2.5-flash'])

            if period != "전체":
                query = query.where('timestamp', '>=', start_date)

            query = query.order_by('timestamp', direction=firestore.Query.DESCENDING).limit(100)

            docs = query.stream()

            for doc in docs:
                data = doc.to_dict()
                if data.get('generated_by'):
                    generation_logs.append({
                        'id': doc.id,
                        'timestamp': data.get('timestamp', ''),
                        'type': data.get('type', 'MCQ'),
                        'model': data.get('generated_by', 'Unknown'),
                        'difficulty': data.get('difficulty', 'medium'),
                        'subject': data.get('subject', 'nursing'),
                        'created_by': data.get('created_by', 'ai_batch_generator')
                    })

            # Also check for batch generation logs if we have a separate collection
            try:
                batch_logs_ref = db.collection('generation_logs')
                batch_query = batch_logs_ref

                if period != "전체":
                    batch_query = batch_query.where('timestamp', '>=', start_date)

                batch_query = batch_query.order_by('timestamp', direction=firestore.Query.DESCENDING).limit(50)
                batch_docs = batch_query.stream()

                for doc in batch_docs:
                    data = doc.to_dict()
                    generation_logs.append({
                        'id': doc.id,
                        'timestamp': data.get('timestamp', ''),
                        'type': 'Batch Generation',
                        'model': data.get('model_used', 'GPT-5-mini'),
                        'count': data.get('questions_generated', 0),
                        'user': data.get('user_id', 'System'),
                        'status': data.get('status', 'completed')
                    })
            except:
                # If generation_logs collection doesn't exist, continue
                pass

            if generation_logs:
                # Convert to DataFrame
                history_data = []
                for log in generation_logs:
                    # Format timestamp
                    timestamp_str = ""
                    if log.get('timestamp'):
                        try:
                            if isinstance(log['timestamp'], datetime):
                                timestamp_str = log['timestamp'].strftime('%Y-%m-%d %H:%M')
                            elif isinstance(log['timestamp'], str):
                                timestamp_str = log['timestamp'][:16]  # Take first 16 chars (YYYY-MM-DD HH:MM)
                        except:
                            timestamp_str = "N/A"

                    history_data.append({
                        '시간': timestamp_str,
                        '유형': log.get('type', 'MCQ'),
                        '모델': log.get('model', 'Unknown'),
                        '난이도': log.get('difficulty', log.get('status', 'N/A')),
                        '과목': log.get('subject', log.get('user', 'N/A')),
                        '생성자': log.get('created_by', log.get('user', 'System'))
                    })

                df = pd.DataFrame(history_data)

                # Display summary metrics
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("총 생성 문제", len(history_data))
                with col2:
                    # Count by model
                    if 'gpt-5-mini' in df['모델'].values:
                        gpt5_mini_count = len(df[df['모델'] == 'gpt-5-mini'])
                    else:
                        gpt5_mini_count = 0
                    st.metric("GPT-5-mini", gpt5_mini_count)
                with col3:
                    if 'gpt-5' in df['모델'].values:
                        gpt5_count = len(df[df['모델'] == 'gpt-5'])
                    else:
                        gpt5_count = 0
                    st.metric("GPT-5", gpt5_count)
                with col4:
                    if 'gemini-2.5-flash' in df['모델'].values:
                        gemini_count = len(df[df['모델'] == 'gemini-2.5-flash'])
                    else:
                        gemini_count = 0
                    st.metric("Gemini", gemini_count)

                # Display the dataframe
                st.dataframe(df, width='stretch')

                # Model usage chart
                if len(df) > 0:
                    st.subheader("[CHART] 모델별 사용 통계")
                    model_counts = df['모델'].value_counts()
                    st.bar_chart(model_counts)

            else:
                st.info("[EMPTY] 선택한 기간에 생성 이력이 없습니다")

        except Exception as e:
            st.error(f"[ERROR] 이력 조회 실패: {str(e)}")

            # Show sample data for demonstration
            st.info("[INFO] 샘플 데이터를 표시합니다")
            sample_data = {
                "시간": ["2025-01-23 10:00", "2025-01-23 09:30", "2025-01-23 09:00"],
                "유형": ["MCQ", "Case", "Image"],
                "모델": ["gpt-5-mini", "gpt-5", "gemini-2.5-flash"],
                "난이도": ["medium", "hard", "easy"],
                "과목": ["nursing", "medical", "pharmacology"],
                "생성자": ["ai_batch_generator", "user_monitor", "manual"]
            }
            df = pd.DataFrame(sample_data)
            st.dataframe(df, width='stretch')


def system_management_tab():
    """System management and settings tab"""
    st.header("[SYSTEM] 시스템 관리")

    # Create subtabs for system management
    mgmt_tab1, mgmt_tab2 = st.tabs(["[SETTINGS] 시스템 설정", "[API] API 사용량"])

    with mgmt_tab1:
        st.subheader("[SETTINGS] 시스템 설정")

        col1, col2 = st.columns(2)

        with col1:
            st.info("[PATH] Jobs 디렉터리")
            st.code(str(JOBS_DIR))

            st.info("[PATH] ChromaDB 경로")
            st.code("database/chroma_db/")

        with col2:
            st.info("[MODEL] AI 모델 설정")
            st.code("Embedding: text-embedding-004")
            st.code("Primary: GPT-5 Mini")
            st.code("Advanced: GPT-5")

        # Environment check
        st.subheader("[CHECK] 환경 확인")

        try:
            validate_config()
            st.success("[OK] 모든 설정이 올바릅니다")
        except Exception as e:
            st.error(f"[ERROR] 설정 오류: {e}")

    with mgmt_tab2:
        st.subheader("[API] API 사용량 추적")

        # API Usage Overview
        st.info("[INFO] OpenAI 및 Gemini API 사용량 및 비용 추적")

        # Time period selection
        period = st.selectbox("기간 선택", ["오늘", "이번 주", "이번 달"])

        try:
            # Get usage data based on period
            if period == "오늘":
                usage_data = api_tracker.get_daily_usage()
                st.subheader(f"[TODAY] 오늘 사용량 ({datetime.now().strftime('%Y-%m-%d')})")
            elif period == "이번 주":
                usage_data = api_tracker.get_weekly_usage()
                st.subheader("[WEEK] 최근 7일 사용량")
            else:  # 이번 달
                now = datetime.now()
                usage_data = api_tracker.get_monthly_usage(now.year, now.month)
                st.subheader(f"[MONTH] {now.year}년 {now.month}월 사용량")

            # Display metrics
            col1, col2, col3 = st.columns(3)

            total_cost = usage_data.get('total_cost', 0) if usage_data else 0
            total_tokens = usage_data.get('total_tokens', 0) if usage_data else 0

            with col1:
                st.metric("총 토큰 사용량", f"{total_tokens:,}")
            with col2:
                st.metric("총 비용", f"${total_cost:.4f}")
            with col3:
                st.metric("원화 환산 (1,400원/$)", f"₩{total_cost * 1400:.0f}")

            # Model-wise breakdown
            if usage_data and usage_data.get('by_model'):
                st.subheader("[MODEL] 모델별 사용량")

                model_data = []
                for model, stats in usage_data['by_model'].items():
                    model_data.append({
                        '모델': model,
                        '입력 토큰': f"{stats.get('input_tokens', 0):,}",
                        '출력 토큰': f"{stats.get('output_tokens', 0):,}",
                        '요청 횟수': stats.get('requests', 0),
                        '비용 (USD)': f"${stats.get('cost', 0):.4f}"
                    })

                if model_data:
                    model_df = pd.DataFrame(model_data)
                    st.dataframe(model_df, width='stretch')
            else:
                st.info("[INFO] 해당 기간의 사용 기록이 없습니다")

        except Exception as e:
            st.error(f"[ERROR] API 사용량 조회 실패: {e}")
            st.info("[INFO] api_usage_tracker가 제대로 설정되었는지 확인하세요")

        # Model pricing reference
        with st.expander("[PRICE] 모델별 가격표"):
            pricing_data = [
                {'모델': 'GPT-5', '입력 (1M tokens)': '$1.25', '출력 (1M tokens)': '$10.00'},
                {'모델': 'GPT-5 Mini', '입력 (1M tokens)': '$0.65', '출력 (1M tokens)': '$5.00'},
                {'모델': 'GPT-5 Nano', '입력 (1M tokens)': '$0.40', '출력 (1M tokens)': '$2.50'},
                {'모델': 'Gemini 2.5 Pro', '입력 (1M tokens)': '$1.25', '출력 (1M tokens)': '$10.00'},
                {'모델': 'Gemini 2.5 Flash', '입력 (1M tokens)': '$0.10', '출력 (1M tokens)': '$0.40'},
            ]
            pricing_df = pd.DataFrame(pricing_data)
            st.dataframe(pricing_df, width='stretch')


def chromadb_check_tab():
    """ChromaDB data check tab with deletion capability"""
    st.subheader("[CHECK] ChromaDB 데이터 확인 및 관리")

    # Collection selection
    collection_name = st.selectbox(
        "컬렉션 선택",
        ["nursing_questions", "nursing_concepts", "medical_concepts", "fitness_knowledge", "lingumo_knowledge"]
    )

    # Store data in session state
    if 'chromadb_data' not in st.session_state:
        st.session_state.chromadb_data = None
        st.session_state.chromadb_ids = []

    # Get collection data
    col1, col2, col3 = st.columns([1, 1, 2])
    with col1:
        if st.button("[LOAD] 데이터 조회"):
            try:
                from rag_engine_multi_domain import multi_domain_rag_engine

                # Get or create collection
                collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(collection_name)

                # Get all data
                results = collection.get()

                if results and results['ids']:
                    st.success(f"[SUCCESS] {len(results['ids'])}개 데이터 발견")

                    # Store full IDs for deletion
                    st.session_state.chromadb_ids = results['ids']

                    # Create DataFrame for display
                    data_list = []
                    for i, doc_id in enumerate(results['ids']):
                        metadata = results['metadatas'][i] if i < len(results['metadatas']) else {}
                        document = results['documents'][i] if i < len(results['documents']) else ""

                        # Extract full question data from document and metadata
                        question_display = metadata.get('questionText', metadata.get('title', ''))
                        if not question_display and document:
                            # Try to extract from document if not in metadata
                            question_display = document.split('\n')[0].replace('문제: ', '').replace('설명: ', '')[:100]

                        # Check if data has image
                        has_image = metadata.get('hasImage', False)
                        image_url = metadata.get('imageUrl', '')

                        data_item = {
                            'Index': i,
                            'ID': doc_id[:8] + '...',  # Display shortened ID
                            '문제/개념': question_display[:80] + '...' if len(question_display) > 80 else question_display,
                            '타입': metadata.get('type', 'N/A'),
                            '과목': metadata.get('subject', metadata.get('category', 'N/A')),
                            '난이도': metadata.get('difficulty', 'N/A'),
                            '태그': metadata.get('tags', metadata.get('keywords', 'N/A')),
                            '이미지': '[IMAGE]' if has_image else 'N/A',
                            '이미지URL': image_url[:50] + '...' if len(image_url) > 50 else image_url if image_url else 'N/A'
                        }

                        # Add specific fields based on type
                        if metadata.get('type') == 'problem':
                            data_item.update({
                                '정답': metadata.get('correctAnswer', 'N/A')[:50],
                                '선택지1': metadata.get('choice1', 'N/A')[:30],
                                '선택지2': metadata.get('choice2', 'N/A')[:30],
                            })
                        elif metadata.get('type') == 'concept':
                            data_item.update({
                                '이미지분석': '[ANALYZED]' if metadata.get('imageMainObjects') else 'N/A',
                                '주요객체': metadata.get('imageMainObjects', 'N/A')[:50],
                                '의료태그': metadata.get('imageMedicalTags', 'N/A')[:50]
                            })

                        data_list.append(data_item)

                    st.session_state.chromadb_data = pd.DataFrame(data_list)
                else:
                    st.info(f"[INFO] {collection_name} 컬렉션에 데이터가 없습니다")
                    st.session_state.chromadb_data = None
                    st.session_state.chromadb_ids = []

            except Exception as e:
                st.error(f"[ERROR] 데이터 조회 실패: {e}")

    with col2:
        # Delete all button
        if st.button("[DELETE ALL] 전체 삭제", type="secondary"):
            if st.session_state.chromadb_ids:
                try:
                    from rag_engine_multi_domain import multi_domain_rag_engine
                    collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(collection_name)

                    # Delete all documents
                    collection.delete(ids=st.session_state.chromadb_ids)
                    st.success(f"[SUCCESS] {len(st.session_state.chromadb_ids)}개 데이터 삭제 완료!")

                    # Clear session state
                    st.session_state.chromadb_data = None
                    st.session_state.chromadb_ids = []
                    st.rerun()

                except Exception as e:
                    st.error(f"[ERROR] 전체 삭제 실패: {e}")
            else:
                st.warning("[WARNING] 삭제할 데이터가 없습니다. 먼저 조회하세요.")

    # Display data if available
    if st.session_state.chromadb_data is not None:
        st.divider()

        # Show data table
        st.dataframe(st.session_state.chromadb_data, width='stretch')

        # Image preview section
        st.divider()
        st.subheader("[IMAGE] 이미지 미리보기")

        # Select item for image preview
        if '[IMAGE]' in st.session_state.chromadb_data['이미지'].values:
            image_items = st.session_state.chromadb_data[st.session_state.chromadb_data['이미지'] == '[IMAGE]']

            selected_index = st.selectbox(
                "이미지가 있는 항목 선택",
                options=image_items['Index'].tolist(),
                format_func=lambda x: f"Index {x}: {image_items.iloc[image_items['Index'].tolist().index(x)]['문제/개념'][:50]}..."
            )

            if selected_index is not None:
                selected_row = st.session_state.chromadb_data.iloc[selected_index]
                image_url = selected_row['이미지URL'].replace('...', '') if selected_row['이미지URL'] != 'N/A' else None

                col_img1, col_img2 = st.columns([1, 2])

                with col_img1:
                    if image_url and image_url != 'N/A':
                        try:
                            st.image(image_url, caption="저장된 이미지", width=200)
                        except Exception as e:
                            st.error(f"[ERROR] 이미지 로드 실패: {e}")
                            st.write(f"**이미지 URL**: {image_url}")
                    else:
                        st.info("[INFO] 이미지 URL이 없습니다")

                with col_img2:
                    st.write(f"**문제/개념**: {selected_row['문제/개념']}")
                    st.write(f"**타입**: {selected_row['타입']}")
                    st.write(f"**과목**: {selected_row['과목']}")

                    if selected_row.get('이미지분석') == '[ANALYZED]':
                        st.write("**[ANALYSIS] 이미지 분석 완료**")
                        st.write(f"**주요 객체**: {selected_row.get('주요객체', 'N/A')}")
                        st.write(f"**의료 태그**: {selected_row.get('의료태그', 'N/A')}")
                    elif selected_row.get('정답'):
                        st.write(f"**정답**: {selected_row.get('정답', 'N/A')}")
        else:
            st.info("[INFO] 이미지가 포함된 데이터가 없습니다")

        # Export option
        csv = st.session_state.chromadb_data.to_csv(index=False, encoding='utf-8-sig')
        st.download_button(
            label="[EXPORT] CSV로 다운로드",
            data=csv,
            file_name=f"{collection_name}_data.csv",
            mime="text/csv"
        )

        # Individual deletion
        st.divider()
        st.subheader("[DELETE] 개별 데이터 삭제")

        # Select items to delete
        indices_to_delete = st.multiselect(
            "삭제할 항목 선택 (Index 번호)",
            options=st.session_state.chromadb_data['Index'].tolist(),
            format_func=lambda x: f"Index {x}: {st.session_state.chromadb_data.iloc[x]['문제'][:50] if '문제' in st.session_state.chromadb_data.columns else st.session_state.chromadb_data.iloc[x].get('제목/질문', 'N/A')[:50]}..."
        )

        if st.button("[DELETE SELECTED] 선택 항목 삭제"):
            if indices_to_delete:
                try:
                    from rag_engine_multi_domain import multi_domain_rag_engine
                    collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(collection_name)

                    # Get IDs to delete
                    ids_to_delete = [st.session_state.chromadb_ids[i] for i in indices_to_delete]

                    # Delete selected documents
                    collection.delete(ids=ids_to_delete)
                    st.success(f"[SUCCESS] {len(ids_to_delete)}개 항목 삭제 완료!")

                    # Clear session state to refresh
                    st.session_state.chromadb_data = None
                    st.session_state.chromadb_ids = []
                    st.rerun()

                except Exception as e:
                    st.error(f"[ERROR] 선택 항목 삭제 실패: {e}")
            else:
                st.warning("[WARNING] 삭제할 항목을 선택하세요.")

    # Collection statistics
    st.divider()
    st.subheader("[STATS] 컬렉션 통계")

    try:
        from services.firebase_service import firebase_service
        from rag_engine_multi_domain import multi_domain_rag_engine

        stats_data = []

        # ChromaDB collections to check
        collections_info = [
            ("nursing_questions", "간호 문제"),
            ("medical_problems", "의학 문제"),
            ("medical_concepts", "의학 개념"),
            ("fitness_knowledge", "운동/영양"),
            ("lingumo_knowledge", "언어 학습")
        ]

        # Get ChromaDB stats
        for coll_name, display_name in collections_info:
            try:
                collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(coll_name)

                # fitness_knowledge는 운동/영양/건강 분리
                if coll_name == "fitness_knowledge":
                    results = collection.get()
                    if results and results['metadatas']:
                        # 운동 개념
                        exercise_count = sum(1 for m in results['metadatas'] if m.get('category') == '운동')
                        stats_data.append({
                            '데이터베이스': 'ChromaDB',
                            '컬렉션': '운동',
                            '데이터 수': exercise_count,
                            '상태': '[ACTIVE]' if exercise_count > 0 else '[EMPTY]'
                        })

                        # 영양 개념
                        nutrition_count = sum(1 for m in results['metadatas'] if m.get('category') == '영양')
                        stats_data.append({
                            '데이터베이스': 'ChromaDB',
                            '컬렉션': '영양',
                            '데이터 수': nutrition_count,
                            '상태': '[ACTIVE]' if nutrition_count > 0 else '[EMPTY]'
                        })

                        # 건강 개념
                        health_count = sum(1 for m in results['metadatas'] if m.get('category') == '건강')
                        stats_data.append({
                            '데이터베이스': 'ChromaDB',
                            '컬렉션': '건강',
                            '데이터 수': health_count,
                            '상태': '[ACTIVE]' if health_count > 0 else '[EMPTY]'
                        })
                    else:
                        stats_data.append({
                            '데이터베이스': 'ChromaDB',
                            '컬렉션': '운동',
                            '데이터 수': 0,
                            '상태': '[EMPTY]'
                        })
                        stats_data.append({
                            '데이터베이스': 'ChromaDB',
                            '컬렉션': '영양',
                            '데이터 수': 0,
                            '상태': '[EMPTY]'
                        })
                        stats_data.append({
                            '데이터베이스': 'ChromaDB',
                            '컬렉션': '건강',
                            '데이터 수': 0,
                            '상태': '[EMPTY]'
                        })
                else:
                    count = collection.count()
                    stats_data.append({
                        '데이터베이스': 'ChromaDB',
                        '컬렉션': display_name,
                        '데이터 수': count,
                        '상태': '[ACTIVE]' if count > 0 else '[EMPTY]'
                    })
            except Exception as e:
                if coll_name == "fitness_knowledge":
                    stats_data.append({
                        '데이터베이스': 'ChromaDB',
                        '컬렉션': '운동',
                        '데이터 수': 0,
                        '상태': '[ERROR]'
                    })
                    stats_data.append({
                        '데이터베이스': 'ChromaDB',
                        '컬렉션': '영양',
                        '데이터 수': 0,
                        '상태': '[ERROR]'
                    })
                    stats_data.append({
                        '데이터베이스': 'ChromaDB',
                        '컬렉션': '건강',
                        '데이터 수': 0,
                        '상태': '[ERROR]'
                    })
                else:
                    stats_data.append({
                        '데이터베이스': 'ChromaDB',
                        '컬렉션': display_name,
                        '데이터 수': 0,
                        '상태': '[ERROR]'
                    })


        # Display statistics
        if stats_data:
            stats_df = pd.DataFrame(stats_data)

            # Summary metrics
            col1, col2, col3 = st.columns(3)

            with col1:
                total_problems = sum(row['데이터 수'] for row in stats_data if '문제' in row['컬렉션'])
                st.metric("[PROBLEMS] 총 문제", f"{total_problems:,}")

            with col2:
                total_concepts = sum(row['데이터 수'] for row in stats_data if '개념' in row['컬렉션'] or row['컬렉션'] in ['운동', '영양', '건강'])
                st.metric("[CONCEPTS] 총 개념", f"{total_concepts:,}")

            with col3:
                total_chromadb = sum(row['데이터 수'] for row in stats_data)
                st.metric("[TOTAL] 전체 데이터", f"{total_chromadb:,}")

            # Detailed table
            st.dataframe(
                stats_df.style.highlight_max(subset=['데이터 수'], color='lightgreen'),
                width='stretch'
            )

            # Last update time
            st.caption(f"[UPDATE] 마지막 업데이트: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    except Exception as e:
        st.error(f"[ERROR] 통계 로드 실패: {e}")


def fitness_data_input_tab():
    """Fitness and nutrition data input tab"""
    from fitness_manual_form import fitness_concept_input_form

    st.header("🏋️ 운동/영양 개념 입력")
    st.markdown("운동 방법, 폼 가이드, 영양 정보 등을 입력하여 Areumfit RAG 시스템에 저장합니다.")

    fitness_concept_input_form()


def lingumo_data_input_tab():
    """Language learning data input tab"""
    from lingumo_manual_form import lingumo_content_input_form

    st.header("🌍 언어 학습 콘텐츠 입력")
    st.markdown("단어, 문장, 문법 등을 입력하여 Lingumo RAG 시스템에 저장합니다.")

    lingumo_content_input_form()


if __name__ == "__main__":
    main()




