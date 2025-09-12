# HaneulTone Backend API

HaneulTone AI 보컬 트레이너 앱을 위한 Node.js/Express 백엔드 API 서버입니다.

## 🚀 시작하기

### 필요 조건

- Node.js 16.x 이상
- MongoDB 4.4 이상 (로컬 또는 MongoDB Atlas)
- npm 또는 yarn

### 설치 및 설정

1. **의존성 설치**
```bash
cd backend
npm install
```

2. **환경 변수 설정**
```bash
# .env.example을 복사하여 .env 파일 생성
cp .env.example .env

# .env 파일을 편집하여 실제 값 입력
# - MONGODB_URI: MongoDB 연결 문자열
# - JWT_SECRET: JWT 토큰용 비밀키 (강력한 랜덤 문자열)
# - PORT: 서버 포트 (기본값: 3000)
```

3. **MongoDB 설정**
   
   **옵션 1: 로컬 MongoDB 사용**
   ```bash
   # MongoDB 설치 및 실행
   # macOS (Homebrew)
   brew install mongodb-community
   brew services start mongodb-community

   # Ubuntu
   sudo apt-get install mongodb
   sudo systemctl start mongodb

   # Windows: MongoDB 공식 사이트에서 다운로드 후 설치
   ```

   **옵션 2: MongoDB Atlas 사용 (권장)**
   - [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) 계정 생성
   - 새 클러스터 생성
   - 연결 문자열을 .env 파일에 추가

4. **서버 실행**
```bash
# 개발 모드 (nodemon 사용)
npm run dev

# 프로덕션 모드
npm start
```

## 📚 API 문서

서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:
- **API 문서**: http://localhost:3000/api
- **헬스 체크**: http://localhost:3000/health

### 인증 엔드포인트

#### POST /api/auth/register
회원가입

**요청 본문:**
```json
{
  "email": "user@example.com",
  "username": "username123",
  "displayName": "사용자 이름",
  "password": "SecurePass123"
}
```

**응답:**
```json
{
  "success": true,
  "message": "회원가입이 완료되었습니다",
  "user": {
    "_id": "...",
    "email": "user@example.com",
    "username": "username123",
    "displayName": "사용자 이름",
    "voiceType": "unknown",
    "skillLevel": "beginner",
    "isEmailVerified": false,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  "token": "jwt_token_here"
}
```

#### POST /api/auth/login
로그인

**요청 본문:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

**응답:**
```json
{
  "success": true,
  "message": "로그인 성공",
  "user": { ... },
  "token": "jwt_token_here"
}
```

### 사용자 엔드포인트

모든 사용자 엔드포인트는 `Authorization: Bearer <token>` 헤더가 필요합니다.

#### GET /api/user/profile
사용자 프로필 조회

#### PUT /api/user/profile
사용자 프로필 업데이트

**요청 본문:**
```json
{
  "displayName": "새로운 이름",
  "voiceType": "tenor",
  "skillLevel": "intermediate",
  "preferences": {
    "theme": "dark",
    "language": "ko"
  }
}
```

#### GET /api/user/stats
사용자 통계 조회

### 세션 엔드포인트

#### POST /api/sessions
연습 세션 저장

**요청 본문:**
```json
{
  "sessionType": "scale_practice",
  "accuracyMean": 15.5,
  "accuracyMedian": 14.2,
  "stabilitySd": 8.3,
  "totalNotes": 24,
  "correctNotes": 20,
  "duration": 180,
  "audioReferenceId": "ref123",
  "analysisData": {
    "pitchData": [440.0, 493.88, 523.25],
    "timeStamps": [0, 1000, 2000],
    "noteEvents": [
      {
        "note": "A4",
        "startTime": 0,
        "endTime": 1000,
        "accuracy": 12.5
      }
    ]
  }
}
```

#### GET /api/sessions
연습 세션 목록 조회

**쿼리 파라미터:**
- `page`: 페이지 번호 (기본값: 1)
- `limit`: 페이지당 항목 수 (기본값: 20)
- `sessionType`: 세션 타입 필터 (선택사항)

#### GET /api/sessions/stats/summary
세션 통계 조회

**쿼리 파라미터:**
- `period`: 통계 기간 (`week`, `month`, `year`)

## 🛠 개발

### 프로젝트 구조

```
backend/
├── config/
│   └── database.js          # MongoDB 연결 설정
├── middleware/
│   ├── auth.js              # JWT 인증 미들웨어
│   └── validation.js        # 입력 검증 미들웨어
├── models/
│   ├── User.js              # 사용자 모델
│   └── Session.js           # 세션 모델
├── routes/
│   ├── auth.js              # 인증 라우트
│   ├── user.js              # 사용자 라우트
│   └── sessions.js          # 세션 라우트
├── server.js                # 메인 서버 파일
├── package.json
├── .env.example
└── README.md
```

### 테스트

```bash
# 테스트 실행
npm test

# 테스트 커버리지
npm run test:coverage
```

### 데이터베이스 스키마

#### User 모델
- `email`: 이메일 (고유, 필수)
- `username`: 사용자명 (고유, 필수)
- `displayName`: 표시 이름 (필수)
- `password`: 비밀번호 (해싱됨, 필수)
- `voiceType`: 음성 타입 (enum)
- `skillLevel`: 실력 레벨 (enum)
- `isEmailVerified`: 이메일 인증 여부
- `preferences`: 사용자 설정 (Map)
- `lastLoginAt`: 마지막 로그인 시간
- `createdAt`, `updatedAt`: 자동 생성

#### Session 모델
- `userId`: 사용자 ID (필수, 외래키)
- `sessionType`: 세션 타입 (enum)
- `accuracyMean`: 평균 정확도 (필수)
- `accuracyMedian`: 중간값 정확도 (필수)
- `stabilitySd`: 안정도 표준편차 (필수)
- `totalNotes`: 전체 음표 수 (필수)
- `correctNotes`: 정확한 음표 수 (필수)
- `duration`: 세션 시간 (초, 필수)
- `audioReferenceId`: 오디오 참조 ID (선택)
- `analysisData`: 상세 분석 데이터 (선택)
- `coachFeedback`: AI 코치 피드백 (선택)
- `metadata`: 메타데이터 (선택)
- `createdAt`, `updatedAt`: 자동 생성

## 🔧 환경 변수

```env
# 필수 환경 변수
MONGODB_URI=mongodb://localhost:27017/haneultone
JWT_SECRET=your-super-secret-jwt-key-here
PORT=3000

# 선택 환경 변수
NODE_ENV=development
CORS_ORIGIN=http://localhost:*
```

## 🚀 배포

### Docker 사용

```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### PM2 사용

```bash
# PM2 설치
npm install -g pm2

# 애플리케이션 실행
pm2 start server.js --name "haneultone-api"

# PM2 상태 확인
pm2 status
pm2 logs haneultone-api
```

## 🔐 보안

- JWT 토큰 기반 인증
- bcryptjs를 사용한 비밀번호 해싱 (12 라운드)
- Helmet.js를 사용한 보안 헤더 설정
- Rate limiting으로 DDoS 공격 방지
- CORS 정책 적용
- 입력 검증 및 sanitization

## 📝 라이센스

MIT License