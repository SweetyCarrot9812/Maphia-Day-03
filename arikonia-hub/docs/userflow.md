# Arikonia Hub - Userflow 명세서

## 문서 정보
- **작성일**: 2025-01-20
- **버전**: 1.0
- **관련 PRD**: [/docs/prd.md](./prd.md)
- **프로젝트**: Arikonia Hub (통합 SSO 플랫폼)

---

## 목차
1. [회원가입 유저플로우](#1-회원가입-sign-up)
2. [로그인 유저플로우](#2-로그인-sign-in)
3. [프로젝트 접근 제어](#3-프로젝트-접근-제어-project-access-control)
4. [관리자 - 사용자 구독 관리](#4-관리자---사용자-구독-관리-admin-user-subscription-management)
5. [공통 에러 처리](#공통-에러-처리)
6. [플로우 간 연결](#플로우-간-연결)

---

## 1. 회원가입 (Sign Up)

### 개요
- **목적**: 신규 사용자가 이메일 또는 구글 계정으로 Arikonia 계정 생성
- **사용자**: 처음 방문한 학습자
- **빈도**: 사용자당 1회
- **가입 방식**:
  - **옵션 1**: 이메일 + 비밀번호
  - **옵션 2**: 구글 OAuth

### 1. 입력 (User Input & Interaction)

**진입점**:
- 랜딩 페이지(/) 헤더에서 "회원가입" 버튼 클릭
- 로그인 페이지(/login)에서 "계정이 없으신가요? 회원가입" 링크 클릭
- 프로젝트 카드 클릭 시 "로그인 필요" 모달에서 "회원가입" 선택

**옵션 1: 이메일 회원가입**

필수 입력:
- [ ] 이메일 주소 (email)
- [ ] 닉네임 (nickname, 2자 이상)
- [ ] 비밀번호 (password, 6자 이상)
- [ ] 비밀번호 확인 (passwordConfirm, password와 일치)

사용자 액션:
- 각 입력 필드에 포커스 및 텍스트 입력
- "이메일로 회원가입" 버튼 클릭

**옵션 2: 구글 OAuth 회원가입**

필수 입력:
- 없음 (구글에서 자동 제공)

사용자 액션:
- "Google로 시작하기" 버튼 클릭
- 구글 로그인 팝업에서 계정 선택
- 권한 동의 화면에서 "허용" 클릭

### 2. 처리 (System Processing)

#### **옵션 1: 이메일 회원가입**

**정상 흐름 (Happy Path)**:

1. **[Step 1] 클라이언트 측 검증**
   - 검증 사항:
     - 이메일 형식: 정규식 검증 (example@domain.com)
     - 닉네임: 최소 2자 이상
     - 비밀번호: 최소 6자 이상
     - 비밀번호 확인: password와 일치 여부
   - 변환 로직: 없음
   - **검증 실패 시**: 해당 필드 하단에 빨간색 에러 메시지 표시

2. **[Step 2] Supabase Auth 회원가입 API 호출**
   - 처리 내용:
     - `authStore.signUp(email, password, nickname)` 호출
     - Supabase `auth.signUp()` 실행
   - 외부 API 호출:
     - Supabase Auth API: `POST /auth/v1/signup`
     - 요청 본문: `{ email, password, options: { data: { nickname } } }`
   - DB 작업:
     - `auth.users` 테이블에 사용자 생성
     - `public.users` 테이블에 프로필 생성
     - `user_subscriptions` 테이블에 무료 플랜 할당

3. **[Step 3] 이메일 인증 메일 발송**
   - 데이터 가공: Supabase가 자동으로 인증 링크 포함 이메일 생성
   - 상태 업데이트:
     - 사용자 상태: `email_confirmed_at = NULL` (미인증)
     - 세션 생성 없음 (이메일 인증 필수)

4. **[Step 4] 결과 반환**
   - 성공 응답: `{ user, session: null }` (이메일 미인증)
   - 클라이언트 상태 업데이트: `authStore.user = null`

#### **옵션 2: 구글 OAuth 회원가입**

**정상 흐름**:

1. **[Step 1] 구글 OAuth 플로우 시작**
   - `authStore.signInWithGoogle()` 호출
   - Supabase `auth.signInWithOAuth({ provider: 'google' })` 실행
   - 리다이렉트 URL: `https://arikonia.com/auth/callback`

2. **[Step 2] 구글 로그인 팝업**
   - Google OAuth 2.0 API 호출
   - 권한 요청: 이메일, 프로필, 기본 정보

3. **[Step 3] 구글 인증 완료 및 콜백**
   - Supabase로 콜백: `/auth/callback?code=xxx`
   - Supabase가 code를 token으로 교환
   - 구글 프로필: email, name, picture

4. **[Step 4] Supabase 사용자 생성**
   - DB 작업:
     - `auth.users`: provider='google', email_confirmed_at=NOW()
     - `public.users`: nickname 자동 생성 (구글 name 또는 이메일 앞부분)
     - `user_subscriptions`: 무료 플랜 자동 할당

5. **[Step 5] 세션 생성 및 리다이렉트**
   - JWT 토큰 생성
   - `/dashboard`로 자동 리다이렉트

**엣지케이스**:

- **이미 등록된 이메일**: "이미 사용 중인 이메일입니다" + 로그인 페이지 링크
- **비밀번호 불일치**: passwordConfirm 필드 에러 표시
- **중복 제출**: `isLoading` 플래그로 중복 방지
- **구글 권한 거부**: "구글 로그인이 취소되었습니다" 메시지
- **닉네임 중복**: 랜덤 숫자 suffix 추가 (예: "홍길동123")

**에러 처리**:

- **네트워크 에러**: "네트워크 오류가 발생했습니다. 다시 시도해주세요"
- **서버 에러**: "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요"
- **구글 OAuth 설정 오류**: "일시적으로 구글 로그인을 사용할 수 없습니다"

### 3. 출력 (User Feedback & Side Effects)

**즉시 피드백**:
- 로딩: "가입 중..." 또는 "Google 로그인 중..."
- 성공: "회원가입 완료! 인증 메일 확인하세요" (이메일) / "Google 계정으로 가입되었습니다!" (구글)
- 실패: 빨간색 에러 배너

**데이터 변경**:
- `auth.users`, `public.users`, `user_subscriptions` 테이블 INSERT

**화면 전환**:
- 이메일: `/login` (3초 후)
- 구글: `/dashboard` (즉시)

**사이드 이펙트**:
- 이메일 인증 메일 발송 (이메일 방식만)
- Supabase Auth 로그: 회원가입 시도 기록

### 플로우 차트

```
[시작: 회원가입 페이지]
  ↓
[선택: 이메일 or 구글]
  ├─ [이메일]
  │   → [폼 입력] → [검증] → [Supabase signUp]
  │   → [이메일 발송] → [로그인 페이지로 리다이렉트]
  │
  └─ [구글]
      → [OAuth 시작] → [계정 선택] → [권한 허용]
      → [콜백 처리] → [프로필 생성] → [대시보드로 리다이렉트]
```

---

## 2. 로그인 (Sign In)

### 개요
- **목적**: 기존 사용자가 이메일 또는 구글 계정으로 로그인하여 세션 생성
- **사용자**: 가입된 사용자
- **빈도**: 세션 만료 시마다
- **로그인 방식**: 이메일+비밀번호, 구글 OAuth

### 1. 입력 (User Input & Interaction)

**진입점**:
- 랜딩 페이지(/) 헤더 "로그인" 버튼
- 회원가입 페이지 "이미 계정이 있으신가요?" 링크
- 세션 만료 시 자동 리다이렉트

**옵션 1: 이메일 로그인**
- [ ] 이메일 주소
- [ ] 비밀번호

**옵션 2: 구글 OAuth 로그인**
- 클릭만 (자동 처리)

### 2. 처리 (System Processing)

#### **옵션 1: 이메일 로그인**

1. **클라이언트 검증**: 이메일 형식, 비밀번호 최소 6자
2. **Supabase 로그인**: `auth.signInWithPassword({ email, password })`
3. **세션 생성**: JWT access_token (1시간), refresh_token (30일)
4. **프로필 로드**: `users` JOIN `user_subscriptions`
5. **리다이렉트**: `/` 메인 페이지

#### **옵션 2: 구글 OAuth 로그인**

1. **OAuth 플로우 시작**: 구글 로그인 페이지로 리다이렉트
2. **구글 인증**: 계정 선택 (이미 로그인 시 자동)
3. **콜백 처리**: `/auth/callback`에서 토큰 교환
4. **프로필 확인**: 기존 프로필 로드 (첫 로그인 시 생성)
5. **리다이렉트**: `/dashboard`

**엣지케이스**:

- **잘못된 비밀번호**: "이메일 또는 비밀번호가 올바르지 않습니다"
- **가입되지 않은 이메일**: 동일 에러 메시지 (보안상)
- **이메일 미인증**: "이메일 인증이 필요합니다. 인증 메일을 확인해주세요"
- **구글 계정으로 가입했는데 이메일 로그인**: "이 계정은 Google로 가입되었습니다"
- **세션 이미 존재**: 자동으로 `/` 리다이렉트
- **중복 로그인 시도**: `isLoading` 플래그로 방지

**에러 처리**:

- **네트워크 에러**: "네트워크 오류가 발생했습니다"
- **서버 에러**: "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요"
- **Rate Limit**: "너무 많은 로그인 시도입니다. 5분 후 다시 시도해주세요"

### 3. 출력 (User Feedback & Side Effects)

**즉시 피드백**:
- 로딩: "로그인 중..." 또는 "Google 로그인 중..."
- 성공: 자동 리다이렉트 (별도 메시지 없음)
- 실패: 빨간색 Alert

**데이터 변경**:
- `authStore.user` 업데이트
- localStorage: Supabase 세션 토큰 저장

**화면 전환**:
- 성공: `/` 또는 이전 페이지
- 실패: `/login` 유지

**사이드 이펙트**:
- Supabase Auth 로그: 로그인 시도 기록
- (Phase 2) 분석 이벤트: `user_login`

### 플로우 차트

```
[시작: 로그인 페이지]
  ↓
[선택: 이메일 or 구글]
  ├─ [이메일]
  │   → [폼 입력] → [검증] → [signInWithPassword]
  │   → [세션 생성] → [프로필 로드] → [메인 페이지]
  │
  └─ [구글]
      → [OAuth 시작] → [계정 선택] → [콜백]
      → [세션 생성] → [메인 페이지]
```

---

## 3. 프로젝트 접근 제어 (Project Access Control)

### 개요
- **목적**: 사용자의 구독 플랜에 따라 프로젝트 접근 권한 확인 및 제어
- **사용자**: 로그인된 모든 사용자
- **빈도**: 프로젝트 접근 시도마다

### 1. 입력 (User Input & Interaction)

**진입점**:
- 랜딩 페이지(/) 프로젝트 카드 클릭
- 대시보드(/dashboard) "시작하기" 버튼 클릭
- 직접 프로젝트 URL 접근

**사용자 액션**:
- 프로젝트 카드 또는 버튼 클릭

### 2. 처리 (System Processing)

**정상 흐름**:

1. **[Step 1] 사용자 인증 확인**
   - `authStore.user` 존재 여부
   - JWT 토큰 유효성
   - **미로그인**: `/login`으로 리다이렉트 (리턴 URL 저장)

2. **[Step 2] 프로젝트 코드 추출**
   - 클릭된 프로젝트: "carelit", "temflow", "arisper"

3. **[Step 3] 접근 권한 확인**
   - Supabase RPC: `check_project_access(user_id, project_code)`
   - DB 조회:
     ```sql
     -- 1. 사용자별 커스텀 권한 확인
     SELECT * FROM user_project_access WHERE user_id = $1

     -- 2. 플랜 기반 권한 확인
     SELECT * FROM plan_project_access
     JOIN user_subscriptions ...
     ```
   - 반환:
     ```typescript
     {
       has_access: boolean,
       access_level?: 'full' | 'limited',
       reason?: string,
       required_plan?: string
     }
     ```

4. **[Step 4] 권한 결과 처리**
   - `has_access = true`: Step 5로
   - `has_access = false`: 접근 제한 모달

5. **[Step 5] 프로젝트 URL로 이동**
   - SSO 토큰 생성
   - 새 탭에서 프로젝트 열기
   - 토큰 전달 (URL 파라미터 or postMessage)

**엣지케이스**:

- **무료 플랜 → Premium 프로젝트**: "Premium 플랜이 필요합니다" 모달 + 업그레이드 버튼
- **세션 만료**: Refresh token으로 자동 갱신 → 실패 시 로그인 페이지
- **프로젝트 비활성**: "이 프로젝트는 현재 준비 중입니다"
- **관리자 커스텀 권한**: 플랜 제약 무시하고 접근 허용
- **구독 만료**: "구독이 만료되었습니다. 갱신하시겠습니까?"

**에러 처리**:

- **check_project_access RPC 실패**: "접근 권한 확인 중 오류 발생"
- **네트워크 타임아웃**: 재시도 로직 (최대 2회)
- **프로젝트 서버 다운**: 새 탭에서 "서비스 점검 중" 페이지
- **SSO 토큰 전달 실패**: 프로젝트에서 재로그인 요구

### 3. 출력 (User Feedback & Side Effects)

**즉시 피드백**:
- 로딩: "접근 확인 중..." (1-2초)
- 성공: 새 탭에 프로젝트 열림
- 실패: 접근 제한 모달

**데이터 변경**:
- 없음 (읽기 전용)

**로그 기록**:
- 접근 시도: user_id, project_code, timestamp, result

**사이드 이펙트**:
- (Phase 2) 분석 이벤트: `project_access_attempt`

### 플로우 차트

```
[프로젝트 카드 클릭]
  ↓
[인증 확인] → [미로그인] → [로그인 페이지]
  ↓ [로그인됨]
[check_project_access RPC]
  ↓
[권한 분기]
  ├─ [has_access=true] → [SSO 토큰] → [새 탭에서 프로젝트 열기]
  ├─ [insufficient_plan] → [업그레이드 모달]
  ├─ [project_inactive] → [준비 중 메시지]
  └─ [subscription_expired] → [갱신 안내]
```

---

## 4. 관리자 - 사용자 구독 관리 (Admin: User Subscription Management)

### 개요
- **목적**: 관리자가 사용자의 구독 플랜을 조회하고 수동 변경
- **사용자**: 관리자 (tkandpf18@naver.com)
- **빈도**: 필요 시
- **Phase**: Phase 1 (SQL), Phase 2 (UI)

### 1. 입력 (User Input & Interaction)

**Phase 1: SQL 기반**
- Supabase SQL Editor 직접 접근
- 사용자 이메일 또는 ID
- 변경할 플랜명 (free/basic/premium/enterprise)
- 만료일 (선택적)

**Phase 2: UI 기반 (미래)**
- 관리자 패널(/admin) 접근
- 사용자 검색 (이메일/닉네임)
- 플랜 선택 (드롭다운)
- 만료일 설정 (Date picker)

### 2. 처리 (System Processing)

#### **Phase 1: SQL 직접 실행**

1. **Supabase SQL Editor 접속**
   - https://supabase.com/dashboard/project/bijluuvpkzhjbypbhlqy
   - "SQL Editor" 메뉴

2. **사용자 조회**
   ```sql
   SELECT u.id, u.email, u.nickname, sp.name, us.status, us.expires_at
   FROM users u
   LEFT JOIN user_subscriptions us ON u.id = us.user_id
   LEFT JOIN subscription_plans sp ON us.plan_id = sp.id
   WHERE u.email = 'user@example.com';
   ```

3. **플랜 ID 조회**
   ```sql
   SELECT id, name FROM subscription_plans;
   ```

4. **구독 업데이트**
   ```sql
   UPDATE user_subscriptions
   SET
     plan_id = (SELECT id FROM subscription_plans WHERE name = 'premium'),
     status = 'active',
     expires_at = NOW() + INTERVAL '1 year'
   WHERE user_id = (SELECT id FROM users WHERE email = 'user@example.com');
   ```

5. **결과 확인**
   - Step 2 쿼리 재실행

#### **Phase 2: UI 기반 (미래)**

1. **관리자 인증**: `users.role = 'admin'` 확인
2. **사용자 목록 조회**: `GET /api/admin/users`
3. **플랜 변경 모달**: 현재 플랜 표시 + 드롭다운
4. **플랜 변경 API**: `PATCH /api/admin/users/:id/subscription`
5. **결과 피드백**: Toast + 목록 새로고침

**엣지케이스**:

- **구독 없음**: INSERT 쿼리로 새 구독 생성
- **동일 플랜 변경**: 경고 메시지 (Phase 2)
- **만료일 과거**: 즉시 만료 상태로 저장 (Phase 1)
- **여러 구독 중복**: 최근 구독만 활성화

**에러 처리**:

- **존재하지 않는 사용자**: "0 rows updated" 또는 404 Not Found
- **잘못된 플랜명**: Foreign key constraint 위반
- **권한 부족**: 403 Forbidden
- **DB 트랜잭션 실패**: 롤백 + 재시도 안내

### 3. 출력 (User Feedback & Side Effects)

**Phase 1**:
- 성공: "1 row(s) affected"
- 실패: SQL 에러 메시지

**Phase 2**:
- 성공: "플랜이 변경되었습니다" Toast
- 실패: 빨간색 Toast
- 목록 자동 새로고침

**데이터 변경**:
- `user_subscriptions.plan_id` 업데이트
- 사용자는 즉시 새 플랜 권한 적용

**사이드 이펙트**:
- (Phase 2) 이메일: "구독 플랜이 변경되었습니다"
- 관리 로그: `admin_actions` 테이블 (Phase 2)

### 플로우 차트

```
[관리자 플랜 변경]
  ↓
[Phase 1: SQL]
  → [Supabase Editor] → [사용자 조회] → [플랜 ID 조회]
  → [UPDATE 쿼리] → [결과 확인]

[Phase 2: UI (미래)]
  → [관리자 패널] → [권한 확인] → [사용자 검색]
  → [플랜 변경 모달] → [API 호출] → [Toast + 새로고침]
```

---

## 공통 에러 처리

### 네트워크 에러
- **발생 시점**: 모든 API 호출 시
- **처리 방식**:
  - 에러 메시지: "네트워크 오류가 발생했습니다"
  - 재시도 버튼 제공
  - 타임아웃: 5초
- **사용자 액션**: "다시 시도" 버튼 클릭

### 인증 에러
- **발생 시점**: JWT 토큰 만료, 세션 무효
- **처리 방식**:
  - Refresh token으로 자동 갱신 시도
  - 실패 시: 로그인 페이지로 리다이렉트
  - 메시지: "세션이 만료되었습니다. 다시 로그인해주세요"
- **사용자 액션**: 재로그인

### 권한 에러
- **발생 시점**:
  - 관리자 페이지 접근 (일반 사용자)
  - 프로젝트 접근 (플랜 부족)
- **처리 방식**:
  - 403 Forbidden 또는 접근 제한 모달
  - 메시지: "접근 권한이 없습니다" 또는 "Premium 플랜이 필요합니다"
- **사용자 액션**: 업그레이드 또는 뒤로가기

### 타임아웃
- **발생 시점**: API 응답 지연 (>5초)
- **처리 방식**:
  - 로딩 스피너 지속
  - 타임아웃 후 에러 메시지
  - 재시도 로직 (최대 2회)
- **사용자 액션**: "다시 시도" 또는 페이지 새로고침

---

## 플로우 간 연결

### 회원가입 → 로그인
- **연결 조건**: 이메일 회원가입 성공
- **데이터 전달**: 없음 (사용자가 직접 이메일/비밀번호 입력)
- **상태 유지**: 없음

### 로그인 → 프로젝트 접근
- **연결 조건**: 로그인 성공
- **데이터 전달**: `authStore.user` (세션 정보)
- **상태 유지**: JWT 토큰 localStorage 저장

### 프로젝트 접근 실패 → 관리자 플랜 변경
- **연결 조건**: "Premium 플랜 필요" 에러
- **데이터 전달**: 사용자 이메일 (관리자가 수동 입력)
- **상태 유지**: 플랜 변경 후 재접근 시 자동 허용

---

## 성능 고려사항

### 로딩 시간 목표
- 회원가입/로그인: < 2초
- 프로젝트 접근 권한 확인: < 500ms
- 관리자 사용자 목록 로드: < 1초

### 동시 처리
- 예상 동시 사용자: ~100명 (Phase 1)
- Supabase 기본 성능으로 충분

### 캐싱 전략
- 사용자 프로필: localStorage 캐싱 (1시간)
- 구독 정보: API 호출마다 최신 정보 조회
- 프로젝트 접근 권한: 세션당 1회 조회 후 캐싱

---

## 접근성 고려사항

### 스크린 리더
- 모든 입력 필드: `<label>` 태그 명시
- 에러 메시지: `aria-live="polite"` 또는 `role="alert"`
- 성공 메시지: `role="status"`
- 로딩 상태: `aria-busy="true"`

### 키보드 네비게이션
- Tab: 모든 인터랙티브 요소 순차 이동
- Enter: 폼 제출, 버튼 활성화
- Escape: 모달 닫기
- 포커스 트랩: 모달 열릴 때 포커스 유지

### 색상 대비
- 텍스트: WCAG AA 기준 (4.5:1)
- 에러 메시지: 빨간색 + 아이콘 (색맹 대응)
- 성공 메시지: 초록색 + 체크 아이콘
- 다크모드: 모든 색상 재조정

---

## 버전 히스토리

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|-----------|--------|
| 1.0 | 2025-01-20 | 초안 작성: 회원가입, 로그인, 프로젝트 접근, 관리자 기능 | Claude Code + Product Owner |

---

**다음 단계**: 03-Tech Stack & Codebase Structure 에이전트 실행
