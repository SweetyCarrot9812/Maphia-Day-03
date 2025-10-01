-- test@advertiser.com 계정의 profile 생성
INSERT INTO profiles (id, email, role, name, phone, created_at, updated_at)
VALUES (
  '2d00970a-0295-496f-8444-b72ec718cd7b',
  'test@advertiser.com',
  'advertiser',
  'Test Advertiser',
  '010-1234-5678',
  NOW(),
  NOW()
);

-- 확인
SELECT * FROM profiles WHERE email = 'test@advertiser.com';
