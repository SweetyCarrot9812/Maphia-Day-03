-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. concerts 테이블
-- =====================================================
CREATE TABLE concerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(200) NOT NULL,
  artist VARCHAR(100) NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  venue VARCHAR(200) NOT NULL,
  description TEXT,
  image_url TEXT,
  running_time INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_concerts_date ON concerts(date);

-- 코멘트
COMMENT ON TABLE concerts IS '콘서트 정보 테이블';
COMMENT ON COLUMN concerts.running_time IS '러닝타임 (분 단위)';

-- =====================================================
-- 2. seats 테이블
-- =====================================================
CREATE TABLE seats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  concert_id UUID NOT NULL REFERENCES concerts(id) ON DELETE CASCADE,
  row INTEGER NOT NULL CHECK (row >= 1 AND row <= 15),
  number INTEGER NOT NULL CHECK (number >= 1 AND number <= 10),
  grade VARCHAR(10) NOT NULL CHECK (grade IN ('VIP', 'R', 'S', 'A')),
  price INTEGER NOT NULL CHECK (price > 0),
  is_booked BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(concert_id, row, number)
);

-- 인덱스
CREATE INDEX idx_seats_concert_id ON seats(concert_id);
CREATE INDEX idx_seats_is_booked ON seats(is_booked);

-- 코멘트
COMMENT ON TABLE seats IS '좌석 정보 테이블';
COMMENT ON COLUMN seats.grade IS '좌석 등급: VIP(1-2행), R(3-5행), S(6-10행), A(11-15행)';
COMMENT ON COLUMN seats.price IS '좌석 가격 (원)';
COMMENT ON COLUMN seats.is_booked IS '예약 여부';

-- =====================================================
-- 3. bookings 테이블
-- =====================================================
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_number VARCHAR(50) NOT NULL UNIQUE,
  concert_id UUID NOT NULL REFERENCES concerts(id) ON DELETE CASCADE,
  seat_ids UUID[] NOT NULL,
  customer_name VARCHAR(50) NOT NULL,
  customer_phone VARCHAR(20) NOT NULL,
  customer_email VARCHAR(100) NOT NULL,
  customer_birthdate DATE,
  total_amount INTEGER NOT NULL CHECK (total_amount > 0),
  status VARCHAR(20) NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_bookings_concert_id ON bookings(concert_id);
CREATE INDEX idx_bookings_booking_number ON bookings(booking_number);
CREATE INDEX idx_bookings_customer_email ON bookings(customer_email);

-- 코멘트
COMMENT ON TABLE bookings IS '예약 정보 테이블';
COMMENT ON COLUMN bookings.booking_number IS '예약 번호 (BK-YYYYMMDDHHMMSS-XXXX 형식)';
COMMENT ON COLUMN bookings.seat_ids IS '선택된 좌석 ID 배열';
COMMENT ON COLUMN bookings.total_amount IS '총 결제 금액 (원)';

-- =====================================================
-- 4. 샘플 데이터 삽입
-- =====================================================

-- 콘서트 샘플 데이터
INSERT INTO concerts (id, title, artist, date, venue, description, image_url, running_time)
VALUES
  ('550e8400-e29b-41d4-a716-446655440001', '아이유 콘서트 2025', '아이유', '2025-02-14 19:00:00+09', '올림픽공원 체조경기장', '아이유의 2025년 단독 콘서트입니다. 최신 앨범의 타이틀곡과 히트곡을 만나보세요.', 'https://picsum.photos/seed/iu/800/600', 150),
  ('550e8400-e29b-41d4-a716-446655440002', 'BTS 월드투어', 'BTS', '2025-03-20 18:00:00+09', '잠실 종합운동장', 'BTS 월드투어 서울 공연입니다. 전 세계를 감동시킨 무대를 서울에서 만나보세요.', 'https://picsum.photos/seed/bts/800/600', 180),
  ('550e8400-e29b-41d4-a716-446655440003', '볼빨간사춘기 단독 콘서트', '볼빨간사춘기', '2025-04-05 19:30:00+09', 'YES24 라이브홀', '볼빨간사춘기의 감성 가득한 단독 콘서트입니다.', 'https://picsum.photos/seed/bol4/800/600', 120);

-- 좌석 샘플 데이터 (각 콘서트별 150개 좌석 자동 생성)
INSERT INTO seats (concert_id, row, number, grade, price)
SELECT
  c.id,
  r.row_num,
  n.number,
  CASE
    WHEN r.row_num BETWEEN 1 AND 2 THEN 'VIP'
    WHEN r.row_num BETWEEN 3 AND 5 THEN 'R'
    WHEN r.row_num BETWEEN 6 AND 10 THEN 'S'
    ELSE 'A'
  END AS grade,
  CASE
    WHEN r.row_num BETWEEN 1 AND 2 THEN 150000
    WHEN r.row_num BETWEEN 3 AND 5 THEN 100000
    WHEN r.row_num BETWEEN 6 AND 10 THEN 70000
    ELSE 50000
  END AS price
FROM
  concerts c,
  generate_series(1, 15) AS r(row_num),
  generate_series(1, 10) AS n(number);

-- =====================================================
-- 5. 트리거: updated_at 자동 업데이트
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_concerts_updated_at
BEFORE UPDATE ON concerts
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_seats_updated_at
BEFORE UPDATE ON seats
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
BEFORE UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 6. Row Level Security (RLS) 설정
-- =====================================================

-- RLS 활성화
ALTER TABLE concerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 읽기 가능
CREATE POLICY "Anyone can read concerts" ON concerts FOR SELECT USING (true);
CREATE POLICY "Anyone can read seats" ON seats FOR SELECT USING (true);
CREATE POLICY "Anyone can read bookings" ON bookings FOR SELECT USING (true);

-- 예약 생성은 모두 허용
CREATE POLICY "Anyone can create bookings" ON bookings FOR INSERT WITH CHECK (true);

-- 좌석 업데이트는 모두 허용
CREATE POLICY "Anyone can update seats" ON seats FOR UPDATE USING (true);
