-- 현재 로그인한 사용자의 advertiser profile ID 확인
SELECT
  p.id as profile_id,
  p.email,
  p.role,
  ap.id as advertiser_profile_id,
  ap.business_name
FROM profiles p
LEFT JOIN advertiser_profiles ap ON p.id = ap.user_id
WHERE p.email = 'advertiser123@gmail.com';

-- 캠페인 확인
SELECT
  c.id,
  c.title,
  c.advertiser_id,
  ap.business_name,
  ap.user_id
FROM campaigns c
LEFT JOIN advertiser_profiles ap ON c.advertiser_id = ap.id
ORDER BY c.created_at DESC;
