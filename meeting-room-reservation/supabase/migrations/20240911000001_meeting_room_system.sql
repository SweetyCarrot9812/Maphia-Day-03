-- 회의실 예약 시스템 데이터베이스 스키마
-- RLS Policy 비활성화

-- 1. 회의실 테이블
CREATE TABLE rooms (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200) NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. 예약 테이블
CREATE TABLE reservations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
    reserver_name VARCHAR(50) NOT NULL,
    reserver_phone VARCHAR(20) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    title VARCHAR(200) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

-- 시간 충돌 방지를 위한 인덱스
CREATE INDEX idx_reservations_room_time ON reservations(room_id, start_time, end_time);
CREATE INDEX idx_reservations_phone ON reservations(reserver_phone);

-- RLS Policy 비활성화
ALTER TABLE rooms DISABLE ROW LEVEL SECURITY;
ALTER TABLE reservations DISABLE ROW LEVEL SECURITY;

-- 예약 시간 충돌 검사 함수
CREATE OR REPLACE FUNCTION check_reservation_conflict(
    p_room_id UUID,
    p_start_time TIMESTAMP WITH TIME ZONE,
    p_end_time TIMESTAMP WITH TIME ZONE,
    p_exclude_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM reservations
        WHERE room_id = p_room_id
        AND (p_exclude_id IS NULL OR id != p_exclude_id)
        AND (
            (start_time <= p_start_time AND end_time > p_start_time) OR
            (start_time < p_end_time AND end_time >= p_end_time) OR
            (start_time >= p_start_time AND end_time <= p_end_time)
        )
    );
END;
$$ LANGUAGE plpgsql;

-- 테스트용 더미 데이터 insert

-- 회의실 데이터
INSERT INTO rooms (id, name, location, capacity, description) VALUES
('550e8400-e29b-41d4-a716-446655440000', '대회의실', '1층', 20, '프레젠테이션용 대형 스크린과 화상회의 시설이 완비된 메인 회의실입니다.'),
('550e8400-e29b-41d4-a716-446655440001', '소회의실 A', '2층', 8, '팀 미팅과 브레인스토밍에 최적화된 아늑한 공간입니다.'),
('550e8400-e29b-41d4-a716-446655440002', '소회의실 B', '2층', 6, '집중적인 토론과 워크샵을 위한 조용한 환경의 회의실입니다.'),
('550e8400-e29b-41d4-a716-446655440003', '화상회의실', '3층', 12, '최신 화상회의 장비와 고화질 디스플레이가 구비된 원격 회의 전용실입니다.'),
('550e8400-e29b-41d4-a716-446655440004', '세미나실', '1층', 30, '대규모 교육 및 세미나를 위한 강의실형 회의실입니다.');

-- 테스트용 예약 데이터 (현재 날짜 기준)
INSERT INTO reservations (room_id, reserver_name, reserver_phone, password_hash, title, start_time, end_time) VALUES
(
    '550e8400-e29b-41d4-a716-446655440000',
    '김철수',
    '01012345678',
    '1234',
    '프로젝트 킥오프 미팅',
    CURRENT_DATE + INTERVAL '14 hours',
    CURRENT_DATE + INTERVAL '16 hours'
),
(
    '550e8400-e29b-41d4-a716-446655440001',
    '이영희',
    '01098765432',
    'test123',
    '팀 회의',
    CURRENT_DATE + INTERVAL '10 hours',
    CURRENT_DATE + INTERVAL '11 hours'
),
(
    '550e8400-e29b-41d4-a716-446655440000',
    '박민수',
    '01055556666',
    'meeting2024',
    '고객 미팅',
    CURRENT_DATE + INTERVAL '1 day' + INTERVAL '9 hours',
    CURRENT_DATE + INTERVAL '1 day' + INTERVAL '10 hours'
);