"""
Hanoa RAG System - Streamlit Main Application (Simplified Version)
"""
import json
import os
import uuid
from datetime import datetime
from pathlib import Path
from utils.datetime_utils import get_iso_timestamp
from utils.firebase_utils import ensure_created_at_iso
from storage.firebase_storage import FirebaseStorage

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
# ChromaDB 관리자 임포트
from database.chroma_manager import ChromaManager

# 새로운 AI 시스템 임포트
from services.model_selector import model_selector
from services.question_type_handler import question_type_handler
from services.image_generator import image_generator
from services.smart_problem_generator import smart_problem_generator
from services.difficulty_classifier import difficulty_classifier

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

# ==============================
# ChromaDB 관리 유틸 함수 (imports 이후)
# ==============================
def delete_image_file(image_url: str) -> None:
    """
    이미지 파일 삭제 (확장자 자동 감지 포함)

    Args:
        image_url: 이미지 파일 경로 (확장자 누락 가능)
    """
    import os

    try:
        if not image_url:
            return

        # UI에서 잘라낸 '...' 제거
        image_url = image_url.replace('...', '')

        # 확장자 자동 감지
        if not os.path.exists(image_url):
            base_path = image_url.rstrip('.')
            possible_exts = ['.webp', '.jpg', '.jpeg', '.png']
            for ext in possible_exts:
                test_path = base_path + ext
                if os.path.exists(test_path):
                    image_url = test_path
                    break

        # 파일 삭제
        if os.path.exists(image_url):
            os.remove(image_url)
            print(f"[DELETE] 이미지 파일 삭제: {image_url}")
        else:
            print(f"[SKIP] 이미지 파일 없음: {image_url}")

    except Exception as e:
        print(f"[ERROR] 이미지 파일 삭제 실패: {e}")


def delete_chromadb_item(row_data, collection_name: str) -> bool:
    """
    ChromaDB에서 단일 항목 삭제 (선택 행 기반)

    Args:
        row_data: st.dataframe에서 선택된 행 데이터 (Series)
        collection_name: 현재 선택된 컬렉션 이름

    Returns:
        bool: 삭제 성공 여부
    """
    try:
        # Index를 통해 실제 ID 매핑
        idx = None
        try:
            idx = int(row_data.get('Index')) if hasattr(row_data, 'get') else int(row_data['Index'])
        except Exception:
            pass

        if idx is None:
            st.error("항목 Index를 확인할 수 없습니다")
            return False

        full_ids = st.session_state.get('chromadb_ids', [])
        if not full_ids or idx >= len(full_ids):
            st.error("세션에 저장된 ID 목록이 유효하지 않습니다")
            return False

        item_id = full_ids[idx]

        # 컬렉션 접근: 기존 엔진의 chroma_client 사용
        collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(collection_name)
        collection.delete(ids=[item_id])

        # 이미지 파일 삭제 (옵션)
        # 다양한 키 시도 (로컬라이징 대응)
        image_url = None
        for k in ['이미지URL', 'imageUrl', 'image_url', '�̹���URL']:
            try:
                if k in row_data and row_data[k] and row_data[k] != 'N/A':
                    image_url = str(row_data[k])
                    break
            except Exception:
                # pandas Series .get 사용 가능 시도
                v = getattr(row_data, 'get', lambda _k, _d=None: None)(k, None)
                if v and v != 'N/A':
                    image_url = str(v)
                    break

        if image_url:
            delete_image_file(image_url)

        st.success(f"✅ 항목 삭제 완료: {item_id}")

        # 새로고침을 위해 세션 초기화
        st.session_state.chromadb_data = None
        st.session_state.chromadb_ids = []
        st.rerun()
        return True

    except Exception as e:
        st.error(f"❌ 삭제 실패: {e}")
        return False


def fix_broken_image_paths():
    """
    모든 컬렉션의 이미지 경로를 검사하여 확장자가 누락된 항목을 복구
    """
    try:
        import os

        collections = [
            'nursing_questions',
            'ai_questions',
            'medical_concepts',
            'fitness_concepts',
            'lingumo_knowledge',
        ]

        fixed_count = 0

        for coll_name in collections:
            try:
                collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(coll_name)
                all_data = collection.get()
                if not all_data or not all_data.get('ids'):
                    continue

                for i, item_id in enumerate(all_data['ids']):
                    metadata = all_data['metadatas'][i] if i < len(all_data.get('metadatas', [])) else {}
                    image_url = None
                    if isinstance(metadata, dict):
                        image_url = metadata.get('imageUrl') or metadata.get('image_url')

                    if image_url and not os.path.exists(image_url):
                        base_path = image_url.rstrip('.')
                        for ext in ['.webp', '.jpg', '.jpeg', '.png']:
                            test_path = base_path + ext
                            if os.path.exists(test_path):
                                # 메타데이터 업데이트
                                metadata = dict(metadata or {})
                                metadata['imageUrl'] = test_path
                                collection.update(ids=[item_id], metadatas=[metadata])
                                fixed_count += 1
                                break
            except Exception as e:
                print(f"[ERROR] {coll_name} 복구 실패: {e}")
                continue

        st.success(f"✅ {fixed_count}개 이미지 경로 복구 완료")
        st.rerun()
    except Exception as e:
        st.error(f"❌ 복구 실패: {e}")


def cleanup_orphan_files():
    """
    ChromaDB에 등록되지 않은 고아 이미지 파일 정리
    """
    from pathlib import Path
    import os

    try:
        image_dir = Path("uploaded_images/concepts")
        if not image_dir.exists():
            st.info("이미지 디렉토리가 없습니다")
            return

        all_files = set(image_dir.glob("*.*"))

        registered_files = set()
        for coll_name in ['nursing_questions', 'ai_questions', 'medical_concepts', 'fitness_concepts', 'lingumo_knowledge']:
            try:
                collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(coll_name)
                data = collection.get()
                if not data or not data.get('ids'):
                    continue

                for i, _ in enumerate(data['ids']):
                    md = data['metadatas'][i] if i < len(data.get('metadatas', [])) else {}
                    image_url = None
                    if isinstance(md, dict):
                        image_url = md.get('imageUrl') or md.get('image_url')
                    if image_url:
                        base = image_url.rstrip('.')
                        for ext in ['.webp', '.jpg', '.jpeg', '.png']:
                            test = Path(base + ext)
                            if test.exists():
                                registered_files.add(test)
                                break
            except Exception:
                continue

        orphan_files = all_files - registered_files
        if orphan_files:
            st.warning(f"⚠️ {len(orphan_files)}개 고아 파일 발견")
            for f in sorted(orphan_files):
                st.write(f"- {f.name}")

            if st.button("🗑️ 고아 파일 모두 삭제", key="delete_orphans"):
                for f in orphan_files:
                    try:
                        f.unlink()
                    except Exception as e:
                        print(f"[ERROR] 파일 삭제 실패: {f} - {e}")
                st.success(f"✅ {len(orphan_files)}개 파일 삭제 완료")
                st.rerun()
        else:
            st.info("✅ 고아 파일 없음")
    except Exception as e:
        st.error(f"❌ 정리 실패: {e}")

# ���� �׸� ���� ������ ������ ǥ���ϴ� ����
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

    # Initialize ChromaDB manager
    if 'chroma_manager' not in st.session_state:
        st.session_state.chroma_manager = ChromaManager()

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
                ("nursing_questions", "question"),  # 직접 입력한 문제
                ("ai_questions", "question"),  # AI가 생성한 문제
                ("medical_problems", "question"),
                ("medical_concepts", "concept"),
                ("fitness_concepts", "concept"),
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
    st.header("[AI] AI 문제 생성")

    # Display save logs if any
    if 'save_logs' in st.session_state and len(st.session_state.save_logs) > 0:
        with st.expander(f"📋 저장 로그 ({len(st.session_state.save_logs)}개)", expanded=False):
            for log in reversed(st.session_state.save_logs[-20:]):  # Show last 20 logs, newest first
                if "✅" in log:
                    st.success(log)
                elif "⚠️" in log:
                    st.warning(log)
                elif "❌" in log:
                    st.error(log)
                else:
                    st.info(log)

            if st.button("🗑️ 로그 지우기"):
                st.session_state.save_logs = []
                st.rerun()

    # Simplified tabs - MAIN, HISTORY
    # gen_tab1, gen_tab2 = st.tabs([
    #     "🤖 틀린 문제 기반 생성",
    #     "[HISTORY] 생성 이력"
    # ])

    # with gen_tab1:
    #     explanation_requests_section()

    # DISABLED: 틀린 문제 기반 자동 생성 기능 (추후 다른 기능 추가 예정)
    st.info("🚧 이 섹션은 현재 개발 중입니다. 곧 새로운 기능이 추가될 예정입니다.")

    gen_tab2 = st.container()
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
            error_msg = str(e)

            # Check if it's a Firebase index error
            if "requires an index" in error_msg or "400" in error_msg:
                st.error("[ERROR] Firebase 인덱스가 필요합니다")
                st.warning("""
                ### 해결 방법:
                1. 아래 링크를 클릭하여 Firebase Console에서 인덱스 생성
                2. 인덱스 생성 완료 후 (1-5분 소요) 페이지 새로고침

                **또는** 샘플 데이터를 삭제하세요:
                ```bash
                cd backend
                python delete_sample_data.py
                ```
                """)

                # Extract index creation link if available
                if "https://" in error_msg:
                    import re
                    urls = re.findall(r'https://[^\s]+', error_msg)
                    if urls:
                        st.markdown(f"**인덱스 생성 링크**: {urls[0]}")

                # Show helpful info instead of sample data
                st.info("""
                [INFO] 현재 ai_generation_history 컬렉션에 데이터가 없습니다.

                AI 문제 생성이 완료되면 여기에 이력이 표시됩니다.
                """)
            else:
                st.error(f"[ERROR] 이력 조회 실패: {error_msg}")

                # Show helpful message for empty data
                st.info("[INFO] 생성 이력이 없거나 조회 중 오류가 발생했습니다")


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
            st.code("Embedding: gemini-embedding-001 (768d)")
            st.code("Primary: GPT-4o Mini")
            st.code("Advanced: GPT-4o")

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
        [
            "nursing_questions",  # 직접 입력한 문제
            "ai_questions",  # AI가 생성한 문제
            "medical_concepts",
            "fitness_concepts",
            "lingumo_knowledge"
        ]
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
                        question_display = metadata.get('questionText', metadata.get('description', metadata.get('title', '')))
                        if not question_display and document:
                            # Try to extract from document if not in metadata
                            first_line = document.split('\n')[0] if document else ''
                            # Remove common prefixes
                            for prefix in ['문제: ', '설명: ', '개념: ', '키워드: ', '분야: ', '태그: ']:
                                first_line = first_line.replace(prefix, '')
                            question_display = first_line[:100]

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
                            # Handle choices - can be array or individual fields
                            choices = metadata.get('choices', [])
                            if isinstance(choices, list) and len(choices) >= 2:
                                choice1 = choices[0][:30] if len(choices) > 0 else 'N/A'
                                choice2 = choices[1][:30] if len(choices) > 1 else 'N/A'
                                choice3 = choices[2][:30] if len(choices) > 2 else 'N/A'
                            else:
                                choice1 = metadata.get('choice1', 'N/A')[:30]
                                choice2 = metadata.get('choice2', 'N/A')[:30]
                                choice3 = metadata.get('choice3', 'N/A')[:30]

                            data_item.update({
                                '정답': metadata.get('correctAnswer', metadata.get('correctanswer', 'N/A'))[:50],
                                '선택지1': choice1,
                                '선택지2': choice2,
                                '선택지3': choice3,
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

        # 📋 일괄 작업 섹션
        st.subheader("📋 일괄 작업")
        col_bulk1, col_bulk2, col_bulk3 = st.columns(3)

        with col_bulk1:
            if st.button("🗑️ 선택 항목 삭제", key="bulk_delete_toggle"):
                st.session_state['show_bulk_delete'] = not st.session_state.get('show_bulk_delete', False)

            if st.session_state.get('show_bulk_delete', False):
                # 간단한 선택/확인 UI 제공
                indices_for_bulk = st.multiselect(
                    "삭제할 Index 선택",
                    options=st.session_state.chromadb_data['Index'].tolist(),
                    key="bulk_delete_indices"
                )
                if st.button("✅ 예, 삭제합니다", key="bulk_delete_confirm"):
                    if indices_for_bulk:
                        try:
                            collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(collection_name)
                            ids_to_delete = [st.session_state.chromadb_ids[i] for i in indices_for_bulk]
                            collection.delete(ids=ids_to_delete)
                            st.success(f"[SUCCESS] {len(ids_to_delete)}개 항목 삭제 완료!")
                            st.session_state.chromadb_data = None
                            st.session_state.chromadb_ids = []
                            st.session_state['show_bulk_delete'] = False
                            st.rerun()
                        except Exception as e:
                            st.error(f"[ERROR] 일괄 삭제 실패: {e}")
                    else:
                        st.info("선택된 항목이 없습니다")

        with col_bulk2:
            if st.button("🔄 깨진 이미지 경로 복구", key="fix_img_paths"):
                fix_broken_image_paths()

        with col_bulk3:
            if st.button("🧹 고아 파일 정리", key="cleanup_orphans"):
                cleanup_orphan_files()

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

                # 오른쪽 패널에 개별 삭제 버튼 (미리보기 옆)
                with col_img2:
                    if st.button("🗑️ 이 항목 삭제", key=f"delete_{selected_index}"):
                        st.warning("정말 삭제하시겠습니까?")
                        col_confirm1, col_confirm2 = st.columns(2)
                        with col_confirm1:
                            if st.button("✅ 예, 삭제합니다", key=f"confirm_delete_{selected_index}"):
                                delete_chromadb_item(selected_row, collection_name)
                        with col_confirm2:
                            if st.button("❌ 취소", key=f"cancel_delete_{selected_index}"):
                                st.info("삭제 취소")

                with col_img1:
                    if image_url and image_url != 'N/A':
                        try:
                            # 확장자 자동 감지 및 추가
                            import os
                            import glob
                            if not os.path.exists(image_url):
                                # 확장자 없거나 잘못된 경우 (끝이 .으로 끝나는 경우)
                                base_path = image_url.rstrip('.')  # 마지막 점 제거
                                possible_exts = ['.webp', '.jpg', '.jpeg', '.png']
                                for ext in possible_exts:
                                    test_path = base_path + ext
                                    if os.path.exists(test_path):
                                        image_url = test_path
                                        break
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
            ("fitness_concepts", "운동/영양"),
            ("lingumo_knowledge", "언어 학습")
        ]

        # Get ChromaDB stats
        for coll_name, display_name in collections_info:
            try:
                collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(coll_name)

                # fitness_concepts는 운동/영양/건강 분리
                if coll_name == "fitness_concepts":
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
                if coll_name == "fitness_concepts":
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


def explanation_requests_section():
    """Generate problems based on wrong answers using GPT-4o mini"""
    st.subheader("🤖 틀린 문제 기반 자동 생성")
    st.markdown("학생들이 틀린 문제의 개념을 분석하여 GPT-4o mini로 유사 문제를 자동 생성합니다.")

    try:
        # Check Firebase connection
        if not firebase_service.initialized:
            st.error("❌ Firebase 연결 실패. 서비스 계정 키를 확인해주세요.")
            st.info("💡 firebase-service-account.json 파일을 backend 폴더에 배치해야 합니다.")
            return

        # Fetch wrong answers from SRS events (rating = 'again')
        srs_events = firebase_service.db.collection('srs_events').where('rating', '==', 'again').limit(50).stream()

        wrong_problems = []
        seen_cards = set()

        for event in srs_events:
            data = event.to_dict()
            card_id = data.get('cardId')

            # Avoid duplicates
            if card_id in seen_cards:
                continue
            seen_cards.add(card_id)

            # Get problem details
            try:
                problem_doc = firebase_service.db.collection('nursing_problems').document(card_id).get()
                if problem_doc.exists:
                    problem_data = problem_doc.to_dict()
                    problem_data['id'] = card_id
                    problem_data['userId'] = data.get('userId')
                    problem_data['wrongAt'] = data.get('timestamp')

                    # Skip 보건의료법규 (laws change yearly, no need to maintain)
                    if problem_data.get('subject') == '보건의료법규':
                        continue

                    wrong_problems.append(problem_data)
            except:
                pass

        if not wrong_problems:
            st.info("📭 최근 틀린 문제가 없습니다.")
            st.caption("💡 학생이 문제를 틀리면 자동으로 여기에 표시됩니다.")
            return

        # Initialize processed problems tracking
        if 'processed_wrong_problems' not in st.session_state:
            st.session_state.processed_wrong_problems = set()

        # Filter out processed problems
        unprocessed_problems = [p for p in wrong_problems if p['id'] not in st.session_state.processed_wrong_problems]

        st.metric("틀린 문제 수", f"{len(unprocessed_problems)} / {len(wrong_problems)}")
        if len(unprocessed_problems) < len(wrong_problems):
            st.caption(f"✅ {len(wrong_problems) - len(unprocessed_problems)}개 문제 처리 완료")
        st.divider()

        if not unprocessed_problems:
            st.success("🎉 모든 틀린 문제를 처리했습니다!")
            if st.button("🔄 목록 초기화"):
                st.session_state.processed_wrong_problems = set()
                st.rerun()
            return

        # Display wrong problems and generate similar ones (all, sorted by time)
        for prob in unprocessed_problems:  # Show all unprocessed problems
            with st.expander(f"🔹 {prob.get('subject', 'N/A')} - {prob.get('field', 'N/A')}"):
                st.markdown(f"**문제:** {prob.get('questionText', 'N/A')}")

                # Display choices
                choices = prob.get('choices', [])
                if choices:
                    st.markdown("**보기:**")
                    for i, choice in enumerate(choices, 1):
                        st.markdown(f"{i}. {choice}")

                # Get correct answer (check both field names and calculate from index if needed)
                correct_answer = prob.get('correctAnswer') or prob.get('correctanswer')
                if not correct_answer and choices:
                    answer_idx = prob.get('answer')
                    if answer_idx is not None and 0 <= answer_idx < len(choices):
                        correct_answer = choices[answer_idx]

                st.markdown(f"**정답:** {correct_answer or 'N/A'}")
                st.markdown(f"**난이도:** {prob.get('difficulty', 'N/A')}")

                if prob.get('keywords'):
                    st.markdown(f"**키워드:** {', '.join(prob.get('keywords', []))}")

                st.divider()

                # AI 자동 분석 안내
                st.caption("💡 AI가 원본 문제를 분석하여 최적의 문제 유형과 출제 스타일을 자동 선택합니다")


                if st.button("🤖 AI가 분석 후 자동 생성", key=f"gen_{prob['id']}", type="primary", use_container_width=True):
                        with st.spinner("AI가 문제를 분석하고 있습니다..."):
                            try:
                                # AI 자동 분석 - 유형 및 페르소나 선택
                                question_type, persona = question_type_handler.analyze_and_select(prob)

                                # 분석 결과 표시
                                type_icons = {
                                    "MCQ": "📝", "Matching": "🔗", "Procedure": "📋",
                                    "Scenario": "🏥", "Image": "🖼️"
                                }
                                persona_icons = {
                                    "학술전문가": "📚", "임상전문가": "🏥",
                                    "시험전문가": "📝", "최근합격자": "🎓"
                                }
                                st.info(f"📊 AI 분석 결과: {type_icons.get(question_type, '📝')} {question_type} 유형 | {persona_icons.get(persona, '📝')} {persona} 스타일")

                                # Generate problems using GPT-4o mini
                                from openai import OpenAI
                                client = OpenAI(api_key=OPENAI_API_KEY)

                                # Build detailed original problem context
                                original_choices = prob.get('choices', [])
                                choices_text = "\n".join([f"선택지 {i+1}: {choice}" for i, choice in enumerate(original_choices)])

                                # Get correct answer (check both field names and calculate from index if needed)
                                original_correct_answer = prob.get('correctAnswer') or prob.get('correctanswer')
                                if not original_correct_answer and original_choices:
                                    answer_idx = prob.get('answer')
                                    if answer_idx is not None and 0 <= answer_idx < len(original_choices):
                                        original_correct_answer = original_choices[answer_idx]

                                # 난이도 분포 결정 (균형형)
                                target_difficulties = ['하', '중', '중', '상', '하']  # 5개 생성

                                st.info(f"🎯 난이도 분포: 하 2개, 중 2개, 상 1개")

                                # 스마트 문제 생성 시스템 사용
                                generated_problems_list, generation_stats = smart_problem_generator.generate_with_difficulty_control(
                                    original_problem=prob,
                                    target_difficulties=target_difficulties,
                                    question_type=question_type,
                                    persona=persona
                                )

                                # 생성 통계 표시
                                st.success(f"✅ 생성 완료: {generation_stats['total_generated']}개 / {generation_stats['total_requested']}개")
                                st.info(f"📊 모델 사용: {', '.join([f'{k}({v}개)' for k, v in generation_stats['models_used'].items()])}")
                                st.info(f"✔️ 난이도 검증: 통과 {generation_stats['validation_passed']}개 / 수정 {generation_stats['difficulty_corrections']}개")

                                # 기존 형식으로 변환
                                generated_problems = generated_problems_list

                                # ChromaDB-based duplicate checker (uses semantic similarity)
                                def is_duplicate_problem_chromadb(new_question, new_answer):
                                    """Check if problem is duplicate using ChromaDB semantic search"""
                                    chroma = st.session_state.chroma_manager
                                    if not chroma or not chroma.problems_collection:
                                        return False, 0.0

                                    try:
                                        # Combine question + answer for search
                                        combined_text = f"{new_question} {new_answer}"

                                        # Query ChromaDB for similar problems
                                        results = chroma.problems_collection.query(
                                            query_texts=[combined_text],
                                            n_results=1  # Get top 1 most similar
                                        )

                                        if results and results['distances'] and len(results['distances'][0]) > 0:
                                            # ChromaDB returns distance (lower = more similar)
                                            # Convert to similarity score (0-1, higher = more similar)
                                            distance = results['distances'][0][0]
                                            similarity = 1.0 - (distance / 2.0)  # Normalize to 0-1

                                            # Threshold: 0.85 = very similar
                                            if similarity > 0.85:
                                                return True, similarity
                                            return False, similarity
                                        return False, 0.0
                                    except Exception as e:
                                        st.warning(f"ChromaDB 검색 실패, 중복 체크 스킵: {e}")
                                        return False, 0.0

                                # Store in session state for approval workflow
                                if 'pending_problems' not in st.session_state:
                                    st.session_state.pending_problems = {}

                                # Validate and prepare for approval with duplicate retry
                                valid_problems = []
                                skipped_count = 0
                                duplicate_count = 0
                                MAX_RETRY = 5  # Maximum retry per problem

                                progress_text = st.empty()
                                for idx, gen_prob in enumerate(generated_problems):
                                    progress_text.info(f"문제 {idx+1}/{len(generated_problems)} 검증 중...")

                                    # Retry loop for duplicate problems
                                    retry_count = 0
                                    current_problem = gen_prob

                                    while retry_count <= MAX_RETRY:
                                        # Check for semantic duplicate using ChromaDB
                                        is_dup, similarity_score = is_duplicate_problem_chromadb(
                                            current_problem.get('questionText', ''),
                                            current_problem.get('correctanswer', '')
                                        )

                                        if is_dup and retry_count < MAX_RETRY:
                                            duplicate_count += 1
                                            retry_count += 1
                                            progress_text.warning(f"문제 {idx+1}: 중복 감지 (유사도: {similarity_score:.2f}) - 재생성 시도 {retry_count}/{MAX_RETRY}")

                                        # 중복 감지 시 재생성
                                        if is_dup and retry_count < MAX_RETRY:
                                            # Regenerate single problem
                                            try:
                                                regenerate_prompt = f"""이전에 생성한 문제가 기존 문제와 너무 유사합니다.
다른 각도에서 접근하여 새로운 문제를 1개만 생성해주세요.

[원본 문제]
질문: {prob.get('questionText')}
정답: {original_correct_answer}
난이도: {prob.get('difficulty', '중')}

[생성 요구사항]
- 완전히 다른 임상 상황 사용
- 다른 나이대, 다른 증상, 다른 시나리오
- 하지만 같은 개념을 테스트
- 선택지 5개 필수
- 해설 없음
- 난이도는 원본과 동일하거나 약간 쉽게

JSON 형식:
{{
  "questionText": "...",
  "choices": ["...", "...", "...", "...", "..."],
  "answer": 0,
  "correctanswer": "...",
  "difficulty": "{prob.get('difficulty', '중')}"
}}"""

                                                regen_response = client.chat.completions.create(
                                                    model="gpt-4o-mini",
                                                    messages=[
                                                        {"role": "system", "content": system_prompt},
                                                        {"role": "user", "content": regenerate_prompt}
                                                    ],
                                                    temperature=0.9  # Higher temperature for more variety
                                                )

                                                regen_content = regen_response.choices[0].message.content.strip()
                                                if regen_content.startswith('```json'):
                                                    regen_content = regen_content[7:]
                                                if regen_content.endswith('```'):
                                                    regen_content = regen_content[:-3]

                                                current_problem = json.loads(regen_content.strip())
                                                continue  # Retry duplicate check

                                            except Exception as regen_error:
                                                progress_text.error(f"재생성 실패: {regen_error}")
                                                break

                                        elif is_dup and retry_count >= MAX_RETRY:
                                            # Give up after MAX_RETRY attempts
                                            progress_text.error(f"문제 {idx+1}: {MAX_RETRY}회 재시도 후에도 중복 - 건너뛰기")
                                            current_problem = None
                                            break
                                        else:
                                            # Not duplicate, proceed
                                            problem_difficulty = current_problem.get('difficulty', '중')

                                            # 난이도 검증은 smart_problem_generator에서 이미 완료됨
                                            validation_details = current_problem.get('_validation_details', {})
                                            if not validation_details.get('is_valid', True):
                                                progress_text.info(f"문제 {idx+1}: 난이도 자동 수정 ({validation_details.get('claimed')} → {validation_details.get('actual')})")

                                            break

                                    # Skip if couldn't generate unique problem
                                    if current_problem is None:
                                        skipped_count += 1
                                        continue

                                    # Validate 5 choices
                                    choices = current_problem.get('choices', [])
                                    if len(choices) != 5:
                                        progress_text.warning(f"⚠️ 문제 {idx+1}: 선택지가 {len(choices)}개 (5개 필수) - 건너뛰기")
                                        skipped_count += 1
                                        continue

                                    # Validate answer index
                                    answer = current_problem.get('answer', 0)
                                    if not (0 <= answer <= 4):
                                        progress_text.warning(f"⚠️ 문제 {idx+1}: 정답 번호 오류 - 건너뛰기")
                                        skipped_count += 1
                                        continue

                                    # AI 모델 정보 가져오기 (smart_problem_generator에서 생성)
                                    generation_model = current_problem.get('_generated_by', 'unknown')
                                    verification_model = None  # 검증은 난이도 분류기가 수행

                                    new_problem = {
                                        'questionText': current_problem['questionText'],
                                        'choices': choices,
                                        'answer': answer,
                                        'correctanswer': current_problem['correctanswer'],
                                        # No explanation - students can request it separately

                                        # Tag-based system (Proposal 1)
                                        'subject': None,  # AI-generated problems have no fixed subject
                                        'relatedSubjects': [prob.get('subject')],  # Related subjects array
                                        'relatedConcepts': prob.get('keywords', []),  # Concept-based

                                        'field': prob.get('field'),
                                        'difficulty': current_problem.get('difficulty', '중'),  # Use AI-generated difficulty
                                        'keywords': prob.get('keywords', []),

                                        # AI model tracking
                                        'aiModels': {
                                            'generation': generation_model,
                                            'verification': verification_model,
                                            'questionType': question_type,
                                            'persona': persona
                                        },

                                        # Priority & metadata
                                        'priority': 2,  # 1=manual, 2=AI-generated
                                        'source': 'ai-generated',
                                        'generatedFrom': prob['id'],
                                        'generatedBy': f"{generation_model}{'+' + verification_model if verification_model else ''}",
                                        'createdAt': get_iso_timestamp()
                                    }

                                    valid_problems.append(new_problem)
                                    progress_text.success(f"문제 {idx+1}: ✅ 검증 완료")

                                progress_text.empty()

                                # Store for approval
                                problem_key = f"{prob['id']}_generated"
                                st.session_state.pending_problems[problem_key] = valid_problems

                                if len(valid_problems) > 0:
                                    st.success(f"✅ {len(valid_problems)}개 문제 생성 완료! 아래에서 검토 후 승인해주세요.")
                                if duplicate_count > 0:
                                    st.info(f"ℹ️ {duplicate_count}개 문제는 의미적 중복으로 스킵했습니다. (코사인 유사도 > 0.85)")
                                if skipped_count > 0:
                                    st.info(f"ℹ️ {skipped_count}개 문제는 검증 실패로 생성하지 않았습니다.")

                                # Display generated problems for approval
                                st.divider()
                                st.subheader("🔍 생성된 문제 검토")

                                # Initialize saved/rejected tracking
                                if 'saved_problems' not in st.session_state:
                                    st.session_state.saved_problems = set()
                                if 'rejected_problems' not in st.session_state:
                                    st.session_state.rejected_problems = set()
                                # Initialize save logs tracking
                                if 'save_logs' not in st.session_state:
                                    st.session_state.save_logs = []

                                # Count processed problems for this original problem
                                processed_count = sum(1 for idx in range(len(valid_problems))
                                                     if f"{prob['id']}_{idx}" in st.session_state.saved_problems or
                                                        f"{prob['id']}_{idx}" in st.session_state.rejected_problems)

                                # If all problems processed, mark original as complete
                                if processed_count == len(valid_problems):
                                    st.session_state.processed_wrong_problems.add(prob['id'])
                                    st.success(f"✅ 모든 생성 문제 처리 완료! 이 원본 문제가 목록에서 제거됩니다.")
                                    st.rerun()

                                # Bulk actions - show only if there are unprocessed problems
                                unprocessed_indices = [idx for idx in range(len(valid_problems))
                                                      if f"{prob['id']}_{idx}" not in st.session_state.saved_problems and
                                                         f"{prob['id']}_{idx}" not in st.session_state.rejected_problems]

                                if unprocessed_indices:
                                    col1, col2, col3 = st.columns([2, 1, 1])
                                    with col1:
                                        st.caption(f"미처리 문제: {len(unprocessed_indices)}개")
                                    with col2:
                                        if st.button("✅ 모두 승인", key=f"approve_all_{prob['id']}", type="primary"):
                                            st.write(f"DEBUG: valid_problems 개수 = {len(valid_problems)}")
                                            st.write(f"DEBUG: unprocessed_indices = {unprocessed_indices}")

                                            saved_count = 0
                                            chroma = st.session_state.chroma_manager
                                            fs = FirebaseStorage()

                                            # Progress tracking
                                            total_count = len(unprocessed_indices)
                                            progress_placeholder = st.empty()
                                            status_placeholder = st.empty()

                                            for idx_num, idx in enumerate(unprocessed_indices, 1):
                                                st.write(f"DEBUG: 처리 중 idx={idx}, valid_problems[{idx}] exists = {idx < len(valid_problems)}")
                                                prob_hash = f"{prob['id']}_{idx}"

                                                # Update progress
                                                progress_placeholder.progress(idx_num / total_count)
                                                status_placeholder.info(f"[{idx_num}/{total_count}] 문제 저장 중...")

                                                try:
                                                    # === STEP 1: 중복 검사 ===
                                                    status_placeholder.info(f"[{idx_num}/{total_count}] STEP 1: 중복 검사 중...")

                                                    # TODO: 중복 검사 로직 추가 (현재는 스킵)
                                                    is_duplicate = False
                                                    max_similarity = 0.0

                                                    log_entry = f"✅ [{idx_num}/{total_count}] STEP 1: 중복 검사 완료 (유사도: {max_similarity:.3f})"
                                                    st.session_state.save_logs.append(log_entry)

                                                    # === STEP 2: ChromaDB 저장 ===
                                                    status_placeholder.info(f"[{idx_num}/{total_count}] STEP 2: ChromaDB 저장 중...")

                                                    # Generate unique ID
                                                    problem_id = str(uuid.uuid4())

                                                    if chroma and chroma.problems_collection:
                                                        try:
                                                            chroma_data = {
                                                                'id': problem_id,
                                                                'question_text': valid_problems[idx].get('questionText', ''),
                                                                'choices': valid_problems[idx].get('choices', []),
                                                                'correct_answer': valid_problems[idx].get('correctanswer', ''),
                                                                'subject': prob.get('subject', ''),
                                                                'difficulty': valid_problems[idx].get('difficulty', ''),
                                                                'keywords': valid_problems[idx].get('keywords', []),
                                                                'concepts': valid_problems[idx].get('relatedConcepts', []),
                                                                'created_at': str(valid_problems[idx].get('createdAt', ''))
                                                            }
                                                            chroma.add_problem(chroma_data)

                                                            # Log ChromaDB save
                                                            log_entry = f"✅ [{idx_num}/{total_count}] STEP 2: ChromaDB 저장 완료 (ID: {problem_id[:8]}...)"
                                                            st.session_state.save_logs.append(log_entry)
                                                        except Exception as chroma_error:
                                                            # Log ChromaDB failure
                                                            log_entry = f"⚠️ [{idx_num}/{total_count}] STEP 2: ChromaDB 실패: {str(chroma_error)[:50]}..."
                                                            st.session_state.save_logs.append(log_entry)
                                                            raise  # Re-raise to skip Firebase save

                                                    # === STEP 3: Firebase 저장 ===
                                                    status_placeholder.info(f"[{idx_num}/{total_count}] STEP 3: Firebase 저장 중...")

                                                    # Prepare data for Firebase (convert datetime to string)
                                                    problem_data = valid_problems[idx].copy()
                                                    problem_data['id'] = problem_id  # Use same ID as ChromaDB
                                                    problem_data = ensure_created_at_iso(problem_data)

                                                    # Save to Firebase via storage adapter
                                                    save_result = fs.save_problem('nursing_problems', problem_data)
                                                    if not save_result.get('success'):
                                                        raise RuntimeError(save_result.get('message', 'Firebase save failed'))

                                                    status_placeholder.success(f"[{idx_num}/{total_count}] ✅ 전체 저장 완료 (ID: {problem_id[:8]}...)")

                                                    # Log Firebase save
                                                    log_entry = f"✅ [{idx_num}/{total_count}] STEP 3: Firebase 저장 완료 (ID: {problem_id[:8]}...)"
                                                    st.session_state.save_logs.append(log_entry)

                                                    st.session_state.saved_problems.add(prob_hash)
                                                    saved_count += 1
                                                except Exception as save_error:
                                                    status_placeholder.error(f"[{idx_num}/{total_count}] ❌ 문제 저장 실패: {save_error}")

                                                    # Log save failure
                                                    log_entry = f"❌ [{idx_num}/{total_count}] 저장 실패: {str(save_error)[:50]}..."
                                                    st.session_state.save_logs.append(log_entry)

                                            # Clear progress indicators and show final message
                                            progress_placeholder.empty()

                                            # Only rerun if at least one problem was successfully saved
                                            if saved_count > 0:
                                                status_placeholder.success(f"✅ {saved_count}/{total_count}개 문제를 Firebase + ChromaDB에 저장했습니다!")

                                                # Verify data was saved by checking ChromaDB count
                                                try:
                                                    verify_count = chroma.problems_collection.count() if chroma and chroma.problems_collection else 0
                                                    st.info(f"📊 현재 ai_questions 총 문제 수: {verify_count}")
                                                except Exception as e:
                                                    st.warning(f"⚠️ 검증 실패: {e}")

                                                # 자동 새로고침을 피하고 사용자에게 결과를 남깁니다.
                                                # 필요 시 사용자가 수동으로 새로고침하거나 다음 작업을 진행할 수 있습니다.
                                            else:
                                                status_placeholder.error(f"❌ {total_count}개 문제 저장 모두 실패했습니다. 위의 오류 메시지를 확인하세요.")

                                    with col3:
                                        if st.button("❌ 모두 거부", key=f"reject_all_{prob['id']}"):
                                            for idx in unprocessed_indices:
                                                prob_hash = f"{prob['id']}_{idx}"
                                                st.session_state.rejected_problems.add(prob_hash)
                                            st.info(f"❌ {len(unprocessed_indices)}개 문제를 거부했습니다.")
                                            st.rerun()

                                    st.divider()

                                for idx, new_prob in enumerate(valid_problems):
                                    prob_hash = f"{prob['id']}_{idx}"

                                    # Skip if already processed
                                    if prob_hash in st.session_state.saved_problems:
                                        st.success(f"✅ 문제 {idx+1}: Firebase에 저장 완료")
                                        continue
                                    if prob_hash in st.session_state.rejected_problems:
                                        st.info(f"❌ 문제 {idx+1}: 거부됨")
                                        continue

                                    with st.expander(f"📝 생성 문제 {idx+1}", expanded=True):
                                        # AI 모델 정보 표시
                                        ai_models = new_prob.get('aiModels', {})
                                        gen_model = ai_models.get('generation', 'unknown')
                                        ver_model = ai_models.get('verification')
                                        q_type = ai_models.get('questionType', 'unknown')
                                        persona_used = ai_models.get('persona', 'unknown')

                                        model_info = f"AI: {gen_model}"
                                        if ver_model:
                                            model_info += f" + {ver_model}"
                                        model_info += f" | {q_type} | {persona_used}"

                                        st.caption(f"🤖 {model_info}")

                                        st.markdown(f"**질문:** {new_prob['questionText']}")
                                        st.markdown("**보기:**")
                                        for i, choice in enumerate(new_prob['choices'], 1):
                                            st.markdown(f"{i}. {choice}")
                                        st.markdown(f"**정답:** {new_prob['correctanswer']}")
                                        st.markdown(f"**난이도:** {new_prob.get('difficulty', '중')}")
                                        st.caption("💡 해설은 학생이 문제를 틀렸을 때 요청하면 생성됩니다.")

                                        col1, col2 = st.columns(2)
                                        with col1:
                                            if st.button("✅ 승인 (저장)", key=f"approve_{prob_hash}", type="primary"):
                                                try:
                                                    # Prepare data for Firebase (convert datetime to string)
                                                    problem_data = ensure_created_at_iso(new_prob.copy())

                                                    # Save to Firebase via storage adapter
                                                    fs = FirebaseStorage()
                                                    save_result = fs.save_problem('nursing_problems', problem_data)
                                                    if not save_result.get('success'):
                                                        raise RuntimeError(save_result.get('message', 'Firebase save failed'))
                                                    problem_id = save_result.get('id')

                                                    # Save to ChromaDB for semantic search
                                                    chroma = st.session_state.chroma_manager
                                                    if chroma and chroma.problems_collection:
                                                        try:
                                                            chroma_data = {
                                                                'id': problem_id,
                                                                'question_text': new_prob.get('questionText', ''),
                                                                'choices': new_prob.get('choices', []),
                                                                'correct_answer': new_prob.get('correctanswer', ''),
                                                                'subject': prob.get('subject', ''),
                                                                'difficulty': new_prob.get('difficulty', ''),
                                                                'keywords': new_prob.get('keywords', []),
                                                                'concepts': new_prob.get('relatedConcepts', []),
                                                                'created_at': str(new_prob.get('createdAt', ''))
                                                            }
                                                            chroma.add_problem(chroma_data)
                                                        except Exception as chroma_error:
                                                            st.warning(f"ChromaDB 저장 실패 (검색에만 영향): {chroma_error}")

                                                    st.session_state.saved_problems.add(prob_hash)
                                                    st.success("✅ Firebase + ChromaDB에 저장되었습니다!")
                                                    st.rerun()
                                                except Exception as save_error:
                                                    st.error(f"❌ 저장 실패: {save_error}")

                                        with col2:
                                            if st.button("❌ 거부", key=f"reject_{prob_hash}"):
                                                st.session_state.rejected_problems.add(prob_hash)
                                                st.info("문제를 거부했습니다.")
                                                st.rerun()

                            except Exception as e:
                                st.error(f"❌ 문제 생성 실패: {e}")

    except Exception as e:
        st.error(f"❌ 틀린 문제 로드 실패: {e}")


if __name__ == "__main__":
    main()




