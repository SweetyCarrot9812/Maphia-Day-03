# RLS 정책 문제 해결 가이드

## 현재 상황
- 회원가입 시 "프로필 생성에 실패했습니다" 오류 발생
- 에러 코드: 42501 (Row Level Security 정책 위반)
- 에러 메시지: "new row violates row-level security policy"

## 확인해야 할 사항

### 1. Supabase에서 정책이 제대로 생성되었는지 확인

Supabase SQL Editor에서 다음 쿼리 실행:

```sql
-- profiles 테이블의 모든 정책 확인
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'profiles';
```

**예상 결과**: "Users can insert own profile" 정책이 `cmd = 'INSERT'`로 표시되어야 합니다.

### 2. 정책이 없다면 다시 생성

```sql
-- 기존 정책 삭제 (있다면)
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- INSERT 정책 추가
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### 3. RLS가 활성화되어 있는지 확인

```sql
-- RLS 활성화 확인
SELECT
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE tablename = 'profiles';
```

**예상 결과**: `rowsecurity = true`

### 4. 모든 필요한 정책 확인

profiles 테이블에는 다음 3개의 정책이 필요합니다:

1. **INSERT 정책** (회원가입용):
```sql
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

2. **SELECT 정책** (프로필 조회용):
```sql
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);
```

3. **UPDATE 정책** (프로필 수정용):
```sql
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
```

### 5. 정책이 있는데도 실패한다면

RLS 정책의 조건이 문제일 수 있습니다. 임시로 모든 사용자가 INSERT 할 수 있도록 허용:

```sql
-- 임시 테스트용 (보안 주의!)
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

CREATE POLICY "Allow authenticated users to insert profile" ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (true);
```

이렇게 하면 회원가입이 작동하는지 확인할 수 있습니다.
**주의**: 이 정책은 테스트용이므로, 확인 후 다시 원래 정책으로 변경해야 합니다.

### 6. Supabase Auth 설정 확인

Supabase 대시보드 → Authentication → Settings에서:
- "Enable email confirmations"가 활성화되어 있는지 확인
- 비활성화하면 이메일 인증 없이 즉시 로그인 가능

## 빠른 해결 방법

가장 간단한 해결책:

```sql
-- profiles 테이블 RLS 임시 비활성화 (테스트용)
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
```

이렇게 하면 회원가입이 즉시 작동합니다.
**주의**: 프로덕션에서는 RLS를 반드시 활성화해야 합니다!

테스트가 끝나면:
```sql
-- RLS 다시 활성화
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
```

## 현재 권장 조치

1. Supabase SQL Editor에서 다음 실행:
```sql
-- 1단계: 현재 정책 확인
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'profiles';

-- 2단계: 테스트를 위해 RLS 임시 비활성화
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
```

2. 회원가입 다시 시도

3. 회원가입 성공 후:
```sql
-- RLS 다시 활성화
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 올바른 정책 추가
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
```
