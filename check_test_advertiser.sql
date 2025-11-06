-- test@advertiser.com 계정 상태 확인
SELECT
  au.id as auth_id,
  au.email,
  au.email_confirmed_at,
  p.id as profile_id,
  p.role,
  p.name,
  p.phone
FROM auth.users au
LEFT JOIN profiles p ON au.id = p.id
WHERE au.email = 'test@advertiser.com';

-- advertiser_profile 확인
SELECT
  ap.*
FROM advertiser_profiles ap
JOIN profiles p ON ap.user_id = p.id
WHERE p.email = 'test@advertiser.com';
