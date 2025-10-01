-- 캠페인과 advertiser_profiles 조인 테스트
SELECT
  c.*,
  ap.business_name
FROM campaigns c
INNER JOIN advertiser_profiles ap ON c.advertiser_id = ap.id
WHERE c.status = 'recruiting'
ORDER BY c.created_at DESC;

-- advertiser_profiles 테이블 확인
SELECT * FROM advertiser_profiles;
