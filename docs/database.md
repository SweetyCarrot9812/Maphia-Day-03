# Database Schema: 콘서트 예약 플랫폼 (Supabase)

## 데이터베이스 선택: Supabase (PostgreSQL)

### 선정 이유
- **PostgreSQL 기반**: 강력한 관계형 데이터베이스
- **실시간 기능**: Realtime Subscriptions (좌석 예약 동시성 처리)
- **Row Level Security**: 보안 정책 내장
- **무료 플랜**: 프로토타입 및 배포에 충분
- **Next.js 통합**: 공식 라이브러리 지원

---

## 데이터 모델 개요

### Entity Relationship Diagram (ERD)

```
┌─────────────┐
│  concerts   │
│             │
│ id (PK)     │
│ title       │◄─────┐
│ artist      │      │
│ date        │      │
│ venue       │      │
│ ...         │      │
└─────────────┘      │
                     │ concert_id (FK)
                     │
┌─────────────┐      │
│   seats     │──────┘
│             │
│ id (PK)     │◄─────┐
│ concert_id  │      │
│ row         │      │
│ number      │      │
│ grade       │      │
│ price       │      │
│ is_booked   │      │
└─────────────┘      │
                     │ seat_ids[] (FK)
                     │
┌─────────────┐      │
│  bookings   │──────┘
│             │
│ id (PK)     │
│ concert_id  │
│ seat_ids[]  │
│ customer_*  │
│ ...         │
└─────────────┘
```

---

## 테이블 설계

### 1. concerts (콘서트 테이블)

**목적**: 콘서트 기본 정보 저장

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| `id` | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | 콘서트 고유 ID |
| `title` | VARCHAR(200) | NOT NULL | 콘서트 제목 |
| `artist` | VARCHAR(100) | NOT NULL | 아티스트명 |
| `date` | TIMESTAMPTZ | NOT NULL | 공연 날짜 및 시간 |
| `venue` | VARCHAR(200) | NOT NULL | 공연 장소 |
| `description` | TEXT | | 공연 설명 |
| `image_url` | TEXT | | 썸네일 이미지 URL |
| `running_time` | INTEGER | NOT NULL | 러닝타임 (분) |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | 생성 일시 |
| `updated_at` | TIMESTAMPTZ | DEFAULT now() | 수정 일시 |

**인덱스**:
- `idx_concerts_date`: `date` 컬럼 인덱스 (날짜 기준 조회 최적화)

**샘플 데이터**:
```sql
INSERT INTO concerts (id, title, artist, date, venue, description, image_url, running_time)
VALUES
  ('550e8400-e29b-41d4-a716-446655440001', '아이유 콘서트 2025', '아이유', '2025-02-14 19:00:00+09', '올림픽공원 체조경기장', '아이유의 2025년 콘서트', '/images/concerts/iu.jpg', 150),
  ('550e8400-e29b-41d4-a716-446655440002', 'BTS 월드투어', 'BTS', '2025-03-20 18:00:00+09', '잠실 종합운동장', 'BTS 월드투어 서울 공연', '/images/concerts/bts.jpg', 180);
```

---

### 2. seats (좌석 테이블)

**목적**: 콘서트별 좌석 정보 및 예약 상태 저장

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| `id` | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | 좌석 고유 ID |
| `concert_id` | UUID | NOT NULL, FOREIGN KEY → concerts(id) | 콘서트 ID |
| `row` | INTEGER | NOT NULL, CHECK (row >= 1 AND row <= 15) | 좌석 행 번호 (1-15) |
| `number` | INTEGER | NOT NULL, CHECK (number >= 1 AND number <= 10) | 좌석 열 번호 (1-10) |
| `grade` | VARCHAR(10) | NOT NULL, CHECK (grade IN ('VIP', 'R', 'S', 'A')) | 좌석 등급 |
| `price` | INTEGER | NOT NULL, CHECK (price > 0) | 가격 (원) |
| `is_booked` | BOOLEAN | NOT NULL, DEFAULT false | 예약 여부 |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | 생성 일시 |
| `updated_at` | TIMESTAMPTZ | DEFAULT now() | 수정 일시 |

**복합 유니크 제약**:
- `UNIQUE(concert_id, row, number)` - 같은 콘서트에서 동일 좌석 중복 방지

**인덱스**:
- `idx_seats_concert_id`: `concert_id` 컬럼 인덱스 (콘서트별 좌석 조회 최적화)
- `idx_seats_is_booked`: `is_booked` 컬럼 인덱스 (예약 가능 좌석 필터링 최적화)

**좌석 등급 및 가격 규칙**:
- **VIP**: 1-2열, 150,000원
- **R**: 3-5열, 100,000원
- **S**: 6-10열, 70,000원
- **A**: 11-15열, 50,000원

**샘플 데이터 생성 로직**:
```sql
-- 콘서트별로 15행 x 10열 = 150개 좌석 자동 생성
-- grade와 price는 row 번호에 따라 자동 할당
-- 샘플: 아이유 콘서트 (550e8400-e29b-41d4-a716-446655440001)의 좌석 생성
INSERT INTO seats (concert_id, row, number, grade, price)
SELECT
  '550e8400-e29b-41d4-a716-446655440001',
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
  generate_series(1, 15) AS r(row_num),
  generate_series(1, 10) AS n(number);
```

---

### 3. bookings (예약 테이블)

**목적**: 사용자 예약 정보 및 내역 저장

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| `id` | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | 예약 고유 ID |
| `booking_number` | VARCHAR(50) | NOT NULL, UNIQUE | 예약 번호 (BK-YYYYMMDDHHMMSS-XXXX) |
| `concert_id` | UUID | NOT NULL, FOREIGN KEY → concerts(id) | 콘서트 ID |
| `seat_ids` | UUID[] | NOT NULL | 선택된 좌석 ID 배열 |
| `customer_name` | VARCHAR(50) | NOT NULL | 예약자 이름 |
| `customer_phone` | VARCHAR(20) | NOT NULL | 예약자 전화번호 |
| `customer_email` | VARCHAR(100) | NOT NULL | 예약자 이메일 |
| `customer_birthdate` | DATE | | 예약자 생년월일 (선택) |
| `total_amount` | INTEGER | NOT NULL, CHECK (total_amount > 0) | 총 결제 금액 |
| `status` | VARCHAR(20) | NOT NULL, DEFAULT 'confirmed', CHECK (status IN ('confirmed', 'cancelled')) | 예약 상태 |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | 예약 생성 일시 |
| `updated_at` | TIMESTAMPTZ | DEFAULT now() | 수정 일시 |

**인덱스**:
- `idx_bookings_concert_id`: `concert_id` 컬럼 인덱스
- `idx_bookings_booking_number`: `booking_number` 컬럼 인덱스 (예약 번호 조회 최적화)
- `idx_bookings_customer_email`: `customer_email` 컬럼 인덱스 (이메일별 예약 조회)

**예약 번호 생성 규칙**:
- 형식: `BK-YYYYMMDDHHMMSS-XXXX`
- 예시: `BK-20250116142305-0001`

**샘플 데이터**:
```sql
INSERT INTO bookings (booking_number, concert_id, seat_ids, customer_name, customer_phone, customer_email, customer_birthdate, total_amount, status)
VALUES
  ('BK-20250116142305-0001',
   '550e8400-e29b-41d4-a716-446655440001',
   ARRAY['<seat_id_1>', '<seat_id_2>']::UUID[],
   '홍길동',
   '010-1234-5678',
   'hong@example.com',
   '1990-01-01',
   300000,
   'confirmed');
```

---

## 데이터 흐름 (Data Flow)

### Userflow 기반 데이터 흐름

#### Flow 1-2: 콘서트 목록 및 상세 조회
```sql
-- 콘서트 목록 조회 (예약 가능 여부 포함)
SELECT
  c.*,
  COUNT(s.id) AS total_seats,
  COUNT(s.id) FILTER (WHERE s.is_booked = false) AS available_seats
FROM concerts c
LEFT JOIN seats s ON c.id = s.concert_id
GROUP BY c.id
ORDER BY c.date ASC;

-- 콘서트 상세 조회
SELECT * FROM concerts WHERE id = $1;

-- 콘서트의 좌석 등급별 가격 조회
SELECT DISTINCT grade, price
FROM seats
WHERE concert_id = $1
ORDER BY price DESC;
```

#### Flow 3: 좌석 선택
```sql
-- 특정 콘서트의 모든 좌석 조회
SELECT * FROM seats
WHERE concert_id = $1
ORDER BY row ASC, number ASC;

-- 예약 가능한 좌석만 조회
SELECT * FROM seats
WHERE concert_id = $1 AND is_booked = false
ORDER BY row ASC, number ASC;
```

#### Flow 4-5: 예약 생성
```sql
-- 트랜잭션 시작
BEGIN;

-- 1. 선택한 좌석들이 아직 예약 가능한지 확인 (동시성 제어)
SELECT id, is_booked
FROM seats
WHERE id = ANY($1::UUID[])
FOR UPDATE; -- 행 잠금

-- 2. 모든 좌석이 is_booked = false인지 확인
-- 만약 하나라도 true면 ROLLBACK;

-- 3. 예약 생성
INSERT INTO bookings (
  booking_number, concert_id, seat_ids,
  customer_name, customer_phone, customer_email, customer_birthdate,
  total_amount, status
) VALUES (
  'BK-20250116142305-0001',
  $1,
  $2::UUID[],
  $3, $4, $5, $6,
  $7,
  'confirmed'
) RETURNING *;

-- 4. 좌석 예약 상태 업데이트
UPDATE seats
SET is_booked = true, updated_at = now()
WHERE id = ANY($2::UUID[]);

-- 트랜잭션 커밋
COMMIT;
```

#### Flow 6: 예약 조회
```sql
-- 모든 예약 조회 (최신순)
SELECT
  b.*,
  c.title AS concert_title,
  c.date AS concert_date,
  c.venue AS concert_venue
FROM bookings b
JOIN concerts c ON b.concert_id = c.id
ORDER BY b.created_at DESC;

-- 예약 번호로 특정 예약 조회
SELECT
  b.*,
  c.title AS concert_title,
  c.date AS concert_date,
  c.venue AS concert_venue,
  c.image_url AS concert_image,
  ARRAY_AGG(
    json_build_object(
      'id', s.id,
      'row', s.row,
      'number', s.number,
      'grade', s.grade,
      'price', s.price
    )
  ) AS seats
FROM bookings b
JOIN concerts c ON b.concert_id = c.id
JOIN seats s ON s.id = ANY(b.seat_ids)
WHERE b.booking_number = $1
GROUP BY b.id, c.id;
```

---

## Supabase 마이그레이션 SQL

### 파일: `supabase/migrations/20250116_initial_schema.sql`

```sql
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

-- 예약 생성은 인증된 사용자만 (임시로 모두 허용)
CREATE POLICY "Anyone can create bookings" ON bookings FOR INSERT WITH CHECK (true);

-- 좌석 업데이트는 시스템만 (임시로 모두 허용)
CREATE POLICY "Anyone can update seats" ON seats FOR UPDATE USING (true);
```

---

## Supabase 설정

### 환경 변수 (.env.local)
```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

### Supabase Client 설정
```typescript
// lib/supabase/client.ts
import { createClient } from '@supabase/supabase-js';
import { Database } from '@/types/supabase';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey);
```

---

## 데이터 타입 (TypeScript)

### Supabase에서 자동 생성된 타입
```typescript
// types/supabase.ts (supabase gen types typescript --local로 생성)
export type Database = {
  public: {
    Tables: {
      concerts: {
        Row: {
          id: string;
          title: string;
          artist: string;
          date: string;
          venue: string;
          description: string | null;
          image_url: string | null;
          running_time: number;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['concerts']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['concerts']['Insert']>;
      };
      seats: {
        Row: {
          id: string;
          concert_id: string;
          row: number;
          number: number;
          grade: 'VIP' | 'R' | 'S' | 'A';
          price: number;
          is_booked: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['seats']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['seats']['Insert']>;
      };
      bookings: {
        Row: {
          id: string;
          booking_number: string;
          concert_id: string;
          seat_ids: string[];
          customer_name: string;
          customer_phone: string;
          customer_email: string;
          customer_birthdate: string | null;
          total_amount: number;
          status: 'confirmed' | 'cancelled';
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['bookings']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['bookings']['Insert']>;
      };
    };
  };
};
```

---

## 동시성 제어 전략

### 좌석 예약 시 동시성 문제 해결

**문제**: 여러 사용자가 동시에 같은 좌석을 예약하려고 할 때

**해결 방법**: PostgreSQL 트랜잭션 + FOR UPDATE 잠금

```typescript
// lib/repositories/bookingRepository.ts
export async function createBooking(bookingData: BookingInsert) {
  // 트랜잭션 시작
  const { data: seats, error: lockError } = await supabase
    .from('seats')
    .select('id, is_booked')
    .in('id', bookingData.seat_ids)
    .single();

  // 좌석이 이미 예약되었는지 확인
  if (seats.some(seat => seat.is_booked)) {
    throw new Error('이미 예약된 좌석이 포함되어 있습니다');
  }

  // 예약 생성
  const { data: booking, error: bookingError } = await supabase
    .from('bookings')
    .insert(bookingData)
    .select()
    .single();

  // 좌석 상태 업데이트
  const { error: updateError } = await supabase
    .from('seats')
    .update({ is_booked: true })
    .in('id', bookingData.seat_ids);

  return booking;
}
```

---

## 쿼리 최적화

### 인덱스 활용
- `concert_id` 인덱스: 콘서트별 좌석 조회 최적화
- `is_booked` 인덱스: 예약 가능 좌석 필터링 최적화
- `booking_number` 인덱스: 예약 번호 조회 최적화

### JOIN 최적화
- 예약 상세 조회 시 `concerts`, `seats` 테이블 JOIN
- `ARRAY_AGG` 사용하여 좌석 정보 배열로 집계

---

## 다음 단계

1. ✅ Supabase 프로젝트 생성
2. ✅ 마이그레이션 SQL 실행
3. ✅ 환경 변수 설정
4. ✅ Supabase Client 설정
5. ✅ Repository 레이어 구현

---

**문서 버전**: 1.0
**작성일**: 2025-01-16
**데이터베이스**: Supabase (PostgreSQL)
**다음 단계**: Usecase 명세 작성
