"""
Fitness Manual Input Form - Exercise and Nutrition Concepts
"""
import streamlit as st
import uuid
from datetime import datetime


def handle_fitness_image_upload():
    """Handle image upload with automatic compression for fitness concepts"""
    st.subheader("[IMAGE] 이미지 업로드 (선택사항)")

    uploaded_images = st.file_uploader(
        "운동/영양 관련 이미지 (여러 개 선택 가능)",
        type=['png', 'jpg', 'jpeg', 'webp'],
        accept_multiple_files=True,
        help="운동 폼, 영양 차트, 음식 사진 등을 업로드하세요 (PNG, JPG, JPEG, WebP 지원)",
        key="fitness_images"
    )

    processed_images = []

    if uploaded_images:
        from image_utils import image_processor

        st.success(f"[AUTO] {len(uploaded_images)}개 이미지 자동 압축 중...")

        # Auto-process images immediately
        with st.spinner("[PROCESSING] 이미지 압축 중..."):
            # Compress images only (no Firebase upload yet)
            compressed_images = []
            for idx, uploaded_file in enumerate(uploaded_images):
                # Compress image
                compressed_bytes, file_ext = image_processor.compress_image(uploaded_file)

                if compressed_bytes:
                    # Calculate compression info
                    original_size = len(uploaded_file.getvalue())
                    compressed_size = len(compressed_bytes)
                    compression_ratio = (1 - compressed_size / original_size) * 100

                    # Store compressed data in memory (no Firebase upload yet)
                    compressed_images.append({
                        'original_name': uploaded_file.name,
                        'compressed_bytes': compressed_bytes,
                        'file_ext': file_ext,
                        'original_size': original_size,
                        'compressed_size': compressed_size,
                        'compression_ratio': compression_ratio
                    })

        if compressed_images:
            st.success(f"[SUCCESS] {len(compressed_images)}개 이미지 압축 완료!")

            # Show preview
            cols = st.columns(min(len(compressed_images), 3))
            for idx, img_data in enumerate(compressed_images[:3]):
                with cols[idx % 3]:
                    st.image(img_data['compressed_bytes'],
                            caption=f"{img_data['original_name']}\n압축률: {img_data['compression_ratio']:.1f}%",
                            width=150)

            if len(compressed_images) > 3:
                st.info(f"[INFO] 추가 {len(compressed_images)-3}개 이미지")

            # Store in session state for later Firebase upload
            st.session_state.fitness_compressed_images = compressed_images
            st.info("[INFO] 이미지가 준비되었습니다. 개념 정보를 입력하고 [SAVE] 버튼을 누르면 저장됩니다.")
        else:
            st.error("[ERROR] 이미지 압축에 실패했습니다")

    # Check if there are compressed images in session state
    if 'fitness_compressed_images' in st.session_state and not uploaded_images:
        compressed_images = st.session_state.fitness_compressed_images
        st.info(f"[READY] {len(compressed_images)}개 압축된 이미지가 저장 대기 중입니다")
        processed_images = compressed_images

    return st.session_state.get('fitness_compressed_images', [])


def fitness_concept_input_form():
    """Manual form for inputting fitness and nutrition concepts"""
    st.subheader("🏋️ 운동/영양 개념 수동 입력")

    # Handle image upload outside of form
    handle_fitness_image_upload()

    st.divider()

    # Category selection OUTSIDE form for conditional logic
    concept_category = st.selectbox(
        "분류 *",
        options=["운동", "영양", "건강"],
        help="개념의 주요 분류를 선택하세요",
        key="fitness_concept_category_selector"
    )

    # Exercise subcategory OUTSIDE form for conditional logic
    exercise_subcategory = None
    if concept_category == "운동":
        exercise_subcategory = st.selectbox(
            "운동 종목",
            options=["해당 없음", "헬스", "크로스핏"],
            help="운동 종목을 선택하세요",
            key="fitness_exercise_subcategory_selector"
        )

    st.divider()

    with st.form("fitness_manual_form"):

        # Manual input fields based on user requirements
        st.subheader("[INPUT] 개념 정보 직접 입력")

        col1, col2 = st.columns(2)

        with col1:

            concept_text = st.text_area(
                "개념 설명",
                height=150,
                help="운동 방법, 영양 정보 등을 상세히 입력하세요",
                key="fitness_concept_text"
            )

            keywords = st.text_input(
                "keywords",
                help="핵심 키워드를 쉼표로 구분하여 입력 (예: bench_press, chest, compound)",
                key="fitness_keywords"
            )

            # Conditional fields based on category
            if concept_category == "운동":

                # 운동명 입력
                exercise_name = st.text_input(
                    "운동명",
                    help="운동 이름을 입력하세요 (예: 벤치프레스, Fran, 데드리프트)",
                    key="fitness_exercise_name"
                )

                exercise_type = st.selectbox(
                    "운동 유형",
                    options=["해당 없음", "상체", "하체", "전신", "코어", "유산소", "유연성"],
                    help="운동이 주로 타겟하는 부위를 선택하세요",
                    key="fitness_exercise_type"
                )

                exercise_equipment = st.multiselect(
                    "필요 장비",
                    options=["해당 없음", "맨몸", "덤벨", "바벨", "머신", "케틀벨", "밴드", "기타"],
                    help="운동에 필요한 장비를 선택하세요",
                    key="fitness_equipment"
                )

                # 크로스핏 전용 필드
                if exercise_subcategory == "크로스핏":
                    reps = st.text_input(
                        "Reps (반복 횟수)",
                        help="반복 횟수를 입력하세요 (예: 21-15-9, 10-9-8-7-6-5-4-3-2-1)",
                        key="fitness_reps"
                    )
            elif concept_category == "영양":
                nutrition_type = st.selectbox(
                    "영양소 유형",
                    options=["해당 없음", "단백질", "탄수화물", "지방", "비타민", "미네랄", "종합"],
                    help="주요 영양소 유형을 선택하세요",
                    key="fitness_nutrition_type"
                )

                meal_type = st.multiselect(
                    "식사 시간",
                    options=["아침", "점심", "저녁", "간식", "운동 전", "운동 후"],
                    help="적합한 식사 시간을 선택하세요",
                    key="fitness_meal_type"
                )
            # 건강 카테고리는 별도 필드 없음

        with col2:
            difficulty = st.selectbox(
                "난이도",
                options=["해당 없음", "초보", "중급", "고급", "전문가"],
                help="개념의 난이도를 선택하세요",
                key="fitness_difficulty"
            )

            target_goal = st.multiselect(
                "목표",
                options=["해당 없음", "근력 향상", "근비대", "체지방 감소", "지구력 향상", "유연성 향상", "건강 유지"],
                help="이 개념이 도움이 되는 목표를 선택하세요",
                key="fitness_target_goal"
            )

            tags = st.text_input(
                "tags",
                help="추가 태그를 쉼표로 구분하여 입력 (선택사항)",
                key="fitness_tags"
            )

            concepts = st.text_input(
                "concepts",
                help="주요 개념을 쉼표로 구분하여 입력 (선택사항)",
                key="fitness_concepts"
            )

            related_concepts = st.text_input(
                "related_concepts",
                help="연관 개념을 쉼표로 구분하여 입력 (선택사항)",
                key="fitness_related_concepts"
            )

        # Duplicate check settings
        duplicate_threshold = st.slider(
            "중복 유사도 임계값",
            min_value=0.5,
            max_value=0.95,
            value=0.8,
            step=0.05,
            help="이 값 이상의 유사도를 가진 개념이 있으면 중복으로 판단",
            key="fitness_duplicate_threshold"
        )

        submitted = st.form_submit_button("[SAVE] 개념 저장")

        if submitted:
            # Get compressed images from session state
            compressed_images = st.session_state.get('fitness_compressed_images', [])

            # Upload compressed images to Firebase Storage now
            processed_images = []
            if compressed_images:
                st.info(f"[UPLOAD] {len(compressed_images)}개 이미지를 Firebase Storage에 업로드 중...")
                from image_utils import image_processor

                for img_data in compressed_images:
                    # Generate unique filename
                    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                    unique_id = str(uuid.uuid4())[:8]
                    file_name = f"fitness_{timestamp}_{unique_id}.{img_data['file_ext']}"

                    # Save to local first
                    local_path = image_processor.save_to_local(img_data['compressed_bytes'], file_name)

                    # Upload to Firebase Storage
                    public_url = image_processor.upload_to_firebase_storage(
                        img_data['compressed_bytes'],
                        file_name,
                        'image/webp'
                    )

                    processed_images.append({
                        'original_name': img_data['original_name'],
                        'file_name': file_name,
                        'public_url': public_url if public_url else None,
                        'local_path': local_path if local_path else None,
                        'content_type': 'image/webp',
                        'original_size': img_data['original_size'],
                        'compressed_size': img_data['compressed_size'],
                        'compression_ratio': img_data['compression_ratio'],
                        'uploaded_at': datetime.now().isoformat()
                    })

                if processed_images:
                    st.success(f"[SUCCESS] {len(processed_images)}개 이미지 Firebase 업로드 완료!")

            # Validate required fields
            missing_fields = []
            has_content = bool(concept_text.strip()) or bool(keywords.strip()) or bool(processed_images)

            if not has_content:
                st.error("[ERROR] 개념 설명, keywords, 또는 이미지 중 하나는 반드시 입력해야 합니다")
            else:
                # Create concept data structure (filter out "해당 없음")
                concept_data = {
                    'id': str(uuid.uuid4()),
                    'type': 'fitness_concept',
                    'category': concept_category,  # 운동 or 영양
                    'concept_text': concept_text.strip() if concept_text else '',
                    'keywords': [k.strip() for k in keywords.split(',') if k.strip()] if keywords else [],
                    'difficulty': difficulty if difficulty != "해당 없음" else "",
                    'target_goal': [goal for goal in target_goal if goal != "해당 없음"],
                    'tags': [t.strip() for t in tags.split(',') if t.strip()] if tags else [],
                    'concepts': [c.strip() for c in concepts.split(',') if c.strip()] if concepts else [],
                    'related_concepts': [r.strip() for r in related_concepts.split(',') if r.strip()] if related_concepts else [],
                    'created_at': datetime.now().isoformat(),
                    'hasImage': bool(processed_images),
                    'images': processed_images if processed_images else [],
                    'createdBy': 'streamlit_user'
                }

                # Add category-specific fields (filter out "해당 없음")
                if concept_category == "운동":
                    concept_data['exercise_subcategory'] = exercise_subcategory if exercise_subcategory != "해당 없음" else ""
                    concept_data['exercise_name'] = exercise_name.strip() if exercise_name else ""
                    concept_data['exercise_type'] = exercise_type if exercise_type != "해당 없음" else ""
                    concept_data['equipment'] = [eq for eq in exercise_equipment if eq != "해당 없음"]

                    # 크로스핏 전용 필드
                    if exercise_subcategory == "크로스핏":
                        concept_data['reps'] = reps.strip() if reps else ""
                elif concept_category == "영양":
                    concept_data['nutrition_type'] = nutrition_type if nutrition_type != "해당 없음" else ""
                    concept_data['meal_type'] = meal_type
                # 건강 카테고리는 별도 필드 없음

                # === Step 1: Duplicate Check ===
                st.header("[STEP 1] 중복 검사")

                with st.spinner("[SEARCH] 유사 개념 검색 중..."):
                    try:
                        from rag_engine_multi_domain import multi_domain_rag_engine

                        # Use fitness_knowledge collection
                        collection_name = 'fitness_knowledge'
                        collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(
                            collection_name,
                            metadata={
                                "description": "Fitness and nutrition knowledge base",
                                "domain": "fitness",
                                "embedding_model": "models/text-embedding-004",
                                "embedding_dim": 768
                            }
                        )

                        # Search for similar concepts
                        search_parts = []
                        if concept_text.strip():
                            search_parts.append(concept_text)
                        if concept_data['keywords']:
                            search_parts.append(' '.join(concept_data['keywords']))
                        search_text = ' '.join(search_parts) if search_parts else "fitness concept"

                        results = collection.query(
                            query_texts=[search_text],
                            n_results=5,
                            where={"type": "fitness_concept"}
                        )

                        max_similarity = 0.0
                        is_duplicate = False

                        if results.get('distances') and results['distances'][0]:
                            distances = results['distances'][0]
                            similarities = [1 - d for d in distances]
                            max_similarity = max(similarities) if similarities else 0.0

                            if max_similarity >= duplicate_threshold:
                                is_duplicate = True
                                st.warning(f"[DUPLICATE] 중복 가능성 높음 (최대 유사도: {max_similarity:.3f})")
                            else:
                                st.success(f"[UNIQUE] 새로운 개념 (최대 유사도: {max_similarity:.3f})")

                            # Show top results
                            if results.get('documents') and results['documents'][0]:
                                with st.expander("[DETAILS] 유사 개념 결과", expanded=False):
                                    for i, (doc, sim) in enumerate(zip(results['documents'][0][:3], similarities[:3])):
                                        st.write(f"**{i+1}위** (유사도: {sim:.3f})")
                                        st.write(doc[:200] + "..." if len(doc) > 200 else doc)
                                        st.divider()
                        else:
                            st.info("[INFO] 첫 번째 개념입니다.")

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
                            doc_parts = []
                            doc_parts.append(f"분류: {concept_data['category']}")
                            if concept_data['concept_text']:
                                doc_parts.append(f"설명: {concept_data['concept_text']}")
                            if concept_data['keywords']:
                                doc_parts.append(f"키워드: {', '.join(concept_data['keywords'])}")
                            if concept_data['difficulty']:
                                doc_parts.append(f"난이도: {concept_data['difficulty']}")
                            if concept_data['target_goal']:
                                doc_parts.append(f"목표: {', '.join(concept_data['target_goal'])}")

                            # Add category-specific info
                            if concept_category == "운동":
                                if concept_data.get('exercise_type'):
                                    doc_parts.append(f"운동 유형: {concept_data['exercise_type']}")
                                if concept_data.get('equipment'):
                                    doc_parts.append(f"장비: {', '.join(concept_data['equipment'])}")
                            elif concept_category == "영양":
                                if concept_data.get('nutrition_type'):
                                    doc_parts.append(f"영양소: {concept_data['nutrition_type']}")
                                if concept_data.get('meal_type'):
                                    doc_parts.append(f"식사: {', '.join(concept_data['meal_type'])}")
                            # 건강 카테고리는 별도 필드 없음

                            if concept_data['tags']:
                                doc_parts.append(f"태그: {', '.join(concept_data['tags'])}")
                            if concept_data['hasImage']:
                                doc_parts.append(f"이미지: {len(concept_data['images'])}개 첨부")

                            full_document = '\n'.join(doc_parts)

                            # Prepare metadata
                            title_text = concept_data['concept_text'] or ', '.join(concept_data['keywords']) or f"{concept_data['category']} 개념"
                            desc_text = concept_data['concept_text'] or f"{concept_data['category']} - {concept_data['difficulty']}"

                            # Extract image URLs for metadata
                            image_url = ""
                            image_urls = ""
                            local_image_path = ""

                            if concept_data['hasImage'] and concept_data['images']:
                                # Get first image URL (Firebase or local)
                                first_image = concept_data['images'][0]
                                image_url = first_image.get('public_url') or first_image.get('local_path', '')

                                # Get all image URLs (comma-separated)
                                all_urls = []
                                for img in concept_data['images']:
                                    url = img.get('public_url') or img.get('local_path', '')
                                    if url:
                                        all_urls.append(url)
                                image_urls = ', '.join(all_urls)

                                # Get local path for first image
                                local_image_path = first_image.get('local_path', '')

                            metadata = {
                                'title': title_text[:100],
                                'description': desc_text[:500],
                                'category': concept_data['category'],
                                'difficulty': concept_data['difficulty'] if concept_data['difficulty'] else "",
                                'keywords': ', '.join(concept_data['keywords']),
                                'tags': ', '.join(concept_data['tags']),
                                'target_goal': ', '.join(concept_data['target_goal']),
                                'createdBy': concept_data['createdBy'],
                                'createdAt': concept_data['created_at'],
                                'hasImage': concept_data['hasImage'],
                                'imageUrl': image_url,
                                'imageUrls': image_urls,
                                'localImagePath': local_image_path,
                                'imageCount': len(concept_data['images']) if concept_data['images'] else 0,
                                'type': 'fitness_concept'
                            }

                            # Add category-specific metadata (only if not empty)
                            if concept_category == "운동":
                                metadata['exercise_type'] = concept_data.get('exercise_type', '')
                                metadata['equipment'] = ', '.join(concept_data.get('equipment', []))
                            elif concept_category == "영양":
                                metadata['nutrition_type'] = concept_data.get('nutrition_type', '')
                                metadata['meal_type'] = ', '.join(concept_data.get('meal_type', []))
                            # 건강 카테고리는 별도 메타데이터 없음

                            # Save to ChromaDB with direct embedding
                            collection.add(
                                ids=[concept_data['id']],
                                documents=[full_document],
                                metadatas=[metadata]
                            )

                            st.success(f"[SUCCESS] ChromaDB 저장 완료!")
                            st.success(f"[SUCCESS] 문서 ID: {concept_data['id']}")

                            # === Step 3: Firebase Save ===
                            st.subheader("[STEP 3] Firebase 저장")

                            try:
                                from firebase_service import firebase_service

                                # Prepare Firebase data
                                firebase_data = {
                                    'id': concept_data['id'],
                                    'type': 'fitness_concept',
                                    'category': concept_data['category'],
                                    'concept_text': concept_data['concept_text'],
                                    'keywords': concept_data['keywords'],
                                    'difficulty': concept_data['difficulty'],
                                    'target_goal': concept_data['target_goal'],
                                    'tags': concept_data['tags'],
                                    'related_concepts': concept_data['related_concepts'],
                                    'createdAt': concept_data['created_at'],
                                    'createdBy': concept_data['createdBy'],
                                    'hasImage': concept_data['hasImage'],
                                    'images': concept_data['images'],
                                    'similarity_check': {
                                        'max_similarity': max_similarity,
                                        'is_duplicate': is_duplicate
                                    }
                                }

                                # Add category-specific fields
                                if concept_category == "운동":
                                    firebase_data['exercise_subcategory'] = concept_data.get('exercise_subcategory', '')
                                    firebase_data['exercise_name'] = concept_data.get('exercise_name', '')
                                    firebase_data['exercise_type'] = concept_data.get('exercise_type', '')
                                    firebase_data['equipment'] = concept_data.get('equipment', [])
                                    # 크로스핏 전용 필드
                                    if exercise_subcategory == "크로스핏":
                                        firebase_data['reps'] = concept_data.get('reps', '')
                                elif concept_category == "영양":
                                    firebase_data['nutrition_type'] = concept_data.get('nutrition_type', '')
                                    firebase_data['meal_type'] = concept_data.get('meal_type', [])
                                # 건강 카테고리는 별도 필드 없음

                                # Save to fitness_concepts collection
                                upload_result = firebase_service.add_fitness_concept(firebase_data)

                                if upload_result.get('success'):
                                    st.success(f"[SUCCESS] Firebase 저장 완료!")
                                    st.success(f"[SUCCESS] 문서 ID: {upload_result.get('id', 'N/A')}")
                                else:
                                    st.warning(f"[WARNING] Firebase 저장 실패: {upload_result.get('message', 'Unknown error')}")

                            except Exception as e:
                                st.warning(f"[WARNING] Firebase 저장 실패: {e}")
                                import traceback
                                st.error(f"상세 오류: {traceback.format_exc()}")

                            # Final success message
                            st.balloons()
                            st.success("[COMPLETE] 운동/영양 개념 저장이 완료되었습니다!")

                            # Clear session state after successful save
                            if 'fitness_compressed_images' in st.session_state:
                                del st.session_state.fitness_compressed_images

                        except Exception as e:
                            st.error(f"[ERROR] 저장 실패: {e}")
                            import traceback
                            st.error(f"[ERROR] 상세 오류: {traceback.format_exc()}")
                else:
                    st.info("[INFO] 중복으로 인해 저장이 취소되었습니다.")


if __name__ == "__main__":
    fitness_concept_input_form()
