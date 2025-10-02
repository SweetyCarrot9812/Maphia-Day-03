"""
Firebase Firestore 연동 서비스
Clintest 앱과 문제 데이터 동기화
"""
import os
import json
import firebase_admin
from firebase_admin import credentials, firestore
from typing import Dict, List, Optional, Any
from datetime import datetime
from pathlib import Path

class FirebaseService:
    """Firebase Firestore 서비스"""

    def __init__(self):
        """Firebase 초기화"""
        self.db = None
        self.initialized = False
        self._initialize_firebase()

    def _initialize_firebase(self):
        """Firebase Admin SDK 초기화"""
        try:
            # Firebase 서비스 계정 키 경로
            cred_path = Path(__file__).parent.parent / "firebase-service-account.json"

            if not cred_path.exists():
                print("[WARNING] Firebase 서비스 계정 키 파일이 없습니다.")
                print(f"[INFO] 경로: {cred_path}")
                print("[INFO] Firebase Console에서 서비스 계정 키를 다운로드하여 배치하세요.")
                print("[INFO] 1. Firebase Console → 프로젝트 설정 → 서비스 계정")
                print("[INFO] 2. '새 비공개 키 생성' 클릭")
                print("[INFO] 3. 다운로드된 JSON 파일을 'firebase-service-account.json'으로 저장")
                return

            # Firebase 초기화
            if not firebase_admin._apps:
                cred = credentials.Certificate(str(cred_path))
                firebase_admin.initialize_app(cred, {
                    'storageBucket': 'hanoa-97393.firebasestorage.app'
                })

            self.db = firestore.client()
            self.initialized = True
            print("[SUCCESS] Firebase Firestore 연결 성공")

        except Exception as e:
            print(f"[ERROR] Firebase 초기화 실패: {e}")
            self.initialized = False

    def upload_problem(self, problem_data: Dict[str, Any]) -> Dict[str, Any]:
        """문제를 Firestore에 업로드"""
        if not self.initialized:
            print("[WARNING] Firebase가 초기화되지 않았습니다.")
            return {'success': False, 'message': 'Firebase not initialized'}

        try:
            # Firestore 컬렉션 참조
            problems_ref = self.db.collection('nursing_problems')

            # 문제 ID 확인 (없으면 생성)
            if 'id' not in problem_data:
                problem_data['id'] = problems_ref.document().id

            # 타임스탬프 추가
            problem_data['uploadedAt'] = firestore.SERVER_TIMESTAMP
            problem_data['lastModified'] = firestore.SERVER_TIMESTAMP

            # Firestore 문서 생성/업데이트
            doc_ref = problems_ref.document(problem_data['id'])
            doc_ref.set(problem_data)

            print(f"[SUCCESS] 문제 업로드 성공: {problem_data['id']}")
            return {'success': True, 'id': problem_data['id'], 'message': 'Upload successful'}

        except Exception as e:
            print(f"[ERROR] 문제 업로드 실패: {e}")
            return {'success': False, 'message': str(e)}

    def upload_concept(self, concept_data: Dict[str, Any]) -> Dict[str, Any]:
        """개념을 Firestore에 업로드"""
        if not self.initialized:
            print("[WARNING] Firebase가 초기화되지 않았습니다.")
            return {'success': False, 'message': 'Firebase not initialized'}

        try:
            # Firestore 컬렉션 참조
            concepts_ref = self.db.collection('nursing_concepts')

            # 개념 ID 확인 (없으면 생성)
            if 'id' not in concept_data:
                concept_data['id'] = concepts_ref.document().id

            # 타임스탬프 추가
            concept_data['uploadedAt'] = firestore.SERVER_TIMESTAMP
            concept_data['lastModified'] = firestore.SERVER_TIMESTAMP

            # Firestore 문서 생성/업데이트
            doc_ref = concepts_ref.document(concept_data['id'])
            doc_ref.set(concept_data)

            print(f"[SUCCESS] 개념 업로드 성공: {concept_data['id']}")
            return {'success': True, 'id': concept_data['id'], 'message': 'Upload successful'}

        except Exception as e:
            print(f"[ERROR] 개념 업로드 실패: {e}")
            return {'success': False, 'message': str(e)}

    def add_concept(self, concept_data: Dict[str, Any]) -> Dict[str, Any]:
        """개념을 Firestore에 추가 (nursing_concepts 컬렉션)"""
        if not self.initialized:
            print("[WARNING] Firebase가 초기화되지 않았습니다.")
            return {'success': False, 'message': 'Firebase not initialized'}

        try:
            # Firestore 컬렉션 참조
            concepts_ref = self.db.collection('nursing_concepts')

            # 개념 ID 확인 (없으면 생성)
            if 'id' not in concept_data:
                concept_data['id'] = concepts_ref.document().id

            # 타임스탬프 추가
            concept_data['uploadedAt'] = firestore.SERVER_TIMESTAMP
            concept_data['lastModified'] = firestore.SERVER_TIMESTAMP

            # Firestore 문서 생성/업데이트
            doc_ref = concepts_ref.document(concept_data['id'])
            doc_ref.set(concept_data)

            print(f"[SUCCESS] 개념 추가 성공: {concept_data['id']}")
            return {'success': True, 'id': concept_data['id'], 'message': 'Concept added successfully'}

        except Exception as e:
            print(f"[ERROR] 개념 추가 실패: {e}")
            return {'success': False, 'message': str(e)}

    def add_medical_concept(self, concept_data: Dict[str, Any]) -> Dict[str, Any]:
        """의학 개념을 Firestore에 추가 (medical_concepts 컬렉션)"""
        if not self.initialized:
            print("[WARNING] Firebase가 초기화되지 않았습니다.")
            return {'success': False, 'message': 'Firebase not initialized'}

        try:
            # Firestore 컬렉션 참조
            concepts_ref = self.db.collection('medical_concepts')

            # 개념 ID 확인 (없으면 생성)
            if 'id' not in concept_data:
                concept_data['id'] = concepts_ref.document().id

            # 타임스탬프 추가
            concept_data['uploadedAt'] = firestore.SERVER_TIMESTAMP
            concept_data['lastModified'] = firestore.SERVER_TIMESTAMP

            # Firestore 문서 생성/업데이트
            doc_ref = concepts_ref.document(concept_data['id'])
            doc_ref.set(concept_data)

            print(f"[SUCCESS] 의학 개념 추가 성공: {concept_data['id']}")
            return {'success': True, 'id': concept_data['id'], 'message': 'Medical concept added successfully'}

        except Exception as e:
            print(f"[ERROR] 의학 개념 추가 실패: {e}")
            return {'success': False, 'message': str(e)}

    def upload_medical_problem(self, problem_data: Dict[str, Any]) -> Dict[str, Any]:
        """의학 문제를 Firestore에 업로드"""
        if not self.initialized:
            print("[WARNING] Firebase가 초기화되지 않았습니다.")
            return {'success': False, 'message': 'Firebase not initialized'}

        try:
            # Firestore 컬렉션 참조 (의학 문제용 별도 컬렉션)
            problems_ref = self.db.collection('medical_problems')

            # 문제 ID 확인 (없으면 생성)
            if 'id' not in problem_data:
                problem_data['id'] = problems_ref.document().id

            # 타임스탬프 추가
            problem_data['uploadedAt'] = firestore.SERVER_TIMESTAMP
            problem_data['lastModified'] = firestore.SERVER_TIMESTAMP

            # Firestore 문서 생성/업데이트
            doc_ref = problems_ref.document(problem_data['id'])
            doc_ref.set(problem_data)

            print(f"[SUCCESS] 의학 문제 업로드 성공: {problem_data['id']}")
            return {'success': True, 'id': problem_data['id'], 'message': 'Upload successful'}

        except Exception as e:
            print(f"[ERROR] 의학 문제 업로드 실패: {e}")
            return {'success': False, 'message': str(e)}

    def get_problems(self, subject: Optional[str] = None, limit: int = 100) -> List[Dict]:
        """Firestore에서 문제 목록 조회 (nursing_problems 컬렉션)"""
        if not self.initialized:
            return []

        try:
            query = self.db.collection('nursing_problems')

            # 과목별 필터링
            if subject:
                query = query.where('subject', '==', subject)

            # 최신순 정렬
            query = query.order_by('uploadedAt', direction=firestore.Query.DESCENDING)
            query = query.limit(limit)

            # 문서 가져오기
            docs = query.get()
            problems = []

            for doc in docs:
                problem = doc.to_dict()
                problem['id'] = doc.id
                problems.append(problem)

            return problems

        except Exception as e:
            print(f"[ERROR] 문제 조회 실패: {e}")
            return []

    def get_nursing_problems(self, subject: Optional[str] = None, limit: int = 100) -> List[Dict]:
        """Firestore에서 간호 문제 목록 조회"""
        return self.get_problems(subject=subject, limit=limit)

    def get_medical_problems(self, subject: Optional[str] = None, limit: int = 100) -> List[Dict]:
        """Firestore에서 의학 문제 목록 조회"""
        if not self.initialized:
            return []

        try:
            query = self.db.collection('medical_problems')

            # 과목별 필터링
            if subject:
                query = query.where('subject', '==', subject)

            # 최신순 정렬
            query = query.order_by('uploadedAt', direction=firestore.Query.DESCENDING)
            query = query.limit(limit)

            # 문서 가져오기
            docs = query.get()
            problems = []

            for doc in docs:
                problem = doc.to_dict()
                problem['id'] = doc.id
                problems.append(problem)

            return problems

        except Exception as e:
            print(f"[ERROR] 의학 문제 조회 실패: {e}")
            return []

    def get_all_problems(self, subject: Optional[str] = None, limit: int = 100) -> List[Dict]:
        """Firestore에서 모든 문제 목록 조회 (간호 + 의학)"""
        nursing = self.get_nursing_problems(subject=subject, limit=limit//2)
        medical = self.get_medical_problems(subject=subject, limit=limit//2)

        # 합치고 최신순 정렬
        all_problems = nursing + medical
        all_problems.sort(key=lambda x: x.get('uploadedAt', ''), reverse=True)

        # limit 적용
        return all_problems[:limit]

    def get_concepts(self, subject: Optional[str] = None, limit: int = 100) -> List[Dict]:
        """Firestore에서 개념 목록 조회"""
        if not self.initialized:
            return []

        try:
            query = self.db.collection('nursing_concepts')

            # 과목별 필터링
            if subject:
                query = query.where('subject', '==', subject)

            # 최신순 정렬
            query = query.order_by('uploadedAt', direction=firestore.Query.DESCENDING)
            query = query.limit(limit)

            # 문서 가져오기
            docs = query.get()
            concepts = []

            for doc in docs:
                concept = doc.to_dict()
                concept['id'] = doc.id
                concepts.append(concept)

            return concepts

        except Exception as e:
            print(f"[ERROR] 개념 조회 실패: {e}")
            return []

    def batch_upload_problems(self, problems: List[Dict[str, Any]]) -> int:
        """여러 문제를 일괄 업로드"""
        if not self.initialized:
            return 0

        success_count = 0
        batch = self.db.batch()
        batch_size = 0

        try:
            for problem in problems:
                # 문제 ID 확인
                if 'id' not in problem:
                    problem['id'] = self.db.collection('nursing_problems').document().id

                # 타임스탬프 추가
                problem['uploadedAt'] = firestore.SERVER_TIMESTAMP
                problem['lastModified'] = firestore.SERVER_TIMESTAMP

                # 배치에 추가
                doc_ref = self.db.collection('nursing_problems').document(problem['id'])
                batch.set(doc_ref, problem)
                batch_size += 1

                # 500개씩 커밋 (Firestore 제한)
                if batch_size >= 500:
                    batch.commit()
                    success_count += batch_size
                    batch = self.db.batch()
                    batch_size = 0

            # 남은 배치 커밋
            if batch_size > 0:
                batch.commit()
                success_count += batch_size

            print(f"[SUCCESS] {success_count}개 문제 일괄 업로드 성공")
            return success_count

        except Exception as e:
            print(f"[ERROR] 일괄 업로드 실패: {e}")
            return success_count

    def delete_problem(self, problem_id: str) -> bool:
        """문제 삭제"""
        if not self.initialized:
            return False

        try:
            self.db.collection('nursing_problems').document(problem_id).delete()
            print(f"[SUCCESS] 문제 삭제 성공: {problem_id}")
            return True
        except Exception as e:
            print(f"[ERROR] 문제 삭제 실패: {e}")
            return False

    def update_problem(self, problem_id: str, updates: Dict[str, Any]) -> bool:
        """문제 업데이트"""
        if not self.initialized:
            return False

        try:
            updates['lastModified'] = firestore.SERVER_TIMESTAMP
            self.db.collection('nursing_problems').document(problem_id).update(updates)
            print(f"[SUCCESS] 문제 업데이트 성공: {problem_id}")
            return True
        except Exception as e:
            print(f"[ERROR] 문제 업데이트 실패: {e}")
            return False

# 전역 인스턴스
firebase_service = FirebaseService()