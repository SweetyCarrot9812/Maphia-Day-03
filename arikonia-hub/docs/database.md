# Arikonia Hub - Database Design

## 문서 정보
- **작성일**: 2025-10-21
- **데이터베이스**: PostgreSQL (Supabase)
- **버전**: 2.0 (개선 버전)
- **관련 문서**:
  - [PRD](./prd.md)
  - [Userflow](./userflow.md)
  - [Tech Stack](./tech-stack.md)
  - [Codebase Structure](./codebase-structure.md)

---

## 데이터베이스 선택

### PostgreSQL (Supabase)

**선택 이유**:
1. **복잡한 관계**: 다대다 관계 (플랜-프로젝트, 사용자-프로젝트)
2. **트랜잭션 중요**: 구독 변경, 권한 부여
3. **복잡한 JOIN**: `check_project_access` 함수에서 여러 테이블 조인 필요
4. **데이터 무결성**: Foreign Key, UNIQUE 제약조건으로 데이터 정합성 보장
5. **Supabase 통합**: Auth, RLS, Realtime 등 내장 기능 활용

**장점**:
- Row Level Security (RLS)로 자동 권한 제어
- Supabase Auth와 완벽 통합
- PostgreSQL 표준 SQL (AI 친화적)
- 자동 백업 및 복구

**단점**:
- NoSQL보다 스키마 변경이 까다로움 (마이그레이션 필요)
- 수평 확장 제한 (현재 Phase에서는 문제 없음)

---

## 데이터플로우 (간략)

### 플로우 1: 회원가입 (이메일)
```
[사용자 입력: email, password, nickname]
   ↓
[클라이언트 검증: Zod schema]
   ↓
Supabase auth.signUp({ email, password, data: { nickname } })
   ↓
[auth.users 테이블 INSERT] ← Supabase 자동
   ↓
[트리거: handle_new_user()] ← 자동 실행
   ├─ public.users INSERT (nickname)
   └─ public.user_subscriptions INSERT (plan='free')
   ↓
{user, session: null} → 이메일 인증 대기
```

### 플로우 2: 회원가입 (구글 OAuth)
```
[사용자 클릭: Google로 시작하기]
   ↓
Supabase signInWithOAuth({ provider: 'google' })
   ↓
[구글 로그인 팝업 → 계정 선택 → 권한 허용]
   ↓
OAuth callback: /auth/callback?code=xxx
   ↓
[auth.users 테이블 INSERT]
  - provider: 'google'
  - email_confirmed_at: NOW()
  - raw_user_meta_data: { full_name, avatar_url }
   ↓
[트리거: handle_new_user()]
   ├─ public.users INSERT (nickname=full_name, avatar_url)
   └─ public.user_subscriptions INSERT (plan='free')
   ↓
{user, session} → JWT 토큰 생성 → /dashboard
```

### 플로우 3: 로그인 (이메일)
```
[사용자 입력: email, password]
   ↓
Supabase auth.signInWithPassword({ email, password })
   ↓
[auth.users SELECT WHERE email] → 비밀번호 검증
   ↓
[JWT 생성: access_token (1h), refresh_token (30d)]
   ↓
[authStore.loadUser()]
   ├─ users SELECT WHERE id
   └─ user_subscriptions JOIN subscription_plans
   ↓
{user, session} → authStore 업데이트 → /dashboard
```

### 플로우 4: 로그인 (구글 OAuth)
```
[사용자 클릭: Google로 로그인]
   ↓
Supabase signInWithOAuth({ provider: 'google' })
   ↓
[구글 계정 선택] → OAuth callback
   ↓
[auth.users SELECT WHERE email]
   ↓
[JWT 생성]
   ↓
{user, session} → /dashboard
```

### 플로우 5: 프로젝트 접근 제어
```
[프로젝트 카드 클릭: project_code='carelit']
   ↓
[authStore.user 확인] → 미로그인 시 /login
   ↓
authStore.checkProjectAccess('carelit')
   ↓
Supabase RPC: check_project_access(user_id, 'carelit')
   ↓
[함수 내부 로직]
1. projects SELECT WHERE code='carelit' AND is_active=true
   └─ 없으면: {has_access: false, reason: 'project_not_found'}

2. user_project_access SELECT (커스텀 권한)
   └─ 있으면: {has_access: true, source: 'custom', access_level}

3. user_subscriptions JOIN subscription_plans
   └─ 없으면: {has_access: false, reason: 'no_active_subscription'}

4. plan_project_access SELECT
   └─ 있으면: {has_access: true, source: 'subscription', access_level}
   └─ 없으면: {has_access: false, reason: 'plan_does_not_include_project'}
   ↓
[클라이언트 분기]
├─ has_access=true → 새 탭에서 프로젝트 열기
└─ has_access=false → 모달 표시 (업그레이드 안내)
```

### 플로우 6: 관리자 - 플랜 변경 (Phase 1: SQL)
```
[Supabase SQL Editor 접속]
   ↓
-- 1. 사용자 조회
SELECT u.id, u.email, u.nickname, sp.name, us.status, us.expires_at
FROM users u
LEFT JOIN user_subscriptions us ON u.id = us.user_id
LEFT JOIN subscription_plans sp ON us.plan_id = sp.id
WHERE u.email = 'user@example.com';
   ↓
-- 2. 플랜 변경
UPDATE user_subscriptions
SET
  plan_id = (SELECT id FROM subscription_plans WHERE name = 'premium'),
  status = 'active',
  expires_at = NOW() + INTERVAL '1 year',
  updated_at = NOW()
WHERE user_id = (SELECT id FROM users WHERE email = 'user@example.com');
   ↓
{1 row(s) affected} → 즉시 권한 적용
```

---

## ERD (Entity Relationship Diagram)

```
┌─────────────────┐
│  auth.users     │ (Supabase 관리)
│  - id           │
│  - email        │
│  - password     │
│  - provider     │
│  - metadata     │
└────────┬────────┘
         │ 1:1
         ↓
┌─────────────────┐
│  users          │
│  - id (PK, FK)  │
│  - email        │
│  - nickname     │
│  - avatar_url   │ ← 구글 OAuth 프로필 이미지
│  - created_at   │
│  - updated_at   │
└────────┬────────┘
         │ 1:N
         ↓
┌────────────────────────┐
│  user_subscriptions    │
│  - id (PK)             │
│  - user_id (FK)        │───┐
│  - plan_id (FK)        │   │
│  - status              │   │
│  - expires_at          │   │
│  - created_at          │   │
│  - updated_at          │   │
└────────────────────────┘   │
                              │ N:1
         ┌────────────────────┘
         ↓
┌────────────────────────┐
│  subscription_plans    │
│  - id (PK)             │
│  - name (UNIQUE)       │ ← 'free', 'basic', 'premium', 'enterprise'
│  - display_name        │
│  - price_monthly       │
│  - price_yearly        │
│  - description         │
│  - features (JSONB)    │
│  - created_at          │
└────────┬───────────────┘
         │ 1:N
         ↓
┌────────────────────────┐
│  plan_project_access   │
│  - id (PK)             │
│  - plan_id (FK)        │
│  - project_id (FK)     │───┐
│  - access_level        │   │
│  - features_enabled    │   │
│  - UNIQUE(plan, proj)  │   │
└────────────────────────┘   │
                              │ N:1
         ┌────────────────────┘
         ↓
┌────────────────────────┐
│  projects              │
│  - id (PK)             │
│  - code (UNIQUE)       │ ← 'carelit', 'temflow', 'arisper'
│  - name                │
│  - description         │
│  - url                 │
│  - is_active           │
│  - created_at          │
└────────┬───────────────┘
         │ 1:N
         ↓
┌────────────────────────┐
│  user_project_access   │ (Phase 2 - 커스텀 권한)
│  - id (PK)             │
│  - user_id (FK)        │
│  - project_id (FK)     │
│  - access_level        │
│  - granted_by (FK)     │
│  - granted_at          │
│  - expires_at          │
│  - UNIQUE(user, proj)  │
└────────────────────────┘
```

---

## 테이블 설계 (상세)

### 1. users (사용자 프로필)

**목적**: 사용자 기본 정보 저장 (Supabase Auth와 1:1 관계)

| 컬럼명 | 타입 | 제약조건 | 설명 | 근거(유저플로우) |
|--------|------|----------|------|------------------|
| id | UUID | PRIMARY KEY, FK(auth.users) | 사용자 고유 ID | Supabase Auth ID와 동일 |
| email | TEXT | UNIQUE, NOT NULL | 이메일 주소 | 회원가입/로그인 입력 |
| nickname | TEXT | NOT NULL | 닉네임 (2자 이상) | 회원가입 입력, 프로필 표시 |
| avatar_url | TEXT | NULL | 프로필 이미지 URL | 구글 OAuth 프로필 이미지 |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 생성 일시 | 회원가입 완료 시 자동 기록 |
| updated_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 수정 일시 | 프로필 수정 시 자동 갱신 |

**인덱스**:
```sql
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

**RLS 정책**:
```sql
-- 자신의 프로필만 조회
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- 자신의 프로필만 수정
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- 프로필 생성 (트리거가 처리, 일반 사용자는 직접 INSERT 불가)
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);
```

**데이터 예시**:
```sql
{
  id: '123e4567-e89b-12d3-a456-426614174000',
  email: 'user@example.com',
  nickname: '홍길동',
  avatar_url: 'https://lh3.googleusercontent.com/a/xxx',
  created_at: '2025-01-20T10:00:00Z',
  updated_at: '2025-01-20T10:00:00Z'
}
```

---

### 2. subscription_plans (구독 플랜)

**목적**: 구독 플랜 정의 (무료, 베이직, 프리미엄, 엔터프라이즈)

| 컬럼명 | 타입 | 제약조건 | 설명 | 근거 |
|--------|------|----------|------|------|
| id | UUID | PRIMARY KEY | 플랜 고유 ID | - |
| name | TEXT | UNIQUE, NOT NULL | 플랜 코드 | 코드에서 사용 ('free', 'basic', 'premium', 'enterprise') |
| display_name | TEXT | NOT NULL | 한글 표시명 | UI 표시 ('무료', '베이직', '프리미엄', '엔터프라이즈') |
| price_monthly | INTEGER | DEFAULT 0 | 월간 가격 (원) | Phase 2 결제 기능 |
| price_yearly | INTEGER | DEFAULT 0 | 연간 가격 (원) | Phase 2 결제 기능 (할인 포함) |
| description | TEXT | NULL | 플랜 설명 | UI 표시 |
| features | JSONB | DEFAULT '{}'::jsonb | 플랜 기능 목록 | Phase 2 세밀한 기능 제어 |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 생성 일시 | - |

**RLS 정책**:
```sql
-- 모든 사용자가 플랜 목록 조회 가능 (가격 표시용)
CREATE POLICY "Anyone can view plans"
  ON subscription_plans FOR SELECT
  USING (true);
```

**초기 데이터**:
```sql
INSERT INTO subscription_plans (name, display_name, price_monthly, price_yearly, description, features) VALUES
('free', '무료', 0, 0, '기본 학습 기능을 무료로 체험하세요',
  '{"max_projects": 1, "features": ["basic_access"]}'::jsonb),

('basic', '베이직', 9900, 99000, '1개 프로젝트 전체 이용 (10% 할인)',
  '{"max_projects": 1, "features": ["full_access", "statistics", "srs"]}'::jsonb),

('premium', '프리미엄', 19900, 199000, '모든 프로젝트 이용 (17% 할인)',
  '{"max_projects": 99, "features": ["full_access", "statistics", "srs", "priority_support"]}'::jsonb),

('enterprise', '엔터프라이즈', 0, 0, '기관용 맞춤 솔루션',
  '{"max_projects": 99, "features": ["full_access", "admin", "custom"]}'::jsonb);
```

**플랜 설명**:
- **Free**: Care-Lit 제한적 접근 (20문제)
- **Basic**: Care-Lit 전체 접근 (월 9,900원 / 연 99,000원)
- **Premium**: 모든 프로젝트 전체 접근 (월 19,900원 / 연 199,000원)
- **Enterprise**: 관리자 전용 (tkandpf18@naver.com)

---

### 3. user_subscriptions (사용자 구독)

**목적**: 사용자의 현재 구독 정보 저장

| 컬럼명 | 타입 | 제약조건 | 설명 | 근거 |
|--------|------|----------|------|------|
| id | UUID | PRIMARY KEY | 구독 고유 ID | - |
| user_id | UUID | NOT NULL, FK(users) ON DELETE CASCADE | 사용자 ID | 프로젝트 접근 제어 시 조회 |
| plan_id | UUID | NOT NULL, FK(subscription_plans) | 플랜 ID | 플랜 기반 권한 확인 |
| status | TEXT | NOT NULL, DEFAULT 'active' | 구독 상태 | 'active', 'inactive', 'expired' |
| expires_at | TIMESTAMPTZ | NULL | 만료 일시 | NULL = 무제한 (free, enterprise) |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 구독 시작 일시 | 구독 이력 관리 |
| updated_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 구독 수정 일시 | 플랜 변경 시 갱신 |

**인덱스**:
```sql
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(status);
CREATE INDEX idx_user_subscriptions_expires_at ON user_subscriptions(expires_at);
```

**RLS 정책**:
```sql
-- 자신의 구독 정보만 조회
CREATE POLICY "Users can view own subscription"
  ON user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);
```

**데이터 예시**:
```sql
-- 무료 플랜 (만료 없음)
{
  id: '...',
  user_id: '123e4567-e89b-12d3-a456-426614174000',
  plan_id: 'free_plan_uuid',
  status: 'active',
  expires_at: null,
  created_at: '2025-01-20T10:00:00Z',
  updated_at: '2025-01-20T10:00:00Z'
}

-- 프리미엄 플랜 (1년 구독)
{
  id: '...',
  user_id: '...',
  plan_id: 'premium_plan_uuid',
  status: 'active',
  expires_at: '2026-01-20T10:00:00Z',
  created_at: '2025-01-20T10:00:00Z',
  updated_at: '2025-01-20T10:00:00Z'
}
```

---

### 4. projects (프로젝트)

**목적**: Arikonia Hub에서 관리하는 프로젝트 정의

| 컬럼명 | 타입 | 제약조건 | 설명 | 근거 |
|--------|------|----------|------|------|
| id | UUID | PRIMARY KEY | 프로젝트 고유 ID | - |
| code | TEXT | UNIQUE, NOT NULL | 프로젝트 코드 | URL에서 사용 ('carelit', 'temflow', 'arisper') |
| name | TEXT | NOT NULL | 프로젝트명 | UI 표시 ('Care-Lit', 'Tem-Flow', 'Arisper') |
| description | TEXT | NULL | 설명 | 프로젝트 카드 설명 |
| url | TEXT | NOT NULL | 프로젝트 URL | 새 탭에서 열 때 사용 |
| is_active | BOOLEAN | DEFAULT TRUE | 활성화 여부 | 비활성 프로젝트 숨김 |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 생성 일시 | - |

**RLS 정책**:
```sql
-- 활성화된 프로젝트만 모든 사용자가 조회 가능
CREATE POLICY "Anyone can view active projects"
  ON projects FOR SELECT
  USING (is_active = true);
```

**초기 데이터**:
```sql
INSERT INTO projects (code, name, description, url) VALUES
('carelit', 'Care-Lit', '돌봄을 위한 지식의 빛 - 의학 및 간호학 학습', 'https://carelit.arikonia.com'),
('temflow', 'Tem-Flow', '내 몸을 성전처럼 - 헬스 및 운동 관리', 'https://temflow.arikonia.com'),
('arisper', 'Arisper', '아름다운 속삭임 - 언어 학습', 'https://arisper.arikonia.com');
```

**미래 프로젝트 (Phase 2)**:
```sql
('econoverse', 'EconoVerse', '경제 우주 탐험 - 경제학 학습', 'https://econoverse.arikonia.com'),
('vocalsphere', 'VocalSphere', '목소리의 세계 - 음성 및 발성 훈련', 'https://vocalsphere.arikonia.com'),
('faithbridge', 'FaithBridge', '믿음의 다리 - 신학 및 성경 연구', 'https://faithbridge.arikonia.com');
```

---

### 5. plan_project_access (플랜별 프로젝트 권한)

**목적**: 각 구독 플랜이 어떤 프로젝트에 접근할 수 있는지 정의

| 컬럼명 | 타입 | 제약조건 | 설명 | 근거 |
|--------|------|----------|------|------|
| id | UUID | PRIMARY KEY | 권한 고유 ID | - |
| plan_id | UUID | NOT NULL, FK(subscription_plans) ON DELETE CASCADE | 플랜 ID | - |
| project_id | UUID | NOT NULL, FK(projects) ON DELETE CASCADE | 프로젝트 ID | - |
| access_level | TEXT | DEFAULT 'full' | 접근 레벨 | 'full' (전체), 'limited' (제한적) |
| features_enabled | JSONB | DEFAULT '{}'::jsonb | 활성화 기능 | Phase 2 세밀한 제어 |
| UNIQUE(plan_id, project_id) | - | UNIQUE | 플랜-프로젝트 중복 방지 | - |

**인덱스**:
```sql
CREATE INDEX idx_plan_project_access_plan_id ON plan_project_access(plan_id);
CREATE INDEX idx_plan_project_access_project_id ON plan_project_access(project_id);
```

**RLS 정책**:
```sql
-- 모든 사용자가 플랜별 권한 조회 가능 (플랜 비교용)
CREATE POLICY "Anyone can view plan access"
  ON plan_project_access FOR SELECT
  USING (true);
```

**초기 데이터** (DO 블록으로 생성):
```sql
-- Free: Care-Lit 제한적 (20문제)
INSERT INTO plan_project_access (plan_id, project_id, access_level, features_enabled)
VALUES (
  (SELECT id FROM subscription_plans WHERE name = 'free'),
  (SELECT id FROM projects WHERE code = 'carelit'),
  'limited',
  '{"problems_limit": 20}'::jsonb
);

-- Basic: Care-Lit 전체
INSERT INTO plan_project_access (plan_id, project_id, access_level)
VALUES (
  (SELECT id FROM subscription_plans WHERE name = 'basic'),
  (SELECT id FROM projects WHERE code = 'carelit'),
  'full'
);

-- Premium: 모든 프로젝트 전체
INSERT INTO plan_project_access (plan_id, project_id, access_level)
VALUES
  ((SELECT id FROM subscription_plans WHERE name = 'premium'),
   (SELECT id FROM projects WHERE code = 'carelit'), 'full'),
  ((SELECT id FROM subscription_plans WHERE name = 'premium'),
   (SELECT id FROM projects WHERE code = 'temflow'), 'full'),
  ((SELECT id FROM subscription_plans WHERE name = 'premium'),
   (SELECT id FROM projects WHERE code = 'arisper'), 'full');

-- Enterprise: 모든 프로젝트 + 관리자 권한
INSERT INTO plan_project_access (plan_id, project_id, access_level, features_enabled)
VALUES
  ((SELECT id FROM subscription_plans WHERE name = 'enterprise'),
   (SELECT id FROM projects WHERE code = 'carelit'), 'full', '{"admin": true}'::jsonb),
  ((SELECT id FROM subscription_plans WHERE name = 'enterprise'),
   (SELECT id FROM projects WHERE code = 'temflow'), 'full', '{"admin": true}'::jsonb),
  ((SELECT id FROM subscription_plans WHERE name = 'enterprise'),
   (SELECT id FROM projects WHERE code = 'arisper'), 'full', '{"admin": true}'::jsonb);
```

---

### 6. user_project_access (사용자별 커스텀 권한)

**목적**: 관리자가 특정 사용자에게 플랜 외 추가 권한 부여 (Phase 2)

| 컬럼명 | 타입 | 제약조건 | 설명 | 근거 |
|--------|------|----------|------|------|
| id | UUID | PRIMARY KEY | 권한 고유 ID | - |
| user_id | UUID | NOT NULL, FK(users) ON DELETE CASCADE | 사용자 ID | - |
| project_id | UUID | NOT NULL, FK(projects) ON DELETE CASCADE | 프로젝트 ID | - |
| access_level | TEXT | DEFAULT 'full' | 접근 레벨 | 'full', 'limited' |
| granted_by | UUID | NULL, FK(users) | 권한 부여자 (관리자) | Phase 2 관리자 UI에서 사용 |
| granted_at | TIMESTAMPTZ | DEFAULT NOW() | 권한 부여 일시 | - |
| expires_at | TIMESTAMPTZ | NULL | 만료 일시 | NULL = 무제한, Phase 2 임시 권한 관리 |
| UNIQUE(user_id, project_id) | - | UNIQUE | 사용자-프로젝트 중복 방지 | - |

**RLS 정책**:
```sql
-- 자신의 커스텀 권한만 조회
CREATE POLICY "Users can view own project access"
  ON user_project_access FOR SELECT
  USING (auth.uid() = user_id);
```

**사용 사례** (Phase 2):
```sql
-- 베타 테스터에게 Tem-Flow 임시 접근 권한 (30일)
INSERT INTO user_project_access (user_id, project_id, access_level, granted_by, expires_at)
VALUES (
  'beta_tester_user_id',
  (SELECT id FROM projects WHERE code = 'temflow'),
  'full',
  'admin_user_id',
  NOW() + INTERVAL '30 days'
);
```

---

## 함수 및 트리거

### 함수 1: `handle_new_user()` - 신규 사용자 자동 프로필 생성

**목적**: `auth.users`에 사용자 생성 시 자동으로 `public.users`와 `user_subscriptions` 생성

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_plan_id UUID;
  v_plan_name TEXT;
  v_nickname TEXT;
  v_avatar_url TEXT;
BEGIN
  -- Admin 이메일 확인
  IF NEW.email = 'tkandpf18@naver.com' THEN
    v_plan_name := 'enterprise';
  ELSE
    v_plan_name := 'free';
  END IF;

  -- 플랜 ID 가져오기
  SELECT id INTO v_plan_id FROM public.subscription_plans WHERE name = v_plan_name;

  -- 닉네임 우선순위: nickname > full_name > name > 이메일 앞부분
  v_nickname := COALESCE(
    NEW.raw_user_meta_data->>'nickname',
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    split_part(NEW.email, '@', 1)
  );

  -- 프로필 이미지: 구글 OAuth에서 가져오기
  v_avatar_url := NEW.raw_user_meta_data->>'avatar_url';

  -- 프로필 생성
  INSERT INTO public.users (id, email, nickname, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    v_nickname,
    v_avatar_url
  );

  -- 구독 할당
  IF v_plan_id IS NOT NULL THEN
    INSERT INTO public.user_subscriptions (user_id, plan_id, status)
    VALUES (NEW.id, v_plan_id, 'active');
  END IF;

  RETURN NEW;
END;
$$;
```

**트리거 생성**:
```sql
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

**동작 흐름**:
1. `auth.signUp()` 또는 OAuth 로그인
2. `auth.users` 테이블에 INSERT
3. 트리거 자동 실행
4. `public.users` 생성 (닉네임, 프로필 이미지)
5. `user_subscriptions` 생성 (관리자는 enterprise, 일반 사용자는 free)

---

### 함수 2: `check_project_access()` - 프로젝트 접근 권한 확인

**목적**: 사용자가 특정 프로젝트에 접근할 수 있는지 확인

**매개변수**:
- `p_user_id` (UUID): 사용자 ID
- `p_project_code` (TEXT): 프로젝트 코드 ('carelit', 'temflow', 'arisper')

**반환값** (JSONB):
```typescript
{
  has_access: boolean,
  access_level?: 'full' | 'limited',
  features_enabled?: object,
  plan_name?: string,
  current_plan?: string,
  required_plan?: string,
  reason?: 'project_not_found' | 'project_inactive' | 'no_active_subscription' | 'plan_does_not_include_project',
  source?: 'custom' | 'subscription',
  project_name?: string
}
```

```sql
CREATE OR REPLACE FUNCTION public.check_project_access(
  p_user_id UUID,
  p_project_code TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_subscription RECORD;
  v_plan_access RECORD;
  v_custom_access RECORD;
  v_project RECORD;
BEGIN
  -- 1. 프로젝트 조회 (is_active 체크)
  SELECT id, name, is_active
  INTO v_project
  FROM public.projects
  WHERE code = p_project_code;

  -- 프로젝트 존재 여부
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'has_access', false,
      'reason', 'project_not_found'
    );
  END IF;

  -- 프로젝트 비활성
  IF v_project.is_active = false THEN
    RETURN jsonb_build_object(
      'has_access', false,
      'reason', 'project_inactive',
      'project_name', v_project.name
    );
  END IF;

  -- 2. 커스텀 접근 권한 확인 (최우선)
  SELECT *
  INTO v_custom_access
  FROM public.user_project_access
  WHERE user_id = p_user_id
    AND project_id = v_project.id
    AND (expires_at IS NULL OR expires_at > NOW());

  IF FOUND THEN
    RETURN jsonb_build_object(
      'has_access', true,
      'access_level', v_custom_access.access_level,
      'source', 'custom',
      'project_name', v_project.name
    );
  END IF;

  -- 3. 구독 플랜 확인
  SELECT us.*, sp.name as plan_name, sp.display_name
  INTO v_subscription
  FROM public.user_subscriptions us
  JOIN public.subscription_plans sp ON us.plan_id = sp.id
  WHERE us.user_id = p_user_id
    AND us.status = 'active'
    AND (us.expires_at IS NULL OR us.expires_at > NOW())
  ORDER BY us.created_at DESC
  LIMIT 1;

  -- 활성 구독 없음
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'has_access', false,
      'reason', 'no_active_subscription',
      'project_name', v_project.name
    );
  END IF;

  -- 4. 플랜별 프로젝트 접근 권한
  SELECT *
  INTO v_plan_access
  FROM public.plan_project_access
  WHERE plan_id = v_subscription.plan_id
    AND project_id = v_project.id;

  -- 플랜에 프로젝트 포함됨
  IF FOUND THEN
    RETURN jsonb_build_object(
      'has_access', true,
      'access_level', v_plan_access.access_level,
      'features_enabled', v_plan_access.features_enabled,
      'plan_name', v_subscription.display_name,
      'source', 'subscription',
      'project_name', v_project.name
    );
  END IF;

  -- 플랜에 프로젝트 미포함
  RETURN jsonb_build_object(
    'has_access', false,
    'reason', 'plan_does_not_include_project',
    'current_plan', v_subscription.display_name,
    'required_plan', 'premium',
    'project_name', v_project.name
  );
END;
$$;
```

**사용 예시**:
```sql
-- Care-Lit 접근 권한 확인
SELECT public.check_project_access(
  '123e4567-e89b-12d3-a456-426614174000',
  'carelit'
);

-- 결과 (무료 플랜)
{
  "has_access": true,
  "access_level": "limited",
  "features_enabled": {"problems_limit": 20},
  "plan_name": "무료",
  "source": "subscription",
  "project_name": "Care-Lit"
}

-- 결과 (프리미엄 플랜)
{
  "has_access": true,
  "access_level": "full",
  "plan_name": "프리미엄",
  "source": "subscription",
  "project_name": "Care-Lit"
}

-- 결과 (Tem-Flow 접근 시도 - 무료 플랜)
{
  "has_access": false,
  "reason": "plan_does_not_include_project",
  "current_plan": "무료",
  "required_plan": "premium",
  "project_name": "Tem-Flow"
}
```

---

### 함수 3: `update_updated_at_column()` - updated_at 자동 갱신

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**트리거 생성**:
```sql
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_subscriptions_updated_at
  BEFORE UPDATE ON public.user_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

## 인덱싱 전략

### 자주 조회하는 컬럼

1. **users.email**: 로그인 시 이메일로 조회 → UNIQUE INDEX
2. **user_subscriptions.user_id**: 프로젝트 접근 시 구독 확인 → INDEX
3. **user_subscriptions.status**: 활성 구독만 필터링 → INDEX
4. **user_subscriptions.expires_at**: 만료된 구독 제외 → INDEX
5. **plan_project_access.plan_id**: 플랜별 프로젝트 조회 → INDEX
6. **plan_project_access.project_id**: 프로젝트별 플랜 조회 → INDEX

### 복합 인덱스 (Phase 2)

```sql
-- 사용자별 활성 구독 빠른 조회
CREATE INDEX idx_user_subscriptions_user_status
  ON user_subscriptions(user_id, status)
  WHERE status = 'active';

-- 프로젝트 접근 권한 빠른 조회
CREATE INDEX idx_plan_project_access_composite
  ON plan_project_access(plan_id, project_id);
```

---

## 데이터 무결성 규칙

### Foreign Key Constraints

```sql
-- users.id → auth.users.id (CASCADE: Auth 삭제 시 프로필도 삭제)
ALTER TABLE users
  ADD CONSTRAINT fk_users_auth
  FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- user_subscriptions.user_id → users.id (CASCADE)
ALTER TABLE user_subscriptions
  ADD CONSTRAINT fk_user_subscriptions_user_id
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- user_subscriptions.plan_id → subscription_plans.id
ALTER TABLE user_subscriptions
  ADD CONSTRAINT fk_user_subscriptions_plan_id
  FOREIGN KEY (plan_id) REFERENCES subscription_plans(id);

-- plan_project_access.plan_id → subscription_plans.id (CASCADE)
ALTER TABLE plan_project_access
  ADD CONSTRAINT fk_plan_project_access_plan_id
  FOREIGN KEY (plan_id) REFERENCES subscription_plans(id) ON DELETE CASCADE;

-- plan_project_access.project_id → projects.id (CASCADE)
ALTER TABLE plan_project_access
  ADD CONSTRAINT fk_plan_project_access_project_id
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
```

### CHECK Constraints

```sql
-- 이메일 형식 검증 (간단한 정규식)
ALTER TABLE users
  ADD CONSTRAINT check_email_format
  CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- 구독 상태 값 제한
ALTER TABLE user_subscriptions
  ADD CONSTRAINT check_status_values
  CHECK (status IN ('active', 'inactive', 'expired'));

-- 접근 레벨 값 제한
ALTER TABLE plan_project_access
  ADD CONSTRAINT check_access_level_values
  CHECK (access_level IN ('full', 'limited'));
```

### UNIQUE Constraints

```sql
-- 플랜-프로젝트 중복 방지
ALTER TABLE plan_project_access
  ADD CONSTRAINT unique_plan_project
  UNIQUE (plan_id, project_id);

-- 사용자-프로젝트 중복 방지
ALTER TABLE user_project_access
  ADD CONSTRAINT unique_user_project
  UNIQUE (user_id, project_id);
```

---

## 스케일링 고려사항

### Phase 1 (현재)

**예상 규모**:
- 사용자: ~100명
- 구독: ~100건
- 프로젝트: 3개
- 동시 접속: ~20명

**충분한 이유**:
- Supabase 무료 티어로 충분
- 인덱스로 쿼리 성능 최적화
- RLS로 자동 권한 제어

### Phase 2 (6개월 후)

**예상 규모**:
- 사용자: ~1,000명
- 구독: ~1,000건
- 프로젝트: 6개
- 동시 접속: ~100명

**최적화 전략**:
1. **Connection Pooling**: Supabase Pooler 활성화
2. **쿼리 캐싱**: Redis (Vercel KV) 사용
3. **읽기 복제**: Supabase Pro 플랜 (읽기 전용 복제본)
4. **파티셔닝**: `user_subscriptions` 테이블 연도별 파티션

### Phase 3 (1년 후)

**예상 규모**:
- 사용자: ~10,000명
- 구독: ~10,000건
- 프로젝트: 6개
- 동시 접속: ~500명

**최적화 전략**:
1. **Materialized View**: `check_project_access` 결과 캐싱
2. **Vertical Scaling**: Supabase Pro 더 높은 티어
3. **CDN**: Cloudflare for API 응답 캐싱
4. **분석 DB 분리**: OLAP 워크로드 별도 DB

---

## 마이그레이션 가이드

### 초기 스키마 생성

마이그레이션 파일은 `/supabase/migrations/` 디렉토리에 생성됩니다.

**파일명**: `20250120_initial_schema.sql` (다음 섹션 참고)

**실행 방법**:

1. **Supabase CLI 사용**:
```bash
# Supabase 프로젝트 연결
supabase link --project-ref bijluuvpkzhjbypbhlqy

# 마이그레이션 실행
supabase db push
```

2. **Supabase Dashboard SQL Editor**:
```
1. https://supabase.com/dashboard/project/bijluuvpkzhjbypbhlqy
2. SQL Editor 메뉴 클릭
3. 마이그레이션 SQL 복사-붙여넣기
4. "Run" 버튼 클릭
```

3. **PostgreSQL CLI**:
```bash
psql postgresql://postgres:[password]@db.bijluuvpkzhjbypbhlqy.supabase.co:5432/postgres \
  -f supabase/migrations/20250120_initial_schema.sql
```

### 검증 방법

```sql
-- 1. 테이블 목록 확인
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 예상 결과:
-- plan_project_access
-- projects
-- subscription_plans
-- user_project_access
-- user_subscriptions
-- users

-- 2. RLS 정책 확인
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 3. 트리거 확인
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table;

-- 4. 함수 확인
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- 5. 초기 데이터 확인
SELECT name, display_name, price_monthly FROM subscription_plans;
SELECT code, name FROM projects;

-- 6. 테스트 사용자 생성 및 접근 권한 확인
SELECT public.check_project_access(
  (SELECT id FROM users LIMIT 1),
  'carelit'
);
```

---

## 다음 단계

1. ✅ **데이터베이스 설계 완료** (현재)
2. ⏭️ **마이그레이션 SQL 생성** (`/supabase/migrations/20250120_initial_schema.sql`)
3. ⏭️ **05-UseCase Generator** (기능별 유스케이스 작성)
4. ⏭️ **06-State Management Generator** (Zustand 상태 관리 설계)

---

**문서 작성**: Claude Code + Database Architect
**버전**: 2.0 (개선 버전)
**최종 수정**: 2025-01-20
