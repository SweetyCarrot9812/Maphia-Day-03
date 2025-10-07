"""
Image processing utilities for Hanoa RAG System
Handles image compression and Firebase Storage upload
Uses Gemini 2.5 Flash for AI-powered compression with PIL fallback
"""
import io
import uuid
import base64
from datetime import datetime
from typing import List, Dict, Optional, Tuple
from PIL import Image
import streamlit as st

try:
    from firebase_admin import storage
    FIREBASE_STORAGE_AVAILABLE = True
except ImportError:
    FIREBASE_STORAGE_AVAILABLE = False

try:
    import google.generativeai as genai
    from config import GEMINI_API_KEY, GEMINI_MODEL
    genai.configure(api_key=GEMINI_API_KEY)
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False


class ImageProcessor:
    """Handles image compression and Firebase Storage operations"""

    def __init__(self, max_width: int = 1920, max_height: int = 1920, quality: int = 95):
        """
        Initialize image processor

        Args:
            max_width: Maximum width for compressed images (default: 1920 for high quality)
            max_height: Maximum height for compressed images (default: 1920 for high quality)
            quality: JPEG compression quality (1-100, default: 95 for maximum quality)
        """
        self.max_width = max_width
        self.max_height = max_height
        self.quality = quality
        self.bucket_name = "hanoa-97393.firebasestorage.app"  # Firebase Storage bucket

    def compress_image_with_gemini(self, uploaded_file) -> Tuple[bytes, str, dict]:
        """
        Compress image using Gemini 2.5 Flash AI with analysis

        Args:
            uploaded_file: Streamlit uploaded file object

        Returns:
            Tuple of (compressed_image_bytes, file_extension, metadata)
        """
        try:
            if not GEMINI_AVAILABLE:
                raise Exception("Gemini API not available, falling back to PIL")

            # Read image bytes
            image_bytes = uploaded_file.getvalue()

            # Open with PIL for processing
            image = Image.open(io.BytesIO(image_bytes))

            # Convert RGBA to RGB if necessary
            if image.mode in ('RGBA', 'LA'):
                background = Image.new('RGB', image.size, (255, 255, 255))
                if image.mode == 'RGBA':
                    background.paste(image, mask=image.split()[-1])
                else:
                    background.paste(image)
                image = background
            elif image.mode not in ('RGB', 'L'):
                image = image.convert('RGB')

            # Calculate optimal dimensions
            width, height = image.size
            if width > self.max_width or height > self.max_height:
                scale_w = self.max_width / width
                scale_h = self.max_height / height
                scale = min(scale_w, scale_h)
                new_width = int(width * scale)
                new_height = int(height * scale)
                image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)

            # Convert to WebP with high quality
            output = io.BytesIO()
            image.save(output, format='WEBP', quality=self.quality, method=6, optimize=True)
            compressed_bytes = output.getvalue()
            output.close()

            # Use Gemini for image analysis (optional metadata)
            try:
                model = genai.GenerativeModel(GEMINI_MODEL)

                # Prepare image for Gemini
                image_part = {
                    "mime_type": "image/webp",
                    "data": base64.b64encode(compressed_bytes).decode('utf-8')
                }

                # Ask Gemini to analyze the image
                prompt = """이미지를 분석하고 다음 정보를 JSON 형식으로 제공하세요:
                {
                  "description": "이미지에 대한 간단한 설명 (한국어, 50자 이내)",
                  "category": "이미지 카테고리 (의학/운동/영양/기타)",
                  "tags": ["태그1", "태그2", "태그3"]
                }"""

                response = model.generate_content([prompt, image_part])

                # Parse metadata from Gemini response
                metadata = {
                    'ai_analysis': response.text,
                    'analyzed_by': 'gemini-2.5-flash',
                    'compression_method': 'pil_webp_with_gemini_analysis'
                }

            except Exception as gemini_error:
                # Gemini analysis failed, but compression succeeded
                metadata = {
                    'ai_analysis': None,
                    'analyzed_by': None,
                    'compression_method': 'pil_webp_only',
                    'gemini_error': str(gemini_error)
                }

            return compressed_bytes, 'webp', metadata

        except Exception as e:
            # Fall back to PIL-only compression
            st.warning(f"[WARNING] Gemini 압축 실패, PIL로 폴백: {e}")
            return self.compress_image_pil_fallback(uploaded_file)

    def compress_image_pil_fallback(self, uploaded_file) -> Tuple[bytes, str, dict]:
        """
        PIL fallback compression (original method)

        Args:
            uploaded_file: Streamlit uploaded file object

        Returns:
            Tuple of (compressed_image_bytes, file_extension, metadata)
        """
        try:
            # Open image
            image = Image.open(uploaded_file)

            # Convert RGBA to RGB if necessary
            if image.mode in ('RGBA', 'LA'):
                background = Image.new('RGB', image.size, (255, 255, 255))
                if image.mode == 'RGBA':
                    background.paste(image, mask=image.split()[-1])
                else:
                    background.paste(image)
                image = background
            elif image.mode not in ('RGB', 'L'):
                image = image.convert('RGB')

            # Calculate new dimensions maintaining aspect ratio
            width, height = image.size
            if width > self.max_width or height > self.max_height:
                scale_w = self.max_width / width
                scale_h = self.max_height / height
                scale = min(scale_w, scale_h)
                new_width = int(width * scale)
                new_height = int(height * scale)
                image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)

            # Save to bytes
            output = io.BytesIO()
            image.save(output, format='WEBP', quality=self.quality, method=6, optimize=True)
            compressed_bytes = output.getvalue()
            output.close()

            metadata = {
                'compression_method': 'pil_webp_fallback',
                'ai_analysis': None
            }

            return compressed_bytes, 'webp', metadata

        except Exception as e:
            st.error(f"[ERROR] 이미지 압축 실패: {e}")
            return None, None, {}

    def compress_image(self, uploaded_file) -> Tuple[bytes, str]:
        """
        Main compress image method with Gemini AI (maintains backward compatibility)

        Args:
            uploaded_file: Streamlit uploaded file object

        Returns:
            Tuple of (compressed_image_bytes, file_extension)
        """
        # Try Gemini compression first
        compressed_bytes, file_ext, metadata = self.compress_image_with_gemini(uploaded_file)

        # Return only bytes and extension for backward compatibility
        return compressed_bytes, file_ext

    def upload_to_firebase_storage(self, image_bytes: bytes, file_name: str, content_type: str) -> Optional[str]:
        """
        Upload compressed image to Firebase Storage

        Args:
            image_bytes: Compressed image bytes
            file_name: File name for storage
            content_type: MIME type

        Returns:
            Public URL of uploaded image or None if failed
        """
        if not FIREBASE_STORAGE_AVAILABLE:
            st.warning("[WARNING] Firebase Storage 모듈을 사용할 수 없습니다")
            st.info("[INFO] firebase-admin 패키지를 설치하세요: pip install firebase-admin")
            return None

        try:
            # Get Firebase Storage bucket with explicit bucket name
            bucket = storage.bucket("hanoa-97393.firebasestorage.app")

            # Create blob (file) in bucket
            blob = bucket.blob(f"concept_images/{file_name}")

            # Upload image bytes
            blob.upload_from_string(
                image_bytes,
                content_type=content_type
            )

            # Make the blob publicly accessible
            blob.make_public()

            # Return public URL
            return blob.public_url

        except Exception as e:
            error_msg = str(e)
            if "bucket does not exist" in error_msg or "404" in error_msg:
                st.error("[ERROR] Firebase Storage 버킷이 생성되지 않았습니다")
                st.info("""
                [INFO] Firebase Storage 설정 방법:
                1. Firebase 콘솔 접속: https://console.firebase.google.com/project/hanoa-97393
                2. 왼쪽 메뉴 > Storage 클릭
                3. '시작하기' 버튼 클릭하여 Storage 활성화
                4. 보안 규칙 설정 (테스트 모드로 시작 가능)
                5. 완료 후 이미지 업로드 재시도
                """)
            else:
                st.error(f"[ERROR] Firebase Storage 업로드 실패: {e}")
            return None

    def save_to_local(self, image_bytes: bytes, file_name: str) -> Optional[str]:
        """
        Save compressed image to local storage

        Args:
            image_bytes: Compressed image bytes
            file_name: File name for storage

        Returns:
            Local path of saved image or None if failed
        """
        import os

        try:
            # Create local storage directory if it doesn't exist
            local_dir = os.path.join(os.getcwd(), "uploaded_images", "concepts")
            os.makedirs(local_dir, exist_ok=True)

            # Save image to local directory
            file_path = os.path.join(local_dir, file_name)
            with open(file_path, 'wb') as f:
                f.write(image_bytes)

            # Return relative path for storage
            relative_path = f"uploaded_images/concepts/{file_name}"
            return relative_path

        except Exception as e:
            st.error(f"[ERROR] 로컬 저장 실패: {e}")
            return None

    def process_uploaded_images(self, uploaded_files: List) -> List[Dict[str, str]]:
        """
        Process multiple uploaded images

        Args:
            uploaded_files: List of Streamlit uploaded file objects

        Returns:
            List of dictionaries containing image metadata
        """
        if not uploaded_files:
            return []

        processed_images = []

        with st.spinner(f"[PROCESSING] {len(uploaded_files)}개 이미지 처리 중..."):
            for idx, uploaded_file in enumerate(uploaded_files):
                st.write(f"처리 중: {uploaded_file.name} ({idx + 1}/{len(uploaded_files)})")

                # Compress image
                compressed_bytes, file_ext = self.compress_image(uploaded_file)

                if compressed_bytes is None:
                    st.error(f"[ERROR] {uploaded_file.name} 압축 실패")
                    continue

                # Generate unique filename
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                unique_id = str(uuid.uuid4())[:8]
                file_name = f"{timestamp}_{unique_id}.{file_ext}"

                # Content type is always WebP now
                content_type = 'image/webp'

                # Always save locally first
                local_path = self.save_to_local(compressed_bytes, file_name)
                if not local_path:
                    st.error(f"[ERROR] 로컬 저장 실패")
                    continue

                # Try to upload to Firebase Storage as well
                public_url = self.upload_to_firebase_storage(
                    compressed_bytes,
                    file_name,
                    content_type
                )

                if not public_url:
                    st.warning(f"[WARNING] Firebase Storage 업로드 실패, 로컬 저장만 완료")

                # Calculate compression ratio
                original_size = len(uploaded_file.getvalue())
                compressed_size = len(compressed_bytes)
                compression_ratio = (1 - compressed_size / original_size) * 100

                processed_images.append({
                    'original_name': uploaded_file.name,
                    'file_name': file_name,
                    'public_url': public_url if public_url else None,
                    'local_path': local_path if local_path else None,
                    'content_type': content_type,
                    'original_size': original_size,
                    'compressed_size': compressed_size,
                    'compression_ratio': compression_ratio,
                    'uploaded_at': datetime.now().isoformat()
                })

                if public_url and local_path:
                    st.success(f"[SUCCESS] {uploaded_file.name} 로컬 + Firebase 저장 완료 (압축률: {compression_ratio:.1f}%)")
                elif local_path:
                    st.success(f"[SUCCESS] {uploaded_file.name} 로컬 저장 완료 (압축률: {compression_ratio:.1f}%)")
                else:
                    st.error(f"[ERROR] {uploaded_file.name} 저장 실패")

        return processed_images

    def display_processed_images(self, processed_images: List[Dict[str, str]]):
        """Display processed images with metadata"""
        if not processed_images:
            return

        st.subheader(f"[SUCCESS] {len(processed_images)}개 이미지 업로드 완료")

        # Display images in columns
        cols = st.columns(min(len(processed_images), 3))
        for idx, img_data in enumerate(processed_images[:3]):
            with cols[idx % 3]:
                # Use local path for display if Firebase URL is not available
                image_source = img_data.get('public_url') or img_data.get('local_path')
                if image_source:
                    # If it's a local path, read the file
                    if img_data.get('local_path') and not img_data.get('public_url'):
                        import os
                        full_path = os.path.join(os.getcwd(), img_data['local_path'])
                        if os.path.exists(full_path):
                            with open(full_path, 'rb') as f:
                                image_bytes = f.read()
                            st.image(
                                image_bytes,
                                caption=f"{img_data['original_name']}\n압축률: {img_data['compression_ratio']:.1f}%",
                                width=150
                            )
                        else:
                            st.write(f"[INFO] 이미지 저장됨: {img_data['original_name']}")
                    else:
                        # Use Firebase URL if available
                        st.image(
                            image_source,
                            caption=f"{img_data['original_name']}\n압축률: {img_data['compression_ratio']:.1f}%",
                            width=150
                        )
                else:
                    st.write(f"[INFO] 이미지 저장됨: {img_data['original_name']}")

        if len(processed_images) > 3:
            st.info(f"[INFO] 추가 {len(processed_images)-3}개 이미지가 더 업로드되었습니다")

        # Show detailed metadata in expander
        with st.expander("[DETAILS] 이미지 업로드 상세 정보"):
            for img_data in processed_images:
                st.write(f"**{img_data['original_name']}**")
                if img_data.get('public_url'):
                    st.write(f"- Firebase URL: {img_data['public_url']}")
                if img_data.get('local_path'):
                    st.write(f"- 로컬 경로: {img_data['local_path']}")
                st.write(f"- 원본 크기: {img_data['original_size']:,} bytes")
                st.write(f"- 압축 크기: {img_data['compressed_size']:,} bytes")
                st.write(f"- 압축률: {img_data['compression_ratio']:.1f}%")
                st.divider()


# Global image processor instance
image_processor = ImageProcessor()