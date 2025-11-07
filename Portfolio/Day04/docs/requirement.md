# 요구사항 명세: 체험단 매칭 플랫폼

## Meta
- **작성일**: 2025-11-07
- **화면/기능**: 체험단 매칭 플랫폼 (전체)
- **목표**: 광고주와 인플루언서를 매칭하는 체험단 중개 플랫폼
- **주요 사용자**: 광고주, 인플루언서, 일반 사용자

---

## 사용자 행동 (Use Cases)

### UC-1: 체험단 탐색 및 검색
- **입력**: 검색어, 카테고리 필터, 상태 필터, 정렬 기준, 페이지 번호
- **처리**:
  - 입력값 검증 (검색어 길이, 카테고리 유효성)
  - 데이터베이스 쿼리 (필터링, 정렬, 페이징)
  - 지원 가능 여부 확인 (로그인 상태, 인플루언서 등록 여부)
- **출력**: 체험단 목록 카드, 페이지네이션 컨트롤, 필터 상태
- **엣지케이스**:
  - 검색 결과 없음 → "검색 결과가 없습니다" 메시지
  - 네트워크 실패 → "목록을 불러올 수 없습니다" + 재시도 버튼
  - 잘못된 페이지 → 첫 페이지로 리다이렉트

### UC-2: 체험단 등록 (광고주)
- **입력**: 제목, 설명, 모집인원, 마감일, 체험기간, 혜택, 카테고리
- **처리**:
  - 광고주 권한 확인
  - 입력값 검증 (글자 수, 날짜, 인원 범위)
  - 캠페인 생성 및 DB 저장
  - 상태를 '모집중'으로 설정
- **출력**: 등록 완료 메시지, 대시보드로 리다이렉트
- **엣지케이스**:
  - 권한 부족 → "광고주 정보 등록 후 이용 가능합니다"
  - 마감일 과거 → "모집 마감일은 오늘 이후로 설정해주세요"
  - 네트워크 실패 → 입력값 유지 + 재시도 안내

### UC-3: 체험단 지원 (인플루언서)
- **입력**: 지원 동기, 예상 리뷰 발행일, 예상 조회수, 포트폴리오 링크
- **처리**:
  - 인플루언서 권한 확인
  - 중복 지원 체크
  - 모집 상태 및 마감일 확인
  - 지원서 저장 및 광고주 알림 발송
- **출력**: 지원 완료 페이지, 성공 메시지
- **엣지케이스**:
  - 중복 지원 → "이미 지원한 체험단입니다"
  - 모집 마감 → "모집이 마감된 체험단입니다"
  - 권한 부족 → "인플루언서 정보 등록 후 지원 가능합니다"

### UC-4: 광고주 대시보드 관리
- **입력**: 체험단 선택, 인플루언서 선정, 모집 조기 종료
- **처리**:
  - 광고주 권한 확인
  - 체험단 소유권 확인
  - 선정/미선정 처리
  - 알림 발송 (선정자/미선정자)
  - 캠페인 상태 변경 ('진행중' 또는 '완료')
- **출력**: 선정 완료 메시지, 업데이트된 지원자 목록
- **엣지케이스**:
  - 권한 부족 → "본인이 등록한 체험단만 관리할 수 있습니다"
  - 잘못된 상태 → "이미 종료된 체험단입니다"
  - 선정자 없음 → "최소 1명 이상 선정해주세요"

### UC-5: 회원가입 및 로그인
- **입력**: 이메일, 비밀번호, 개인정보, 역할 선택
- **처리**:
  - 입력값 검증 (이메일 형식, 비밀번호 정책)
  - 중복 확인 (이메일, 전화번호)
  - 계정 생성 및 역할 설정
  - JWT 토큰 발급
- **출력**: 로그인 성공, 역할별 페이지 리다이렉트
- **엣지케이스**:
  - 이메일 중복 → "이미 사용 중인 이메일입니다"
  - 잘못된 자격증명 → "이메일 또는 비밀번호가 틀렸습니다"
  - 계정 잠금 → "계정이 일시 잠금되었습니다"

---

## 데이터베이스 명세

### 테이블: users (사용자)
| 필드 | 타입 | 제약 | 기본값 | 인덱스 |
|------|------|------|--------|--------|
| id | TEXT (CUID) | PK | cuid() | ✅ |
| email | VARCHAR(255) | UNIQUE, NOT NULL | - | ✅ |
| password_hash | VARCHAR(255) | NOT NULL | - | - |
| name | VARCHAR(100) | NOT NULL | - | - |
| phone_number | VARCHAR(20) | NOT NULL | - | - |
| birth_date | DATE | NOT NULL | - | - |
| role | ENUM | NULL | - | ✅ |
| created_at | TIMESTAMPTZ | NOT NULL | now() | ✅ |
| updated_at | TIMESTAMPTZ | NOT NULL | now() | - |

### 테이블: campaigns (체험단)
| 필드 | 타입 | 제약 | 기본값 | 인덱스 |
|------|------|------|--------|--------|
| id | TEXT (CUID) | PK | cuid() | ✅ |
| advertiser_id | TEXT | FK, NOT NULL | - | ✅ |
| title | VARCHAR(200) | NOT NULL | - | ✅ |
| description | TEXT | NOT NULL | - | - |
| recruit_count | INTEGER | NOT NULL | - | - |
| deadline | DATE | NOT NULL | - | ✅ |
| category | VARCHAR(50) | NOT NULL | - | ✅ |
| status | ENUM | NOT NULL | 'RECRUITING' | ✅ |
| created_at | TIMESTAMPTZ | NOT NULL | now() | ✅ |

### 테이블: applications (지원내역)
| 필드 | 타입 | 제약 | 기본값 | 인덱스 |
|------|------|------|--------|--------|
| id | TEXT (CUID) | PK | cuid() | ✅ |
| campaign_id | TEXT | FK, NOT NULL | - | ✅ |
| influencer_id | TEXT | FK, NOT NULL | - | ✅ |
| motivation | TEXT | NOT NULL | - | - |
| status | ENUM | NOT NULL | 'PENDING' | ✅ |
| created_at | TIMESTAMPTZ | NOT NULL | now() | ✅ |

### 관계
- users (1) ──< (N) advertisers
- users (1) ──< (N) influencers
- advertisers (1) ──< (N) campaigns
- influencers (1) ──< (N) applications
- campaigns (1) ──< (N) applications
- users (1) ──< (N) notifications

### 쿼리 패턴

```sql
-- 체험단 목록 조회 (페이징, 필터링, 정렬)
SELECT c.id, c.title, c.description, c.recruit_count, c.deadline,
       c.category, c.status, a.company_name,
       COUNT(app.id) as application_count
FROM campaigns c
JOIN advertisers a ON c.advertiser_id = a.id
LEFT JOIN applications app ON c.id = app.campaign_id
WHERE c.status = 'RECRUITING'
  AND ($1::varchar IS NULL OR c.category = $1)
  AND ($2::varchar IS NULL OR c.title ILIKE '%' || $2 || '%')
GROUP BY c.id, a.company_name
ORDER BY c.created_at DESC
LIMIT 20 OFFSET $3;

-- 체험단 상세 조회 (지원 가능 여부 포함)
SELECT c.*, a.company_name,
       COUNT(app.id) as application_count,
       EXISTS(
         SELECT 1 FROM applications app2
         WHERE app2.campaign_id = c.id AND app2.influencer_id = $2
       ) as already_applied
FROM campaigns c
JOIN advertisers a ON c.advertiser_id = a.id
LEFT JOIN applications app ON c.id = app.campaign_id
WHERE c.id = $1
GROUP BY c.id, a.company_name;

-- 광고주 대시보드 체험단 목록
SELECT c.id, c.title, c.status, c.deadline,
       COUNT(app.id) as total_applications,
       COUNT(CASE WHEN app.status = 'SELECTED' THEN 1 END) as selected_count
FROM campaigns c
LEFT JOIN applications app ON c.id = app.campaign_id
WHERE c.advertiser_id = $1
GROUP BY c.id
ORDER BY c.created_at DESC;
```

### 트랜잭션 단위
- 회원가입: BEGIN → INSERT users → INSERT advertiser/influencer → INSERT auth_tokens → COMMIT
- 체험단 등록: 단일 INSERT (campaigns)
- 체험단 지원: BEGIN → INSERT applications → INSERT notifications → COMMIT
- 인플루언서 선정: BEGIN → UPDATE applications (선정/미선정) → INSERT notifications → UPDATE campaigns → COMMIT

---

## 상태 변화 시나리오

### 시나리오 1: 체험단 목록 로드
**전 (Before)**:
```json
{
  "campaigns": [],
  "loading": true,
  "filters": { "category": null, "search": "", "status": "RECRUITING" },
  "pagination": { "page": 1, "total": 0 }
}
```

**액션**: `campaigns/fetchRequested(filters, page)`

**후 (After)**:
```json
{
  "campaigns": [
    {
      "id": "cm3h4k...",
      "title": "신제품 립스틱 체험단",
      "company_name": "(주)뷰티코스메틱",
      "application_count": 3,
      "deadline": "2025-11-20"
    }
  ],
  "loading": false,
  "pagination": { "page": 1, "total": 45 }
}
```

### 시나리오 2: 체험단 지원
**전 (Before)**:
```json
{
  "selectedCampaign": { "id": "cm3h4k...", "already_applied": false },
  "isApplying": false,
  "applicationForm": { "motivation": "", "expectedDate": "" }
}
```

**액션**: `applications/submitRequested(campaignId, formData)`

**후 (After)**:
```json
{
  "selectedCampaign": { "id": "cm3h4k...", "already_applied": true },
  "isApplying": false,
  "applicationForm": { "motivation": "", "expectedDate": "" },
  "showSuccessModal": true
}
```

### 시나리오 3: 광고주 인플루언서 선정
**전 (Before)**:
```json
{
  "campaign": { "id": "cm3h4k...", "status": "CLOSED" },
  "applications": [
    { "id": "app1", "status": "PENDING", "selected": false },
    { "id": "app2", "status": "PENDING", "selected": false }
  ],
  "isSelecting": false
}
```

**액션**: `campaigns/selectInfluencers(campaignId, selectedIds)`

**후 (After)**:
```json
{
  "campaign": { "id": "cm3h4k...", "status": "IN_PROGRESS" },
  "applications": [
    { "id": "app1", "status": "SELECTED", "selected": true },
    { "id": "app2", "status": "REJECTED", "selected": false }
  ],
  "isSelecting": false,
  "showSelectionComplete": true
}
```

---

## 비기능 요구사항

### 성능
- **목표**: P95 < 500ms (API 응답), P95 < 200ms (검색)
- **페이징**: 20개 단위, 무한 스크롤 (체험단 목록)
- **캐싱**: 5분 TTL (체험단 목록), 1분 TTL (상세 정보)
- **최적화**: 이미지 lazy loading, 가상화 스크롤 (긴 목록)

### 보안
- **권한**: JWT 토큰 검증 (httpOnly 쿠키)
- **입력 검증**: Zod 스키마 (클라이언트 + 서버 이중 검증)
- **Rate Limiting**:
  - 로그인: 5회/분 per IP
  - 체험단 등록: 10회/시간 per 사용자
  - 지원: 20회/시간 per 사용자
- **CSRF 보호**: SameSite 쿠키 + CSRF 토큰

### 접근성
- **WCAG 2.2 Level AA**: 모든 주요 기능
- **키보드 네비게이션**: Tab, Enter, ESC 지원
- **Focus Management**: 모달 오픈/닫기 시 포커스 이동
- **ARIA 라벨**: 스크린 리더 지원
- **색상 대비**: 4.5:1 이상 (일반 텍스트), 3:1 이상 (큰 텍스트)

### 로깅/감사
- **Action Logging**: 모든 상태 변경 로깅 (Redux DevTools)
- **Error Tracking**: Sentry 통합 (에러 자동 수집)
- **Analytics**: 사용자 행동 추적 (Google Analytics)
- **Audit Trail**: 중요 액션 서버 로깅 (지원, 선정 등)

### 반응형 & 브라우저 지원
- **반응형**: Mobile First (320px+), Tablet (768px+), Desktop (1024px+)
- **브라우저**: Chrome 100+, Firefox 100+, Safari 15+, Edge 100+
- **PWA**: 오프라인 캐싱, 푸시 알림 (선택)

### i18n (다국어 지원)
- **Languages**: ko-KR (기본), en-US (선택)
- **Keys**: `t('campaigns.apply.success')`, `t('errors.network')`
- **Format**: 날짜, 숫자, 통화 현지화
- **RTL**: 미지원 (한국어 우선)

---

## 실시간 기능 요구사항

### WebSocket 연결
- **연결 대상**: 로그인된 사용자
- **실시간 업데이트**:
  - 체험단 지원자 수 변경
  - 새로운 알림 도착
  - 선정 결과 알림

### 알림 시스템
- **인플루언서**: 지원 결과 (선정/미선정), 체험단 마감 임박
- **광고주**: 새로운 지원자, 모집 완료
- **전송 방식**: WebSocket (실시간) + 이메일 (백업)

### 오프라인 지원
- **읽기 기능**: 캐시된 체험단 목록 표시
- **쓰기 기능**: 오프라인 큐 → 온라인 복구 시 동기화
- **상태 표시**: 오프라인 인디케이터 + 동기화 상태