-- advertiser123@gmail.com 계정 확인
SELECT
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users
WHERE email = 'advertiser123@gmail.com';

-- 비밀번호를 'test123456'으로 재설정 (Supabase Dashboard에서 직접 해야 함)
-- 또는 새 계정을 만들 수도 있습니다
