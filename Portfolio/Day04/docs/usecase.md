# UseCase 명세 총괄 (체험단 매칭 플랫폼)

## Meta
- 작성일: 2025-11-07
- 작성자: 06-UseCase Generator Agent v3.0
- 버전: 1.0
- 프로젝트: 체험단 매칭 플랫폼

---

## 📁 UseCase 구조

### 생성된 UseCase 목록
- **UC-001**: [회원가입 및 역할 선택](./001/spec.md) — 신규 사용자 가입 프로세스
- **UC-005**: [체험단 등록 (광고주)](./005/spec.md) — 광고주의 캠페인 생성
- **UC-006**: [체험단 지원 (인플루언서)](./006/spec.md) — 인플루언서의 지원서 제출

### 향후 추가 예정 UseCase
- UC-002: 광고주 정보 입력
- UC-003: 인플루언서 정보 입력
- UC-004: 로그인
- UC-007: 체험단 관리 및 인플루언서 선정 (광고주)
- UC-008: 체험단 탐색 (공통)

---

## 🔗 Traceability Matrix

### @SPEC:ID → 코드 파일 매핑

#### UC-001 (회원가입)
| @SPEC:ID | Business Rule | 검증 계층 | 예상 파일 위치 |
|----------|---------------|-----------|----------------|
| UC001-UBI-001 | 이메일 형식 검증 | Presentation | `/presentation/schemas/auth.schema.ts` |
| UC001-UBI-002 | 비밀번호 정책 | Presentation | `/presentation/schemas/auth.schema.ts` |
| UC001-EVT-001 | 사용자 계정 생성 | Application | `/application/auth/RegisterUserUseCase.ts` |
| UC001-EVT-002 | 인증 토큰 발급 | Application | `/application/auth/EmailTokenService.ts` |
| UC001-STA-001 | 로그인 상태 차단 | Presentation | `/presentation/middleware/auth.middleware.ts` |
| UC001-CON-001 | 비밀번호 해싱 | Domain | `/domain/user/Password.vo.ts` |
| UC001-CON-002 | 나이 제한 | Domain | `/domain/user/Age.vo.ts` |

#### UC-005 (체험단 등록)
| @SPEC:ID | Business Rule | 검증 계층 | 예상 파일 위치 |
|----------|---------------|-----------|----------------|
| UC005-UBI-001 | 광고주 권한 확인 | Presentation | `/presentation/middleware/advertiser.middleware.ts` |
| UC005-UBI-002 | 제목 길이 검증 | Presentation | `/presentation/schemas/campaign.schema.ts` |
| UC005-UBI-003 | 설명 길이 검증 | Presentation | `/presentation/schemas/campaign.schema.ts` |
| UC005-EVT-001 | 캠페인 생성 | Application | `/application/campaigns/CreateCampaignUseCase.ts` |
| UC005-CON-001 | 마감일 검증 | Domain | `/domain/campaign/Deadline.vo.ts` |
| UC005-CON-002 | 모집 인원 검증 | Domain | `/domain/campaign/RecruitCount.vo.ts` |

#### UC-006 (체험단 지원)
| @SPEC:ID | Business Rule | 검증 계층 | 예상 파일 위치 |
|----------|---------------|-----------|----------------|
| UC006-UBI-001 | 인플루언서 권한 | Presentation | `/presentation/middleware/influencer.middleware.ts` |
| UC006-UBI-002 | 지원 동기 길이 | Presentation | `/presentation/schemas/application.schema.ts` |
| UC006-EVT-001 | 지원서 생성 | Application | `/application/campaigns/ApplyCampaignUseCase.ts` |
| UC006-EVT-002 | 알림 발송 | Application | `/application/notifications/NotificationService.ts` |
| UC006-STA-001 | 모집 상태 확인 | Application | `/application/campaigns/CampaignStatusChecker.ts` |
| UC006-CON-001 | 중복 방지 | Infrastructure | DB UNIQUE constraint (자동) |

---

## 📊 구현 우선순위

### Phase 0 (MVP - 즉시 구현)
1. **UC-001**: 회원가입 및 역할 선택 — 모든 기능의 전제 조건
2. **UC-005**: 체험단 등록 — 광고주 핵심 기능
3. **UC-006**: 체험단 지원 — 인플루언서 핵심 기능

### Phase 1 (확장 기능)
4. **UC-002**: 광고주 정보 입력 — UC-005의 전제 조건
5. **UC-003**: 인플루언서 정보 입력 — UC-006의 전제 조건
6. **UC-004**: 로그인 — 모든 인증 기능

### Phase 2 (관리 기능)
7. **UC-007**: 체험단 관리 및 선정 — 광고주 고급 기능
8. **UC-008**: 체험단 탐색 — 사용자 경험 개선

---

## 🧪 테스트 전략

### Unit Test Coverage by Layer
```
Domain Layer (값 객체, 엔티티):
- Password.vo.spec.ts (UC001-CON-001)
- Age.vo.spec.ts (UC001-CON-002)
- RecruitCount.vo.spec.ts (UC005-CON-002)
- Deadline.vo.spec.ts (UC005-CON-001)

Application Layer (Use Cases):
- RegisterUserUseCase.spec.ts (UC001-EVT-001)
- CreateCampaignUseCase.spec.ts (UC005-EVT-001)
- ApplyCampaignUseCase.spec.ts (UC006-EVT-001)

Presentation Layer (스키마, 미들웨어):
- auth.schema.spec.ts (UC001-UBI-001, UC001-UBI-002)
- campaign.schema.spec.ts (UC005-UBI-002, UC005-UBI-003)
- auth.middleware.spec.ts (UC001-STA-001)
```

### Integration Test Coverage
```
API Endpoints:
- POST /api/auth/register (UC-001 전체 플로우)
- POST /api/campaigns (UC-005 전체 플로우)
- POST /api/campaigns/:id/apply (UC-006 전체 플로우)

Database Operations:
- User 생성 트랜잭션 (UC-001)
- Campaign 생성과 권한 체크 (UC-005)
- Application 생성과 중복 방지 (UC-006)
```

### E2E Test Scenarios
```
Happy Paths:
- 신규 사용자 → 회원가입 → 역할 선택 → 전용 기능 사용
- 광고주 → 체험단 등록 → 지원자 확인
- 인플루언서 → 체험단 탐색 → 지원 → 선정 대기

Error Scenarios:
- 중복 이메일 회원가입 시도
- 권한 없는 사용자의 기능 접근
- 마감된 체험단 지원 시도
```

---

## 🔄 의존성 흐름

### UseCase 간 의존성
```
UC-001 (회원가입)
├── UC-002 (광고주 정보 입력)
│   └── UC-005 (체험단 등록)
│       └── UC-007 (체험단 관리)
└── UC-003 (인플루언서 정보 입력)
    └── UC-006 (체험단 지원)

UC-004 (로그인) ←→ 모든 인증 필요 기능

UC-008 (체험단 탐색) ←→ UC-005, UC-006 (양방향 참조)
```

### 데이터 엔티티 의존성
```
users (중심)
├── advertisers (1:1) → campaigns (1:N)
└── influencers (1:1) → applications (1:N)

campaigns ←→ applications (N:M through applications table)
notifications ← users (1:N)
auth_tokens ← users (1:N)
```

---

## 🚀 구현 가이드

### 1. Domain Layer 먼저 구현
```typescript
// 추천 구현 순서
1. Value Objects (Password, Age, RecruitCount, Deadline)
2. Entities (User, Campaign, Application)
3. Domain Services (필요시)
```

### 2. Infrastructure Layer 구현
```typescript
// Repository 패턴으로 구현
1. UserRepository (UC-001 지원)
2. CampaignRepository (UC-005, UC-006 지원)
3. ApplicationRepository (UC-006 지원)
```

### 3. Application Layer 구현
```typescript
// Use Case 순서대로 구현
1. RegisterUserUseCase (UC-001)
2. CreateCampaignUseCase (UC-005)
3. ApplyCampaignUseCase (UC-006)
```

### 4. Presentation Layer 마지막 구현
```typescript
// 사용자 인터페이스 구현
1. Zod Schemas (입력 검증)
2. Middleware (권한 검증)
3. Controllers (API 엔드포인트)
4. UI Components (React)
```

---

## ✅ 완료 체크리스트

### UseCase 명세 완료 여부
- [x] UC-001: 회원가입 및 역할 선택
- [x] UC-005: 체험단 등록 (광고주)
- [x] UC-006: 체험단 지원 (인플루언서)
- [ ] UC-002: 광고주 정보 입력
- [ ] UC-003: 인플루언서 정보 입력
- [ ] UC-004: 로그인
- [ ] UC-007: 체험단 관리 및 선정
- [ ] UC-008: 체험단 탐색

### 문서 품질 검증
- [x] EARS 기반 Business Rules 분류
- [x] @SPEC:ID 모든 규칙에 태깅
- [x] PlantUML 표준 문법 준수
- [x] Gherkin Acceptance Criteria 작성
- [x] Traceability 코드 매핑 완료
- [x] Error Catalogue 구체적 명시

### 구현 준비도
- [x] 데이터베이스 스키마 연동 확인
- [x] UserFlow 요구사항 반영 완료
- [x] 아키텍처 계층 매핑 완료
- [x] 테스트 전략 수립 완료

---

## 📝 Notes

### Technical Decisions Made
1. **@SPEC:ID 체계**: UC{번호}-{카테고리}-{순번} 형식 채택
2. **Validation Layer**: Presentation(입력) → Application(비즈니스) → Domain(불변) 3단계
3. **Error Code System**: {카테고리}-{번호} 형식 (예: VAL-001, BIZ-002)
4. **Traceability**: 코드 파일과 @SPEC:ID 1:1 매핑 원칙

### 향후 고려사항
- 소셜 로그인 (Phase 2)
- 파일 업로드 정책 수립
- 실시간 알림 시스템 (WebSocket)
- AI 매칭 알고리즘 (Phase 3)

이제 체험단 매칭 플랫폼의 핵심 UseCase 명세가 완료되었습니다! 🎉