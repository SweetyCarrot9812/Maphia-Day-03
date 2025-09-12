# 🚀 Haneul AI Agent - 빠른 시작 가이드

## ⚡ 1분 만에 시작하기

### 1단계: 자동 설정 & 실행
```bash
# Windows
python start_server.py

# 또는 직접 실행
python -m app.main
```

### 2단계: 환경 설정 (최초 1회)
첫 실행 시 자동으로 `.env` 파일이 생성됩니다. 다음 정보만 입력하세요:

```env
# 필수 - OpenAI API 키
OPENAI_API_KEY=sk-your-openai-api-key-here

# 필수 - 이메일 주소
EMAIL_ADDRESS=your_email@gmail.com

# 필수 - Obsidian Vault 경로 (자동 생성됨)
OBSIDIAN_VAULT_PATH=C:\Users\YourName\Documents\HaneulVault
```

### 3단계: 즉시 테스트
```bash
# API 테스트 실행
python test_api.py

# 브라우저에서 확인
http://localhost:8000/docs
```

**🎉 완성! 이제 AI가 당신의 할 일을 관리합니다.**

---

## 💡 핵심 사용법

### 1. 작업 생성 (AI 자동 분석)
```python
import requests

# AI가 우선순위를 자동으로 분석합니다
response = requests.post("http://localhost:8000/api/ai/tasks", json={
    "title": "프로젝트 발표 준비",
    "content": "내일까지 PPT 완성하고 발표 연습하기",
    "urgency": 0,  # 0 = AI 자동 분석
    "importance": 0,
    "tags": ["발표", "프로젝트"]
})

result = response.json()
print(f"우선순위 점수: {result['priority_score']}/20")
```

### 2. 최고 우선순위 작업 확인
```bash
curl http://localhost:8000/api/ai/tasks/top-priority?limit=3
```

### 3. Obsidian과 동기화
- 작업이 자동으로 마크다운 파일로 생성됩니다
- `00-Inbox/` → `01-Todo/` → `02-Completed/` 폴더로 자동 분류

### 4. 이메일 알림 테스트
```bash
curl http://localhost:8000/api/notifications/test-email
```

---

## 🔧 고급 설정

### Gmail/Calendar 연동 (선택사항)
Google API 사용을 위해 다음 단계를 따르세요:

1. **Google Cloud Console에서 프로젝트 생성**
2. **Gmail & Calendar API 활성화**
3. **OAuth 2.0 클라이언트 생성**
4. **credentials.json 다운로드 후 프로젝트 폴더에 저장**

```env
# .env에 추가
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
```

### 알림 설정 커스터마이징
```bash
# 알림 시간 변경
curl -X PUT http://localhost:8000/api/notifications/settings \
  -H "Content-Type: application/json" \
  -d '{
    "email_enabled": true,
    "notification_time": "08:00",
    "frequency": "daily",
    "priority_threshold": 10
  }'
```

---

## 🎯 실제 사용 시나리오

### 시나리오 1: 아이디어 캡처
```python
# 갑작스런 아이디어를 AI가 분석하여 우선순위 점수화
requests.post("http://localhost:8000/api/ai/tasks", json={
    "title": "새로운 앱 아이디어",
    "content": "음식점 대기시간을 실시간으로 보여주는 앱. 사용자가 예약도 할 수 있게 하면 좋을 것 같다.",
    "tags": ["아이디어", "앱개발", "창업"]
})
```

### 시나리오 2: 일일 할 일 관리
```bash
# 매일 오전 9시에 자동으로 받는 이메일 알림 예시:
📧 제목: 🌟 Haneul AI - 오늘의 우선순위 작업 (3개)

🎯 오늘 집중할 TOP 3 작업
1. [18점] 프로젝트 데모 준비 - 예상 2시간
2. [15점] 클라이언트 미팅 자료 - 예상 1시간  
3. [12점] 코드 리뷰 완료 - 예상 30분

📅 캘린더에 추가하기 [클릭]
```

### 시나리오 3: Obsidian 워크플로우
```
📁 HaneulVault/
├── 00-Inbox/           ← AI가 새 작업을 자동 생성
│   └── 20240123_새로운_아이디어.md
├── 01-Todo/            ← 계획된 작업들
│   └── 20240123_프로젝트_데모_준비.md
└── 02-Completed/       ← 완료된 작업들
    └── 20240122_코드_리뷰.md
```

---

## 🛠️ 문제 해결

### 자주 발생하는 문제들

#### 1. OpenAI API 에러
```bash
# API 키 확인
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://api.openai.com/v1/models
```

#### 2. Obsidian Vault 권한 문제
```bash
# 폴더 권한 확인 (Windows)
icacls "C:\Users\YourName\Documents\HaneulVault"
```

#### 3. 포트 충돌
```bash
# 다른 포트로 실행
python start_server.py --port 8001
```

#### 4. 로그 확인
```bash
# 실시간 로그 모니터링
tail -f logs/haneul_ai.log

# Windows에서
powershell Get-Content logs/haneul_ai.log -Wait
```

### 헬스체크
```bash
# 시스템 상태 확인
curl http://localhost:8000/health

# 각 서비스별 상태
curl http://localhost:8000/api/obsidian/health
curl http://localhost:8000/api/notifications/health
```

---

## 📚 API 문서

### 전체 API 문서 확인
서버 실행 후 브라우저에서: http://localhost:8000/docs

### 주요 엔드포인트

#### AI 분석
- `POST /api/ai/analyze` - 우선순위 분석
- `POST /api/ai/tasks` - 작업 생성 (AI 분석 포함)
- `GET /api/ai/tasks/top-priority` - 최고 우선순위 작업

#### Obsidian 연동  
- `GET /api/obsidian/vault/stats` - Vault 통계
- `POST /api/obsidian/sync/import` - Obsidian에서 가져오기

#### 알림 시스템
- `POST /api/notifications/send-daily-summary` - 즉시 알림 발송
- `GET /api/notifications/settings` - 알림 설정 조회

---

## 🎉 성공적인 설치 확인

다음 명령어들이 모두 성공하면 완벽하게 설치된 것입니다:

```bash
# 1. 서버 상태 확인
curl http://localhost:8000/health

# 2. AI 분석 테스트
python test_api.py --test ai

# 3. 작업 생성 테스트  
python test_api.py --test task

# 4. Obsidian 연동 확인
python test_api.py --test obsidian
```

**모든 테스트가 ✅ 통과하면 Haneul AI Agent가 완벽하게 작동하는 것입니다!**

---

## 🚀 다음 단계

1. **개인화**: `.env` 파일에서 알림 시간, Obsidian 경로 등을 원하는 대로 설정
2. **자동화**: OS 시작 시 자동 실행 설정 (선택사항)  
3. **확장**: 필요에 따라 새로운 기능 추가 개발
4. **팀 사용**: 여러 사용자 지원으로 확장 가능

**🌟 이제 AI가 당신의 할 일을 체계적으로 관리해드립니다!**