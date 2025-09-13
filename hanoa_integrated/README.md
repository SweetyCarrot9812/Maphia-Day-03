# 🏠 Hanoa 통합 플랫폼

**Hanoa Hub (백엔드) + Hanoa Desktop (Flutter) 통합 솔루션**

## 🏗️ 아키텍처

```
hanoa_integrated/
├── backend/          # Node.js 중앙 인증 서버 (기존 Hanoa Hub)
│   ├── server.js
│   ├── config/
│   ├── routes/
│   └── package.json
├── frontend/         # Flutter 통합 교육 허브 (기존 hanoa_desktop_flutter)
│   ├── lib/
│   ├── assets/
│   └── pubspec.yaml
├── package.json      # 통합 실행 스크립트
├── start.bat         # Windows 원클릭 실행
└── README.md
```

## 🚀 빠른 시작

### 방법 1: 원클릭 실행 (Windows)
```bash
# 더블클릭으로 실행
start.bat
```

### 방법 2: NPM 스크립트
```bash
# 의존성 설치
npm run install:all

# 개발 모드 (백엔드 + 프론트엔드 동시 실행)
npm run dev

# 백엔드만 실행
npm run backend:dev

# 프론트엔드만 실행
npm run frontend:dev
```

## 🛠️ 개별 구성 요소

### Backend (Node.js 인증 서버)
- **포트**: 4000
- **기능**: 중앙 인증, 권한 관리, API 게이트웨이
- **실행**: `cd backend && npm run dev`

### Frontend (Flutter Desktop)
- **타입**: Windows 데스크톱 앱
- **기능**: 통합 교육 허브 플랫폼
- **실행**: `cd frontend && flutter run -d windows`

## 📡 통신 구조

```
Flutter App ←→ Node.js Server ←→ Firebase Auth
     │                │
     └── Local DB ─────┴── External APIs
```

## 🔧 개발 환경 설정

### 필수 요구사항
- Node.js 18+
- Flutter 3.35.2+
- Windows 10/11

### 환경 변수 설정
```bash
# backend/.env
NODE_ENV=development
PORT=4000
FIREBASE_PROJECT_ID=hanoa-97393
JWT_SECRET=your-secret-key

# frontend/.env
GEMINI_API_KEY=your-key
OPENAI_API_KEY=your-key
PERPLEXITY_API_KEY=your-key
```

## 📝 사용 가능한 명령어

| 명령어 | 설명 |
|--------|------|
| `npm run dev` | 백엔드 + 프론트엔드 동시 실행 |
| `npm run backend:dev` | 백엔드만 개발 모드 실행 |
| `npm run frontend:dev` | 프론트엔드만 실행 |
| `npm run build` | 프론트엔드 빌드 + 백엔드 프로덕션 실행 |
| `npm run install:all` | 모든 의존성 설치 |
| `npm run clean` | 빌드 캐시 정리 |
| `npm run test` | 전체 테스트 실행 |

## 🔐 인증 플로우

1. **사용자 로그인** → Frontend에서 Firebase Auth
2. **토큰 발급** → Backend에서 JWT 생성
3. **API 요청** → Frontend가 Backend API 호출
4. **권한 검증** → Backend에서 토큰 및 권한 확인

## 🌟 주요 기능

### Backend (Hanoa Hub)
- 🔐 통합 인증 시스템
- 🎯 서비스별 권한 관리
- 🔄 다중 서비스 연동 API

### Frontend (Hanoa Desktop)
- 🏫 통합 교육 허브
- 🤖 LLM 프록시 서비스
- 📊 일일 배치 및 알림
- 💾 로컬 데이터베이스 (Isar)

## 🚢 배포

### 개발 환경
```bash
npm run dev
```

### 프로덕션 환경
```bash
npm run build
```

## 📚 관련 문서

- [Backend API 문서](./backend/README.md)
- [Frontend 개발 가이드](./frontend/README.md)
- [Firebase 설정 가이드](./backend/SETUP_FIREBASE_GUIDE.md)

## 🤝 기여하기

1. 기능 요청이나 버그는 이슈로 등록
2. 코드 변경시 테스트 작성 필수
3. 커밋 메시지는 명확하게
4. PR 전 `npm run test` 실행

---

**버전**: 1.0.0
**마지막 업데이트**: 2025-09-14
**개발팀**: Hanoa Team