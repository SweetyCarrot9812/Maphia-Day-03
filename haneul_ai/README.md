# 🌟 Haneul AI Agent

**GPT-5 기반 멀티 페르소나 AI 에이전트** - 생산성, 헬스, 보컬 트레이닝을 하나의 시스템에서 관리합니다.

## ✨ 핵심 기능

### 🎭 **3개 AI 페르소나 (GPT-5)**
- **🎯 생산성 매니저**: 작업 우선순위 분석, Obsidian 연동, 스마트 알림
- **🏋️‍♂️ 헬스 트레이너**: 운동 플랜 생성, 진행도 추적, 식단 관리
- **🎵 보컬 트레이너**: 음역 분석, 발성 피드백, 연습 루틴 제안

### 🤖 **자동 페르소나 감지**
키워드 기반으로 최적의 페르소나를 자동 선택합니다.

## 🚀 빠른 시작

### 1. 설치
```bash
cd haneul_ai
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

### 2. 환경 설정
`.env` 파일 생성:
```env
OPENAI_API_KEY=your_openai_api_key
OBSIDIAN_VAULT_PATH=C:\Users\YourName\Documents\ObsidianVault
EMAIL_ADDRESS=your_email@gmail.com
```

### 3. 실행
```bash
uvicorn app.main:app --reload
# 접속: http://localhost:8000
```

## 📚 API 사용법

### 작업 생성 (생산성)
```python
import requests

response = requests.post("http://localhost:8000/api/ai/tasks", json={
    "title": "프로젝트 문서 작성",
    "content": "새로운 AI 프로젝트의 기술 문서 작성",
    "urgency": 0,  # AI 자동 분석
    "importance": 0
})
```

### 운동 플랜 생성 (헬스)
```python
response = requests.post("http://localhost:8000/api/fitness/workout-plan", json={
    "goal": "muscle_building",
    "experience": "beginner", 
    "days_per_week": 4
})
```

### 음역 분석 (보컬)
```python
response = requests.post("http://localhost:8000/api/vocal/analyze-range", json={
    "pitch_data": [261.63, 293.66, 329.63]  # C4, D4, E4
})
```

## 🏗️ 아키텍처

### 핵심 컴포넌트
- **PersonaManager**: 자동 페르소나 감지 및 라우팅
- **BasePersona**: 모든 페르소나의 추상 기본 클래스
- **FitnessTrackingService**: 운동 데이터 관리 (SQLite)
- **ObsidianService**: 마크다운 파일 자동 생성

### 파일 구조
```
haneul_ai/
├── app/
│   ├── main.py                 # FastAPI 애플리케이션
│   ├── personas/               # AI 페르소나들
│   │   ├── base_persona.py     # 추상 기본 클래스
│   │   ├── fitness_persona.py  # 헬스 트레이너
│   │   └── vocal_persona.py    # 보컬 트레이너
│   ├── services/               # 비즈니스 로직
│   │   ├── ai_service.py       # GPT-5 연동
│   │   ├── persona_manager.py  # 페르소나 라우팅
│   │   └── fitness_tracking_service.py  # 운동 데이터
│   └── models/schemas.py       # 데이터 모델
└── requirements.txt
```

## 🎯 구현 완료 (2025-09-12)

### ✅ 완성된 기능
- **BasePersona 시스템**: GPT-5 통합 추상 클래스
- **PersonaManager**: 자동 페르소나 감지 및 라우팅
- **FitnessPersona**: 운동 플랜, 진행도 분석, 식단 관리, 홈짐 가이드
- **VocalPersona**: 음역 분석, 연습 스케줄, 발성 피드백
- **SQLite 데이터베이스**: 운동 세션, 체측정, 1RM 완전 추적

### 📱 사용 예시
```python
# 피트니스 페르소나
fitness = FitnessPersona()
workout_plan = await fitness.create_workout_plan({
    'goal': 'muscle_building',
    'experience': 'beginner'
})

# 보컬 페르소나  
vocal = VocalPersona()
practice_plan = vocal.generate_practice_schedule(
    level='intermediate',
    goals=['pitch_accuracy'],
    time_per_day=30
)
```

## 🔧 개발

### API 문서
서버 실행 후: http://localhost:8000/docs

### 테스트
```bash
pytest tests/ -v
```

### 데이터베이스 초기화
```bash
python -c "from app.database import init_db; init_db()"
```

## 📈 다음 계획

- [ ] 웹 대시보드 UI
- [ ] 음성 파일 업로드 및 피치 분석
- [ ] 실시간 튜너 기능
- [ ] 웨어러블 연동 (헬스)
- [ ] 모바일 앱

---

**🌟 "GPT-5 기반 3개 AI 페르소나가 생산성·피트니스·보컬까지 완전 관리!"**