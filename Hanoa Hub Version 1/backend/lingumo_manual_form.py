"""
Lingumo Manual Input Form - Language Learning Content (Words and Sentences)
"""
import streamlit as st
import uuid
from datetime import datetime


def handle_lingumo_audio_upload():
    """Handle audio file upload or TTS generation for language learning content"""
    st.subheader("🔊 오디오 설정 (선택사항)")

    audio_col1, audio_col2 = st.columns(2)

    with audio_col1:
        auto_generate_tts = st.checkbox(
            "TTS 자동 생성",
            value=False,
            help="저장 시 Google TTS/ElevenLabs로 자동 생성 (API 키 필요)",
            key="auto_generate_tts"
        )

        if auto_generate_tts:
            st.info("💡 저장 시 자동으로 음성이 생성됩니다 (API 키 설정 필요)")

    with audio_col2:
        if not auto_generate_tts:
            uploaded_audio = st.file_uploader(
                "오디오 파일 업로드",
                type=['mp3', 'wav', 'ogg', 'm4a'],
                help="MP3, WAV, OGG, M4A 형식 지원",
                key="lingumo_audio"
            )

            if uploaded_audio:
                audio_bytes = uploaded_audio.getvalue()
                file_size = len(audio_bytes)

                st.success(f"✅ 업로드됨: {uploaded_audio.name} ({file_size / 1024:.1f} KB)")

                # Preview audio
                st.audio(audio_bytes, format=f'audio/{uploaded_audio.name.split(".")[-1]}')

                st.session_state.lingumo_audio_file = {
                    'original_name': uploaded_audio.name,
                    'audio_bytes': audio_bytes,
                    'file_size': file_size,
                    'file_ext': uploaded_audio.name.split('.')[-1]
                }

            if 'lingumo_audio_file' in st.session_state and not uploaded_audio:
                audio_data = st.session_state.lingumo_audio_file
                st.info(f"[READY] {audio_data['original_name']}")
        else:
            st.info("📢 단어: Google TTS\n🎙️ 문장: ElevenLabs")

    return st.session_state.get('lingumo_audio_file', None)


def handle_lingumo_image_upload():
    """Handle image upload for language learning content"""
    st.subheader("[IMAGE] 이미지 업로드 (선택사항)")

    uploaded_images = st.file_uploader(
        "언어 학습 관련 이미지 (여러 개 선택 가능)",
        type=['png', 'jpg', 'jpeg', 'webp'],
        accept_multiple_files=True,
        help="단어 이미지, 문법 차트 등을 업로드하세요 (PNG, JPG, JPEG, WebP 지원)",
        key="lingumo_images"
    )

    if uploaded_images:
        from image_utils import image_processor

        st.success(f"[AUTO] {len(uploaded_images)}개 이미지 자동 압축 중...")

        with st.spinner("[PROCESSING] 이미지 압축 중..."):
            compressed_images = []
            for idx, uploaded_file in enumerate(uploaded_images):
                compressed_bytes, file_ext = image_processor.compress_image(uploaded_file)

                if compressed_bytes:
                    original_size = len(uploaded_file.getvalue())
                    compressed_size = len(compressed_bytes)
                    compression_ratio = (1 - compressed_size / original_size) * 100

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

            cols = st.columns(min(len(compressed_images), 3))
            for idx, img_data in enumerate(compressed_images[:3]):
                with cols[idx % 3]:
                    st.image(img_data['compressed_bytes'],
                            caption=f"{img_data['original_name']}\n압축률: {img_data['compression_ratio']:.1f}%",
                            width=150)

            if len(compressed_images) > 3:
                st.info(f"[INFO] 추가 {len(compressed_images)-3}개 이미지")

            st.session_state.lingumo_compressed_images = compressed_images
            st.info("[INFO] 이미지가 준비되었습니다. 내용을 입력하고 [SAVE] 버튼을 누르면 저장됩니다.")
        else:
            st.error("[ERROR] 이미지 압축에 실패했습니다")

    if 'lingumo_compressed_images' in st.session_state and not uploaded_images:
        compressed_images = st.session_state.lingumo_compressed_images
        st.info(f"[READY] {len(compressed_images)}개 압축된 이미지가 저장 대기 중입니다")

    return st.session_state.get('lingumo_compressed_images', [])


def lingumo_content_input_form():
    """Manual form for inputting language learning content (words and sentences)"""
    st.subheader("🌍 언어 학습 콘텐츠 수동 입력")

    handle_lingumo_audio_upload()

    st.divider()

    handle_lingumo_image_upload()

    st.divider()

    with st.form("lingumo_manual_form"):

        st.subheader("[INPUT] 학습 내용 직접 입력")

        col1, col2 = st.columns(2)

        with col1:
            content_type = st.selectbox(
                "콘텐츠 유형 *",
                options=["단어", "문장", "문법"],
                help="학습 콘텐츠 유형을 선택하세요",
                key="lingumo_content_type"
            )

            language = st.selectbox(
                "언어 *",
                options=["영어", "일본어", "중국어", "스페인어", "프랑스어", "독일어", "기타"],
                help="학습할 언어를 선택하세요",
                key="lingumo_language"
            )

            content_text = st.text_area(
                "내용 (단어/문장/문법)",
                height=100,
                help="학습할 단어, 문장 또는 문법을 입력하세요",
                key="lingumo_content_text"
            )

            translation = st.text_area(
                "번역/의미",
                height=100,
                help="한국어 번역 또는 의미를 입력하세요",
                key="lingumo_translation"
            )

        with col2:
            difficulty = st.selectbox(
                "난이도",
                options=["초급", "중급", "고급", "원어민"],
                help="학습 난이도를 선택하세요",
                key="lingumo_difficulty"
            )

            if content_type == "단어":
                pronunciation = st.text_input(
                    "발음",
                    help="발음 표기 (예: /prəˌnʌnsiˈeɪʃn/)",
                    key="lingumo_pronunciation"
                )

                part_of_speech = st.selectbox(
                    "품사",
                    options=["명사", "동사", "형용사", "부사", "전치사", "접속사", "기타"],
                    help="품사를 선택하세요",
                    key="lingumo_pos"
                )

            example_sentence = st.text_area(
                "예문 (선택사항)",
                height=80,
                help="예문을 입력하세요",
                key="lingumo_example"
            )

            tags = st.text_input(
                "태그",
                help="태그를 쉼표로 구분하여 입력 (예: TOEIC, 비즈니스, 여행)",
                key="lingumo_tags"
            )

        duplicate_threshold = st.slider(
            "중복 유사도 임계값",
            min_value=0.70,
            max_value=0.99,
            value=0.92,
            step=0.01,
            help="이 값 이상의 유사도를 가진 콘텐츠가 있으면 중복으로 판단 (권장: 0.92-0.95)",
            key="lingumo_duplicate_threshold"
        )

        st.info("""
        **유사도 기준:**
        - 0.95+ : 거의 동일
        - 0.90-0.95 : 매우 유사 (권장 중복 기준)
        - 0.85-0.90 : 유사한 주제
        - 0.85 미만 : 다른 콘텐츠
        """)

        submitted = st.form_submit_button("[SAVE] 콘텐츠 저장")

        if submitted:
            # Handle audio (upload or auto-generate)
            audio_file = st.session_state.get('lingumo_audio_file', None)
            auto_generate = st.session_state.get('auto_generate_tts', False)
            audio_url = None

            # Option 1: Manual upload
            if audio_file and not auto_generate:
                st.info(f"[UPLOAD] 오디오 파일을 Firebase Storage에 업로드 중...")
                try:
                    from firebase_service import firebase_service

                    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                    unique_id = str(uuid.uuid4())[:8]
                    file_name = f"audio/lingumo/lingumo_{timestamp}_{unique_id}.{audio_file['file_ext']}"

                    audio_url = firebase_service.upload_audio_to_storage(
                        audio_file['audio_bytes'],
                        file_name,
                        f'audio/{audio_file["file_ext"]}'
                    )

                    if audio_url:
                        st.success(f"[SUCCESS] 오디오 Firebase 업로드 완료!")
                    else:
                        st.warning("[WARNING] 오디오 업로드 실패")

                except Exception as e:
                    st.error(f"[ERROR] 오디오 업로드 실패: {e}")

            # Option 2: Auto-generate TTS
            elif auto_generate and content_text.strip():
                st.info(f"[TTS] 오디오 자동 생성 중...")
                try:
                    from audio_utils import audio_generator

                    provider = "google" if content_type == "단어" else "elevenlabs"
                    content_id = str(uuid.uuid4())

                    audio_metadata = audio_generator.generate_and_upload_audio(
                        text=content_text.strip(),
                        language=language,
                        voice_name="en-US-Neural2-A (미국 여성1)",  # 기본 음성
                        provider=provider,
                        content_id=content_id
                    )

                    if audio_metadata:
                        audio_url = audio_metadata['audio_url']
                        st.success(f"[SUCCESS] TTS 오디오 생성 및 업로드 완료!")
                    else:
                        st.warning("[WARNING] TTS 생성 실패 (API 키를 확인하세요)")

                except Exception as e:
                    st.warning(f"[WARNING] TTS 생성 실패: {e}")

            # Handle image upload
            compressed_images = st.session_state.get('lingumo_compressed_images', [])

            processed_images = []
            if compressed_images:
                st.info(f"[UPLOAD] {len(compressed_images)}개 이미지를 Firebase Storage에 업로드 중...")
                from image_utils import image_processor

                for img_data in compressed_images:
                    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                    unique_id = str(uuid.uuid4())[:8]
                    file_name = f"lingumo_{timestamp}_{unique_id}.{img_data['file_ext']}"

                    local_path = image_processor.save_to_local(img_data['compressed_bytes'], file_name)

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

            missing_fields = []
            has_content = bool(content_text.strip()) or bool(translation.strip()) or bool(processed_images)

            if not has_content:
                st.error("[ERROR] 내용, 번역, 또는 이미지 중 하나는 반드시 입력해야 합니다")
            else:
                content_data = {
                    'id': str(uuid.uuid4()),
                    'type': 'lingumo_content',
                    'content_type': content_type,
                    'language': language,
                    'content_text': content_text.strip() if content_text else '',
                    'translation': translation.strip() if translation else '',
                    'difficulty': difficulty,
                    'example_sentence': example_sentence.strip() if example_sentence else '',
                    'tags': [t.strip() for t in tags.split(',') if t.strip()] if tags else [],
                    'created_at': datetime.now().isoformat(),
                    'hasImage': bool(processed_images),
                    'images': processed_images if processed_images else [],
                    'has_audio': bool(audio_url),
                    'audio_url': audio_url if audio_url else '',
                    'createdBy': 'streamlit_user'
                }

                if content_type == "단어":
                    content_data['pronunciation'] = pronunciation.strip() if pronunciation else ''
                    content_data['part_of_speech'] = part_of_speech

                # === Step 1: Duplicate Check ===
                st.header("[STEP 1] 중복 검사")

                with st.spinner("[SEARCH] 유사 콘텐츠 검색 중..."):
                    try:
                        from rag_engine_multi_domain import multi_domain_rag_engine

                        collection_name = 'lingumo_knowledge'
                        collection = multi_domain_rag_engine.chroma_client.get_or_create_collection(
                            collection_name,
                            metadata={
                                "description": "Language learning content base",
                                "domain": "lingumo",
                                "embedding_model": "models/text-embedding-004",
                                "embedding_dim": 768
                            }
                        )

                        search_parts = []
                        if content_text.strip():
                            search_parts.append(content_text)
                        if translation.strip():
                            search_parts.append(translation)
                        search_text = ' '.join(search_parts) if search_parts else "lingumo content"

                        results = collection.query(
                            query_texts=[search_text],
                            n_results=5,
                            where={"type": "lingumo_content"}
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
                                st.success(f"[UNIQUE] 새로운 콘텐츠 (최대 유사도: {max_similarity:.3f})")

                            if results.get('documents') and results['documents'][0]:
                                with st.expander("[DETAILS] 유사 콘텐츠 결과", expanded=False):
                                    for i, (doc, sim) in enumerate(zip(results['documents'][0][:3], similarities[:3])):
                                        st.write(f"**{i+1}위** (유사도: {sim:.3f})")
                                        st.write(doc[:200] + "..." if len(doc) > 200 else doc)
                                        st.divider()
                        else:
                            st.info("[INFO] 첫 번째 콘텐츠입니다.")

                    except Exception as e:
                        st.error(f"[ERROR] 중복 검사 실패: {e}")
                        max_similarity = 0.0
                        is_duplicate = False

                # === Step 2: TTS Audio Generation (if enabled) ===
                audio_metadata = None
                if st.session_state.get('enable_tts', False) and content_text.strip():
                    st.header("[STEP 2] TTS 오디오 생성")

                    with st.spinner("[TTS] 음성 파일 생성 및 업로드 중..."):
                        try:
                            from audio_utils import audio_generator

                            tts_voice = st.session_state.get('tts_voice', None)
                            if content_type == "단어":
                                provider = "google"
                            else:
                                provider = "elevenlabs"

                            if tts_voice:
                                audio_metadata = audio_generator.generate_and_upload_audio(
                                    text=content_text.strip(),
                                    language=language,
                                    voice_name=tts_voice,
                                    provider=provider,
                                    content_id=content_data['id']
                                )

                                if audio_metadata:
                                    st.success(f"✅ TTS 오디오 생성 완료!")
                                    st.success(f"🔗 Firebase URL: {audio_metadata['audio_url'][:50]}...")
                                else:
                                    st.warning("⚠️ TTS 오디오 생성 실패 (계속 진행합니다)")
                            else:
                                st.warning("⚠️ 음성이 선택되지 않음")

                        except Exception as e:
                            st.warning(f"⚠️ TTS 오디오 생성 실패: {e}")
                            import traceback
                            st.error(f"상세 오류: {traceback.format_exc()}")

                # === Step 3: Direct Embedding & Save ===
                if not is_duplicate or st.checkbox("중복이어도 저장하기"):
                    st.header("[STEP 3] 임베딩 및 저장")

                    with st.spinner("[SAVE] 벡터 임베딩 및 저장 중..."):
                        try:
                            doc_parts = []
                            doc_parts.append(f"언어: {content_data['language']}")
                            doc_parts.append(f"유형: {content_data['content_type']}")
                            if content_data['content_text']:
                                doc_parts.append(f"내용: {content_data['content_text']}")
                            if content_data['translation']:
                                doc_parts.append(f"번역: {content_data['translation']}")
                            doc_parts.append(f"난이도: {content_data['difficulty']}")

                            if content_type == "단어" and content_data.get('pronunciation'):
                                doc_parts.append(f"발음: {content_data['pronunciation']}")
                                doc_parts.append(f"품사: {content_data['part_of_speech']}")

                            if content_data['example_sentence']:
                                doc_parts.append(f"예문: {content_data['example_sentence']}")
                            if content_data['tags']:
                                doc_parts.append(f"태그: {', '.join(content_data['tags'])}")
                            if content_data['hasImage']:
                                doc_parts.append(f"이미지: {len(content_data['images'])}개 첨부")

                            full_document = '\n'.join(doc_parts)

                            title_text = content_data['content_text'] or content_data['translation'] or f"{content_data['language']} {content_data['content_type']}"
                            desc_text = f"{content_data['content_text']} - {content_data['translation']}"

                            image_url = ""
                            image_urls = ""
                            local_image_path = ""

                            if content_data['hasImage'] and content_data['images']:
                                first_image = content_data['images'][0]
                                image_url = first_image.get('public_url') or first_image.get('local_path', '')

                                all_urls = []
                                for img in content_data['images']:
                                    url = img.get('public_url') or img.get('local_path', '')
                                    if url:
                                        all_urls.append(url)
                                image_urls = ', '.join(all_urls)

                                local_image_path = first_image.get('local_path', '')

                            metadata = {
                                'title': title_text[:100],
                                'description': desc_text[:500],
                                'language': content_data['language'],
                                'content_type': content_data['content_type'],
                                'difficulty': content_data['difficulty'],
                                'tags': ', '.join(content_data['tags']),
                                'has_audio': content_data['has_audio'],
                                'audio_url': content_data['audio_url'],
                                'createdBy': content_data['createdBy'],
                                'createdAt': content_data['created_at'],
                                'hasImage': content_data['hasImage'],
                                'imageUrl': image_url,
                                'imageUrls': image_urls,
                                'localImagePath': local_image_path,
                                'imageCount': len(content_data['images']) if content_data['images'] else 0,
                                'type': 'lingumo_content'
                            }

                            if content_type == "단어":
                                metadata['pronunciation'] = content_data.get('pronunciation', '')
                                metadata['part_of_speech'] = content_data.get('part_of_speech', '')

                            collection.add(
                                ids=[content_data['id']],
                                documents=[full_document],
                                metadatas=[metadata]
                            )

                            st.success(f"[SUCCESS] ChromaDB 저장 완료!")
                            st.success(f"[SUCCESS] 문서 ID: {content_data['id']}")

                            # === Step 4: Firebase Save ===
                            st.subheader("[STEP 4] Firebase 저장")

                            try:
                                from firebase_service import firebase_service

                                firebase_data = {
                                    'id': content_data['id'],
                                    'type': 'lingumo_content',
                                    'content_type': content_data['content_type'],
                                    'language': content_data['language'],
                                    'content_text': content_data['content_text'],
                                    'translation': content_data['translation'],
                                    'difficulty': content_data['difficulty'],
                                    'example_sentence': content_data['example_sentence'],
                                    'tags': content_data['tags'],
                                    'createdAt': content_data['created_at'],
                                    'createdBy': content_data['createdBy'],
                                    'hasImage': content_data['hasImage'],
                                    'images': content_data['images'],
                                    'similarity_check': {
                                        'max_similarity': max_similarity,
                                        'is_duplicate': is_duplicate
                                    }
                                }

                                # Add audio to Firebase
                                firebase_data['has_audio'] = content_data['has_audio']
                                firebase_data['audio_url'] = content_data['audio_url']

                                if content_type == "단어":
                                    firebase_data['pronunciation'] = content_data.get('pronunciation', '')
                                    firebase_data['part_of_speech'] = content_data.get('part_of_speech', '')

                                upload_result = firebase_service.add_lingumo_content(firebase_data)

                                if upload_result.get('success'):
                                    st.success(f"[SUCCESS] Firebase 저장 완료!")
                                    st.success(f"[SUCCESS] 문서 ID: {upload_result.get('id', 'N/A')}")
                                else:
                                    st.warning(f"[WARNING] Firebase 저장 실패: {upload_result.get('message', 'Unknown error')}")

                            except Exception as e:
                                st.warning(f"[WARNING] Firebase 저장 실패: {e}")
                                import traceback
                                st.error(f"상세 오류: {traceback.format_exc()}")

                            st.balloons()
                            st.success("[COMPLETE] 언어 학습 콘텐츠 저장이 완료되었습니다!")

                            # Clean up session state
                            if 'lingumo_compressed_images' in st.session_state:
                                del st.session_state.lingumo_compressed_images
                            if 'lingumo_audio_file' in st.session_state:
                                del st.session_state.lingumo_audio_file

                        except Exception as e:
                            st.error(f"[ERROR] 저장 실패: {e}")
                            import traceback
                            st.error(f"[ERROR] 상세 오류: {traceback.format_exc()}")
                else:
                    st.info("[INFO] 중복으로 인해 저장이 취소되었습니다.")


if __name__ == "__main__":
    lingumo_content_input_form()
