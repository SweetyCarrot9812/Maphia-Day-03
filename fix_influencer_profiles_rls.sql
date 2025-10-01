-- influencer_profiles 테이블의 RLS 정책 확인
SELECT * FROM pg_policies WHERE tablename = 'influencer_profiles';

-- 광고주가 자신의 캠페인 지원자의 influencer_profiles를 볼 수 있도록 정책 추가
DROP POLICY IF EXISTS "Advertisers can view influencer profiles of applicants" ON influencer_profiles;

CREATE POLICY "Advertisers can view influencer profiles of applicants"
ON influencer_profiles
FOR SELECT
TO public
USING (
  id IN (
    SELECT a.influencer_id
    FROM applications a
    JOIN campaigns c ON a.campaign_id = c.id
    JOIN advertiser_profiles ap ON c.advertiser_id = ap.id
    WHERE ap.user_id = auth.uid()
  )
);

-- profiles 테이블의 RLS 정책 확인
SELECT * FROM pg_policies WHERE tablename = 'profiles';

-- 광고주가 지원자의 기본 프로필 정보를 볼 수 있도록 정책 추가
DROP POLICY IF EXISTS "Advertisers can view profiles of applicants" ON profiles;

CREATE POLICY "Advertisers can view profiles of applicants"
ON profiles
FOR SELECT
TO public
USING (
  id IN (
    SELECT ip.user_id
    FROM influencer_profiles ip
    JOIN applications a ON a.influencer_id = ip.id
    JOIN campaigns c ON a.campaign_id = c.id
    JOIN advertiser_profiles ap ON c.advertiser_id = ap.id
    WHERE ap.user_id = auth.uid()
  )
);
