# Hanoa Hub Backend - Claude Code 설정

## 프로젝트 개요
- **이름**: Hanoa Hub Version 1 Backend
- **기술 스택**: Python, Streamlit, ChromaDB, Firebase, OpenAI, Gemini
- **목적**: 간호학 문제/개념 관리 및 RAG 검색 시스템

## 📋 중요 규칙

### 🚫 이모지 사용 절대 금지 (Critical Rule)
- **모든 Python 코드, Streamlit 앱, 콘솔 출력에서 이모지 완전 금지**
- **Windows cp949 인코딩 환경에서 UnicodeEncodeError 발생**
- **터미널/콘솔에서 이모지는 "[Image #1]" 형태로 깨져서 표시됨**
- **print() 문, 로그, 메시지 모든 곳에서 이모지 사용하지 말것**
- **CRITICAL**: 코드 작성 시 이모지 사용하면 실행 오류 발생
- 모든 아이콘과 표시는 반드시 텍스트 태그로 대체

### 텍스트 태그 표준
- `[SUCCESS]`: 성공 메시지
- `[ERROR]`: 오류 메시지
- `[WARNING]`: 경고 메시지
- `[INFO]`: 정보 메시지
- `[SAVE]`: 저장 버튼
- `[LOAD]`: 로드 버튼
- `[REFRESH]`: 새로고침 버튼
- `[GENERATE]`: 생성 버튼
- `[ANALYSIS]`: 분석 관련
- `[RAG]`: RAG 관련
- `[AI]`: AI 모델 관련
- `[STATUS]`: 상태 표시
- `[JOBS]`: Jobs 관리
- `[SYSTEM]`: 시스템 관리

## Firebase 연동
- **서비스 계정 키**: `firebase-service-account.json`
- **프로젝트 ID**: hanoa-97393
- **컬렉션**: nursing_problems, nursing_concepts

## ChromaDB 설정
- **경로**: database/chroma_db/
- **컬렉션**: nursing_questions, nursing_concepts
- **임베딩 모델**: text-embedding-004 (Gemini)

## AI 모델 사용
- **주 모델**: GPT-5 Mini (gpt-5-mini)
- **고급 모델**: GPT-5 (gpt-5)
- **임베딩**: Gemini text-embedding-004
- **비용 효율**: 계층적 분석 (GPT-5 Mini → GPT-5)

## 개발 명령어
```bash
# Streamlit 앱 실행
streamlit run app.py

# ChromaDB 초기화
python chroma_init.py init

# 의존성 설치
pip install -r requirements.txt
```

## 주의사항
- **이모지 절대 사용 금지** - 화면 표시 오류 발생
- Firebase 키 파일명 정확히 유지
- Python 환경에서 UTF-8 인코딩 사용
- Streamlit은 터미널 환경에서 실행됨