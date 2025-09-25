"""
Medical Genre Classification for Advanced Deduplication
의료 도메인 특화 장르 분류기
"""
import re
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum


class MedicalGenre(Enum):
    """의료 문서 장르 분류"""
    DEFINITION = "definition"      # 정의, 개념 설명
    SYMPTOM = "symptom"           # 증상, 징후
    DIAGNOSIS = "diagnosis"       # 진단, 검사
    TREATMENT = "treatment"       # 치료, 처치
    PROCEDURE = "procedure"       # 절차, 단계
    MEDICATION = "medication"     # 약물, 투약
    ANATOMY = "anatomy"          # 해부학, 구조
    PATHOLOGY = "pathology"      # 병리, 질병
    PREVENTION = "prevention"    # 예방, 관리
    OTHER = "other"              # 기타


@dataclass
class GenreKeywords:
    """장르별 키워드 패턴"""
    patterns: List[str]
    weight: float = 1.0


class MedicalGenreClassifier:
    """의료 도메인 장르 분류기 (Gemini 2.5 Flash 기반)"""

    def __init__(self):
        self.genre_patterns = self._init_genre_patterns()  # 폴백용 키워드 패턴 유지
        self.use_ai_classification = True  # AI 분류 사용 여부
        self.gemini_client = None
        self._init_gemini_client()

    def _init_gemini_client(self):
        """Gemini 클라이언트 초기화"""
        try:
            import google.generativeai as genai
            import os

            # API 키 확인
            api_key = os.getenv('GEMINI_API_KEY')
            if api_key:
                genai.configure(api_key=api_key)
                self.gemini_client = genai.GenerativeModel('gemini-2.5-flash')
                print("[SUCCESS] Gemini 2.5 Flash 클라이언트 초기화 완료")
            else:
                print("[WARNING] GEMINI_API_KEY not found, using fallback classification")
                self.use_ai_classification = False
        except ImportError:
            print("[WARNING] google-generativeai not installed, using fallback classification")
            self.use_ai_classification = False
        except Exception as e:
            print(f"[ERROR] Gemini client initialization failed: {e}")
            self.use_ai_classification = False

    def _classify_with_ai(self, text: str) -> Tuple[MedicalGenre, float]:
        """Gemini 2.5 Flash를 사용한 AI 장르 분류"""
        if not self.use_ai_classification or not self.gemini_client:
            return None, 0.0

        try:
            prompt = f"""
다음 의료 텍스트를 10개 장르 중 하나로 분류하고 신뢰도(0.0~1.0)를 제공하세요.

장르:
1. definition - 정의, 개념 설명
2. symptom - 증상, 징후
3. diagnosis - 진단, 검사
4. treatment - 치료, 처치
5. procedure - 절차, 단계
6. medication - 약물, 투약
7. anatomy - 해부학, 구조
8. pathology - 병리, 질병
9. prevention - 예방, 관리
10. other - 기타

텍스트: "{text[:500]}"

응답 형식: genre:confidence (예: symptom:0.85)
"""

            response = self.gemini_client.generate_content(prompt)
            response_text = response.text.strip().lower()

            # 응답 파싱
            if ':' in response_text:
                genre_str, confidence_str = response_text.split(':', 1)
                genre_str = genre_str.strip()
                confidence = float(confidence_str.strip())

                # 장르 매핑
                genre_mapping = {
                    'definition': MedicalGenre.DEFINITION,
                    'symptom': MedicalGenre.SYMPTOM,
                    'diagnosis': MedicalGenre.DIAGNOSIS,
                    'treatment': MedicalGenre.TREATMENT,
                    'procedure': MedicalGenre.PROCEDURE,
                    'medication': MedicalGenre.MEDICATION,
                    'anatomy': MedicalGenre.ANATOMY,
                    'pathology': MedicalGenre.PATHOLOGY,
                    'prevention': MedicalGenre.PREVENTION,
                    'other': MedicalGenre.OTHER
                }

                if genre_str in genre_mapping:
                    return genre_mapping[genre_str], min(max(confidence, 0.0), 1.0)

            return None, 0.0

        except Exception as e:
            print(f"[ERROR] AI classification failed: {e}")
            return None, 0.0

    def _init_genre_patterns(self) -> Dict[MedicalGenre, GenreKeywords]:
        """장르별 키워드 패턴 초기화"""
        return {
            MedicalGenre.DEFINITION: GenreKeywords([
                r'정의', r'개념', r'이란', r'무엇', r'definition', r'concept',
                r'overview', r'설명', r'의미', r'개요', r'이다', r'이며'
            ], weight=1.0),

            MedicalGenre.SYMPTOM: GenreKeywords([
                r'증상', r'징후', r'증세', r'symptom', r'sign', r'나타난다',
                r'호소', r'느낀다', r'아프다', r'통증', r'불편', r'이상'
            ], weight=1.2),

            MedicalGenre.DIAGNOSIS: GenreKeywords([
                r'진단', r'검사', r'판정', r'diagnosis', r'test', r'examination',
                r'평가', r'확인', r'발견', r'소견', r'결과', r'수치'
            ], weight=1.1),

            MedicalGenre.TREATMENT: GenreKeywords([
                r'치료', r'처치', r'요법', r'treatment', r'therapy', r'care',
                r'관리', r'수술', r'시술', r'처방', r'투여', r'적용'
            ], weight=1.2),

            MedicalGenre.PROCEDURE: GenreKeywords([
                r'절차', r'단계', r'방법', r'과정', r'procedure', r'step',
                r'순서', r'진행', r'실시', r'수행', r'따라', r'먼저'
            ], weight=1.0),

            MedicalGenre.MEDICATION: GenreKeywords([
                r'약물', r'의약품', r'처방약', r'medication', r'drug', r'medicine',
                r'투약', r'복용', r'주사', r'정제', r'캡슐', r'mg', r'용량'
            ], weight=1.3),

            MedicalGenre.ANATOMY: GenreKeywords([
                r'해부', r'구조', r'anatomy', r'structure', r'기관', r'조직',
                r'근육', r'뼈', r'혈관', r'신경', r'세포', r'위치'
            ], weight=1.0),

            MedicalGenre.PATHOLOGY: GenreKeywords([
                r'병리', r'질병', r'질환', r'pathology', r'disease', r'disorder',
                r'syndrome', r'염증', r'감염', r'암', r'종양', r'병변'
            ], weight=1.1),

            MedicalGenre.PREVENTION: GenreKeywords([
                r'예방', r'관리', r'prevention', r'management', r'주의',
                r'조심', r'피하다', r'방지', r'건강', r'생활습관'
            ], weight=1.0)
        }

    def classify_text(self, text: str) -> Tuple[MedicalGenre, float]:
        """
        텍스트를 의료 장르로 분류 (AI 우선 → 키워드 폴백)

        Args:
            text: 분류할 텍스트

        Returns:
            (장르, 신뢰도 점수)
        """
        if not text or not text.strip():
            return MedicalGenre.OTHER, 0.0

        # 1. AI 분류 시도 (Gemini 2.5 Flash 우선)
        ai_result = self._classify_with_ai(text)
        if ai_result[0] is not None and ai_result[1] > 0.5:  # AI 신뢰도 임계값
            print(f"[AI] 장르 분류: {ai_result[0].value} (신뢰도: {ai_result[1]:.3f})")
            return ai_result

        # 2. 키워드 기반 폴백 분류
        print("[FALLBACK] 키워드 기반 분류 사용")
        text_normalized = self._normalize_text(text)

        # 각 장르별 점수 계산
        genre_scores = {}
        for genre, keywords in self.genre_patterns.items():
            score = self._calculate_genre_score(text_normalized, keywords)
            if score > 0:
                genre_scores[genre] = score

        # 가장 높은 점수의 장르 선택
        if not genre_scores:
            return MedicalGenre.OTHER, 0.0

        best_genre = max(genre_scores.items(), key=lambda x: x[1])
        return best_genre[0], min(best_genre[1], 1.0)

    def _normalize_text(self, text: str) -> str:
        """텍스트 정규화"""
        # 소문자 변환
        text = text.lower()

        # 특수문자 공백으로 변환 (의료 용어 보존)
        text = re.sub(r'[^\w\sㄱ-ㅎㅏ-ㅣ가-힣0-9]', ' ', text)

        # 다중 공백 제거
        text = re.sub(r'\s+', ' ', text)

        return text.strip()

    def _calculate_genre_score(self, text: str, keywords: GenreKeywords) -> float:
        """장르 점수 계산"""
        total_matches = 0
        text_length = len(text.split())

        for pattern in keywords.patterns:
            # 패턴 매칭 (대소문자 무시)
            matches = len(re.findall(pattern, text, re.IGNORECASE))
            total_matches += matches

        if total_matches == 0:
            return 0.0

        # 정규화된 점수 계산 (텍스트 길이 고려)
        normalized_score = (total_matches / max(text_length, 1)) * keywords.weight

        # 텍스트 길이별 보정
        if text_length < 10:  # 짧은 텍스트
            normalized_score *= 1.2
        elif text_length > 100:  # 긴 텍스트
            normalized_score *= 0.8

        return min(normalized_score, 1.0)

    def get_genre_compatibility_matrix(self) -> Dict[Tuple[MedicalGenre, MedicalGenre], float]:
        """
        장르 간 호환성 매트릭스
        유사한 장르 간에는 중복 허용도를 조정
        """
        compatibility = {}

        # 높은 호환성 (중복 허용도 높음)
        high_compat_pairs = [
            (MedicalGenre.DEFINITION, MedicalGenre.PATHOLOGY),
            (MedicalGenre.SYMPTOM, MedicalGenre.DIAGNOSIS),
            (MedicalGenre.TREATMENT, MedicalGenre.MEDICATION),
            (MedicalGenre.TREATMENT, MedicalGenre.PROCEDURE),
        ]

        # 중간 호환성
        medium_compat_pairs = [
            (MedicalGenre.DEFINITION, MedicalGenre.SYMPTOM),
            (MedicalGenre.DIAGNOSIS, MedicalGenre.TREATMENT),
            (MedicalGenre.ANATOMY, MedicalGenre.PATHOLOGY),
        ]

        # 모든 장르 쌍 초기화 (기본값: 0.5)
        all_genres = list(MedicalGenre)
        for g1 in all_genres:
            for g2 in all_genres:
                if g1 == g2:
                    compatibility[(g1, g2)] = 1.0  # 같은 장르
                else:
                    compatibility[(g1, g2)] = 0.5  # 기본값

        # 높은 호환성 설정
        for g1, g2 in high_compat_pairs:
            compatibility[(g1, g2)] = 0.8
            compatibility[(g2, g1)] = 0.8

        # 중간 호환성 설정
        for g1, g2 in medium_compat_pairs:
            compatibility[(g1, g2)] = 0.65
            compatibility[(g2, g1)] = 0.65

        return compatibility


# 싱글톤 인스턴스
medical_genre_classifier = MedicalGenreClassifier()


def classify_medical_genre(text: str) -> Tuple[str, float]:
    """
    의료 텍스트 장르 분류 (외부 인터페이스)

    Returns:
        (장르명, 신뢰도)
    """
    genre, confidence = medical_genre_classifier.classify_text(text)
    return genre.value, confidence


if __name__ == "__main__":
    # 테스트 예제
    test_texts = [
        "당뇨병은 혈당이 높아지는 대사 질환입니다",  # DEFINITION
        "환자가 가슴 통증을 호소합니다",              # SYMPTOM
        "혈액 검사 결과 백혈구 수치가 상승했습니다",    # DIAGNOSIS
        "항생제를 하루 3회 투여합니다",              # TREATMENT/MEDICATION
        "수술 전 금식이 필요합니다",                # PROCEDURE
    ]

    classifier = MedicalGenreClassifier()

    for text in test_texts:
        genre, confidence = classifier.classify_text(text)
        print(f"텍스트: {text}")
        print(f"장르: {genre.value} (신뢰도: {confidence:.3f})")
        print("---")