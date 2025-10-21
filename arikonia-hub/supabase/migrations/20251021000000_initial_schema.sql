-- =====================================================
-- Migration: Initial Schema (v2.0 - 개선 버전)
-- Created: 2025-10-21
-- Description: 유저플로우 기반 최소 스펙 스키마 생성
-- Changes from v1.0:
--   - users.avatar_url 추가 (구글 OAuth 프로필 이미지)
--   - user_subscriptions.started_at 제거 (created_at와 중복)
--   - 인덱스 최적화 (status, expires_at)
--   - handle_new_user() 함수 개선 (avatar_url 자동 저장)
--   - check_project_access() 함수 개선 (project_name 포함)
-- =====================================================

-- =====================================================
-- 기존 테이블/함수 삭제 (Clean Slate)
-- =====================================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_user_subscriptions_updated_at ON public.user_subscriptions;

DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.check_project_access(UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

DROP TABLE IF EXISTS public.user_project_access CASCADE;
DROP TABLE IF EXISTS public.plan_project_access CASCADE;
DROP TABLE IF EXISTS public.user_subscriptions CASCADE;
DROP TABLE IF EXISTS public.projects CASCADE;
DROP TABLE IF EXISTS public.subscription_plans CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- =====================================================
-- 1. users 테이블
-- 목적: 사용자 프로필 정보 저장 (auth.users와 1:1)
-- 관련 플로우: 회원가입, 로그인, 프로필 수정
-- =====================================================

CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,  -- 실명
  nickname TEXT NOT NULL,  -- 닉네임
  birth_date DATE,  -- 생년월일
  country_code TEXT DEFAULT '+82',  -- 국가 코드 (예: +82, +1, +81)
  phone TEXT,  -- 휴대전화번호 (국가코드 포함 전체 번호)
  phone_verified BOOLEAN DEFAULT FALSE,  -- 휴대전화 인증 여부
  avatar_url TEXT,  -- 구글 OAuth 프로필 이미지
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 인덱스: 로그인 시 이메일로 빠른 조회
CREATE UNIQUE INDEX idx_users_email ON public.users(email);

-- 인덱스: 최근 가입자 조회
CREATE INDEX idx_users_created_at ON public.users(created_at DESC);

COMMENT ON TABLE public.users IS '사용자 프로필 정보';
COMMENT ON COLUMN public.users.id IS 'Supabase Auth 사용자 ID와 동일';
COMMENT ON COLUMN public.users.email IS '이메일 주소 (로그인용)';
COMMENT ON COLUMN public.users.nickname IS '닉네임 (2자 이상)';
COMMENT ON COLUMN public.users.avatar_url IS '프로필 이미지 URL (구글 OAuth에서 자동 저장)';

-- =====================================================
-- 2. subscription_plans 테이블
-- 목적: 구독 플랜 정의 (free, basic, premium, enterprise)
-- 관련 플로우: 프로젝트 접근 제어, 플랜 업그레이드
-- =====================================================

CREATE TABLE public.subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  price_monthly INTEGER DEFAULT 0,
  price_yearly INTEGER DEFAULT 0,
  description TEXT,
  features JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.subscription_plans IS '구독 플랜 정의';
COMMENT ON COLUMN public.subscription_plans.name IS '플랜 코드 (free, basic, premium, enterprise)';
COMMENT ON COLUMN public.subscription_plans.display_name IS '한글 표시명 (무료, 베이직, 프리미엄, 엔터프라이즈)';
COMMENT ON COLUMN public.subscription_plans.features IS 'JSONB 형식 기능 목록 (Phase 2 활용)';

-- =====================================================
-- 3. user_subscriptions 테이블
-- 목적: 사용자의 현재 구독 정보
-- 관련 플로우: 프로젝트 접근 제어, 플랜 변경
-- =====================================================

CREATE TABLE public.user_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES public.subscription_plans(id),
  status TEXT NOT NULL DEFAULT 'active',
  expires_at TIMESTAMPTZ,  -- NULL = 무제한 (free, enterprise)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 인덱스: 사용자별 구독 조회
CREATE INDEX idx_user_subscriptions_user_id ON public.user_subscriptions(user_id);

-- ✅ 인덱스 추가: 활성 구독 필터링
CREATE INDEX idx_user_subscriptions_status ON public.user_subscriptions(status);

-- ✅ 인덱스 추가: 만료된 구독 제외
CREATE INDEX idx_user_subscriptions_expires_at ON public.user_subscriptions(expires_at);

-- 제약조건: 구독 상태 값 제한
ALTER TABLE public.user_subscriptions
  ADD CONSTRAINT check_status_values
  CHECK (status IN ('active', 'inactive', 'expired'));

COMMENT ON TABLE public.user_subscriptions IS '사용자 구독 정보';
COMMENT ON COLUMN public.user_subscriptions.status IS 'active: 활성, inactive: 비활성, expired: 만료';
COMMENT ON COLUMN public.user_subscriptions.expires_at IS 'NULL이면 무제한 (free, enterprise)';

-- =====================================================
-- 4. projects 테이블
-- 목적: Arikonia Hub에서 관리하는 프로젝트 정의
-- 관련 플로우: 프로젝트 접근 제어, 프로젝트 카드 표시
-- =====================================================

CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  url TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.projects IS 'Arikonia Hub 관리 프로젝트';
COMMENT ON COLUMN public.projects.code IS '프로젝트 코드 (carelit, temflow, arisper)';
COMMENT ON COLUMN public.projects.is_active IS 'false면 비활성 (준비 중 상태)';

-- =====================================================
-- 5. plan_project_access 테이블
-- 목적: 플랜별 프로젝트 접근 권한 매핑
-- 관련 플로우: 프로젝트 접근 제어 (check_project_access)
-- =====================================================

CREATE TABLE public.plan_project_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES public.subscription_plans(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  access_level TEXT DEFAULT 'full',
  features_enabled JSONB DEFAULT '{}'::jsonb,
  UNIQUE(plan_id, project_id)
);

-- 인덱스: 플랜별 프로젝트 조회
CREATE INDEX idx_plan_project_access_plan_id ON public.plan_project_access(plan_id);

-- 인덱스: 프로젝트별 플랜 조회
CREATE INDEX idx_plan_project_access_project_id ON public.plan_project_access(project_id);

-- 제약조건: 접근 레벨 값 제한
ALTER TABLE public.plan_project_access
  ADD CONSTRAINT check_access_level_values
  CHECK (access_level IN ('full', 'limited'));

COMMENT ON TABLE public.plan_project_access IS '플랜별 프로젝트 접근 권한';
COMMENT ON COLUMN public.plan_project_access.access_level IS 'full: 전체 접근, limited: 제한적 접근';
COMMENT ON COLUMN public.plan_project_access.features_enabled IS 'JSONB 형식 활성화 기능 (예: {"problems_limit": 20})';

-- =====================================================
-- 6. user_project_access 테이블
-- 목적: 사용자별 커스텀 프로젝트 권한 (Phase 2)
-- 관련 플로우: 관리자가 특정 사용자에게 임시 권한 부여
-- =====================================================

CREATE TABLE public.user_project_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  access_level TEXT DEFAULT 'full',
  granted_by UUID REFERENCES public.users(id),
  granted_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,  -- NULL = 무제한
  UNIQUE(user_id, project_id)
);

COMMENT ON TABLE public.user_project_access IS '사용자별 커스텀 프로젝트 권한 (Phase 2)';
COMMENT ON COLUMN public.user_project_access.granted_by IS '권한 부여자 (관리자 ID)';

-- =====================================================
-- RLS (Row Level Security) 활성화
-- =====================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plan_project_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_project_access ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS 정책 생성
-- =====================================================

-- users: 자신의 프로필만 조회/수정
CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- subscription_plans: 모든 사용자가 플랜 목록 조회 가능
CREATE POLICY "Anyone can view plans"
  ON public.subscription_plans FOR SELECT
  USING (true);

-- user_subscriptions: 자신의 구독 정보만 조회
CREATE POLICY "Users can view own subscription"
  ON public.user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- projects: 활성화된 프로젝트만 모든 사용자가 조회 가능
CREATE POLICY "Anyone can view active projects"
  ON public.projects FOR SELECT
  USING (is_active = true);

-- plan_project_access: 모든 사용자가 플랜별 권한 조회 가능
CREATE POLICY "Anyone can view plan access"
  ON public.plan_project_access FOR SELECT
  USING (true);

-- user_project_access: 자신의 커스텀 권한만 조회
CREATE POLICY "Users can view own project access"
  ON public.user_project_access FOR SELECT
  USING (auth.uid() = user_id);

-- =====================================================
-- 초기 데이터 삽입
-- =====================================================

-- 구독 플랜
INSERT INTO public.subscription_plans (name, display_name, price_monthly, price_yearly, description, features) VALUES
('free', '무료', 0, 0, '기본 학습 기능을 무료로 체험하세요',
  '{"max_projects": 1, "features": ["basic_access"]}'::jsonb),

('basic', '베이직', 9900, 99000, '1개 프로젝트 전체 이용',
  '{"max_projects": 1, "features": ["full_access", "statistics", "srs"]}'::jsonb),

('premium', '프리미엄', 19900, 199000, '모든 프로젝트 이용',
  '{"max_projects": 99, "features": ["full_access", "statistics", "srs", "priority_support"]}'::jsonb),

('enterprise', '엔터프라이즈', 0, 0, '기관용 맞춤 솔루션',
  '{"max_projects": 99, "features": ["full_access", "admin", "custom"]}'::jsonb);

-- 프로젝트
INSERT INTO public.projects (code, name, description, url) VALUES
('carelit', 'Care-Lit', '돌봄을 위한 지식의 빛 - 의학 및 간호학 학습', 'https://carelit.arikonia.com'),
('temflow', 'Tem-Flow', '내 몸을 성전처럼 - 헬스 및 운동 관리', 'https://temflow.arikonia.com'),
('arisper', 'Arisper', '아름다운 속삭임 - 언어 학습', 'https://arisper.arikonia.com');

-- 플랜별 프로젝트 접근 권한
DO $$
DECLARE
  free_plan_id UUID;
  basic_plan_id UUID;
  premium_plan_id UUID;
  enterprise_plan_id UUID;
  carelit_id UUID;
  temflow_id UUID;
  arisper_id UUID;
BEGIN
  -- 플랜 ID 가져오기
  SELECT id INTO free_plan_id FROM public.subscription_plans WHERE name = 'free';
  SELECT id INTO basic_plan_id FROM public.subscription_plans WHERE name = 'basic';
  SELECT id INTO premium_plan_id FROM public.subscription_plans WHERE name = 'premium';
  SELECT id INTO enterprise_plan_id FROM public.subscription_plans WHERE name = 'enterprise';

  -- 프로젝트 ID 가져오기
  SELECT id INTO carelit_id FROM public.projects WHERE code = 'carelit';
  SELECT id INTO temflow_id FROM public.projects WHERE code = 'temflow';
  SELECT id INTO arisper_id FROM public.projects WHERE code = 'arisper';

  -- Free: Care-Lit 제한적 (20문제)
  INSERT INTO public.plan_project_access (plan_id, project_id, access_level, features_enabled)
  VALUES (free_plan_id, carelit_id, 'limited', '{"problems_limit": 20}'::jsonb);

  -- Basic: Care-Lit 전체
  INSERT INTO public.plan_project_access (plan_id, project_id, access_level)
  VALUES (basic_plan_id, carelit_id, 'full');

  -- Premium: 모든 프로젝트 전체
  INSERT INTO public.plan_project_access (plan_id, project_id, access_level)
  VALUES
    (premium_plan_id, carelit_id, 'full'),
    (premium_plan_id, temflow_id, 'full'),
    (premium_plan_id, arisper_id, 'full');

  -- Enterprise: 모든 프로젝트 + 관리자 권한
  INSERT INTO public.plan_project_access (plan_id, project_id, access_level, features_enabled)
  VALUES
    (enterprise_plan_id, carelit_id, 'full', '{"admin": true}'::jsonb),
    (enterprise_plan_id, temflow_id, 'full', '{"admin": true}'::jsonb),
    (enterprise_plan_id, arisper_id, 'full', '{"admin": true}'::jsonb);
END $$;

-- =====================================================
-- 함수 1: handle_new_user()
-- 목적: auth.users 생성 시 자동으로 public.users와 구독 생성
-- 트리거: AFTER INSERT ON auth.users
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_plan_id UUID;
  v_plan_name TEXT;
  v_nickname TEXT;
  v_avatar_url TEXT;
BEGIN
  -- Admin 이메일 확인
  IF NEW.email = 'tkandpf18@naver.com' THEN
    v_plan_name := 'enterprise';
  ELSE
    v_plan_name := 'free';
  END IF;

  -- 플랜 ID 가져오기
  SELECT id INTO v_plan_id FROM public.subscription_plans WHERE name = v_plan_name;

  -- 닉네임 우선순위: nickname > full_name > name > 이메일 앞부분
  v_nickname := COALESCE(
    NEW.raw_user_meta_data->>'nickname',
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    split_part(NEW.email, '@', 1)
  );

  -- ✅ 개선: 프로필 이미지 (구글 OAuth에서 자동 저장)
  v_avatar_url := NEW.raw_user_meta_data->>'avatar_url';

  -- 프로필 생성 (name과 nickname 모두 v_nickname 사용, OAuth는 실명 없음)
  INSERT INTO public.users (id, email, name, nickname, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    v_nickname,  -- OAuth 사용자는 name도 nickname으로 채움
    v_nickname,
    v_avatar_url
  );

  -- 구독 할당
  IF v_plan_id IS NOT NULL THEN
    INSERT INTO public.user_subscriptions (user_id, plan_id, status)
    VALUES (NEW.id, v_plan_id, 'active');
  END IF;

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.handle_new_user() IS '신규 사용자 자동 프로필 및 구독 생성';

-- 트리거 생성
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 함수 2: check_project_access()
-- 목적: 사용자의 프로젝트 접근 권한 확인
-- 매개변수:
--   - p_user_id: 사용자 ID
--   - p_project_code: 프로젝트 코드 ('carelit', 'temflow', 'arisper')
-- 반환값: JSONB {has_access, access_level, reason, ...}
-- =====================================================

CREATE OR REPLACE FUNCTION public.check_project_access(
  p_user_id UUID,
  p_project_code TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_subscription RECORD;
  v_plan_access RECORD;
  v_custom_access RECORD;
  v_project RECORD;
BEGIN
  -- 1. 프로젝트 조회 (is_active 체크)
  SELECT id, name, is_active
  INTO v_project
  FROM public.projects
  WHERE code = p_project_code;

  -- 프로젝트 존재 여부
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'has_access', false,
      'reason', 'project_not_found'
    );
  END IF;

  -- 프로젝트 비활성
  IF v_project.is_active = false THEN
    RETURN jsonb_build_object(
      'has_access', false,
      'reason', 'project_inactive',
      'project_name', v_project.name
    );
  END IF;

  -- 2. 커스텀 접근 권한 확인 (최우선)
  SELECT *
  INTO v_custom_access
  FROM public.user_project_access
  WHERE user_id = p_user_id
    AND project_id = v_project.id
    AND (expires_at IS NULL OR expires_at > NOW());

  IF FOUND THEN
    RETURN jsonb_build_object(
      'has_access', true,
      'access_level', v_custom_access.access_level,
      'source', 'custom',
      'project_name', v_project.name
    );
  END IF;

  -- 3. 구독 플랜 확인
  SELECT us.*, sp.name as plan_name, sp.display_name
  INTO v_subscription
  FROM public.user_subscriptions us
  JOIN public.subscription_plans sp ON us.plan_id = sp.id
  WHERE us.user_id = p_user_id
    AND us.status = 'active'
    AND (us.expires_at IS NULL OR us.expires_at > NOW())
  ORDER BY us.created_at DESC
  LIMIT 1;

  -- 활성 구독 없음
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'has_access', false,
      'reason', 'no_active_subscription',
      'project_name', v_project.name
    );
  END IF;

  -- 4. 플랜별 프로젝트 접근 권한
  SELECT *
  INTO v_plan_access
  FROM public.plan_project_access
  WHERE plan_id = v_subscription.plan_id
    AND project_id = v_project.id;

  -- 플랜에 프로젝트 포함됨
  IF FOUND THEN
    RETURN jsonb_build_object(
      'has_access', true,
      'access_level', v_plan_access.access_level,
      'features_enabled', v_plan_access.features_enabled,
      'plan_name', v_subscription.display_name,
      'source', 'subscription',
      'project_name', v_project.name
    );
  END IF;

  -- 플랜에 프로젝트 미포함
  RETURN jsonb_build_object(
    'has_access', false,
    'reason', 'plan_does_not_include_project',
    'current_plan', v_subscription.display_name,
    'required_plan', 'premium',
    'project_name', v_project.name
  );
END;
$$;

COMMENT ON FUNCTION public.check_project_access(UUID, TEXT) IS '사용자의 프로젝트 접근 권한 확인';

-- =====================================================
-- 함수 3: update_updated_at_column()
-- 목적: updated_at 컬럼 자동 갱신
-- 트리거: BEFORE UPDATE ON users, user_subscriptions
-- =====================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.update_updated_at_column() IS 'updated_at 컬럼 자동 갱신';

-- 트리거 생성
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_subscriptions_updated_at
  BEFORE UPDATE ON public.user_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- Migration 완료
-- =====================================================

-- 검증 쿼리 (실행하지 않음, 참고용)
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;
-- SELECT name, display_name FROM subscription_plans;
-- SELECT code, name FROM projects;
-- SELECT public.check_project_access((SELECT id FROM users LIMIT 1), 'carelit');

COMMENT ON SCHEMA public IS 'Arikonia Hub 초기 스키마 v2.0 (2025-10-21)';
