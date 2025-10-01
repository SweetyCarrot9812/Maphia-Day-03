-- ============================================
-- 블로그 체험단 SaaS - Database Schema
-- PostgreSQL + Supabase
-- ============================================

-- ============================================
-- 1. Auth & Core Profiles
-- ============================================

-- Supabase auth.users 테이블 사용 (built-in)
-- id (uuid), email, phone, created_at 등 제공

-- 기본 프로필 (모든 사용자 공통)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('influencer', 'advertiser')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 약관 동의 이력
CREATE TABLE terms_agreements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  terms_version VARCHAR(20) NOT NULL,
  agreed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ip_address INET
);

-- ============================================
-- 2. Influencer Tables
-- ============================================

-- 인플루언서 상세 프로필
CREATE TABLE influencer_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  birth_date DATE NOT NULL,
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- SNS 채널 정보
CREATE TABLE influencer_channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  influencer_id UUID NOT NULL REFERENCES influencer_profiles(id) ON DELETE CASCADE,
  channel_type VARCHAR(50) NOT NULL, -- 'instagram', 'youtube', 'blog' 등
  channel_name VARCHAR(255) NOT NULL,
  channel_url TEXT NOT NULL,
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  verification_status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (verification_status IN ('pending', 'verified', 'failed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 3. Advertiser Tables
-- ============================================

-- 광고주 상세 프로필
CREATE TABLE advertiser_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  business_name VARCHAR(255) NOT NULL,
  business_location TEXT NOT NULL,
  business_category VARCHAR(100) NOT NULL,
  business_registration_number VARCHAR(50) NOT NULL UNIQUE,
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  verification_status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (verification_status IN ('pending', 'verified', 'failed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 4. Campaign Tables
-- ============================================

-- 체험단 캠페인
CREATE TABLE campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  advertiser_id UUID NOT NULL REFERENCES advertiser_profiles(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  benefits TEXT NOT NULL, -- 혜택 내용
  mission TEXT NOT NULL, -- 미션 내용
  store_location TEXT NOT NULL, -- 매장 위치
  recruitment_start TIMESTAMPTZ NOT NULL,
  recruitment_end TIMESTAMPTZ NOT NULL,
  max_participants INTEGER NOT NULL, -- 모집 인원
  status VARCHAR(20) NOT NULL DEFAULT 'recruiting'
    CHECK (status IN ('recruiting', 'closed', 'selected', 'completed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 체험단 지원
CREATE TABLE applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  influencer_id UUID NOT NULL REFERENCES influencer_profiles(id) ON DELETE CASCADE,
  motivation TEXT NOT NULL, -- 각오 한마디
  visit_date DATE NOT NULL, -- 방문 예정일자
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'selected', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(campaign_id, influencer_id) -- 중복 지원 방지
);

-- ============================================
-- 5. Verification Jobs (비동기 검증)
-- ============================================

CREATE TABLE verification_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type VARCHAR(50) NOT NULL, -- 'influencer_channel', 'advertiser_business'
  entity_id UUID NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  result JSONB, -- 검증 결과 상세 정보
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 6. Indexes for Performance
-- ============================================

-- Profiles
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_email ON profiles(email);

-- Influencer
CREATE INDEX idx_influencer_profiles_user_id ON influencer_profiles(user_id);
CREATE INDEX idx_influencer_channels_influencer_id ON influencer_channels(influencer_id);
CREATE INDEX idx_influencer_channels_verification_status ON influencer_channels(verification_status);

-- Advertiser
CREATE INDEX idx_advertiser_profiles_user_id ON advertiser_profiles(user_id);
CREATE INDEX idx_advertiser_profiles_verification_status ON advertiser_profiles(verification_status);

-- Campaigns
CREATE INDEX idx_campaigns_advertiser_id ON campaigns(advertiser_id);
CREATE INDEX idx_campaigns_status ON campaigns(status);
CREATE INDEX idx_campaigns_recruitment_period ON campaigns(recruitment_start, recruitment_end);

-- Applications
CREATE INDEX idx_applications_campaign_id ON applications(campaign_id);
CREATE INDEX idx_applications_influencer_id ON applications(influencer_id);
CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_applications_created_at ON applications(created_at DESC);

-- Verification Jobs
CREATE INDEX idx_verification_jobs_entity ON verification_jobs(entity_type, entity_id);
CREATE INDEX idx_verification_jobs_status ON verification_jobs(status);

-- ============================================
-- 7. Row Level Security (RLS) - Supabase
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE terms_agreements ENABLE ROW LEVEL SECURITY;
ALTER TABLE influencer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE influencer_channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE advertiser_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_jobs ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can read/update their own profile
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Influencer Profiles: Users can manage their own
CREATE POLICY "Influencers can manage own profile" ON influencer_profiles
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Influencers can manage own channels" ON influencer_channels
  FOR ALL USING (
    influencer_id IN (
      SELECT id FROM influencer_profiles WHERE user_id = auth.uid()
    )
  );

-- Advertiser Profiles: Users can manage their own
CREATE POLICY "Advertisers can manage own profile" ON advertiser_profiles
  FOR ALL USING (auth.uid() = user_id);

-- Campaigns: Advertisers manage their own, everyone can read recruiting ones
CREATE POLICY "Anyone can view recruiting campaigns" ON campaigns
  FOR SELECT USING (status = 'recruiting');

CREATE POLICY "Advertisers can manage own campaigns" ON campaigns
  FOR ALL USING (
    advertiser_id IN (
      SELECT id FROM advertiser_profiles WHERE user_id = auth.uid()
    )
  );

-- Applications: Influencers manage their own, advertisers see applications to their campaigns
CREATE POLICY "Influencers can manage own applications" ON applications
  FOR ALL USING (
    influencer_id IN (
      SELECT id FROM influencer_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Advertisers can view applications to own campaigns" ON applications
  FOR SELECT USING (
    campaign_id IN (
      SELECT c.id FROM campaigns c
      JOIN advertiser_profiles ap ON c.advertiser_id = ap.id
      WHERE ap.user_id = auth.uid()
    )
  );

CREATE POLICY "Advertisers can update applications to own campaigns" ON applications
  FOR UPDATE USING (
    campaign_id IN (
      SELECT c.id FROM campaigns c
      JOIN advertiser_profiles ap ON c.advertiser_id = ap.id
      WHERE ap.user_id = auth.uid()
    )
  );

-- ============================================
-- 8. Triggers for updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_influencer_profiles_updated_at
  BEFORE UPDATE ON influencer_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_influencer_channels_updated_at
  BEFORE UPDATE ON influencer_channels
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_advertiser_profiles_updated_at
  BEFORE UPDATE ON advertiser_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaigns_updated_at
  BEFORE UPDATE ON campaigns
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_applications_updated_at
  BEFORE UPDATE ON applications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_verification_jobs_updated_at
  BEFORE UPDATE ON verification_jobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
