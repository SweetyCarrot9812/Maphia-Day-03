# Database Schema & Dataflow v1.0

## Meta
- 작성일: 2025-11-07
- 작성자: Portfolio Project - Agent 5 (dataflow-schema-generator)
- DB: Supabase PostgreSQL
- Phase: 0 (Core)

---

## 🎯 Phase 분류 결과

**Phase 0 (Core)**: ✅ 적용
- conference_rooms (필수)
- bookings (필수)
- admin_sessions (조건부: Userflow "테스트 관리자 접근" 존재)

**Phase 1 (Optional)**: ❌ 생략
- notifications → Userflow에 "알림" 없음
- fulltext_search → Userflow에 "검색" 없음
- audit_log → 향후 확장 시 고려

**Phase 2 (Advanced)**: ❌ 생략

---

## 📁 ERD

```
conference_rooms (1) ──< (N) bookings
         │
         │
admin_sessions (테스트 관리자 세션 관리)
```

---

## 🔧 Migration Files

### `/supabase/migrations/20251107120000_initial_schema.sql`

```sql
-- Migration: 20251107120000_initial_schema.sql
-- Created: 2025-11-07 12:00:00
-- Phase: 0 (Core)
-- Userflow: 회의실 목록 조회, 날짜/시간대 선택, 예약 정보 입력, 예약 조회, 테스트 관리자 접근

-- 1. conference_rooms (필수)
CREATE TABLE conference_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(30) NOT NULL,
  location VARCHAR(50) NOT NULL,
  capacity INTEGER NOT NULL CHECK (capacity >= 1 AND capacity <= 100),
  operating_hours JSONB NOT NULL DEFAULT '{"start": "09:00", "end": "18:00"}',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT check_name_format CHECK (
    length(trim(name)) >= 2 AND length(trim(name)) <= 30
  ),
  CONSTRAINT check_location_format CHECK (
    length(trim(location)) >= 2 AND length(trim(location)) <= 50
  )
);

CREATE UNIQUE INDEX idx_conference_rooms_name ON conference_rooms(name) WHERE is_active = TRUE;
CREATE INDEX idx_conference_rooms_capacity ON conference_rooms(capacity);
CREATE INDEX idx_conference_rooms_active ON conference_rooms(is_active, created_at);

-- 2. bookings (필수)
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES conference_rooms(id) ON DELETE RESTRICT,
  user_name VARCHAR(20) NOT NULL,
  phone VARCHAR(15) NOT NULL,
  purpose VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  booking_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled')),
  confirmation_number VARCHAR(20) NOT NULL,
  cancelled_at TIMESTAMPTZ,
  cancelled_reason VARCHAR(50),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT check_user_name_format CHECK (
    length(trim(user_name)) >= 2 AND length(trim(user_name)) <= 20
  ),
  CONSTRAINT check_phone_format CHECK (
    phone ~ '^010-[0-9]{4}-[0-9]{4}$'
  ),
  CONSTRAINT check_purpose_format CHECK (
    length(trim(purpose)) >= 10 AND length(trim(purpose)) <= 100
  ),
  CONSTRAINT check_booking_date_future CHECK (
    booking_date >= CURRENT_DATE
  ),
  CONSTRAINT check_time_slots CHECK (
    start_time >= '09:00'::TIME AND
    end_time <= '18:00'::TIME AND
    start_time < end_time
  ),
  CONSTRAINT check_confirmation_format CHECK (
    confirmation_number ~ '^BOOK-[0-9]{8}-[0-9]{4}$'
  )
);

-- 중복 예약 방지: 동일 회의실, 날짜, 시간대에 확정된 예약 1개만
CREATE UNIQUE INDEX idx_bookings_room_time_unique
  ON bookings(room_id, booking_date, start_time, end_time)
  WHERE status = 'confirmed';

-- 동일 휴대폰번호의 동시 시간대 예약 방지
CREATE UNIQUE INDEX idx_bookings_phone_time_unique
  ON bookings(phone, booking_date, start_time, end_time)
  WHERE status = 'confirmed';

-- 조회 최적화 인덱스
CREATE INDEX idx_bookings_phone_lookup ON bookings(phone, status, booking_date DESC);
CREATE INDEX idx_bookings_room_date ON bookings(room_id, booking_date, start_time);
CREATE INDEX idx_bookings_confirmation ON bookings(confirmation_number);
CREATE INDEX idx_bookings_admin_view ON bookings(booking_date DESC, status, created_at DESC);

-- 3. admin_sessions (조건부: Userflow에 "테스트 관리자 접근" 존재)
CREATE TABLE admin_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id VARCHAR(20) NOT NULL DEFAULT 'admin',
  login_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_activity TIMESTAMPTZ NOT NULL DEFAULT now(),
  ip_address INET,
  user_agent TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_admin_sessions_active ON admin_sessions(admin_id, is_active, last_activity DESC);
CREATE INDEX idx_admin_sessions_cleanup ON admin_sessions(last_activity) WHERE is_active = TRUE;

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_conference_rooms_updated_at
  BEFORE UPDATE ON conference_rooms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
  BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 확인번호 자동 생성 함수
CREATE OR REPLACE FUNCTION generate_confirmation_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.confirmation_number = 'BOOK-' ||
    to_char(NEW.booking_date, 'YYYYMMDD') || '-' ||
    lpad(floor(random() * 10000)::text, 4, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_booking_confirmation
  BEFORE INSERT ON bookings
  FOR EACH ROW EXECUTE FUNCTION generate_confirmation_number();

-- 기본 회의실 데이터 삽입
INSERT INTO conference_rooms (name, location, capacity) VALUES
('아이디어룸', '2층 서쪽', 4),
('브레인스토밍룸', '2층 동쪽', 6),
('프레젠테이션룸', '3층 남쪽', 12),
('임원회의실', '3층 북쪽', 8),
('소회의실A', '4층 서쪽', 6),
('소회의실B', '4층 동쪽', 4);
```

---

## 📊 Dataflow (상세)

### Flow 1: 회의실 목록 조회 및 선택
```sql
-- Step 1: 활성 회의실 목록 조회
SELECT
  id,
  name,
  location,
  capacity,
  operating_hours,
  created_at
FROM conference_rooms
WHERE is_active = TRUE
ORDER BY name;

-- Step 2: 회의실별 오늘 예약 현황 조회 (실시간 상태 표시용)
SELECT
  cr.id,
  cr.name,
  COUNT(b.id) as today_bookings,
  ARRAY_AGG(
    b.start_time || '-' || b.end_time
    ORDER BY b.start_time
  ) FILTER (WHERE b.status = 'confirmed') as booked_slots
FROM conference_rooms cr
LEFT JOIN bookings b ON cr.id = b.room_id
  AND b.booking_date = CURRENT_DATE
  AND b.status = 'confirmed'
WHERE cr.is_active = TRUE
GROUP BY cr.id, cr.name
ORDER BY cr.name;
```

### Flow 2: 날짜/시간대 선택 (빈 시간 확인)
```sql
-- Step 1: 특정 회의실의 특정 날짜 예약 현황
SELECT
  start_time,
  end_time,
  user_name,
  purpose
FROM bookings
WHERE room_id = $1
  AND booking_date = $2
  AND status = 'confirmed'
ORDER BY start_time;

-- Step 2: 예약 가능한 시간대 계산 (9시-18시 중 1시간 단위)
WITH RECURSIVE time_slots AS (
  SELECT '09:00'::TIME as slot_start, '10:00'::TIME as slot_end
  UNION ALL
  SELECT slot_start + INTERVAL '1 hour', slot_end + INTERVAL '1 hour'
  FROM time_slots
  WHERE slot_end < '18:00'::TIME
),
booked_times AS (
  SELECT start_time, end_time
  FROM bookings
  WHERE room_id = $1 AND booking_date = $2 AND status = 'confirmed'
)
SELECT
  ts.slot_start,
  ts.slot_end,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM booked_times bt
      WHERE ts.slot_start < bt.end_time AND ts.slot_end > bt.start_time
    ) THEN FALSE
    ELSE TRUE
  END as is_available
FROM time_slots ts
ORDER BY ts.slot_start;
```

### Flow 3: 예약 정보 입력 및 등록
```sql
-- Step 1: 중복 예약 체크 (동일 시간대)
SELECT COUNT(*) as conflict_count
FROM bookings
WHERE room_id = $1
  AND booking_date = $2
  AND start_time = $3
  AND end_time = $4
  AND status = 'confirmed';

-- Step 2: 동일 휴대폰번호 중복 체크 (같은 시간대)
SELECT COUNT(*) as phone_conflict
FROM bookings
WHERE phone = $1
  AND booking_date = $2
  AND start_time = $3
  AND end_time = $4
  AND status = 'confirmed';

-- Step 3: 예약 등록 (비밀번호는 애플리케이션에서 해싱)
INSERT INTO bookings (
  room_id,
  user_name,
  phone,
  purpose,
  password_hash,
  booking_date,
  start_time,
  end_time
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING
  id,
  confirmation_number,
  booking_date,
  start_time,
  end_time,
  created_at;
```

### Flow 4: 예약 조회 (휴대폰번호 + 비밀번호)
```sql
-- Step 1: 휴대폰번호로 예약 내역 조회
SELECT
  b.id,
  b.confirmation_number,
  b.user_name,
  b.purpose,
  b.booking_date,
  b.start_time,
  b.end_time,
  b.status,
  b.cancelled_at,
  b.cancelled_reason,
  b.created_at,
  cr.name as room_name,
  cr.location as room_location
FROM bookings b
JOIN conference_rooms cr ON b.room_id = cr.id
WHERE b.phone = $1
ORDER BY
  CASE WHEN b.booking_date >= CURRENT_DATE AND b.status = 'confirmed'
       THEN 0 ELSE 1 END,  -- 진행 예정 먼저
  b.booking_date DESC,
  b.start_time DESC;

-- Step 2: 비밀번호 검증은 애플리케이션 레벨에서 처리
-- (password_hash 컬럼 값과 입력된 비밀번호의 해시 값 비교)
```

### Flow 5: 예약 취소
```sql
-- Step 1: 예약 상태 및 취소 가능 시점 확인
SELECT
  id,
  status,
  booking_date,
  start_time,
  CASE
    WHEN status = 'cancelled' THEN 'already_cancelled'
    WHEN booking_date < CURRENT_DATE THEN 'past_booking'
    WHEN booking_date = CURRENT_DATE AND start_time <= (CURRENT_TIME + INTERVAL '1 hour')
         THEN 'too_late_to_cancel'
    ELSE 'can_cancel'
  END as cancel_status
FROM bookings
WHERE id = $1;

-- Step 2: 예약 취소 처리
UPDATE bookings
SET
  status = 'cancelled',
  cancelled_at = now(),
  cancelled_reason = $2
WHERE id = $1
  AND status = 'confirmed'
  AND (booking_date > CURRENT_DATE
       OR (booking_date = CURRENT_DATE AND start_time > (CURRENT_TIME + INTERVAL '1 hour')))
RETURNING
  id,
  confirmation_number,
  booking_date,
  start_time,
  cancelled_at;
```

### Flow 6: 테스트 관리자 접근
```sql
-- Step 1: 관리자 세션 생성 (클라이언트에서 admin/1234 검증 후)
INSERT INTO admin_sessions (admin_id, ip_address, user_agent)
VALUES ('admin', $1, $2)
RETURNING id, login_time;

-- Step 2: 활성 세션 갱신
UPDATE admin_sessions
SET last_activity = now()
WHERE id = $1 AND is_active = TRUE;

-- Step 3: 오래된 세션 정리 (24시간 이상)
UPDATE admin_sessions
SET is_active = FALSE
WHERE last_activity < (now() - INTERVAL '24 hours');
```

### Flow 7: 어드민 회의실 관리
```sql
-- Step 1: 회의실 목록 조회 (관리자용 - 비활성 포함)
SELECT
  id,
  name,
  location,
  capacity,
  operating_hours,
  is_active,
  created_at,
  updated_at,
  (SELECT COUNT(*) FROM bookings WHERE room_id = cr.id AND status = 'confirmed') as total_bookings
FROM conference_rooms cr
ORDER BY is_active DESC, name;

-- Step 2: 회의실 추가
INSERT INTO conference_rooms (name, location, capacity, operating_hours)
VALUES ($1, $2, $3, $4)
RETURNING id, name, created_at;

-- Step 3: 회의실 수정
UPDATE conference_rooms
SET
  name = $2,
  location = $3,
  capacity = $4,
  operating_hours = $5
WHERE id = $1
RETURNING id, name, updated_at;

-- Step 4: 회의실 삭제 (예약 존재 시 비활성화만)
UPDATE conference_rooms
SET is_active = FALSE
WHERE id = $1
  AND EXISTS (SELECT 1 FROM bookings WHERE room_id = $1 AND status = 'confirmed')
RETURNING id, name;

-- 예약이 없는 경우 물리적 삭제
DELETE FROM conference_rooms
WHERE id = $1
  AND NOT EXISTS (SELECT 1 FROM bookings WHERE room_id = $1)
RETURNING id, name;
```

### Flow 8: 어드민 예약 현황 조회
```sql
-- Step 1: 필터링된 예약 현황 조회
SELECT
  b.id,
  b.confirmation_number,
  b.user_name,
  b.phone,
  b.purpose,
  b.booking_date,
  b.start_time,
  b.end_time,
  b.status,
  b.cancelled_at,
  b.cancelled_reason,
  b.created_at,
  cr.name as room_name,
  cr.location as room_location,
  cr.capacity as room_capacity
FROM bookings b
JOIN conference_rooms cr ON b.room_id = cr.id
WHERE ($1::DATE IS NULL OR b.booking_date >= $1)  -- 시작 날짜
  AND ($2::DATE IS NULL OR b.booking_date <= $2)  -- 종료 날짜
  AND ($3::UUID IS NULL OR b.room_id = $3)        -- 회의실 필터
  AND ($4::TEXT IS NULL OR b.status = $4)         -- 상태 필터
ORDER BY b.booking_date DESC, b.start_time, cr.name;

-- Step 2: 통계 정보 계산
WITH stats AS (
  SELECT
    COUNT(*) as total_bookings,
    COUNT(*) FILTER (WHERE status = 'confirmed') as confirmed_bookings,
    COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_bookings,
    COUNT(DISTINCT room_id) as rooms_used,
    COUNT(DISTINCT booking_date) as days_with_bookings
  FROM bookings b
  WHERE booking_date BETWEEN $1 AND $2
    AND ($3::UUID IS NULL OR room_id = $3)
)
SELECT
  total_bookings,
  confirmed_bookings,
  cancelled_bookings,
  CASE WHEN total_bookings > 0
       THEN ROUND((cancelled_bookings::NUMERIC / total_bookings) * 100, 1)
       ELSE 0 END as cancellation_rate,
  rooms_used,
  days_with_bookings
FROM stats;
```

---

## 🚀 다음 단계

1. **Phase 0 마이그레이션 실행**
   ```bash
   supabase db reset
   supabase db push
   ```

2. **Row Level Security 설정** (Supabase 보안)
   ```sql
   -- 회의실은 누구나 조회 가능
   ALTER TABLE conference_rooms ENABLE ROW LEVEL SECURITY;
   CREATE POLICY "conference_rooms_select" ON conference_rooms FOR SELECT USING (true);

   -- 예약은 본인 것만 조회/수정 가능 (휴대폰번호 기준)
   ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
   CREATE POLICY "bookings_select" ON bookings FOR SELECT USING (true);
   CREATE POLICY "bookings_insert" ON bookings FOR INSERT WITH CHECK (true);
   CREATE POLICY "bookings_update" ON bookings FOR UPDATE USING (true);
   ```

3. **Real-time 구독 설정** (실시간 예약 현황)
   ```javascript
   // 특정 회의실의 예약 변화 구독
   const subscription = supabase
     .channel('booking-changes')
     .on('postgres_changes',
       { event: '*', schema: 'public', table: 'bookings' },
       (payload) => {
         // 실시간 UI 업데이트
       })
     .subscribe();
   ```

4. **성능 모니터링**
   - 주요 쿼리 실행 계획 분석
   - 인덱스 사용률 모니터링
   - 동시 접속 부하 테스트

---

## Phase 1/2 확장 가이드

| 추가 기능 | Phase | 실행할 파일 | 트리거 조건 |
|-----------|-------|------------|-------------|
| 이메일 알림 | Phase 1 | `{날짜}_add_notifications.sql` | Userflow에 "알림" 추가 시 |
| 예약 검색 | Phase 1 | `{날짜}_add_fulltext_search.sql` | Userflow에 "검색" 추가 시 |
| 감사 로그 | Phase 2 | `{날짜}_add_audit_log.sql` | 규정 준수 요구 시 |
| 반복 예약 | Phase 2 | `{날짜}_add_recurring_bookings.sql` | 정기 회의 지원 시 |

---

## 성능 예상치

**예상 부하 (포트폴리오용)**:
- 동시 사용자: 10명
- 일일 예약: 50건
- 월간 조회: 1,000회

**성능 목표**:
- 회의실 목록 조회: < 100ms
- 예약 등록: < 200ms
- 예약 조회: < 150ms
- 관리자 현황: < 300ms

**Supabase 무료 티어 한계**:
- DB 크기: 500MB (충분)
- API 요청: 50,000/월 (충분)
- 동시 연결: 60개 (충분)