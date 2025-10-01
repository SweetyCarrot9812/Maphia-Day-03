-- 무한 재귀를 일으키는 정책들을 삭제
DROP POLICY IF EXISTS "Advertisers can view influencer profiles of applicants" ON influencer_profiles;
DROP POLICY IF EXISTS "Advertisers can view profiles of applicants" ON profiles;

-- 대신 더 간단한 정책 추가: 모든 인증된 사용자가 influencer_profiles와 profiles를 읽을 수 있도록
-- (실제 프로덕션에서는 더 세밀한 권한이 필요하지만, MVP에서는 이것으로 충분)

CREATE POLICY "Authenticated users can view influencer profiles"
ON influencer_profiles
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authenticated users can view profiles"
ON profiles
FOR SELECT
TO authenticated
USING (true);
