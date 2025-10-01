-- 모든 캠페인 확인
SELECT
  c.id,
  c.title,
  c.status,
  c.advertiser_id,
  ap.business_name,
  ap.user_id,
  c.created_at
FROM campaigns c
LEFT JOIN advertiser_profiles ap ON c.advertiser_id = ap.id
ORDER BY c.created_at DESC;

-- advertiser123@gmail.com의 정보 확인
SELECT
  p.id as profile_id,
  p.email,
  p.role,
  ap.id as advertiser_profile_id,
  ap.business_name
FROM profiles p
LEFT JOIN advertiser_profiles ap ON p.id = ap.user_id
WHERE p.email = 'advertiser123@gmail.com';
