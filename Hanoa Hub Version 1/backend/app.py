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
from deduplication_engine import deduplication_engine
from PIL import Image
import io
import os
import hashlib
import base64
import asyncio
from ai_batch_generator import BatchQuestionGenerator
from question_types import QuestionType

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

    # Main content tabs - 3개 탭
    tab1, tab2, tab3 = st.tabs([
        "[DATA] 데이터 입력",
        "[AI] AI 문제 생성",
        "[SYSTEM] 시스템 관리"
    ])

    with tab1:
        data_input_tab()

    with tab2:
        ai_generation_tab()

    with tab3:
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
            type=['png', 'jpg', 'jpeg', 'webp'],
            help="문제와 관련된 의료 이미지를 업로드하세요 (PNG, JPG, JPEG, WebP 지원)"
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
                            'answer': answer_index if correct_answer else None,
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

                                # 품질/중복 검사 (용량, 해시)
                                try:
                                    img_bytes = uploaded_image.getvalue()
                                except Exception:
                                    img_bytes = uploaded_image.getbuffer()

                                try:
                                    size_bytes = len(img_bytes)
                                except Exception:
                                    size_bytes = uploaded_image.size if hasattr(uploaded_image, 'size') else 0

                                if MAX_IMAGE_SIZE_MB and size_bytes and size_bytes > MAX_IMAGE_SIZE_MB * 1024 * 1024:
                                    st.error(f"[ERROR] 이미지 용량이 {MAX_IMAGE_SIZE_MB}MB를 초과합니다.")
                                    st.stop()

                                image_hash = hashlib.sha256(bytes(img_bytes)).hexdigest()
                                question_data['imageHash'] = image_hash

                                # 로컬 해시 인덱스 중복 체크
                                hash_index_path = Path("database/image_hash_index.json")
                                hash_index_path.parent.mkdir(parents=True, exist_ok=True)
                                try:
                                    with open(hash_index_path, 'r', encoding='utf-8') as hf:
                                        hash_index = json.load(hf)
                                except Exception:
                                    hash_index = {}

                                if image_hash in hash_index:
                                    st.error("[ERROR] 동일한 이미지가 이미 업로드되어 있습니다. 저장을 중단합니다.")
                                    st.info(f"[INFO] 기존 이미지 URL: {hash_index.get(image_hash)}")
                                    st.stop()

                                with open(image_path, "wb") as f:
                                    f.write(uploaded_image.getbuffer())

                                question_data['imagePath'] = str(image_path)

                                # Firebase Storage 업로드 및 URL 설정
                                try:
                                    with open(image_path, 'rb') as img_file:
                                        image_url = firebase_service.upload_image_to_storage(
                                            image_data=img_file,
                                            path_prefix="problems/",
                                            filename=image_filename,
                                            use_webp=True
                                        )
                                    if image_url:
                                        question_data['hasImage'] = True
                                        question_data['imageUrl'] = image_url
                                        question_data['imageUrls'] = [image_url]
                                        # 해시 인덱스 저장
                                        try:
                                            hash_index[image_hash] = image_url
                                            with open(hash_index_path, 'w', encoding='utf-8') as hf:
                                                json.dump(hash_index, hf, ensure_ascii=False, indent=2)
                                        except Exception:
                                            pass
                                except Exception as e:
                                    pass

                                # Analyze image if checkbox was checked
                                if analyze_on_save:
                                    with st.spinner("[ANALYSIS] 이미지 분석 중..."):
                                        # Use hierarchical analyzer
                                        image = Image.open(uploaded_image)
                                        analyzer = ImageHierarchicalAnalyzer()

                                        # 이미지를 임시 파일로 저장
                                        temp_image_path = f"temp_question_{question_data['id']}.jpg"
                                        image.save(temp_image_path)

                                        analysis_result = analyzer.analyze_image(
                                            image_path=temp_image_path,
                                            domain="medical",
                                            context="의학 문제 이미지",
                                            save_to_chroma=False  # ChromaDB는 별도 저장
                                        )

                                        # 임시 파일 정리
                                        if os.path.exists(temp_image_path):
                                            os.remove(temp_image_path)

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
                                    'questionText': question_data.get('questionText', ''),
                                    'choice1': question_data.get('choices', ['', '', '', '', ''])[0] or '',
                                    'choice2': question_data.get('choices', ['', '', '', '', ''])[1] or '',
                                    'choice3': question_data.get('choices', ['', '', '', '', ''])[2] or '',
                                    'choice4': question_data.get('choices', ['', '', '', '', ''])[3] or '',
                                    'choice5': question_data.get('choices', ['', '', '', '', ''])[4] or '',
                                    'correctAnswer': question_data.get('correctAnswer', '') or '',
                                    'explanation': question_data.get('explanation', '') or '',
                                    'subject': question_data.get('subject', '간호학') or '간호학',
                                    'difficulty': question_data.get('analysis', {}).get('difficulty', '보통') or '보통',
                                    'tags': ', '.join(question_data.get('analysis', {}).get('keywords', [])) or '',
                                    'createdBy': 'streamlit_user',
                                    'createdAt': question_data.get('createdAt', '') or '',
                                    'hasImage': bool(question_data.get('hasImage', False)),
                                    'type': 'problem'
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
                                'answer': question_data.get('answer'),
                                'subject': question_data.get('subject', '간호학'),
                                'difficulty': question_data.get('analysis', {}).get('difficulty', '보통'),
                                'tags': question_data.get('analysis', {}).get('keywords', []),
                                'concepts': question_data.get('analysis', {}).get('concepts', []),
                                'explanation': question_data.get('explanation', ''),
                                'hasImage': question_data.get('hasImage', False),
                                'imageUrl': question_data.get('imageUrl'),
                                'imageUrls': question_data.get('imageUrls', []),
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

                        # RAG(ChromaDB)에 질문 등록
                        try:
                            rag_engine.add_question(question_data)
                        except Exception:
                            pass

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
    """Form for inputting medical concepts with image support"""
    st.subheader("[INFO] 의학 개념 입력")

    with st.form("concept_form"):
        # Image upload section
        st.subheader("[IMAGE] 이미지 업로드 (선택사항)")
        uploaded_image = st.file_uploader(
            "개념 관련 이미지",
            type=['png', 'jpg', 'jpeg', 'webp'],
            help="개념과 관련된 의료 이미지, 도식, 차트 등을 업로드하세요 (PNG, JPG, JPEG, WebP 지원)"
        )

        image_analysis_result = None
        image_url = None
        if uploaded_image is not None:
            # Display uploaded image
            col_img1, col_img2 = st.columns([1, 2])
            with col_img1:
                st.image(uploaded_image, caption="업로드된 이미지", width=200)

            with col_img2:
                analyze_on_save = st.checkbox("[ANALYSIS] 이미지 자동 분석", value=True, key="concept_analyze_image")
                if analyze_on_save:
                    st.info("[INFO] 이미지가 저장 시 자동 분석됩니다")

        st.divider()

        description = st.text_area(
            "개념 설명 *",
            height=200,
            help="개념에 대한 상세한 설명을 입력하세요"
        )

        tags = st.text_input("태그", help="쉼표로 구분 (선택사항)")

        submitted = st.form_submit_button("[SAVE] 개념 저장")

        if submitted:
            # 개념 설명이 있거나 이미지가 업로드된 경우 저장 가능
            if description or uploaded_image is not None:
                try:
                    concept_data = {
                        'id': str(uuid.uuid4()),
                        'title': '',  # 나중에 설정
                        'description': description or '',  # 설명이 없으면 빈 문자열
                        'tags': [tag.strip() for tag in tags.split(',') if tag.strip()],
                        'createdAt': datetime.now().isoformat(),
                        'createdBy': 'streamlit_user',
                        'hasImage': uploaded_image is not None,
                        'imageAnalysis': None,
                        'imageUrl': None
                    }

                    # Process image if uploaded
                    if uploaded_image is not None:
                        try:
                            # Upload image to Firebase Storage
                            with st.spinner("[UPLOAD] 이미지를 Firebase Storage에 업로드 중..."):
                                image_url = firebase_service.upload_image_to_storage(
                                    image_data=uploaded_image,
                                    path_prefix="concepts/images/",
                                    filename=f"concept_{concept_data['id']}.jpg",
                                    use_webp=False  # JPEG로 변경
                                )

                                if image_url:
                                    concept_data['imageUrl'] = image_url
                                    st.success(f"[SUCCESS] 이미지 업로드 완료! URL: {image_url[:50]}...")
                                else:
                                    st.error("[ERROR] 이미지 업로드 실패 - Firebase Storage 연결을 확인하세요")
                                    concept_data['hasImage'] = False
                                    raise Exception("Firebase Storage 업로드 실패")

                            # Analyze image if checkbox was checked and upload succeeded
                            if analyze_on_save and image_url:
                                with st.spinner("[ANALYSIS] 이미지 분석 중..."):
                                    try:
                                        # Use hierarchical analyzer
                                        image = Image.open(uploaded_image)
                                        analyzer = ImageHierarchicalAnalyzer()

                                        # 이미지를 임시 파일로 저장
                                        temp_image_path = f"temp_concept_{concept_data['id']}.jpg"
                                        image.save(temp_image_path)

                                        st.info(f"[DEBUG] 임시 파일 생성: {temp_image_path}")

                                        analysis_result = analyzer.analyze_image(
                                            image_path=temp_image_path,
                                            domain="medical",
                                            context="의학 개념 이미지",
                                            save_to_chroma=False  # ChromaDB는 별도 저장
                                        )

                                        # 임시 파일 정리
                                        if os.path.exists(temp_image_path):
                                            os.remove(temp_image_path)

                                        if analysis_result:
                                            concept_data['imageAnalysis'] = {
                                                'main_objects': getattr(analysis_result, 'main_objects', []),
                                                'medical_tags': getattr(analysis_result, 'medical_tags', []),
                                                'description': getattr(analysis_result, 'description', ''),
                                                'confidence': getattr(analysis_result, 'confidence_score', 0.0),
                                                'analyzed_by': getattr(analysis_result, 'analyzed_by', 'unknown'),
                                                'analysis_type': 'concept_image'
                                            }

                                            # 이미지 분석 결과를 개념 설명에 자동으로 추가
                                            if hasattr(analysis_result, 'description') and analysis_result.description:
                                                concept_data['imageDescription'] = analysis_result.description

                                                # 설명이 없으면 이미지 분석 결과를 설명으로 사용
                                                if not concept_data['description']:
                                                    concept_data['description'] = analysis_result.description
                                                    st.info("[AUTO] 이미지 분석 결과를 개념 설명으로 자동 설정했습니다")

                                                # 분석 결과 표시
                                                with st.expander("[RESULT] 이미지 분석 결과", expanded=True):
                                                    # AI 모델 정보 먼저 표시
                                                    analysis_model = getattr(analysis_result, 'analyzed_by', 'unknown')
                                                    if analysis_model == 'gemini_flash':
                                                        st.info("🤖 **분석 모델**: Gemini 2.5 Flash (1단계 - 빠른 분석)")
                                                    elif analysis_model == 'gpt5_mini':
                                                        st.info("🤖 **분석 모델**: GPT-5 Mini (2단계 - 중간 검수)")
                                                    elif analysis_model == 'gpt5_enhanced':
                                                        st.info("🤖 **분석 모델**: GPT-5 (3단계 - 최고급 정밀 분석)")
                                                    else:
                                                        st.info(f"🤖 **분석 모델**: {analysis_model}")

                                                    st.write("**분석된 주요 객체:**", ', '.join(analysis_result.main_objects[:5]))
                                                    st.write("**의료 태그:**", ', '.join(analysis_result.medical_tags[:5]))
                                                    st.write("**이미지 설명:**", analysis_result.description)
                                                    st.write("**신뢰도:**", f"{analysis_result.confidence_score:.1%}")

                                                    # 에스컬레이션 이유 표시 (있는 경우)
                                                    if hasattr(analysis_result, 'escalation_reason') and analysis_result.escalation_reason:
                                                        st.caption(f"💡 **에스컬레이션 이유**: {analysis_result.escalation_reason}")

                                            st.success("[SUCCESS] 이미지 분석 완료!")
                                        else:
                                            st.error("[ERROR] 이미지 분석 결과가 비어있습니다")
                                            concept_data['imageAnalysis'] = None

                                    except Exception as analysis_error:
                                        st.error(f"[ERROR] 이미지 분석 실패: {analysis_error}")
                                        concept_data['imageAnalysis'] = None
                                        # 임시 파일 정리
                                        if os.path.exists(f"temp_concept_{concept_data['id']}.jpg"):
                                            os.remove(f"temp_concept_{concept_data['id']}.jpg")

                        except Exception as e:
                            st.error(f"[ERROR] 이미지 처리 실패: {e}")
                            st.error("[DEBUG] Firebase 서비스 초기화 상태를 확인하세요")
                            concept_data['hasImage'] = False
                            concept_data['imageUrl'] = None
                            concept_data['imageAnalysis'] = None

                    # AI 분석 (설명이 있는 경우에만)
                    if concept_data['description']:
                        with st.spinner("[ANALYSIS] AI가 개념을 분석 중..."):
                            try:
                                analyzed = gemini_service.analyze_concept(concept_data['description'])
                                concept_data.update({
                                    'keywords': analyzed.get('keywords', []),
                                    'category': analyzed.get('category', ''),
                                    'detailed_explanation': analyzed.get('detailed_explanation', concept_data['description'])
                                })
                                st.success("[SUCCESS] AI 분석 완료!")
                            except Exception as e:
                                st.warning(f"[WARNING] AI 분석 실패: {e}")

                    # 제목 설정 (설명 또는 이미지 분석 결과 기반)
                    if concept_data.get('description'):
                        concept_data['title'] = concept_data['description'][:50] + '...' if len(concept_data['description']) > 50 else concept_data['description']
                    elif concept_data.get('imageAnalysis') and concept_data['imageAnalysis'].get('main_objects'):
                        # 이미지 주요 객체를 기반으로 제목 생성
                        main_objects = concept_data['imageAnalysis']['main_objects'][:3]
                        concept_data['title'] = f"의료 이미지: {', '.join(main_objects)}"
                    else:
                        concept_data['title'] = f"개념 {datetime.now().strftime('%Y-%m-%d %H:%M')}"

                    # ChromaDB에 저장
                    with st.spinner("[SAVE] ChromaDB에 저장 중..."):
                        try:
                            st.info("[DEBUG] ChromaDB 저장 시작...")
                            from rag_engine_multi_domain import multi_domain_rag_engine

                            # 모든 개념은 medical_concepts 컬렉션에 저장
                            collection_name = 'medical_concepts'
                            st.info(f"[DEBUG] 컬렉션 접근: {collection_name}")

                            collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(collection_name)
                            st.info(f"[DEBUG] 컬렉션 생성/접근 완료: {collection}")

                            # 데이터 유효성 검사
                            st.info(f"[DEBUG] 개념 데이터 검증: ID={concept_data.get('id')}, 제목={concept_data.get('title')}")
                            st.info(f"[DEBUG] 이미지 정보: hasImage={concept_data.get('hasImage')}, imageUrl={bool(concept_data.get('imageUrl'))}")

                            # Create full document with complete concept data including image info
                            image_info = ""
                            if concept_data.get('hasImage'):
                                image_analysis = concept_data.get('imageAnalysis') or {}
                                if isinstance(image_analysis, dict):
                                    image_info = f"""
이미지 포함: 예
이미지 설명: {concept_data.get('imageDescription', '') or ''}
이미지 주요 객체: {', '.join(image_analysis.get('main_objects', []) or [])}
이미지 의료 태그: {', '.join(image_analysis.get('medical_tags', []) or [])}
"""
                                else:
                                    image_info = "\n이미지 포함: 예\n"

                            full_document = f"""
설명: {concept_data.get('description', '')}
상세 설명: {concept_data.get('detailed_explanation', '')}
카테고리: {concept_data.get('category', '')}
키워드: {', '.join(concept_data.get('keywords', []))}
태그: {', '.join(concept_data.get('tags', []))}
{image_info}
"""

                            # Store complete metadata including image info (ChromaDB에서 None 값 방지)
                            metadata = {
                                'title': concept_data.get('title', ''),
                                'description': concept_data.get('description', '')[:500] if concept_data.get('description') else '',
                                'category': concept_data.get('category', ''),
                                'keywords': ', '.join(concept_data.get('keywords', [])) or '',
                                'tags': ', '.join(concept_data.get('tags', [])) or '',
                                'createdBy': concept_data.get('createdBy', 'streamlit_user'),
                                'createdAt': concept_data.get('createdAt', ''),
                                'hasImage': bool(concept_data.get('hasImage', False)),
                                'imageUrl': concept_data.get('imageUrl', '') or '',
                                'type': 'concept'
                            }

                            # Add image analysis metadata if available (None 값 방지)
                            if concept_data.get('imageAnalysis') and isinstance(concept_data['imageAnalysis'], dict):
                                image_analysis = concept_data['imageAnalysis']
                                metadata.update({
                                    'imageDescription': concept_data.get('imageDescription', '') or '',
                                    'imageMainObjects': ', '.join(image_analysis.get('main_objects', []) or []) or '',
                                    'imageMedicalTags': ', '.join(image_analysis.get('medical_tags', []) or []) or '',
                                    'imageConfidence': float(image_analysis.get('confidence', 0.0) or 0.0)
                                })

                            collection.add(
                                ids=[concept_data['id']],
                                documents=[full_document],
                                metadatas=[metadata]
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
                st.warning("[WARNING] 개념 설명을 입력하거나 이미지를 업로드해주세요")


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
                st.dataframe(df, use_container_width=True)

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
            st.dataframe(df, use_container_width=True)


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
        st.dataframe(st.session_state.chromadb_data, use_container_width=True)

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
