-- advertiser_profiles 테이블의 RLS 확인
SELECT
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE tablename = 'advertiser_profiles';

-- advertiser_profiles 정책 확인
SELECT * FROM pg_policies WHERE tablename = 'advertiser_profiles';

-- 모든 사용자가 advertiser_profiles를 읽을 수 있도록 정책 추가
DROP POLICY IF EXISTS "Anyone can view advertiser profiles" ON advertiser_profiles;

CREATE POLICY "Anyone can view advertiser profiles"
ON advertiser_profiles
FOR SELECT
TO public
USING (true);
