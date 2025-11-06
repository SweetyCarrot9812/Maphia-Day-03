-- campaigns 테이블의 RLS 정책 확인
SELECT * FROM pg_policies WHERE tablename = 'campaigns';

-- RLS를 임시로 비활성화 (테스트용)
ALTER TABLE campaigns DISABLE ROW LEVEL SECURITY;

-- 또는 모든 사용자가 recruiting 캠페인을 읽을 수 있도록 정책 추가
DROP POLICY IF EXISTS "Anyone can view recruiting campaigns" ON campaigns;

CREATE POLICY "Anyone can view recruiting campaigns"
ON campaigns
FOR SELECT
TO public
USING (status = 'recruiting');
