-- 이메일 확인 처리 (테스트용)
-- Supabase SQL Editor에서 실행

UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email = 'testadvertiser@gmail.com';

-- 확인
SELECT email, email_confirmed_at, created_at
FROM auth.users
WHERE email = 'testadvertiser@gmail.com';
