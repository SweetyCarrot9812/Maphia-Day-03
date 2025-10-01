-- campaigns 테이블에 image_url 컬럼 추가
ALTER TABLE campaigns
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 기존 캠페인에 테스트 이미지 URL 추가
UPDATE campaigns
SET image_url = 'https://i.imgur.com/sSkuJUC.png'
WHERE title = '테스트 카페 겨울 신메뉴 체험단';
