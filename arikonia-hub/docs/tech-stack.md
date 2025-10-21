# Arikonia Hub - 기술 스택 문서

## 문서 정보
- **작성일**: 2025-01-20
- **버전**: 1.0
- **프로젝트**: Arikonia Hub (통합 SSO 플랫폼)
- **관련 문서**: [PRD](./prd.md), [Userflow](./userflow.md)

---

## 선정된 기술 스택 (현재)

### 전체 스택 개요

```
[Next.js 15 Frontend] ← HTTPS → [Supabase Backend]
        ↓                              ↓
    [Vercel]                    [PostgreSQL + Auth]
        ↓                              ↓
  [Tailwind CSS 4]              [Row Level Security]
```

**스택명**: **"Next.js + Supabase + Vercel"** (Serverless Full-Stack)

---

## Frontend

### 🥇 Next.js 15.5.6

**선정 이유**:
- 🤖 **AI 친화성**: ⭐⭐⭐⭐⭐ (5/5)
  - GitHub Stars: 130k+
  - npm 주간 다운로드: 6M+
  - Stack Overflow 질문: 100k+
  - 공식 문서: 매우 상세하고 최신 (App Router 완벽 설명)
  - AI 학습 데이터: 방대한 코드 예제와 튜토리얼

- 🔧 **유지보수성**: ⭐⭐⭐⭐⭐ (5/5)
  - 메인 스폰서: **Vercel** (기업 후원)
  - 릴리즈 주기: 안정적 (6-8주)
  - 보안 대응: 매우 빠름
  - LTS 지원: Major 버전마다 장기 지원

- 📊 **안정성**: ⭐⭐⭐⭐⭐ (5/5)
  - 하위 호환성: 우수 (Codemod 제공)
  - Breaking Changes: 연 1-2회 (Major 버전만)
  - 프로덕션 검증: 7년+ (React 기반)
  - TypeScript 지원: First-class citizen

**주요 장점**:
- **App Router**: React Server Components (RSC) 네이티브 지원
- **파일 기반 라우팅**: 직관적인 페이지 구조
- **자동 최적화**: 이미지, 폰트, 번들 최적화 자동
- **서버리스 API Routes**: 별도 백엔드 불필요
- **Vercel 완벽 통합**: 자동 배포, Edge Functions
- **SEO 최적화**: SSR, SSG, ISR 자유롭게 선택

**고려사항**:
- App Router가 비교적 최신 (2023년 안정화)
- 러닝 커브: 초보자에게는 다소 가파름
- 번들 크기: 기본 설정에서 React 포함 시 큼

**생태계**:
- **UI 프레임워크**: shadcn/ui (Radix UI 기반) ✅
- **스타일링**: Tailwind CSS 4 ✅
- **상태관리**: Zustand 5.0.8 ✅
- **폼**: React Hook Form + Zod ✅
- **라우팅**: 내장 App Router ✅

---

### 🎨 Tailwind CSS 4.0

**선정 이유**:
- 🤖 **AI 친화성**: ⭐⭐⭐⭐⭐ (5/5)
  - npm 다운로드: 20M+ /주
  - 클래스 기반: AI가 쉽게 생성 가능
  - 문서: 매우 체계적

- 🔧 **유지보수성**: ⭐⭐⭐⭐⭐ (5/5)
  - 스폰서: Tailwind Labs
  - 버전 4 안정화 (2024)

- 📊 **안정성**: ⭐⭐⭐⭐ (4/5)
  - v4는 신규 엔진 (Oxide)
  - 하위 호환성 우수

**주요 장점**:
- **Utility-First**: HTML에서 직접 스타일링
- **다크모드**: `class` 전략으로 간단 구현 ✅
- **반응형**: 모바일 우선 설계
- **JIT 컴파일**: 빠른 빌드
- **Purge CSS**: 프로덕션 번들 최소화

**Tailwind CSS 4 변경점**:
- `@import "tailwindcss"` 구문 (v3과 다름)
- `@tailwindcss/postcss` 플러그인 필요
- 성능 향상 (Oxide 엔진)

---

### 🧩 shadcn/ui

**선정 이유**:
- 🤖 **AI 친화성**: ⭐⭐⭐⭐⭐ (5/5)
  - 복사 붙여넣기 방식: AI가 쉽게 생성
  - Radix UI 기반: 접근성 자동 보장

- 🔧 **유지보수성**: ⭐⭐⭐⭐ (4/5)
  - npm 패키지 아님 (소스 코드 복사)
  - 직접 커스터마이징 용이

- 📊 **안정성**: ⭐⭐⭐⭐⭐ (5/5)
  - Radix UI 안정성 상속
  - TypeScript 완벽 지원

**현재 사용 중인 컴포넌트**:
- Button, Input, Card, Form, Label ✅
- (필요 시 추가: Dialog, Toast, Select, Dropdown Menu)

---

### ⚡ React 19.1.0

**선정 이유**:
- Next.js 15가 React 19 요구
- Concurrent Rendering 안정화
- Server Components 네이티브 지원

**주요 기능**:
- **use()** hook: 비동기 데이터 처리
- **Server Actions**: 폼 제출 간소화
- **자동 메모이제이션**: 성능 최적화

---

### 🗂️ Zustand 5.0.8

**선정 이유**:
- 🤖 **AI 친화성**: ⭐⭐⭐⭐⭐ (5/5)
  - 간결한 API
  - Redux보다 단순

- 🔧 **유지보수성**: ⭐⭐⭐⭐ (4/5)
  - 단독 개발자 → 커뮤니티 유지보수
  - npm 다운로드: 2M+ /주

- 📊 **안정성**: ⭐⭐⭐⭐⭐ (5/5)
  - Breaking changes 거의 없음
  - TypeScript 완벽 지원

**사용 사례**:
- `authStore`: 사용자 인증 상태 관리 ✅
- 세션, 프로필, 구독 정보 중앙 관리

**대안**:
- **Jotai**: Atomic state (더 작은 단위)
- **React Context**: 내장 기능 (간단한 경우)
- **Redux Toolkit**: 대규모 앱 (현재 오버킬)

---

## Backend & Database

### 🗄️ Supabase

**선정 이유**:
- 🤖 **AI 친화성**: ⭐⭐⭐⭐⭐ (5/5)
  - Firebase보다 SQL 친화적
  - PostgreSQL 표준 문법
  - 공식 문서 우수

- 🔧 **유지보수성**: ⭐⭐⭐⭐⭐ (5/5)
  - 스폰서: Supabase Inc. (Y Combinator)
  - 오픈소스 (self-hosting 가능)
  - 정기 업데이트

- 📊 **안정성**: ⭐⭐⭐⭐ (4/5)
  - PostgreSQL 안정성 상속
  - 프로덕션 검증: 3년+
  - 백업/복구 자동

**주요 기능**:
- **PostgreSQL 15**: 관계형 DB
- **Supabase Auth**: JWT 기반 인증 ✅
  - 이메일/비밀번호 ✅
  - 구글 OAuth ✅
  - 이메일 인증
- **Row Level Security (RLS)**: 데이터 보안 ✅
- **Realtime**: WebSocket (Phase 2에서 활용 가능)
- **Storage**: 파일 업로드 (필요 시)
- **Edge Functions**: Deno 기반 (필요 시)

**생태계**:
- **ORM**: 불필요 (Supabase JS SDK 사용)
- **마이그레이션**: SQL Editor 또는 CLI
- **백업**: 자동 (유료 플랜)
- **호스팅**: Supabase Cloud (무료 티어)

**비용**:
- **Free Tier**: 500MB DB, 2GB 파일, 50MB egress/day
- **Pro**: $25/월 (8GB DB, unlimited API)
- **예상 비용**: Phase 1은 무료, Phase 2 이후 Pro 고려

---

## Infrastructure & DevOps

### 🚀 Vercel

**선정 이유**:
- 🤖 **AI 친화성**: ⭐⭐⭐⭐⭐ (5/5)
  - Next.js 제작사
  - 설정 제로 (자동 감지)

- 🔧 **유지보수성**: ⭐⭐⭐⭐⭐ (5/5)
  - Next.js 최적화 보장
  - 자동 SSL, CDN
  - Git 연동 자동 배포

- 📊 **안정성**: ⭐⭐⭐⭐⭐ (5/5)
  - 99.99% Uptime SLA
  - Edge Network 전세계

**주요 기능**:
- **자동 배포**: Git Push → 자동 빌드/배포
- **Preview Deployments**: PR마다 미리보기
- **Analytics**: 성능 모니터링 내장
- **Edge Functions**: 글로벌 저지연
- **도메인 관리**: DNS 설정 간소화

**비용**:
- **Hobby (Free)**: 개인 프로젝트, 무제한 사이트
- **Pro**: $20/월 (팀, Analytics Pro)
- **예상 비용**: Phase 1은 Hobby, Phase 2 이후 Pro

**대안**:
- **Cloudflare Pages**: 무료, 빠름 (Next.js 지원 제한적)
- **Railway**: DB 포함 호스팅 (Supabase 별도 사용 중)
- **Netlify**: Vercel과 유사 (Next.js는 Vercel이 우세)

---

## 추가 추천 라이브러리

### Phase 1 MVP 완성용

#### 1. **react-hot-toast** (Toast 알림)
```bash
npm install react-hot-toast
```
- **용도**: 성공/실패 메시지 표시
- **장점**: 경량 (3KB), 사용 간단
- **대안**: sonner (shadcn/ui 권장)

#### 2. **date-fns** (날짜 처리)
```bash
npm install date-fns
```
- **용도**: 구독 만료일 계산, 날짜 포맷팅
- **장점**: Tree-shakable, TypeScript 지원
- **대안**: day.js (더 경량)

#### 3. **@tanstack/react-query** (서버 상태 관리)
```bash
npm install @tanstack/react-query
```
- **용도**: API 캐싱, 자동 리페치
- **장점**: Supabase와 완벽 호환
- **사용 사례**: 사용자 프로필, 프로젝트 목록 캐싱

#### 4. **zod** (스키마 검증) ✅ 이미 설치됨
- 폼 검증 외에도 API 응답 검증에 활용

### Phase 2 Enhancement용

#### 5. **stripe** (결제)
```bash
npm install stripe @stripe/stripe-js
```
- **용도**: 구독 결제 (Phase 2)
- **대안**: toss-payments (한국 전용)

#### 6. **@vercel/analytics** (분석)
```bash
npm install @vercel/analytics
```
- **용도**: 사용자 행동 분석
- **장점**: Vercel 네이티브, 프라이버시 친화적

#### 7. **@sentry/nextjs** (에러 트래킹)
```bash
npm install @sentry/nextjs
```
- **용도**: 프로덕션 에러 모니터링
- **무료**: 5,000 errors/월

---

## 전체 기술 스택 점수

| 레이어 | 기술 | AI 친화성 | 유지보수성 | 안정성 | 총점 |
|--------|------|-----------|-----------|--------|------|
| **Frontend** | Next.js 15 | 5/5 | 5/5 | 5/5 | **15/15** ⭐⭐⭐ |
| **Styling** | Tailwind CSS 4 | 5/5 | 5/5 | 4/5 | **14/15** ⭐⭐ |
| **UI** | shadcn/ui | 5/5 | 4/5 | 5/5 | **14/15** ⭐⭐ |
| **State** | Zustand | 5/5 | 4/5 | 5/5 | **14/15** ⭐⭐ |
| **Backend** | Supabase | 5/5 | 5/5 | 4/5 | **14/15** ⭐⭐ |
| **Infra** | Vercel | 5/5 | 5/5 | 5/5 | **15/15** ⭐⭐⭐ |

**평균 점수**: **14.3/15** (95.3%)

---

## 선정 근거

### 🎯 추천 조합: "Next.js + Supabase + Vercel"

**상호 호환성**: ⭐⭐⭐⭐⭐
- Next.js ↔ Vercel: 제작사 동일, 완벽 통합
- Next.js ↔ Supabase: 공식 가이드 제공
- Supabase Auth ↔ Next.js Middleware: JWT 검증 간편

**개발 생산성**: ⭐⭐⭐⭐⭐
- 서버리스: 인프라 관리 불필요
- TypeScript: 전 스택 타입 안정성
- Hot Reload: 빠른 개발 사이클

**러닝 커브**: ⭐⭐⭐⭐ (4/5)
- Next.js App Router: 초기 학습 필요
- Supabase: PostgreSQL 지식 필요
- 전체적으로 중간 수준

**전체 비용**: ⭐⭐⭐⭐⭐
- Phase 1 MVP: **$0/월** (모두 무료 티어)
- Phase 2 런칭: **$45/월** (Vercel Pro + Supabase Pro)
- Scale: **$100-200/월** (트래픽 증가 시)

---

## 예상 개발 속도

**MVP (Phase 1)**:
- 기간: **2주** (이미 1주 진행)
- 완료 기능: 회원가입, 로그인, 프로젝트 접근 제어, 관리자 기능

**전체 완성 (Phase 2)**:
- 기간: **4주** (결제, 구독 관리, 관리자 UI, 이메일 알림)

**생산성 가속 요인**:
- AI 어시스턴트 (Claude Code)
- shadcn/ui 컴포넌트 재사용
- Supabase 자동 API 생성
- Vercel 자동 배포

---

## 마이그레이션 전략

### 만약 향후 변경이 필요하다면

#### From Supabase → To Self-hosted PostgreSQL
- **난이도**: 보통
- **예상 기간**: 1주
- **주요 작업**:
  - PostgreSQL 서버 설정
  - Auth 로직 재구현 (Passport.js 등)
  - RLS → 애플리케이션 레벨 권한 관리
- **리스크**: Auth 재작업 시간 소요

#### From Vercel → To Cloudflare Pages
- **난이도**: 쉬움
- **예상 기간**: 2일
- **주요 작업**:
  - 빌드 설정 조정
  - 환경 변수 이전
  - Edge Functions 재작성 (Workers)
- **리스크**: Next.js 일부 기능 제한

#### From Next.js → To Remix
- **난이도**: 어려움
- **예상 기간**: 3-4주
- **주요 작업**:
  - 라우팅 구조 변경
  - Server Components → Loaders 변환
  - 데이터 fetching 패턴 재작성
- **리스크**: 전체 프론트엔드 재작업
- **권장 안함**: Next.js는 장기적으로 안정적

---

## 학습 자료

### Next.js 15
- 🎓 공식 튜토리얼: https://nextjs.org/learn
- 📚 추천 강의: Vercel YouTube (App Router)
- 💻 샘플 프로젝트: https://github.com/vercel/next.js/tree/canary/examples
- 👥 커뮤니티: r/nextjs

### Supabase
- 🎓 공식 문서: https://supabase.com/docs
- 📚 추천 강의: Supabase YouTube
- 💻 샘플: https://github.com/supabase/supabase/tree/master/examples
- 👥 커뮤니티: Discord (매우 활발)

### Tailwind CSS 4
- 🎓 공식 문서: https://tailwindcss.com/docs
- 📚 추천: Tailwind UI (유료)
- 💻 샘플: https://tailwindui.com/components
- 👥 커뮤니티: Tailwind Labs Discord

---

## 의사결정 체크리스트

선택 전 확인:
- [✅] 팀 전원이 3주 내 학습 가능한가? → **예** (AI 어시스턴트 활용)
- [✅] 예산 범위 내인가? → **예** (Phase 1 무료)
- [✅] 3년 후에도 유지보수 가능한가? → **예** (모두 장기 지원 보장)
- [✅] 커뮤니티가 활발한가? → **예** (매우 활발)
- [✅] 채용 시장에서 인력 구하기 쉬운가? → **예** (Next.js, React 개발자 많음)
- [✅] Breaking change 대응 가능한가? → **예** (연 1-2회, Codemod 제공)
- [✅] 프로덕션 사례가 충분한가? → **예** (Netflix, Twitch, Nike 등)

---

## 보안 고려사항

### Supabase RLS 정책
- ✅ 모든 테이블에 RLS 활성화
- ✅ 사용자별 데이터 격리
- ✅ 관리자 권한 분리

### Next.js 보안
- ✅ HTTPS only (Vercel 자동)
- ✅ CSRF 보호 (Next.js 내장)
- ✅ XSS 방지 (React 자동 escaping)
- ✅ SQL Injection 방지 (Supabase parameterized queries)

### 환경 변수
- ✅ `.env.local` (gitignore)
- ✅ Vercel 환경 변수 암호화
- ✅ Public vs Private 키 분리

---

## 성능 최적화

### 이미 적용된 최적화
- ✅ Next.js 자동 이미지 최적화
- ✅ Tailwind CSS Purge (프로덕션)
- ✅ React Server Components (초기 로딩 빠름)
- ✅ Vercel Edge Network (CDN)

### 추가 최적화 (Phase 2)
- [ ] React Query로 API 캐싱
- [ ] 이미지 lazy loading
- [ ] Code splitting (dynamic import)
- [ ] Vercel Analytics로 성능 모니터링

---

## 다음 단계

1. ✅ **기술 스택 문서 완성** (현재)
2. ⏭️ **03-2 Codebase Structure** (디렉토리 구조 설계)
3. **04 Dataflow Schema** (DB 스키마 최종 확정)
4. **05 UseCase Generator** (기능별 유스케이스)

---

**문서 작성**: Claude Code + Product Owner
**버전**: 1.0
**최종 수정**: 2025-01-20
