# 빠른 데이터베이스 설정 가이드

## 🚀 5분 안에 완료하기

### Step 1: Supabase 대시보드 열기
1. https://supabase.com/dashboard 접속
2. 프로젝트 선택: **bijluuvpkzhjbypbhlqy**

### Step 2: SQL 에디터에서 마이그레이션 실행
1. 왼쪽 메뉴에서 **SQL Editor** 클릭
2. **New query** 버튼 클릭
3. 아래 파일 내용을 **복사**하여 붙여넣기:

**파일 경로**: `supabase/migrations/20251021000000_initial_schema.sql`

4. **RUN** 버튼 (또는 Ctrl+Enter) 클릭

### Step 3: 실행 완료 확인

SQL 실행 후 아래 메시지가 표시되어야 합니다:
```
Success. No rows returned
```

**검증 쿼리 실행**:
```sql
-- 테이블 확인
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 결과: users, subscription_plans, user_subscriptions, projects, plan_project_access, user_project_access

-- 구독 플랜 확인
SELECT name, display_name, price_monthly FROM subscription_plans;

-- 결과: free, basic, premium, enterprise (4개 플랜)

-- 프로젝트 확인
SELECT code, name FROM projects;

-- 결과: carelit, temflow, arisper (3개 프로젝트)
```

### Step 4: 이메일 확인 설정 (선택사항)

**현재 상태 확인**:
1. 왼쪽 메뉴 **Authentication** → **Providers** 클릭
2. **Email** 클릭

**설정 옵션**:

#### 옵션 A: 이메일 확인 비활성화 (테스트용)
- **Confirm email** 토글을 **OFF**로 설정
- 즉시 회원가입 후 로그인 가능
- ⚠️ 프로덕션에서는 권장하지 않음

#### 옵션 B: 이메일 확인 활성화 (프로덕션)
- **Confirm email** 토글을 **ON**으로 유지 (기본값)
- 회원가입 후 이메일로 확인 링크 전송
- 사용자가 이메일 확인 후 로그인 가능
- ✅ 보안 강화, 이메일 중복 방지

**이메일 템플릿 확인**:
1. **Email Templates** 탭 클릭
2. **Confirm signup** 선택
3. 이메일 내용 확인 (수정 가능)

### Step 5: 회원가입 테스트

1. 브라우저에서 http://localhost:3007/signup 접속
2. 이메일, 닉네임, 비밀번호 입력
3. **이메일로 회원가입** 클릭

**이메일 확인 ON인 경우**:
- "회원가입이 완료되었습니다! 이메일을 확인하여 인증을 완료해주세요." 메시지 표시
- 이메일 수신함 확인 → 확인 링크 클릭
- 이메일 확인 완료 후 로그인 가능

**이메일 확인 OFF인 경우**:
- "회원가입이 완료되었습니다!" 메시지 표시
- 즉시 로그인 가능

### 문제 해결

#### 401 Unauthorized Error
**원인**: 마이그레이션 미실행 또는 RLS 정책 오류

**해결**:
1. SQL Editor에서 마이그레이션 재실행
2. RLS 정책 확인:
   ```sql
   SELECT tablename, policyname FROM pg_policies
   WHERE schemaname = 'public';
   ```

#### "relation 'users' does not exist" Error
**원인**: users 테이블이 생성되지 않음

**해결**:
```sql
-- 테이블 존재 확인
SELECT EXISTS (
  SELECT FROM information_schema.tables
  WHERE table_schema = 'public'
  AND table_name = 'users'
);
-- 결과: true여야 함
```

#### 이메일이 오지 않음
**원인**: Supabase 이메일 설정 문제

**해결**:
1. **Authentication** → **Email Templates** 확인
2. **SMTP Settings** 확인 (기본: Supabase 내장 SMTP 사용)
3. 스팸 메일함 확인
4. 테스트용으로 이메일 확인 비활성화

#### 회원가입 후 데이터베이스 확인

```sql
-- 생성된 사용자 확인
SELECT id, email, nickname, created_at FROM users ORDER BY created_at DESC LIMIT 5;

-- 구독 할당 확인
SELECT
  u.email,
  sp.display_name as plan,
  us.status
FROM user_subscriptions us
JOIN users u ON us.user_id = u.id
JOIN subscription_plans sp ON us.plan_id = sp.id
ORDER BY us.created_at DESC
LIMIT 5;
```

---

## ✅ 설정 완료 체크리스트

- [ ] SQL 마이그레이션 실행 완료
- [ ] 테이블 6개 생성 확인 (users, subscription_plans, user_subscriptions, projects, plan_project_access, user_project_access)
- [ ] 초기 데이터 삽입 확인 (플랜 4개, 프로젝트 3개)
- [ ] 이메일 확인 설정 결정 (ON/OFF)
- [ ] 회원가입 테스트 성공

---

**소요 시간**: 약 5분
**다음 단계**: http://localhost:3007/signup 에서 회원가입 테스트
