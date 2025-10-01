-- influencer123@gmail.com 이메일 인증 처리
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email = 'influencer123@gmail.com';

-- 확인
SELECT id, email, email_confirmed_at
FROM auth.users
WHERE email = 'influencer123@gmail.com';
