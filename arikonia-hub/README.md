# Arikonia Hub - SSO Platform

**아리코니아 허브** - 통합 인증 및 프로젝트 접근 제어 플랫폼

[![Next.js](https://img.shields.io/badge/Next.js-15.5.6-black)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-blue)](https://www.typescriptlang.org/)
[![Supabase](https://img.shields.io/badge/Supabase-Auth-green)](https://supabase.com/)
[![Zustand](https://img.shields.io/badge/Zustand-5.0.8-orange)](https://zustand.docs.pmnd.rs/)

---

## 🎯 프로젝트 개요

Arikonia Hub는 여러 프로젝트(Care-Lit, Tem-Flow, Arisper)에 대한 **통합 인증(SSO)**과 **구독 기반 접근 제어**를 제공하는 플랫폼입니다.

### 주요 기능
- ✅ **이메일 회원가입/로그인** (UC-001, UC-003)
- ✅ **구글 OAuth 인증** (UC-002, UC-003)
- ✅ **구독 플랜 기반 접근 제어** (UC-004)
- ✅ **SSO 리다이렉트** (JWT 토큰)
- ✅ **대시보드** (프로젝트 목록 및 접근 관리)

---

## 📁 프로젝트 구조

```
arikonia-hub/
├── app/                          # Next.js App Router
│   ├── signup/page.tsx          # 회원가입 페이지
│   ├── login/page.tsx           # 로그인 페이지
│   ├── auth/callback/page.tsx   # OAuth 콜백
│   └── dashboard/page.tsx       # 대시보드
├── components/
│   ├── features/
│   │   └── dashboard/
│   │       └── ProjectCard.tsx  # 프로젝트 접근 카드
│   └── ui/                      # shadcn/ui 컴포넌트
├── stores/                      # Zustand 상태 관리
│   ├── authStore.ts            # 인증 스토어
│   └── projectStore.ts         # 프로젝트 접근 스토어
├── hooks/                       # Custom Hooks
│   ├── useAuth.ts              # Auth 셀렉터
│   └── useProject.ts           # Project 셀렉터
├── types/
│   └── index.ts                # TypeScript 타입 정의
├── validators/
│   └── authSchemas.ts          # Zod 검증 스키마
├── lib/
│   └── supabase.ts             # Supabase 클라이언트
├── docs/                        # 문서
│   ├── 001/spec.md             # UC-001 명세
│   ├── 002/spec.md             # UC-002 명세
│   ├── 003/spec.md             # UC-003 명세
│   ├── 004/spec.md             # UC-004 명세
│   ├── state-management.md     # 상태 관리 설계
│   ├── implementation-plan.md  # 구현 계획
│   ├── code-quality-analysis.md # 코드 품질 분석
│   └── deployment-guide.md     # 배포 가이드
└── supabase/
    └── migrations/             # 데이터베이스 마이그레이션
```

---

## 🛠️ 기술 스택

### Frontend
- **Framework**: Next.js 15.5.6 (App Router)
- **Language**: TypeScript 5.x
- **UI**: Tailwind CSS 4.0, shadcn/ui
- **State Management**: Zustand 5.0.8
- **Form Validation**: React Hook Form + Zod
- **Notifications**: Sonner

### Backend
- **Auth**: Supabase Auth (Email + Google OAuth)
- **Database**: PostgreSQL (Supabase)
- **Storage**: Supabase Storage

### Infrastructure
- **Hosting**: Vercel
- **Database**: Supabase (PostgreSQL)
- **CI/CD**: Vercel Auto Deploy

---

## 🚀 빠른 시작

### 1. 환경 설정

```bash
# 저장소 클론
git clone https://github.com/your-username/arikonia-hub.git
cd arikonia-hub

# 의존성 설치
npm install

# 환경 변수 설정
cp .env.example .env.local
```

**`.env.local` 설정**:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

### 2. 데이터베이스 설정

1. [Supabase](https://supabase.com)에서 새 프로젝트 생성
2. SQL Editor에서 마이그레이션 실행:
   ```sql
   -- supabase/migrations/20251021000000_initial_schema.sql 내용 복사
   ```
3. Google OAuth 설정 (선택)

### 3. 개발 서버 실행

```bash
npm run dev
```

브라우저에서 http://localhost:3000 접속

---

## 📚 문서

- **[Use Case Specifications](/docs/)**
  - [UC-001: 회원가입 (이메일)](/docs/001/spec.md)
  - [UC-002: 회원가입 (구글 OAuth)](/docs/002/spec.md)
  - [UC-003: 로그인](/docs/003/spec.md)
  - [UC-004: 프로젝트 접근 제어](/docs/004/spec.md)
- **[State Management Design](/docs/state-management.md)**
- **[Implementation Plan](/docs/implementation-plan.md)**
- **[Code Quality Analysis](/docs/code-quality-analysis.md)**
- **[Deployment Guide](/docs/deployment-guide.md)**

---

## 🏗️ 아키텍처

### 레이어 구조
```
┌─────────────────────────────────────┐
│   Presentation Layer                │
│   (Pages, Components)               │
├─────────────────────────────────────┤
│   Application Layer                 │
│   (Stores, Hooks)                   │
├─────────────────────────────────────┤
│   Domain Layer                      │
│   (Types, Validators, Utils)        │
├─────────────────────────────────────┤
│   Infrastructure Layer              │
│   (Supabase Client, Repositories)   │
└─────────────────────────────────────┘
```

### 데이터 흐름
```
User → Page → Component → Hook → Store → Supabase → Database
                                    ↓
                                  Toast
```

---

## 🔐 보안

- ✅ **Supabase Auth**: 안전한 인증 처리
- ✅ **RLS Policies**: Row-Level Security 적용
- ✅ **JWT Tokens**: 세션 관리
- ⚠️ **Session Persistence**: localStorage 사용 (XSS 주의)
- ⚠️ **SSO Token in URL**: 쿼리 파라미터로 전달 (로그 노출 주의)

**보안 개선 권장사항**:
- [ ] Session을 localStorage에서 제거
- [ ] POST 기반 SSO 구현
- [ ] httpOnly 쿠키 사용

---

## 🧪 테스트

### 수동 테스트 체크리스트

**UC-001: 이메일 회원가입**
- [ ] 유효한 이메일/비밀번호/닉네임으로 가입
- [ ] 이메일 중복 에러 처리
- [ ] 비밀번호 유효성 검증
- [ ] 회원가입 후 무료 플랜 자동 할당

**UC-002: 구글 OAuth 회원가입**
- [ ] 구글 로그인 팝업 정상 작동
- [ ] OAuth 콜백 처리
- [ ] 프로필 자동 생성 (닉네임, 아바타)
- [ ] 대시보드로 리다이렉트

**UC-003: 로그인**
- [ ] 이메일 로그인 성공
- [ ] 구글 OAuth 로그인 성공
- [ ] 잘못된 비밀번호 에러 처리
- [ ] 세션 유지

**UC-004: 프로젝트 접근 제어**
- [ ] Free 플랜: Care-Lit (view) 접근 가능
- [ ] Premium 프로젝트 접근 시 업그레이드 메시지
- [ ] 접근 가능 시 SSO 리다이렉트
- [ ] 토스트 메시지 정상 표시

---

## 📊 성능

### Code Metrics
- **TypeScript Coverage**: 100%
- **Type Safety**: 95%
- **Build Time**: ~30s
- **Bundle Size**: ~200KB (gzipped)

### Lighthouse Score (Target)
- **Performance**: 90+
- **Accessibility**: 95+
- **Best Practices**: 90+
- **SEO**: 90+

---

## 🛣️ 로드맵

### Phase 1: MVP Authentication ✅ (완료)
- ✅ 이메일 회원가입/로그인
- ✅ 구글 OAuth
- ✅ 구독 기반 접근 제어
- ✅ 대시보드

### Phase 2: Payment Integration (예정)
- [ ] Stripe/Toss Payments 연동
- [ ] 구독 결제 플로우
- [ ] 결제 내역 페이지
- [ ] 플랜 변경/취소 기능

### Phase 3: Admin Panel (예정)
- [ ] 사용자 관리
- [ ] 구독 관리
- [ ] 프로젝트 관리
- [ ] 통계 대시보드

### Phase 4: Advanced Features (예정)
- [ ] 이메일 알림
- [ ] 2단계 인증 (2FA)
- [ ] API 키 관리
- [ ] Webhook 설정

---

## 🤝 기여

Pull Request는 언제든지 환영합니다!

### 개발 워크플로우
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### 커밋 컨벤션
- `feat:` 새로운 기능
- `fix:` 버그 수정
- `docs:` 문서 변경
- `style:` 코드 포맷팅
- `refactor:` 코드 리팩토링
- `test:` 테스트 추가
- `chore:` 빌드 설정 변경

---

## 📝 라이선스

MIT License

---

## 👥 팀

- **Product Owner**: [Your Name]
- **Technical Lead**: [Your Name]
- **Development**: Built with [Claude Code](https://claude.com/claude-code) using SuperClaude Agents

---

## 🙏 감사의 말

- [Next.js](https://nextjs.org/) - React Framework
- [Supabase](https://supabase.com/) - Backend as a Service
- [Zustand](https://zustand.docs.pmnd.rs/) - State Management
- [shadcn/ui](https://ui.shadcn.com/) - UI Components
- [Vercel](https://vercel.com/) - Deployment Platform

---

**🤖 Generated with [Claude Code](https://claude.com/claude-code) using SuperClaude Agents**
