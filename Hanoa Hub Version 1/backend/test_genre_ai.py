"""
Gemini 2.5 Flash 장르 분류 테스트
"""
import os
from dotenv import load_dotenv

# 환경변수 로드
load_dotenv()

# 고급 중복 제거 시스템에서 장르 분류기 임포트
try:
    from advanced_dedup.genre_classifier import MedicalGenreClassifier
    print("[SUCCESS] 고급 장르 분류기 임포트 성공")
except ImportError as e:
    print(f"[ERROR] 임포트 실패: {e}")
    exit(1)

def test_ai_genre_classification():
    """AI 장르 분류 테스트"""

    # 테스트 텍스트들
    test_texts = [
        "당뇨병은 혈당이 높아지는 대사 질환입니다",  # DEFINITION 예상
        "환자가 가슴 통증을 호소합니다",              # SYMPTOM 예상
        "혈액 검사 결과 백혈구 수치가 상승했습니다",    # DIAGNOSIS 예상
        "항생제를 하루 3회 투여합니다",              # MEDICATION 예상
        "수술 전 금식이 필요합니다",                # PROCEDURE 예상
    ]

    classifier = MedicalGenreClassifier()

    print("\n=== Gemini 2.5 Flash 장르 분류 테스트 ===")
    print(f"AI 분류 사용: {classifier.use_ai_classification}")
    print(f"Gemini 클라이언트: {'설정됨' if classifier.gemini_client else '설정 안됨'}")

    for i, text in enumerate(test_texts, 1):
        print(f"\n[테스트 {i}] {text}")
        try:
            genre, confidence = classifier.classify_text(text)
            print(f"결과: {genre.value} (신뢰도: {confidence:.3f})")
        except Exception as e:
            print(f"[ERROR] 분류 실패: {e}")

    print("\n=== 테스트 완료 ===")

if __name__ == "__main__":
    # GEMINI_API_KEY 확인
    api_key = os.getenv('GEMINI_API_KEY')
    if not api_key:
        print("[WARNING] GEMINI_API_KEY 환경변수가 설정되지 않았습니다.")
        print("키워드 기반 폴백 분류만 사용됩니다.")
    else:
        print(f"[SUCCESS] GEMINI_API_KEY 설정됨 (길이: {len(api_key)})")

    test_ai_genre_classification()