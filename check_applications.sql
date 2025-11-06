-- 모든 지원 내역 확인
SELECT
  a.id,
  a.campaign_id,
  a.influencer_id,
  a.status,
  a.message,
  a.visit_date,
  a.created_at,
  c.title as campaign_title,
  ip.user_id as influencer_user_id
FROM applications a
JOIN campaigns c ON a.campaign_id = c.id
JOIN influencer_profiles ip ON a.influencer_id = ip.id
ORDER BY a.created_at DESC;

-- 특정 캠페인의 지원자 확인
SELECT
  a.*
FROM applications a
WHERE a.campaign_id = 'a7b30eb2-2db7-42fb-b726-2f0a4e8ad42c';
