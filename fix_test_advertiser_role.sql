-- test@advertiser.com 계정 확인
SELECT
  p.id,
  p.email,
  p.role,
  p.name
FROM profiles p
WHERE p.email = 'test@advertiser.com';

-- role을 advertiser로 변경
UPDATE profiles
SET role = 'advertiser'
WHERE email = 'test@advertiser.com';

-- 다시 확인
SELECT
  p.id,
  p.email,
  p.role,
  p.name
FROM profiles p
WHERE p.email = 'test@advertiser.com';
