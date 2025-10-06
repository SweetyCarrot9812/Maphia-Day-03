"""
Manual Problem Input Form - Simplified Version without AI Analysis
"""
import streamlit as st
import uuid
from datetime import datetime


def problem_manual_input_form():
    """Manual form for inputting medical/nursing problems without AI analysis"""
    st.subheader("[MANUAL] 문제 수동 입력")

    with st.form("problem_manual_form"):
        # Field selection (nursing/medical)
        field = st.selectbox("분야 선택 *", ["간호", "의학"], help="문제가 속하는 분야를 선택하세요", key="problem_field")

        # Image upload section with multiple files support
        st.subheader("[IMAGE] 이미지 업로드 (선택사항)")

        uploaded_images = st.file_uploader(
            "문제 관련 이미지 (여러 개 선택 가능)",
            type=['png', 'jpg', 'jpeg', 'webp'],
            accept_multiple_files=True,
            help="문제와 관련된 의료 이미지, 도식, 차트 등을 업로드하세요 (PNG, JPG, JPEG, WebP 지원)"
        )

        # Display uploaded images
        if uploaded_images:
            st.write(f"[INFO] {len(uploaded_images)}개 이미지 업로드됨")
            cols = st.columns(min(len(uploaded_images), 3))
            for idx, img in enumerate(uploaded_images[:3]):
                with cols[idx % 3]:
                    st.image(img, caption=f"이미지 {idx+1}", width=150)

            if len(uploaded_images) > 3:
                st.info(f"[INFO] 추가 {len(uploaded_images)-3}개 이미지가 더 있습니다")

        st.divider()

        # Manual input fields based on user requirements
        st.subheader("[INPUT] 문제 정보 직접 입력")

        col1, col2 = st.columns([2, 1])

        with col1:
            question_text = st.text_area(
                "문제 텍스트 *",
                height=150,
                help="문제의 상세한 내용을 입력하세요",
                key="problem_question_text"
            )

            explanation = st.text_area(
                "해설 (선택사항)",
                height=100,
                help="정답에 대한 해설을 입력하세요 (선택사항)",
                key="problem_explanation"
            )

        with col2:
            # Subject selection based on field
            if field == "간호":
                subject = st.selectbox("과목 *", [
                    "기본간호학", "성인간호학", "아동간호학", "모성간호학",
                    "정신간호학", "지역사회간호학", "간호관리학"
                ], help="문제가 속하는 과목을 선택하세요", key="problem_subject")
            else:  # 의학
                subject = st.selectbox("과목 *", [
                    "해부학", "생리학", "병리학", "약리학",
                    "내과학", "외과학", "소아과학", "산부인과학", "정신의학"
                ], help="문제가 속하는 과목을 선택하세요", key="problem_subject")

            difficulty = st.selectbox(
                "난이도 *",
                options=["상", "중", "하"],
                index=1,  # 기본값: 중
                help="문제의 난이도를 선택하세요",
                key="problem_difficulty"
            )

            tags = st.text_input(
                "tags",
                help="태그를 쉼표로 구분하여 입력 (선택사항)",
                key="problem_tags"
            )

            concepts = st.text_input(
                "concepts",
                help="관련 개념을 쉼표로 구분하여 입력 (선택사항)",
                key="problem_concepts"
            )

            keywords = st.text_input(
                "keywords",
                help="키워드를 쉼표로 구분하여 입력 (선택사항)",
                key="problem_keywords"
            )

        # Choices section
        st.subheader("선택지 (필수 5개)")
        choices = []
        for i in range(1, 6):
            choice = st.text_input(f"선택지 {i} *", key=f"problem_choice_{i}", help="필수 입력")
            choices.append(choice)

        # Correct answer selection
        st.subheader("정답 선택")
        answer_options = ["1번", "2번", "3번", "4번", "5번"]
        correct_answer_number = st.selectbox("정답 *", answer_options, key="problem_correct_answer")

        # Duplicate check settings
        duplicate_threshold = st.slider(
            "중복 유사도 임계값",
            min_value=0.70,
            max_value=0.99,
            value=0.92,
            step=0.01,
            help="이 값 이상의 유사도를 가진 문제가 있으면 중복으로 판단 (권장: 0.92-0.95)",
            key="problem_duplicate_threshold"
        )

        st.info("""
        **유사도 기준:**
        - 0.95+ : 거의 동일
        - 0.90-0.95 : 매우 유사 (권장 중복 기준)
        - 0.85-0.90 : 유사한 주제
        - 0.85 미만 : 다른 문제
        """)

        submitted = st.form_submit_button("[SAVE] 문제 저장")

        if submitted:
            # Validate required fields
            missing_fields = []
            non_empty_choices = [c for c in choices if c.strip()]

            if not question_text.strip():
                missing_fields.append("문제 텍스트")
            # explanation is now optional
            if len(non_empty_choices) != 5:
                missing_fields.append("선택지 5개")
            if not correct_answer_number:
                missing_fields.append("정답 선택")

            # Check for duplicate choices
            if len(non_empty_choices) == 5 and len(set(non_empty_choices)) != len(non_empty_choices):
                st.error("[ERROR] 중복된 선택지가 있습니다! 모든 선택지는 서로 달라야 합니다.")
                return

            if missing_fields:
                st.error(f"[ERROR] 다음 필수 필드를 입력해주세요: {', '.join(missing_fields)}")
            else:
                # Get the actual answer based on selection
                answer_index = int(correct_answer_number.replace("번", "")) - 1
                correct_answer = choices[answer_index] if answer_index < len(choices) else ""

                # Create problem data structure
                problem_data = {
                    'id': str(uuid.uuid4()),
                    'type': 'problem',
                    'questionText': question_text.strip(),
                    'choices': non_empty_choices,
                    'correctAnswer': correct_answer,
                    'answer': answer_index,
                    'explanation': explanation.strip() if explanation else '',
                    'subject': subject,
                    'difficulty': difficulty,
                    'tags': [t.strip() for t in tags.split(',') if t.strip()] if tags else [],
                    'concepts': [c.strip() for c in concepts.split(',') if c.strip()] if concepts else [],
                    'keywords': [k.strip() for k in keywords.split(',') if k.strip()] if keywords else [],
                    'field': field,
                    'created_at': datetime.now().isoformat(),
                    'hasImage': bool(uploaded_images),
                    'createdBy': 'streamlit_user'
                }

                # === Step 1: Duplicate Check ===
                st.header("[STEP 1] 중복 검사")

                with st.spinner("[SEARCH] 유사 문제 검색 중..."):
                    try:
                        from rag_engine_multi_domain import multi_domain_rag_engine
                        from rag_engine import rag_engine

                        # Choose collection based on field
                        if field == "간호":
                            collection_name = 'nursing_questions'
                        else:
                            collection_name = 'medical_problems'

                        collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(collection_name)

                        # Generate embedding using Gemini text-embedding-004 (768 dimensions)
                        search_text = f"{question_text} {' '.join(non_empty_choices)}"
                        search_embedding = rag_engine.generate_embedding(search_text)

                        # Search for similar problems with explicit embedding
                        results = collection.query(
                            query_embeddings=[search_embedding],
                            n_results=5,
                            where={"type": "problem"}
                        )

                        max_similarity = 0.0
                        is_duplicate = False

                        if results.get('distances') and results['distances'][0]:
                            distances = results['distances'][0]
                            # ChromaDB uses L2 distance: smaller = more similar
                            # Convert to similarity score: 1/(1+distance)
                            similarities = [1 / (1 + d) for d in distances]
                            max_similarity = max(similarities) if similarities else 0.0

                            if max_similarity >= duplicate_threshold:
                                is_duplicate = True
                                st.warning(f"[DUPLICATE] 중복 가능성 높음 (최대 유사도: {max_similarity:.3f})")
                            else:
                                st.success(f"[UNIQUE] 새로운 문제 (최대 유사도: {max_similarity:.3f})")

                            # Show top results
                            if results.get('documents') and results['documents'][0]:
                                with st.expander("[DETAILS] 유사 문제 결과", expanded=False):
                                    for i, (doc, sim) in enumerate(zip(results['documents'][0][:3], similarities[:3])):
                                        st.write(f"**{i+1}위** (유사도: {sim:.3f})")
                                        st.write(doc[:200] + "..." if len(doc) > 200 else doc)
                                        st.divider()
                        else:
                            st.info("[INFO] 첫 번째 문제입니다.")

                    except Exception as e:
                        st.error(f"[ERROR] 중복 검사 실패: {e}")
                        max_similarity = 0.0
                        is_duplicate = False

                # === Step 2: Direct Embedding & Save ===
                if not is_duplicate or st.checkbox("중복이어도 저장하기"):
                    st.header("[STEP 2] 임베딩 및 저장")

                    with st.spinner("[SAVE] 벡터 임베딩 및 저장 중..."):
                        try:
                            # Create full document for embedding
                            full_document = f"""
                            문제: {problem_data['questionText']}
                            선택지: {', '.join(problem_data['choices'])}
                            정답: {problem_data['correctAnswer']}
                            해설: {problem_data['explanation']}
                            과목: {problem_data['subject']}
                            난이도: {problem_data['difficulty']}
                            분야: {problem_data['field']}
                            태그: {', '.join(problem_data['tags'])}
                            개념: {', '.join(problem_data['concepts'])}
                            키워드: {', '.join(problem_data['keywords'])}
                            """

                            # Prepare metadata
                            metadata = {
                                'title': problem_data['questionText'][:100],
                                'description': problem_data['questionText'][:500],
                                'subject': problem_data['subject'],
                                'difficulty': problem_data['difficulty'],
                                'field': problem_data['field'],
                                'tags': ', '.join(problem_data['tags']),
                                'concepts': ', '.join(problem_data['concepts']),
                                'keywords': ', '.join(problem_data['keywords']),
                                'correctAnswer': problem_data['correctAnswer'],
                                'createdBy': problem_data['createdBy'],
                                'createdAt': problem_data['created_at'],
                                'hasImage': problem_data['hasImage'],
                                'type': 'problem'
                            }

                            # Generate embedding using Gemini text-embedding-004 (768 dimensions)
                            from rag_engine import rag_engine
                            embedding = rag_engine.generate_embedding(full_document)

                            # Save to ChromaDB with explicit embedding
                            collection.add(
                                ids=[problem_data['id']],
                                documents=[full_document],
                                embeddings=[embedding],
                                metadatas=[metadata]
                            )

                            st.success(f"[SUCCESS] ChromaDB 저장 완료!")
                            st.success(f"[SUCCESS] 문서 ID: {problem_data['id']}")

                            # === Step 3: Firebase Save ===
                            st.subheader("[STEP 3] Firebase 저장")

                            try:
                                from firebase_service import firebase_service

                                firebase_data = {
                                    'id': problem_data['id'],
                                    'questionText': problem_data['questionText'],
                                    'choices': problem_data['choices'],
                                    'correctAnswer': problem_data['correctAnswer'],
                                    'answer': problem_data['answer'],
                                    'explanation': problem_data['explanation'],
                                    'subject': problem_data['subject'],
                                    'difficulty': problem_data['difficulty'],
                                    'tags': problem_data['tags'],
                                    'concepts': problem_data['concepts'],
                                    'keywords': problem_data['keywords'],
                                    'field': problem_data['field'],
                                    'createdAt': problem_data['created_at'],
                                    'createdBy': problem_data['createdBy'],
                                    'hasImage': problem_data['hasImage'],
                                    'type': 'problem',
                                    'similarity_check': {
                                        'max_similarity': max_similarity,
                                        'is_duplicate': is_duplicate
                                    }
                                }

                                upload_result = firebase_service.add_problem(firebase_data)

                                if upload_result.get('success'):
                                    st.success(f"[SUCCESS] Firebase 저장 완료!")
                                    st.success(f"[SUCCESS] 문서 ID: {upload_result.get('id', 'N/A')}")
                                else:
                                    st.warning(f"[WARNING] Firebase 저장 실패: {upload_result.get('message', 'Unknown error')}")

                            except Exception as e:
                                st.warning(f"[WARNING] Firebase 저장 실패: {e}")

                            # Final success message
                            st.balloons()
                            st.success("[COMPLETE] 문제 저장이 완료되었습니다!")

                        except Exception as e:
                            st.error(f"[ERROR] 저장 실패: {e}")
                            import traceback
                            st.error(f"[ERROR] 상세 오류: {traceback.format_exc()}")
                else:
                    st.info("[INFO] 중복으로 인해 저장이 취소되었습니다.")


if __name__ == "__main__":
    problem_manual_input_form()