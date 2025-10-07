"""
Manual Concept Input Form - Simplified Version without AI Analysis
"""
import streamlit as st
import uuid
from datetime import datetime


def get_image_library():
    """Fetch all images from ChromaDB collections"""
    try:
        from rag_engine_multi_domain import multi_domain_rag_engine

        all_images = []
        collections = ['nursing_questions', 'medical_problems', 'fitness_concepts', 'medical_concepts']

        for coll_name in collections:
            try:
                collection = multi_domain_rag_engine.chroma_client.get_collection(coll_name)
                results = collection.get(
                    where={"hasImage": True},
                    include=['metadatas']
                )

                if results and results.get('metadatas'):
                    for metadata in results['metadatas']:
                        if metadata.get('imageUrl') or metadata.get('imageUrls'):
                            image_urls = metadata.get('imageUrls', '').split(', ') if metadata.get('imageUrls') else [metadata.get('imageUrl', '')]

                            for url in image_urls:
                                if url:
                                    all_images.append({
                                        'url': url,
                                        'title': metadata.get('title', '')[:100],
                                        'subject': metadata.get('subject', ''),
                                        'field': metadata.get('field', ''),
                                        'collection': coll_name,
                                        'created_at': metadata.get('createdAt', '')
                                    })
            except:
                continue

        return all_images
    except Exception as e:
        st.warning(f"[WARNING] 이미지 라이브러리 로딩 실패: {e}")
        return []


def handle_image_upload():
    """Handle image upload with automatic compression"""
    st.subheader("[IMAGE] 이미지 관리")

    # Image source selection
    image_source = st.radio(
        "이미지 선택 방식:",
        ["📁 기존 이미지 라이브러리에서 선택", "📤 새 이미지 업로드"],
        horizontal=True,
        key="concept_image_source"
    )

    if image_source == "📁 기존 이미지 라이브러리에서 선택":
        st.info("[LIBRARY] 기존에 업로드된 이미지를 검색하고 선택하세요")

        # Get all images from library
        with st.spinner("[LOADING] 이미지 라이브러리 로딩 중..."):
            image_library = get_image_library()

        if not image_library:
            st.warning("[EMPTY] 라이브러리에 이미지가 없습니다. 새 이미지를 업로드하세요.")
            return []

        # Search and filter
        col1, col2 = st.columns([2, 1])
        with col1:
            search_query = st.text_input(
                "검색어",
                placeholder="제목, 과목, 분야로 검색...",
                key="concept_library_search"
            )
        with col2:
            filter_field = st.selectbox(
                "분야 필터",
                ["전체", "간호", "의학", "fitness"],
                key="concept_library_filter"
            )

        # Filter images based on search
        filtered_images = image_library
        if search_query:
            filtered_images = [
                img for img in filtered_images
                if search_query.lower() in img['title'].lower() or
                   search_query.lower() in img['subject'].lower()
            ]

        if filter_field != "전체":
            filtered_images = [img for img in filtered_images if img['field'] == filter_field]

        st.info(f"[RESULTS] {len(filtered_images)}개 이미지 발견")

        if filtered_images:
            # Display images in grid with checkboxes
            selected_images = []

            # Create grid (3 columns)
            num_cols = 3
            for i in range(0, len(filtered_images[:12]), num_cols):  # Show max 12
                cols = st.columns(num_cols)
                for col_idx, img_data in enumerate(filtered_images[i:i+num_cols]):
                    with cols[col_idx]:
                        try:
                            st.image(img_data['url'], width=150, use_container_width=True)
                        except:
                            st.write("🖼️ [이미지]")

                        selected = st.checkbox(
                            f"{img_data['subject']} - {img_data['title'][:30]}...",
                            key=f"select_concept_library_img_{i+col_idx}"
                        )

                        if selected:
                            selected_images.append(img_data)

            if len(filtered_images) > 12:
                st.info(f"[MORE] +{len(filtered_images) - 12}개 이미지가 더 있습니다. 검색어로 좁혀보세요.")

            # Store selected images in session state
            if selected_images:
                st.success(f"[SELECTED] {len(selected_images)}개 이미지 선택됨")
                # Convert to compressed image format for compatibility
                compressed_images = []
                for img in selected_images:
                    compressed_images.append({
                        'original_name': img['title'],
                        'compressed_bytes': None,  # Already uploaded
                        'file_ext': 'webp',
                        'original_size': 0,
                        'compressed_size': 0,
                        'compression_ratio': 0,
                        'from_library': True,
                        'public_url': img['url']
                    })
                st.session_state.compressed_images = compressed_images
                return compressed_images

        return []

    else:  # 새 이미지 업로드
        uploaded_images = st.file_uploader(
            "개념 관련 이미지 (여러 개 선택 가능)",
            type=['png', 'jpg', 'jpeg', 'webp'],
            accept_multiple_files=True,
            help="개념과 관련된 의료 이미지, 도식, 차트 등을 업로드하세요 (PNG, JPG, JPEG, WebP 지원)",
            key="concept_images"
        )

    processed_images = []

    if uploaded_images:
        from image_utils import image_processor
        import hashlib

        st.success(f"[AUTO] {len(uploaded_images)}개 이미지 자동 압축 중...")

        # Auto-process images immediately
        with st.spinner("[PROCESSING] 이미지 압축 및 중복 검사 중..."):
            # Compress images only (no Firebase upload yet)
            compressed_images = []

            for idx, uploaded_file in enumerate(uploaded_images):
                # Generate hash for duplicate detection
                image_bytes = uploaded_file.getvalue()
                image_hash = hashlib.sha256(image_bytes).hexdigest()

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
                        'compression_ratio': compression_ratio,
                        'image_hash': image_hash
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
            st.session_state.compressed_images = compressed_images
            st.info("[INFO] 이미지가 준비되었습니다. 개념 정보를 입력하고 [SAVE] 버튼을 누르면 저장됩니다.")
        else:
            st.error("[ERROR] 이미지 압축에 실패했습니다")

    # Check if there are compressed images in session state
    if 'compressed_images' in st.session_state and not uploaded_images:
        compressed_images = st.session_state.compressed_images
        st.info(f"[READY] {len(compressed_images)}개 압축된 이미지가 저장 대기 중입니다")
        processed_images = compressed_images

    return st.session_state.get('compressed_images', [])


def concept_manual_input_form():
    """Manual form for inputting medical concepts without AI analysis"""
    st.subheader("[MANUAL] 의학 개념 수동 입력")

    # Handle image upload outside of form
    handle_image_upload()

    st.divider()

    with st.form("concept_manual_form"):

        # Manual input fields based on user requirements
        st.subheader("[INPUT] 개념 정보 직접 입력")

        col1, col2 = st.columns(2)

        with col1:
            concept_text = st.text_area(
                "개념 원문",
                height=150,
                help="개념에 대한 상세한 설명을 입력하세요 (선택사항)",
                key="concept_original_text"
            )

            keywords = st.text_input(
                "keywords",
                help="핵심 키워드를 쉼표로 구분하여 입력 (예: 무균술, 감염관리, 수술)",
                key="concept_keywords"
            )


            related_concepts = st.text_input(
                "related_concepts",
                help="연관 개념을 쉼표로 구분하여 입력 (선택사항)",
                key="concept_related_concepts"
            )

        with col2:
            concepts = st.text_input(
                "concepts",
                help="관련 개념 목록을 쉼표로 구분하여 입력 (선택사항)",
                key="concept_concepts"
            )

            tags = st.text_input(
                "tags",
                help="태그를 쉼표로 구분하여 입력 (선택사항)",
                key="concept_tags"
            )

            category = st.selectbox(
                "category *",
                options=["간호", "의학", "공통", "기타"],
                help="개념이 속하는 분야를 선택하세요",
                key="concept_category"
            )

        # Duplicate check settings
        duplicate_threshold = st.slider(
            "중복 유사도 임계값",
            min_value=0.70,
            max_value=0.99,
            value=0.92,
            step=0.01,
            help="이 값 이상의 유사도를 가진 개념이 있으면 중복으로 판단 (권장: 0.92-0.95)",
            key="concept_duplicate_threshold"
        )

        st.info("""
        **유사도 기준:**
        - 0.95+ : 거의 동일
        - 0.90-0.95 : 매우 유사 (권장 중복 기준)
        - 0.85-0.90 : 유사한 주제
        - 0.85 미만 : 다른 개념
        """)

        submitted = st.form_submit_button("[SAVE] 개념 저장")

        if submitted:
            # Get compressed images from session state
            compressed_images = st.session_state.get('compressed_images', [])

            # Upload compressed images to Firebase Storage now
            processed_images = []
            if compressed_images:
                from image_utils import image_processor

                # Separate library images from new uploads
                library_images = [img for img in compressed_images if img.get('from_library')]
                new_uploads = [img for img in compressed_images if not img.get('from_library')]

                if library_images:
                    st.info(f"[REUSE] {len(library_images)}개 이미지를 라이브러리에서 재사용")
                    for img_data in library_images:
                        processed_images.append({
                            'original_name': img_data['original_name'],
                            'file_name': img_data['original_name'],
                            'public_url': img_data['public_url'],
                            'local_path': None,
                            'content_type': 'image/webp',
                            'original_size': 0,
                            'compressed_size': 0,
                            'compression_ratio': 0,
                            'uploaded_at': datetime.now().isoformat(),
                            'from_library': True
                        })

                if new_uploads:
                    st.info(f"[UPLOAD] {len(new_uploads)}개 새 이미지를 Firebase Storage에 업로드 중...")

                    for img_data in new_uploads:
                        # Generate unique filename with hash
                        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                        image_hash_short = img_data.get('image_hash', str(uuid.uuid4()))[:8]
                        file_name = f"concept_{timestamp}_{image_hash_short}.{img_data['file_ext']}"

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
                            'uploaded_at': datetime.now().isoformat(),
                            'image_hash': img_data.get('image_hash')
                        })

                if processed_images:
                    st.success(f"[SUCCESS] 총 {len(processed_images)}개 이미지 준비 완료! (재사용: {len(library_images)}, 신규: {len(new_uploads)})")

            # Validate required fields - allow saving with just images or keywords
            missing_fields = []
            has_content = bool(concept_text.strip()) or bool(keywords.strip()) or bool(processed_images)

            if not has_content:
                st.error("[ERROR] 개념 원문, keywords, 또는 이미지 중 하나는 반드시 입력해야 합니다")
            else:
                # Create concept data structure
                concept_data = {
                    'id': str(uuid.uuid4()),
                    'type': 'concept',
                    'original_text': concept_text.strip() if concept_text else '',
                    'keywords': [k.strip() for k in keywords.split(',') if k.strip()] if keywords else [],
                    'related_concepts': [r.strip() for r in related_concepts.split(',') if r.strip()] if related_concepts else [],
                    'concepts': [c.strip() for c in concepts.split(',') if c.strip()] if concepts else [],
                    'tags': [t.strip() for t in tags.split(',') if t.strip()] if tags else [],
                    'category': category,
                    'created_at': datetime.now().isoformat(),
                    'hasImage': bool(processed_images),
                    'images': processed_images if processed_images else [],
                    'createdBy': 'streamlit_user'
                }

                # === Step 1: Duplicate Check ===
                st.header("[STEP 1] 중복 검사")

                with st.spinner("[SEARCH] 유사 개념 검색 중..."):
                    try:
                        from rag_engine_multi_domain import multi_domain_rag_engine
                        from rag_engine import rag_engine

                        # Select collection based on category
                        category_lower = concept_data['category'].lower()
                        if category_lower in ['간호', '의학', '공통', '기타']:
                            collection_name = 'medical_concepts'
                        elif category_lower in ['운동', '영양', '건강']:
                            collection_name = 'fitness_concepts'
                        else:
                            collection_name = 'medical_concepts'  # Default

                        collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(collection_name)

                        # Search for similar concepts
                        search_parts = []
                        if concept_text.strip():
                            search_parts.append(concept_text)
                        if concept_data['keywords']:
                            search_parts.append(' '.join(concept_data['keywords']))
                        search_text = ' '.join(search_parts) if search_parts else "concept"
                        search_embedding = rag_engine.generate_embedding(search_text)
                        results = collection.query(
                            query_embeddings=[search_embedding],
                            n_results=5,
                            where={"type": "concept"}
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
                            # Select correct collection for saving
                            from rag_engine_multi_domain import multi_domain_rag_engine
                            category_lower = concept_data['category'].lower()
                            if category_lower in ['간호', '의학', '공통', '기타']:
                                save_collection_name = 'medical_concepts'
                            elif category_lower in ['운동', '영양', '건강']:
                                save_collection_name = 'fitness_concepts'
                            else:
                                save_collection_name = 'medical_concepts'  # Default

                            save_collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(save_collection_name)

                            # Create full document for embedding
                            doc_parts = []
                            if concept_data['original_text']:
                                doc_parts.append(f"개념: {concept_data['original_text']}")
                            if concept_data['keywords']:
                                doc_parts.append(f"키워드: {', '.join(concept_data['keywords'])}")
                            if concept_data['related_concepts']:
                                doc_parts.append(f"연관개념: {', '.join(concept_data['related_concepts'])}")
                            doc_parts.append(f"분야: {concept_data['category']}")
                            if concept_data['tags']:
                                doc_parts.append(f"태그: {', '.join(concept_data['tags'])}")
                            if concept_data['hasImage']:
                                doc_parts.append(f"이미지: {len(concept_data['images'])}개 첨부")

                            full_document = '\n'.join(doc_parts) if doc_parts else f"분야: {concept_data['category']}"

                            # Prepare metadata
                            title_text = concept_data['original_text'] or ', '.join(concept_data['keywords']) or f"{concept_data['category']} 개념"
                            desc_text = concept_data['original_text'] or ', '.join(concept_data['keywords']) or f"{concept_data['category']} 분야 개념"

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
                                'keywords': ', '.join(concept_data['keywords']),
                                'tags': ', '.join(concept_data['tags']),
                                'createdBy': concept_data['createdBy'],
                                'createdAt': concept_data['created_at'],
                                'hasImage': concept_data['hasImage'],
                                'imageUrl': image_url,
                                'imageUrls': image_urls,
                                'localImagePath': local_image_path,
                                'imageCount': len(concept_data['images']) if concept_data['images'] else 0,
                                'type': 'concept'
                            }

                            # Generate 768d embedding explicitly with gemini-embedding-001
                            import google.generativeai as genai
                            result = genai.embed_content(
                                model="gemini-embedding-001",
                                content=full_document,
                                output_dimensionality=768
                            )
                            embedding_768d = result['embedding'] if isinstance(result, dict) else result

                            # Save to ChromaDB with explicit 768d embedding
                            save_collection.add(
                                ids=[concept_data['id']],
                                documents=[full_document],
                                embeddings=[embedding_768d],
                                metadatas=[metadata]
                            )

                            st.success(f"[COLLECTION] {save_collection_name}에 저장됨")

                            st.success(f"[SUCCESS] ChromaDB 저장 완료!")
                            st.success(f"[SUCCESS] 문서 ID: {concept_data['id']}")

                            # === Step 3: Firebase Save ===
                            st.subheader("[STEP 3] Firebase 저장")

                            try:
                                from firebase_service import firebase_service

                                firebase_data = {
                                    'id': concept_data['id'],
                                    'original_text': concept_data['original_text'],
                                    'keywords': concept_data['keywords'],
                                    'related_concepts': concept_data['related_concepts'],
                                    'concepts': concept_data['concepts'],
                                    'tags': concept_data['tags'],
                                    'category': concept_data['category'],
                                    'createdAt': concept_data['created_at'],
                                    'createdBy': concept_data['createdBy'],
                                    'hasImage': concept_data['hasImage'],
                                    'images': concept_data['images'],
                                    'type': 'concept',
                                    'similarity_check': {
                                        'max_similarity': max_similarity,
                                        'is_duplicate': is_duplicate
                                    }
                                }

                                upload_result = firebase_service.add_concept(firebase_data)

                                if upload_result.get('success'):
                                    st.success(f"[SUCCESS] Firebase 저장 완료!")
                                    st.success(f"[SUCCESS] 문서 ID: {upload_result.get('id', 'N/A')}")
                                else:
                                    st.warning(f"[WARNING] Firebase 저장 실패: {upload_result.get('message', 'Unknown error')}")

                            except Exception as e:
                                st.warning(f"[WARNING] Firebase 저장 실패: {e}")

                            # Final success message
                            st.balloons()
                            st.success("[COMPLETE] 개념 저장이 완료되었습니다!")

                            # Clear session state after successful save
                            if 'compressed_images' in st.session_state:
                                del st.session_state.compressed_images

                        except Exception as e:
                            st.error(f"[ERROR] 저장 실패: {e}")
                            import traceback
                            st.error(f"[ERROR] 상세 오류: {traceback.format_exc()}")
                else:
                    st.info("[INFO] 중복으로 인해 저장이 취소되었습니다.")


if __name__ == "__main__":
    concept_manual_input_form()
