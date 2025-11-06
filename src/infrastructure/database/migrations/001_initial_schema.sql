-- @SPEC:DB-001 Initial Database Schema Migration
-- Conference Room Booking System - Phase 0 Core Tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Conference Rooms Table
CREATE TABLE public.conference_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    capacity INTEGER NOT NULL CHECK (capacity > 0 AND capacity <= 100),
    amenities TEXT[] DEFAULT '{}',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- Bookings Table
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID NOT NULL REFERENCES public.conference_rooms(id) ON DELETE CASCADE,
    user_name VARCHAR(100) NOT NULL,
    user_phone VARCHAR(20) NOT NULL,
    purpose TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),

    -- Business rule constraints
    CONSTRAINT valid_time_range CHECK (start_time < end_time),
    CONSTRAINT valid_duration CHECK (
        EXTRACT(EPOCH FROM (end_time - start_time)) / 3600 >= 0.5 AND
        EXTRACT(EPOCH FROM (end_time - start_time)) / 3600 <= 8
    ),
    CONSTRAINT no_past_bookings CHECK (start_time > created_at)
);

-- Admin Sessions Table
CREATE TABLE public.admin_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- Indexes for performance
CREATE INDEX idx_conference_rooms_active ON public.conference_rooms(is_active);
CREATE INDEX idx_conference_rooms_capacity ON public.conference_rooms(capacity);

CREATE INDEX idx_bookings_room_id ON public.bookings(room_id);
CREATE INDEX idx_bookings_time_range ON public.bookings(start_time, end_time);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_bookings_user_phone ON public.bookings(user_phone);

CREATE INDEX idx_admin_sessions_admin_id ON public.admin_sessions(admin_id);
CREATE INDEX idx_admin_sessions_active ON public.admin_sessions(is_active);

-- Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc', now());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_conference_rooms_updated_at
    BEFORE UPDATE ON public.conference_rooms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
    BEFORE UPDATE ON public.bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
ALTER TABLE public.conference_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_sessions ENABLE ROW LEVEL SECURITY;

-- Public read access for conference rooms
CREATE POLICY "Allow public read access to active conference rooms" ON public.conference_rooms
    FOR SELECT USING (is_active = true);

-- Public insert/update for bookings (real users)
CREATE POLICY "Allow public insert access to bookings" ON public.bookings
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow users to view their own bookings" ON public.bookings
    FOR SELECT USING (true);

CREATE POLICY "Allow users to update their own bookings" ON public.bookings
    FOR UPDATE USING (status = 'confirmed');

-- Admin-only access for admin sessions (will be configured with admin role)
CREATE POLICY "Restrict admin sessions access" ON public.admin_sessions
    FOR ALL USING (false);

-- Initial seed data
INSERT INTO public.conference_rooms (name, capacity, amenities) VALUES
    ('Meeting Room A', 8, ARRAY['projector', 'whiteboard', 'video_conference']),
    ('Meeting Room B', 12, ARRAY['projector', 'whiteboard']),
    ('Conference Hall', 30, ARRAY['projector', 'sound_system', 'video_conference', 'catering_ready']),
    ('Small Discussion Room', 4, ARRAY['whiteboard']);

-- Create default admin account (password: admin123)
INSERT INTO public.admin_sessions (admin_id, password_hash) VALUES
    ('admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;