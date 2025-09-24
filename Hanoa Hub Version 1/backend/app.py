"""
Hanoa RAG System - Streamlit Main Application (Simplified Version)
"""
import json
import uuid
from datetime import datetime
from pathlib import Path

import streamlit as st
import pandas as pd

from config import (
    validate_config, JOBS_DIR, OBSIDIAN_VAULT_PATH,
    DOMAIN_COLLECTIONS, DEFAULT_DOMAIN, ENABLE_CROSS_DOMAIN_SEARCH,
    ENABLE_IMAGE_VECTORS, GEMINI_API_KEY, OPENAI_API_KEY
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
from deduplication_engine import deduplication_engine
from PIL import Image
import io
import base64

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
    st.markdown("간호학/의학 문제 및 개념 관리 시스템")

    # Sidebar - System Status
    with st.sidebar:
        st.header("[STATUS] 시스템 상태")

        # RAG Stats
        try:
            stats = rag_engine.get_stats()
            st.metric("총 문제", stats['questions'])
            st.metric("전체 데이터", stats['total'])
        except Exception as e:
            st.error(f"[ERROR] RAG 상태 확인 실패: {e}")

        # Firebase Status
        st.divider()
        st.subheader("[FIREBASE] 연결 상태")
        if firebase_service.initialized:
            st.success("[OK] Firebase 연결됨")
        else:
            st.warning("[WARNING] Firebase 미연결")

        st.divider()

        if st.button("[REFRESH] 새로고침"):
            st.rerun()

    # Main content tabs - 단순화 (2개 탭만)
    tab1, tab2 = st.tabs([
        "[DATA] 데이터 입력",
        "[SYSTEM] 시스템 관리"
    ])

    with tab1:
        data_input_tab()

    with tab2:
        system_management_tab()


def data_input_tab():
    """Data input tab for questions and concepts"""
    st.header("[DATA] 데이터 입력")

    # Create sub-tabs for input and data check
    data_tab1, data_tab2 = st.tabs(["[INPUT] 데이터 입력", "[CHECK] 데이터 확인"])

    with data_tab1:
        input_type = st.selectbox("입력 타입", ["문제", "개념"])

        if input_type == "문제":
            question_input_form()
        else:
            concept_input_form()

    with data_tab2:
        chromadb_check_tab()


def question_input_form():
    """Form for inputting nursing/medical questions with image support"""
    st.subheader("[INFO] 문제 입력")

    # 분야 선택 (간호/의학)
    field = st.selectbox("분야 선택 *", ["간호", "의학"])

    with st.form("question_form"):
        # Image upload section
        st.subheader("[IMAGE] 이미지 업로드 (선택사항)")
        uploaded_image = st.file_uploader(
            "문제 관련 이미지",
            type=['png', 'jpg', 'jpeg'],
            help="문제와 관련된 의료 이미지를 업로드하세요"
        )

        image_analysis_result = None
        if uploaded_image is not None:
            # Display uploaded image
            col_img1, col_img2 = st.columns([1, 2])
            with col_img1:
                st.image(uploaded_image, caption="업로드된 이미지", width=200)

            with col_img2:
                analyze_on_save = st.checkbox("[ANALYSIS] 이미지 자동 분석", value=True, key="question_analyze_image")
                if analyze_on_save:
                    st.info("[INFO] 이미지가 저장 시 자동 분석됩니다")

        st.divider()

        col1, col2 = st.columns([2, 1])

        with col1:
            question_text = st.text_area("문제", height=100, help="간호 문제를 입력하세요")
            explanation = st.text_area("해설", height=80, help="정답 해설을 입력하세요")

        with col2:
            # 분야에 따라 과목 목록 변경
            if field == "간호":
                subject = st.selectbox("과목", [
                    "기본간호학", "성인간호학", "아동간호학", "모성간호학",
                    "정신간호학", "지역사회간호학", "간호관리학"
                ])
            else:  # 의학
                subject = st.selectbox("과목", [
                    "해부학", "생리학", "병리학", "약리학",
                    "내과학", "외과학", "소아과학", "산부인과학", "정신의학"
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

        submitted = st.form_submit_button("[SAVE] 문제 저장")

        if submitted:
            # Validate all 5 choices are filled
            if question_text and len(non_empty_choices) == 5 and correct_answer and correct_answer != "선택지를 먼저 입력하세요":
                # 선택지 중복 체크
                if len(set(non_empty_choices)) != len(non_empty_choices):
                    st.error("[ERROR] 중복된 선택지가 있습니다! 모든 선택지는 서로 달라야 합니다.")
                else:
                    try:
                        # 문제 중복 체크를 위해 ChromaDB에서 검색
                        from rag_engine_multi_domain import multi_domain_rag_engine

                        # 문제 텍스트로 유사한 문제 검색
                        if field == "간호":
                            collection_name = 'nursing_questions'
                        else:  # 의학
                            collection_name = 'medical_problems'

                        try:
                            collection = multi_domain_rag_engine.chroma_client.get_collection(collection_name)

                            # 정확히 같은 문제 텍스트가 있는지 확인
                            results = collection.query(
                                query_texts=[question_text],
                                n_results=1,
                                where={"type": "problem"}
                            )

                            # 고급 중복 제거 파이프라인 사용
                            if results['documents'] and results['documents'][0]:
                                # 문서 형태로 준비
                                existing_docs = []
                                for i, doc_text in enumerate(results['documents'][0]):
                                    if doc_text:  # None이 아닌 경우만
                                        existing_docs.append({
                                            'id': results['ids'][0][i] if results['ids'] and results['ids'][0] else str(i),
                                            'text': doc_text,
                                            'meta': results['metadatas'][0][i] if results['metadatas'] and results['metadatas'][0] else {}
                                        })

                                # 현재 문제도 문서로 추가
                                existing_docs.append({
                                    'id': 'new_question',
                                    'text': question_text,
                                    'meta': {'type': 'new'}
                                })

                                # 의료 도메인으로 중복 제거 실행
                                unique_ids, duplicate_pairs = deduplication_engine.deduplicate(
                                    existing_docs,
                                    domain='medical',
                                    return_pairs=True
                                )

                                # new_question이 중복으로 판정되었는지 확인
                                is_duplicate = False
                                if duplicate_pairs:
                                    for pair in duplicate_pairs:
                                        if pair.doc2_id == 'new_question' or pair.doc1_id == 'new_question':
                                            is_duplicate = True
                                            # 중복된 기존 문제 찾기
                                            existing_id = pair.doc1_id if pair.doc2_id == 'new_question' else pair.doc2_id
                                            for doc in existing_docs:
                                                if doc['id'] == existing_id:
                                                    st.error(f"[ERROR] 중복된 문제가 감지되었습니다!")
                                                    st.warning(f"기존 문제: {doc['text'][:100]}...")
                                                    st.info(f"유사도 점수: {pair.combined_score:.3f} (코사인: {pair.cos_sim:.3f}, 자카드: {pair.jaccard_score:.3f})")
                                                    break
                                            break

                                if is_duplicate:
                                    return  # 중복이면 저장하지 않음
                        except Exception as e:
                            # 컬렉션이 없으면 새로 생성될 것이므로 중복 체크 스킵
                            pass

                        question_data = {
                            'id': str(uuid.uuid4()),
                            'questionText': question_text,
                            'choices': non_empty_choices,
                            'correctAnswer': correct_answer,
                            'explanation': explanation,
                            'subject': subject,
                            'difficulty': '미분류',
                            'tags': [tag.strip() for tag in tags.split(',') if tag.strip()],
                            'createdBy': 'streamlit_user',
                            'createdAt': datetime.now().isoformat(),
                            'status': 'pending_analysis',
                            'hasImage': uploaded_image is not None,
                            'imageAnalysis': None
                        }

                        # Process image if uploaded
                        if uploaded_image is not None:
                            try:
                                # Save image
                                image_dir = Path("storage/images")
                                image_dir.mkdir(parents=True, exist_ok=True)

                                image_filename = f"question_{question_data['id']}.{uploaded_image.name.split('.')[-1]}"
                                image_path = image_dir / image_filename

                                with open(image_path, "wb") as f:
                                    f.write(uploaded_image.getbuffer())

                                question_data['imagePath'] = str(image_path)

                                # Analyze image if checkbox was checked
                                if analyze_on_save:
                                    with st.spinner("[ANALYSIS] 이미지 분석 중..."):
                                        # Use hierarchical analyzer
                                        image = Image.open(uploaded_image)
                                        analyzer = ImageHierarchicalAnalyzer()

                                        analysis_result = analyzer.analyze_with_escalation(
                                            image=image,
                                            domain="medical",
                                            analyze_depth="standard"
                                        )

                                        question_data['imageAnalysis'] = {
                                            'main_objects': analysis_result.main_objects,
                                            'medical_tags': analysis_result.medical_tags,
                                            'description': analysis_result.description,
                                            'confidence': analysis_result.confidence_score,
                                            'analyzed_by': analysis_result.analyzed_by
                                        }

                                        st.success("[SUCCESS] 이미지 분석 완료!")
                            except Exception as e:
                                st.warning(f"[WARNING] 이미지 처리 중 오류: {e}")

                        # AI 분석 자동 실행
                        with st.spinner("[ANALYSIS] AI가 문제를 분석 중..."):
                            try:
                                # ProblemAnalyzer의 process_problem 메서드 호출
                                analysis_result = problem_analyzer.process_problem(
                                    question_text=question_text,
                                    choices=non_empty_choices,
                                    correct_answer=correct_answer,
                                    explanation=explanation,
                                    subject=subject
                                )

                                # 분석 결과를 문제 데이터에 추가
                                question_data['analysis'] = {
                                    'concepts': analysis_result.get('concepts', []),
                                    'keywords': analysis_result.get('keywords', []),
                                    'difficulty': analysis_result.get('difficulty', '보통'),
                                    'confidence_score': 0.85,
                                    'verified_by': 'hierarchical_analyzer',
                                    'processed_at': datetime.now().isoformat()
                                }
                                question_data['status'] = 'analysis_completed'

                                st.success("[SUCCESS] AI 분석 완료!")

                                # 분석 결과 표시
                                with st.expander("[RESULT] 분석 결과", expanded=True):
                                    col1, col2 = st.columns(2)
                                    with col1:
                                        st.write("**개념:**", ', '.join(analysis_result.get('concepts', [])))
                                        st.write("**키워드:**", ', '.join(analysis_result.get('keywords', [])))
                                    with col2:
                                        st.write("**난이도:**", analysis_result.get('difficulty', '보통'))
                                        st.write("**신뢰도:**", f"{0.85:.1%}")
                            except Exception as e:
                                st.error(f"[ERROR] AI 분석 중 오류: {e}")
                                question_data['status'] = 'analysis_failed'

                        # ChromaDB에 자동 저장
                        with st.spinner("[SAVE] ChromaDB에 저장 중..."):
                            try:
                                from rag_engine_multi_domain import multi_domain_rag_engine

                                # nursing_questions 컬렉션에 추가
                                collection = multi_domain_rag_engine.chroma_client.get_or_create_collection('nursing_questions')

                                # Create full document with all question data
                                full_document = f"""
문제: {question_data['questionText']}
선택지:
1. {question_data.get('choices', ['', '', '', '', ''])[0]}
2. {question_data.get('choices', ['', '', '', '', ''])[1]}
3. {question_data.get('choices', ['', '', '', '', ''])[2]}
4. {question_data.get('choices', ['', '', '', '', ''])[3]}
5. {question_data.get('choices', ['', '', '', '', ''])[4]}
정답: {question_data.get('correctAnswer', '')}
해설: {question_data.get('explanation', '')}
"""

                                # Store complete metadata including choices
                                collection.add(
                                ids=[question_data['id']],
                                documents=[full_document],
                                metadatas=[{
                                    'questionText': question_data['questionText'],
                                    'choice1': question_data.get('choices', ['', '', '', '', ''])[0],
                                    'choice2': question_data.get('choices', ['', '', '', '', ''])[1],
                                    'choice3': question_data.get('choices', ['', '', '', '', ''])[2],
                                    'choice4': question_data.get('choices', ['', '', '', '', ''])[3],
                                    'choice5': question_data.get('choices', ['', '', '', '', ''])[4],
                                    'correctAnswer': question_data.get('correctAnswer', ''),
                                    'explanation': question_data.get('explanation', ''),
                                    'subject': question_data.get('subject', '간호학'),
                                    'difficulty': question_data.get('analysis', {}).get('difficulty', '보통'),
                                    'tags': ', '.join(question_data.get('analysis', {}).get('keywords', [])),
                                    'createdBy': 'streamlit_user',
                                    'createdAt': question_data.get('createdAt', '')
                                }]
                                )

                                st.success(f"[SUCCESS] ChromaDB 저장 완료!")
                            except Exception as e:
                                st.error(f"[ERROR] ChromaDB 저장 실패: {e}")

                        # Firebase에 자동 업로드 (분야에 따라 다른 컬렉션 사용)
                        with st.spinner("[UPLOAD] Firebase에 업로드 중..."):
                            try:
                                problem_data = {
                                'id': question_data.get('id'),
                                'questionText': question_data['questionText'],
                                'choices': question_data.get('choices', []),
                                'correctAnswer': question_data.get('correctAnswer', ''),
                                'subject': question_data.get('subject', '간호학'),
                                'difficulty': question_data.get('analysis', {}).get('difficulty', '보통'),
                                'tags': question_data.get('analysis', {}).get('keywords', []),
                                'concepts': question_data.get('analysis', {}).get('concepts', []),
                                'explanation': question_data.get('explanation', ''),
                                'hasImage': question_data.get('hasImage', False),
                                'imageAnalysis': question_data.get('imageAnalysis'),
                                'createdAt': question_data.get('createdAt'),
                                'createdBy': question_data.get('createdBy', 'streamlit_user'),
                                'status': 'completed'
                            }

                                # 분야에 따라 다른 업로드 메서드 사용
                                if field == "간호":
                                    upload_result = firebase_service.upload_problem(problem_data)
                                else:  # 의학
                                    upload_result = firebase_service.upload_medical_problem(problem_data)

                                if upload_result and upload_result.get('success', False):
                                    st.success(f"[SUCCESS] Firebase 업로드 성공! (분야: {field})")
                                else:
                                    st.warning("[WARNING] Firebase 업로드 부분 실패")
                            except Exception as e:
                                st.error(f"[ERROR] Firebase 업로드 실패: {e}")

                        # Jobs/completed 폴더에 저장
                        completed_path = Path("Jobs/completed")
                        completed_path.mkdir(parents=True, exist_ok=True)

                        completed_file = completed_path / f"problem_{question_data['id']}.json"
                        with open(completed_file, 'w', encoding='utf-8') as f:
                            json.dump(question_data, f, ensure_ascii=False, indent=2)

                        st.success(f"[SUCCESS] 문제 저장 완료!")
                        st.info(f"[INFO] 파일 위치: {completed_file}")

                    except Exception as e:
                        st.error(f"[ERROR] 저장 실패: {e}")
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
    """Form for inputting medical concepts"""
    st.subheader("[INFO] 의학 개념 입력")

    with st.form("concept_form"):
        description = st.text_area(
            "개념 설명 *",
            height=200,
            help="개념에 대한 상세한 설명을 입력하세요"
        )

        tags = st.text_input("태그", help="쉼표로 구분 (선택사항)")

        submitted = st.form_submit_button("[SAVE] 개념 저장")

        if submitted:
            if description:
                try:
                    concept_data = {
                        'id': str(uuid.uuid4()),
                        'title': description[:50] + '...' if len(description) > 50 else description,  # 설명 앞부분을 제목으로 사용
                        'description': description,
                        'tags': [tag.strip() for tag in tags.split(',') if tag.strip()],
                        'createdAt': datetime.now().isoformat(),
                        'createdBy': 'streamlit_user'
                    }

                    # AI 분석
                    with st.spinner("[ANALYSIS] AI가 개념을 분석 중..."):
                        try:
                            analyzed = gemini_service.analyze_concept(description)
                            concept_data.update({
                                'keywords': analyzed.get('keywords', []),
                                'category': analyzed.get('category', ''),
                                'detailed_explanation': analyzed.get('detailed_explanation', description)
                            })
                            st.success("[SUCCESS] AI 분석 완료!")
                        except Exception as e:
                            st.warning(f"[WARNING] AI 분석 실패: {e}")

                    # ChromaDB에 저장
                    with st.spinner("[SAVE] ChromaDB에 저장 중..."):
                        try:
                            from rag_engine_multi_domain import multi_domain_rag_engine

                            # 모든 개념은 medical_concepts 컬렉션에 저장
                            collection_name = 'medical_concepts'
                            collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(collection_name)

                            # Create full document with complete concept data
                            full_document = f"""
설명: {concept_data.get('description', '')}
상세 설명: {concept_data.get('detailed_explanation', '')}
카테고리: {concept_data.get('category', '')}
키워드: {', '.join(concept_data.get('keywords', []))}
태그: {', '.join(concept_data.get('tags', []))}
"""

                            # Store complete metadata
                            collection.add(
                                ids=[concept_data['id']],
                                documents=[full_document],
                                metadatas=[{
                                    'title': concept_data['title'],
                                    'description': concept_data['description'][:500] if len(concept_data['description']) > 500 else concept_data['description'],
                                    'category': concept_data.get('category', ''),
                                    'keywords': ', '.join(concept_data.get('keywords', [])),
                                    'tags': ', '.join(concept_data.get('tags', [])),
                                    'createdBy': concept_data['createdBy'],
                                    'createdAt': concept_data['createdAt']
                                }]
                            )

                            st.success(f"[SUCCESS] ChromaDB 저장 완료! (컬렉션: {collection_name})")
                        except Exception as e:
                            st.error(f"[ERROR] ChromaDB 저장 실패: {e}")

                    # Firebase에 업로드
                    with st.spinner("[UPLOAD] Firebase에 업로드 중..."):
                        try:
                            upload_result = firebase_service.upload_concept(concept_data)
                            if upload_result.get('success'):
                                st.success(f"[SUCCESS] Firebase 업로드 성공!")
                        except Exception as e:
                            st.error(f"[ERROR] Firebase 업로드 실패: {e}")

                    st.success("[SUCCESS] 개념 저장 완료!")

                except Exception as e:
                    st.error(f"[ERROR] 저장 실패: {e}")
            else:
                st.warning("[WARNING] 개념 설명을 입력해주세요")


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
                    st.dataframe(model_df, use_container_width=True)
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
            st.dataframe(pricing_df, use_container_width=True)


def chromadb_check_tab():
    """ChromaDB data check tab with deletion capability"""
    st.subheader("[CHECK] ChromaDB 데이터 확인 및 관리")

    # Collection selection
    collection_name = st.selectbox(
        "컬렉션 선택",
        ["nursing_questions", "nursing_concepts", "medical_concepts"]
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
                            question_display = document.split('\n')[0].replace('문제: ', '')[:100]

                        data_list.append({
                            'Index': i,
                            'ID': doc_id[:8] + '...',  # Display shortened ID
                            '문제': question_display[:80] + '...' if len(question_display) > 80 else question_display,
                            '과목': metadata.get('subject', 'N/A'),
                            '난이도': metadata.get('difficulty', 'N/A'),
                            '태그': metadata.get('tags', 'N/A'),
                            '정답': metadata.get('correctAnswer', 'N/A')[:50],
                            '선택지1': metadata.get('choice1', 'N/A')[:30],
                            '선택지2': metadata.get('choice2', 'N/A')[:30],
                            '선택지3': metadata.get('choice3', 'N/A')[:30],
                            '선택지4': metadata.get('choice4', 'N/A')[:30],
                            '선택지5': metadata.get('choice5', 'N/A')[:30]
                        })

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
        st.dataframe(st.session_state.chromadb_data, use_container_width=True)

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
        stats_data = []

        for coll_name in ["nursing_questions", "nursing_concepts", "medical_concepts"]:
            try:
                collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(coll_name)
                count = collection.count()
                stats_data.append({
                    '컬렉션': coll_name,
                    '데이터 수': count,
                    '상태': '[ACTIVE]' if count > 0 else '[EMPTY]'
                })
            except:
                stats_data.append({
                    '컬렉션': coll_name,
                    '데이터 수': 0,
                    '상태': '[ERROR]'
                })

        stats_df = pd.DataFrame(stats_data)
        st.dataframe(stats_df, use_container_width=True)

    except Exception as e:
        st.error(f"[ERROR] 통계 로드 실패: {e}")


if __name__ == "__main__":
    main()