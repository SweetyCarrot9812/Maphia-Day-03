# Hanoa Hub - 통합 인증 시스템

Hanoa 생태계의 중앙 인증 허브입니다. 하나의 계정으로 모든 Hanoa 서비스(Clintest, Lingumo, HaneulTone, AreumFit)에 접근할 수 있습니다.

## 🏗️ 아키텍처

```
┌─────────────────────────────────────┐
│            Hanoa Hub                │
│   (중앙 인증 + 권한 관리)            │
└─────────────────┬───────────────────┘
                  │
        ┌─────────┼─────────┐
        │         │         │
   ┌─────────┐ ┌───────┐ ┌──────────┐
   │Clintest │ │Lingumo│ │HaneulTone│
   │ (의학)  │ │(언어) │ │  (성악)  │
   └─────────┘ └───────┘ └──────────┘
```

## 🚀 빠른 시작

### 1. 설치
```bash
cd "Hanoa Hub"
npm install
```

### 2. 환경 설정
```bash
cp .env.example .env
# .env 파일을 편집하여 필요한 환경변수 설정
```

### 3. Firebase 설정
1. Firebase Console에서 프로젝트 생성
2. Service Account Key를 `config/firebase-service-account.json`에 저장
3. `.env`에 Firebase 프로젝트 정보 입력

### 4. 서버 실행
```bash
npm start        # 프로덕션 모드
npm run dev      # 개발 모드 (nodemon)
```

### 5. 헬스 체크
```bash
curl http://localhost:4000/health
```

## 📡 API 엔드포인트

### 인증 API (`/api/auth`)

#### 로그인
```http
POST /api/auth/login
Authorization: Bearer <firebase-id-token>
```

#### 토큰 갱신
```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "refresh-token-here"
}
```

#### 토큰 검증
```http
GET /api/auth/verify
Authorization: Bearer <hanoa-token>
```

### 사용자 API (`/api/users`)

#### 프로필 조회
```http
GET /api/users/profile
Authorization: Bearer <hanoa-token>
```

#### 설정 업데이트
```http
PUT /api/users/settings
Authorization: Bearer <hanoa-token>
Content-Type: application/json

{
  "language": "ko",
  "theme": "dark",
  "notifications": true
}
```

### 서비스 API (`/api/services`)

#### 서비스별 토큰 검증 (서비스 간 통신용)
```http
POST /api/services/clintest/verify
Content-Type: application/json

{
  "token": "hanoa-token-here",
  "requiredPermission": "read:questions"
}
```

#### 사용자 서비스 목록
```http
GET /api/services/my
Authorization: Bearer <hanoa-token>
```

## 🔐 보안 모델

### 토큰 구조
```typescript
interface HanoaToken {
  uid: string;              // 사용자 UID
  email: string;           // 이메일
  name: string;            // 이름
  services: {              // 서비스별 권한
    clintest: {
      isActive: boolean;
      plan: 'free' | 'basic' | 'premium';
      permissions: string[];
    };
    // ... 다른 서비스들
  };
  iat: number;            // 발급 시간
  exp: number;            // 만료 시간
}
```

### 권한 시스템
- **서비스별 구독**: 각 서비스마다 독립적인 구독 상태
- **권한 기반 접근**: 세분화된 권한으로 기능별 접근 제어
- **실시간 검증**: 매 요청마다 최신 권한 상태 확인

## 🔄 서비스 통합 가이드

### 기존 서비스를 Hanoa Hub와 연동하기

#### 1. 미들웨어 추가
```javascript
const axios = require('axios');

async function verifyHanoaToken(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  try {
    const response = await axios.post(`${HANOA_HUB_URL}/api/services/clintest/verify`, {
      token,
      requiredPermission: 'read:questions' // 필요한 권한
    });
    
    req.user = response.data.user;
    req.serviceAccess = response.data.serviceAccess;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Authentication failed' });
  }
}
```

#### 2. 라우트 보호
```javascript
app.get('/api/questions', verifyHanoaToken, (req, res) => {
  // 인증된 사용자만 접근 가능
  // req.user와 req.serviceAccess 사용 가능
});
```

## 🛠️ 개발 도구

### 로그 확인
```bash
# 개발 모드에서는 콘솔에 로그 출력
# 프로덕션 모드에서는 파일에 로그 저장
tail -f logs/combined.log
```

### 테스트
```bash
npm test
```

### 코드 품질
```bash
# ESLint 실행 (package.json에 추가 필요)
npm run lint

# Prettier 실행 (package.json에 추가 필요)
npm run format
```

## 📊 모니터링

### 헬스 체크
- **Hub 상태**: `GET /health`
- **서비스 상태**: `GET /api/services/health`

### 메트릭스
- 사용자 로그인/로그아웃
- 서비스별 접근 통계
- 토큰 검증 요청 수
- 오류 발생 빈도

## 🚢 배포

### 환경변수 설정
```env
NODE_ENV=production
PORT=4000
FIREBASE_PROJECT_ID=your-production-project
JWT_SECRET=your-super-secret-key
```

### 프로세스 관리
```bash
# PM2 사용 예시
pm2 start server.js --name hanoa-hub
pm2 save
pm2 startup
```

### Docker (선택사항)
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 4000
CMD ["node", "server.js"]
```

## 📚 관련 문서

- [Firebase 설정 가이드](./SETUP_FIREBASE_GUIDE.md)
- [API 문서](./docs/API.md) (생성 예정)
- [서비스 통합 가이드](./docs/INTEGRATION.md) (생성 예정)

## 🤝 기여하기

1. 기능 요청이나 버그 리포트는 이슈로 등록
2. 코드 변경 시 테스트 작성
3. 커밋 메시지는 명확하게 작성
4. PR 전에 코드 품질 검사 실행

## 📄 라이선스

MIT License - 자세한 내용은 [LICENSE](./LICENSE) 파일 참조

---

**문의**: Hanoa 개발팀  
**버전**: 1.0.0  
**마지막 업데이트**: 2025-09-06