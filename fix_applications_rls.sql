-- applications 테이블의 RLS 정책 확인
SELECT * FROM pg_policies WHERE tablename = 'applications';

-- 광고주가 자신의 캠페인 지원자를 볼 수 있도록 정책 추가
DROP POLICY IF EXISTS "Advertisers can view applications to their campaigns" ON applications;

CREATE POLICY "Advertisers can view applications to their campaigns"
ON applications
FOR SELECT
TO public
USING (
  campaign_id IN (
    SELECT c.id
    FROM campaigns c
    JOIN advertiser_profiles ap ON c.advertiser_id = ap.id
    WHERE ap.user_id = auth.uid()
  )
);

-- 인플루언서가 자신의 지원 내역을 볼 수 있도록 정책 추가
DROP POLICY IF EXISTS "Influencers can view their own applications" ON applications;

CREATE POLICY "Influencers can view their own applications"
ON applications
FOR SELECT
TO public
USING (
  influencer_id IN (
    SELECT id FROM influencer_profiles WHERE user_id = auth.uid()
  )
);
