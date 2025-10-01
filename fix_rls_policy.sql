-- ============================================
-- RLS 정책 수정: profiles 테이블에 INSERT 정책 추가
-- Supabase SQL Editor에서 실행
-- ============================================

-- 기존 정책이 있다면 먼저 삭제 (에러 무시)
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- INSERT 정책 추가
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 확인
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'profiles';
