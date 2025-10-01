-- 지원 상태를 pending으로 되돌리기
UPDATE applications
SET status = 'pending'
WHERE influencer_id = '44eb7165-0907-4313-adbb-7e727a74748a';
