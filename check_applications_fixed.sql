-- applications 테이블 구조 확인
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'applications';

-- 모든 지원 내역 확인 (필드명 수정)
SELECT
  a.*,
  c.title as campaign_title
FROM applications a
JOIN campaigns c ON a.campaign_id = c.id
ORDER BY a.created_at DESC;

-- 특정 캠페인의 지원자 확인
SELECT *
FROM applications
WHERE campaign_id = 'a7b30eb2-2db7-42fb-b726-2f0a4e8ad42c';
