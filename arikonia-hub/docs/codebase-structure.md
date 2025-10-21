# Arikonia Hub - 코드베이스 구조 문서

## 문서 정보
- **작성일**: 2025-01-20
- **버전**: 1.0
- **프로젝트**: Arikonia Hub (통합 SSO 플랫폼)
- **관련 문서**: [PRD](./prd.md), [Userflow](./userflow.md), [Tech Stack](./tech-stack.md)

---

## 아키텍처 원칙

### 1. Presentation ↔ Business 분리
- **UI 컴포넌트**는 비즈니스 로직을 몰라야 함
- **비즈니스 로직**은 UI 프레임워크에 의존하지 않음
- **연결**: Custom Hooks 또는 Zustand Store를 통해 중재

### 2. Business ↔ Persistence 분리
- **비즈니스 로직**은 데이터베이스 구조를 직접 몰라야 함
- **데이터 액세스**는 Repository 패턴으로 추상화
- **연결**: Service Layer가 Repository를 호출

### 3. Internal ↔ External 분리
- **내부 도메인 로직**과 **외부 서비스**(Supabase, OAuth) 분리
- **Adapter 패턴**으로 외부 의존성 격리
- **테스트 용이성**: Mock으로 외부 서비스 대체 가능

### 4. Single Responsibility (단일 책임)
- **하나의 파일/모듈**은 **하나의 목적**만 수행
- **변경 이유**가 하나여야 함
- **예시**: `authStore.ts`는 인증 상태만, `userRepository.ts`는 사용자 데이터 접근만

---

## 계층 아키텍처 (Layered Architecture)

```
┌─────────────────────────────────────────────────┐
│  Presentation Layer (UI)                        │
│  - pages (app/*/page.tsx)                       │
│  - components (components/ui, features)         │
│  - hooks (useAuth, useProjectAccess)            │
└─────────────────────────────────────────────────┘
                      ↓ calls
┌─────────────────────────────────────────────────┐
│  Application Layer (Orchestration)              │
│  - stores (Zustand)                             │
│  - services (business logic)                    │
└─────────────────────────────────────────────────┘
                      ↓ calls
┌─────────────────────────────────────────────────┐
│  Domain Layer (Core Business)                   │
│  - types (domain models)                        │
│  - validators (Zod schemas)                     │
│  - utils (pure functions)                       │
└─────────────────────────────────────────────────┘
                      ↓ calls
┌─────────────────────────────────────────────────┐
│  Infrastructure Layer (External)                │
│  - lib/supabase (Supabase client)               │
│  - repositories (data access)                   │
│  - adapters (external services)                 │
└─────────────────────────────────────────────────┘
```

**의존성 규칙**:
- **하위 레이어만 호출 가능** (Presentation → Application → Domain → Infrastructure)
- **상위 레이어 의존 금지** (Infrastructure는 Presentation을 몰라야 함)
- **Domain Layer는 독립적** (외부 라이브러리 의존 최소화)

---

## 디렉토리 구조

### 현재 구조 (v1.0)

```
arikonia-hub/
├── app/                          # Next.js App Router (Presentation Layer)
│   ├── layout.tsx                # Root layout (공통 레이아웃)
│   ├── page.tsx                  # Landing page (/)
│   ├── globals.css               # Global styles
│   ├── login/
│   │   └── page.tsx              # 로그인 페이지
│   ├── signup/
│   │   └── page.tsx              # 회원가입 페이지
│   └── auth/
│       └── callback/
│           └── page.tsx          # OAuth callback handler
│
├── components/                   # Presentation Layer
│   ├── ui/                       # shadcn/ui 컴포넌트 (재사용)
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── form.tsx
│   │   ├── input.tsx
│   │   └── label.tsx
│   └── features/                 # 기능별 컴포넌트 (추가 예정)
│       ├── auth/                 # 인증 관련
│       ├── dashboard/            # 대시보드 관련
│       └── projects/             # 프로젝트 관련
│
├── store/                        # Application Layer (Zustand)
│   └── authStore.ts              # 인증 상태 관리
│
├── lib/                          # Infrastructure Layer
│   ├── supabase.ts               # Supabase client 초기화
│   └── utils.ts                  # Utility functions (cn)
│
├── supabase/                     # Database Schema
│   ├── schema.sql                # 기본 스키마
│   ├── schema_fixed.sql          # RLS 수정 버전
│   └── schema_with_admin.sql     # 관리자 기능 포함
│
├── docs/                         # Documentation
│   ├── prd.md
│   ├── userflow.md
│   ├── tech-stack.md
│   └── codebase-structure.md     # 현재 문서
│
├── .env.local                    # 환경 변수 (gitignore)
├── package.json                  # Dependencies
├── tsconfig.json                 # TypeScript 설정
├── tailwind.config.ts            # Tailwind CSS 4 설정
├── postcss.config.mjs            # PostCSS 설정
└── next.config.ts                # Next.js 설정
```

### 확장 계획 (Phase 1 완성 시)

```
arikonia-hub/
├── app/
│   ├── dashboard/                # 대시보드 (로그인 후)
│   │   ├── page.tsx
│   │   └── layout.tsx
│   ├── admin/                    # 관리자 전용 (Phase 2)
│   │   ├── page.tsx
│   │   └── users/
│   │       └── page.tsx
│   └── api/                      # API Routes (필요 시)
│       └── webhook/
│           └── route.ts
│
├── components/
│   ├── ui/                       # shadcn/ui 확장
│   │   ├── dialog.tsx
│   │   ├── toast.tsx
│   │   └── select.tsx
│   ├── features/
│   │   ├── auth/
│   │   │   ├── LoginForm.tsx
│   │   │   └── SignupForm.tsx
│   │   ├── dashboard/
│   │   │   ├── ProjectCard.tsx
│   │   │   └── SubscriptionBadge.tsx
│   │   └── projects/
│   │       └── ProjectAccessGate.tsx
│   └── layout/                   # Layout 컴포넌트
│       ├── Header.tsx
│       ├── Footer.tsx
│       └── Sidebar.tsx
│
├── hooks/                        # Custom Hooks (Application Layer)
│   ├── useAuth.ts                # authStore wrapper
│   ├── useProjectAccess.ts       # 프로젝트 접근 권한
│   └── useSubscription.ts        # 구독 정보
│
├── services/                     # Business Logic (Application Layer)
│   ├── authService.ts            # 인증 비즈니스 로직
│   ├── subscriptionService.ts    # 구독 관리 로직
│   └── projectService.ts         # 프로젝트 관리 로직
│
├── repositories/                 # Data Access (Infrastructure Layer)
│   ├── userRepository.ts         # users 테이블 CRUD
│   ├── subscriptionRepository.ts # user_subscriptions CRUD
│   └── projectRepository.ts      # projects 테이블 CRUD
│
├── types/                        # Domain Layer
│   ├── user.ts                   # User 타입 정의
│   ├── subscription.ts           # Subscription 타입
│   ├── project.ts                # Project 타입
│   └── index.ts                  # 통합 export
│
├── validators/                   # Domain Layer
│   ├── authSchemas.ts            # 인증 Zod 스키마
│   ├── subscriptionSchemas.ts    # 구독 Zod 스키마
│   └── projectSchemas.ts         # 프로젝트 Zod 스키마
│
├── utils/                        # Domain Layer (Pure Functions)
│   ├── dateUtils.ts              # 날짜 계산 함수
│   ├── formatters.ts             # 포맷팅 함수
│   └── constants.ts              # 상수 정의
│
└── middleware.ts                 # Next.js Middleware (인증 체크)
```

---

## 주요 빌딩 블록 (Top-Level Building Blocks)

### 1. Presentation Layer

#### `app/` (Pages)
**책임**: 사용자에게 보여지는 페이지 라우팅 및 레이아웃
**규칙**:
- 각 페이지는 **비즈니스 로직 없음** (UI만)
- **Hooks** 또는 **Stores**를 통해 데이터 가져오기
- **Server Components** 우선, Client는 필요시만 (`'use client'`)

**코드 예시**:
```tsx
// app/dashboard/page.tsx
'use client'

import { useAuth } from '@/hooks/useAuth'
import { ProjectCard } from '@/components/features/dashboard/ProjectCard'

export default function DashboardPage() {
  const { user, checkProjectAccess } = useAuth()

  // UI 로직만 포함, 비즈니스 로직은 hooks/stores에서
  if (!user) {
    return <div>로그인이 필요합니다</div>
  }

  return (
    <div>
      <h1>환영합니다, {user.nickname}님</h1>
      <ProjectCard projectCode="care-lit" />
    </div>
  )
}
```

#### `components/` (UI Components)
**책임**: 재사용 가능한 UI 컴포넌트
**규칙**:
- **Presentation 전용** (데이터 로직 금지)
- **Props로 데이터 받기** (내부에서 API 호출 금지)
- **ui/**: 범용 컴포넌트 (Button, Input)
- **features/**: 도메인 특화 컴포넌트 (ProjectCard, SubscriptionBadge)

**코드 예시**:
```tsx
// components/features/dashboard/ProjectCard.tsx
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import type { Project } from '@/types/project'

interface ProjectCardProps {
  project: Project
  hasAccess: boolean
  onAccessClick: () => void
}

export function ProjectCard({ project, hasAccess, onAccessClick }: ProjectCardProps) {
  return (
    <Card>
      <h3>{project.name}</h3>
      <p>{project.description}</p>
      <Button onClick={onAccessClick} disabled={!hasAccess}>
        {hasAccess ? '접속하기' : '구독 필요'}
      </Button>
    </Card>
  )
}
```

---

### 2. Application Layer

#### `stores/` (Zustand State Management)
**책임**: 전역 상태 관리 및 비즈니스 로직 오케스트레이션
**규칙**:
- **Repository를 호출**하여 데이터 가져오기
- **복잡한 비즈니스 로직**은 `services/`로 위임
- **에러 처리** 및 로딩 상태 관리

**코드 예시**:
```typescript
// store/authStore.ts (현재)
import { create } from 'zustand'
import { createClient } from '@/lib/supabase'
import type { UserProfile } from '@/types/user'

interface AuthState {
  user: UserProfile | null
  isLoading: boolean
  error: string | null

  // Actions
  loadUser: () => Promise<void>
  signIn: (email: string, password: string) => Promise<void>
  signInWithGoogle: () => Promise<void>
  signOut: () => Promise<void>
  checkProjectAccess: (projectCode: string) => Promise<{...}>
  clearError: () => void
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isLoading: false,
  error: null,

  loadUser: async () => {
    const supabase = createClient()
    const { data: { user } } = await supabase.auth.getUser()
    // ... Repository 호출로 변경 예정
  },

  // ... 기타 메서드
}))
```

**리팩토링 계획**:
```typescript
// store/authStore.ts (개선 버전)
import { authService } from '@/services/authService'
import type { UserProfile } from '@/types/user'

interface AuthState {
  user: UserProfile | null
  isLoading: boolean
  error: string | null

  loadUser: () => Promise<void>
  signIn: (email: string, password: string) => Promise<void>
  signInWithGoogle: () => Promise<void>
  signOut: () => Promise<void>
  clearError: () => void
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isLoading: false,
  error: null,

  loadUser: async () => {
    try {
      set({ isLoading: true, error: null })
      const user = await authService.getCurrentUser() // Service 호출
      set({ user, isLoading: false })
    } catch (error: any) {
      set({ error: error.message, isLoading: false })
    }
  },

  signIn: async (email: string, password: string) => {
    try {
      set({ isLoading: true, error: null })
      const user = await authService.signIn(email, password) // Service 호출
      set({ user, isLoading: false })
    } catch (error: any) {
      set({ error: error.message, isLoading: false })
      throw error
    }
  },

  // ... 나머지
}))
```

#### `services/` (Business Logic)
**책임**: 복잡한 비즈니스 로직 구현
**규칙**:
- **Repository를 조합**하여 복잡한 작업 수행
- **도메인 규칙 검증** (예: 구독 만료 체크)
- **Supabase 직접 호출 금지** (Repository를 통해서만)

**코드 예시**:
```typescript
// services/authService.ts (신규 생성 예정)
import { userRepository } from '@/repositories/userRepository'
import { supabaseAuth } from '@/lib/supabase'
import type { UserProfile } from '@/types/user'

export const authService = {
  async getCurrentUser(): Promise<UserProfile | null> {
    const { data: { user } } = await supabaseAuth.getUser()
    if (!user) return null

    return await userRepository.findById(user.id)
  },

  async signIn(email: string, password: string): Promise<UserProfile> {
    const { data, error } = await supabaseAuth.signInWithPassword({
      email,
      password,
    })

    if (error) throw new Error(error.message)
    if (!data.user) throw new Error('인증 실패')

    const profile = await userRepository.findById(data.user.id)
    if (!profile) throw new Error('사용자 프로필이 없습니다')

    return profile
  },

  async signInWithGoogle(): Promise<void> {
    const { error } = await supabaseAuth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    })

    if (error) throw new Error(error.message)
  },

  async signOut(): Promise<void> {
    const { error } = await supabaseAuth.signOut()
    if (error) throw new Error(error.message)
  },

  async checkProjectAccess(userId: string, projectCode: string): Promise<boolean> {
    // 복잡한 비즈니스 로직 (구독 + 프로젝트 매핑)
    const subscription = await userRepository.getUserSubscription(userId)
    const project = await projectRepository.findByCode(projectCode)

    if (!subscription || !project) return false

    // 구독 플랜과 프로젝트 권한 매핑 확인
    return subscriptionService.hasAccess(subscription.plan, project.requiredPlan)
  }
}
```

#### `hooks/` (Custom Hooks)
**책임**: Store와 Component 연결, 로직 재사용
**규칙**:
- **Zustand Store를 래핑**하여 사용 편의성 제공
- **컴포넌트 전용 로직** (UI 관련 side effects)
- **비즈니스 로직 금지** (Service에 위임)

**코드 예시**:
```typescript
// hooks/useAuth.ts (신규 생성 예정)
import { useAuthStore } from '@/store/authStore'
import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

export function useAuth() {
  const router = useRouter()
  const { user, isLoading, error, loadUser, signIn, signOut } = useAuthStore()

  // 초기 로딩
  useEffect(() => {
    loadUser()
  }, [loadUser])

  // 로그인 필요 페이지 리다이렉트
  const requireAuth = () => {
    if (!isLoading && !user) {
      router.push('/login')
    }
  }

  return {
    user,
    isLoading,
    error,
    signIn,
    signOut,
    requireAuth,
    isAuthenticated: !!user,
  }
}
```

```typescript
// hooks/useProjectAccess.ts (신규 생성 예정)
import { useState, useEffect } from 'react'
import { useAuthStore } from '@/store/authStore'

export function useProjectAccess(projectCode: string) {
  const { user, checkProjectAccess } = useAuthStore()
  const [hasAccess, setHasAccess] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!user) {
      setHasAccess(false)
      setLoading(false)
      return
    }

    checkProjectAccess(projectCode).then((result) => {
      setHasAccess(result.hasAccess)
      setLoading(false)
    })
  }, [user, projectCode, checkProjectAccess])

  return { hasAccess, loading }
}
```

---

### 3. Domain Layer

#### `types/` (Domain Models)
**책임**: 도메인 모델 타입 정의
**규칙**:
- **Database 스키마와 분리** (별도 타입)
- **비즈니스 개념 반영** (예: `SubscriptionStatus`, `ProjectAccessLevel`)
- **외부 라이브러리 의존 금지** (순수 TypeScript)

**코드 예시**:
```typescript
// types/user.ts (신규 생성 예정)
export interface UserProfile {
  id: string
  email: string
  nickname: string
  createdAt: Date
  updatedAt: Date
}

export interface UserSubscription {
  id: string
  userId: string
  planId: string
  planName: 'free' | 'basic' | 'premium' | 'enterprise'
  status: 'active' | 'inactive' | 'expired'
  startDate: Date
  endDate: Date | null
}
```

```typescript
// types/project.ts (신규 생성 예정)
export interface Project {
  id: string
  code: string
  name: string
  description: string
  domain: string
  requiredPlan: 'free' | 'basic' | 'premium' | 'enterprise'
  isActive: boolean
}

export interface ProjectAccess {
  projectCode: string
  hasAccess: boolean
  reason?: 'subscription_required' | 'plan_upgrade_needed' | 'project_inactive'
  requiredPlan?: string
}
```

#### `validators/` (Schema Validation)
**책임**: 입력 데이터 검증
**규칙**:
- **Zod 스키마 사용**
- **도메인 규칙 반영** (이메일 형식, 비밀번호 강도)
- **에러 메시지 한글화**

**코드 예시**:
```typescript
// validators/authSchemas.ts (신규 생성 예정)
import { z } from 'zod'

export const signUpSchema = z.object({
  email: z
    .string()
    .email('올바른 이메일 주소를 입력하세요')
    .min(1, '이메일은 필수입니다'),

  password: z
    .string()
    .min(6, '비밀번호는 최소 6자 이상이어야 합니다')
    .max(100, '비밀번호는 최대 100자까지 가능합니다'),

  nickname: z
    .string()
    .min(2, '닉네임은 최소 2자 이상이어야 합니다')
    .max(20, '닉네임은 최대 20자까지 가능합니다')
    .regex(/^[가-힣a-zA-Z0-9_]+$/, '닉네임은 한글, 영문, 숫자, 언더스코어만 가능합니다'),
})

export const signInSchema = z.object({
  email: z.string().email('올바른 이메일 주소를 입력하세요'),
  password: z.string().min(6, '비밀번호는 최소 6자 이상이어야 합니다'),
})

export type SignUpInput = z.infer<typeof signUpSchema>
export type SignInInput = z.infer<typeof signInSchema>
```

#### `utils/` (Pure Functions)
**책임**: 순수 함수 유틸리티
**규칙**:
- **Side-effect 없음** (동일 입력 → 동일 출력)
- **테스트 용이성** (독립적으로 테스트 가능)
- **도메인 로직 포함 가능** (날짜 계산, 포맷팅)

**코드 예시**:
```typescript
// utils/dateUtils.ts (신규 생성 예정)
import { format, addMonths, isAfter, isBefore } from 'date-fns'
import { ko } from 'date-fns/locale'

export const dateUtils = {
  formatDate(date: Date): string {
    return format(date, 'yyyy년 MM월 dd일', { locale: ko })
  },

  calculateEndDate(startDate: Date, months: number): Date {
    return addMonths(startDate, months)
  },

  isExpired(endDate: Date | null): boolean {
    if (!endDate) return false
    return isBefore(endDate, new Date())
  },

  daysUntilExpiry(endDate: Date | null): number | null {
    if (!endDate) return null
    const now = new Date()
    if (isBefore(endDate, now)) return 0
    return Math.ceil((endDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
  },
}
```

```typescript
// utils/constants.ts (신규 생성 예정)
export const SUBSCRIPTION_PLANS = {
  FREE: 'free',
  BASIC: 'basic',
  PREMIUM: 'premium',
  ENTERPRISE: 'enterprise',
} as const

export const PLAN_HIERARCHY: Record<string, number> = {
  free: 0,
  basic: 1,
  premium: 2,
  enterprise: 3,
}

export const PROJECT_CODES = {
  CARE_LIT: 'care-lit',
  TEM_FLOW: 'tem-flow',
  ARISPER: 'arisper',
  ECONOVERSE: 'econoverse',
  VOCALSPHERE: 'vocalsphere',
  FAITHBRIDGE: 'faithbridge',
} as const
```

---

### 4. Infrastructure Layer

#### `lib/` (External Clients)
**책임**: 외부 서비스 클라이언트 초기화
**규칙**:
- **환경 변수 관리** (.env.local)
- **싱글톤 패턴** (클라이언트 재사용)
- **타입 안전성** (TypeScript Generic)

**코드 예시** (현재):
```typescript
// lib/supabase.ts
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

**리팩토링 계획**:
```typescript
// lib/supabase.ts (개선 버전)
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/database' // Supabase CLI 생성

let supabaseClient: ReturnType<typeof createBrowserClient<Database>> | null = null

export function getSupabaseClient() {
  if (!supabaseClient) {
    supabaseClient = createBrowserClient<Database>(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )
  }
  return supabaseClient
}

// Auth 전용 (분리)
export const supabaseAuth = {
  getUser: () => getSupabaseClient().auth.getUser(),
  signInWithPassword: (credentials: { email: string; password: string }) =>
    getSupabaseClient().auth.signInWithPassword(credentials),
  signInWithOAuth: (options: any) => getSupabaseClient().auth.signInWithOAuth(options),
  signOut: () => getSupabaseClient().auth.signOut(),
}
```

#### `repositories/` (Data Access)
**책임**: 데이터베이스 CRUD 추상화
**규칙**:
- **Supabase 직접 호출** (이 레이어에서만)
- **도메인 모델 반환** (Database 타입 → Domain 타입 변환)
- **에러 처리** (Supabase 에러 → 도메인 에러)

**코드 예시**:
```typescript
// repositories/userRepository.ts (신규 생성 예정)
import { getSupabaseClient } from '@/lib/supabase'
import type { UserProfile, UserSubscription } from '@/types/user'

export const userRepository = {
  async findById(id: string): Promise<UserProfile | null> {
    const supabase = getSupabaseClient()

    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .single()

    if (error) {
      if (error.code === 'PGRST116') return null // Not found
      throw new Error(`사용자 조회 실패: ${error.message}`)
    }

    // Database 타입 → Domain 타입 변환
    return {
      id: data.id,
      email: data.email,
      nickname: data.nickname,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
    }
  },

  async findByEmail(email: string): Promise<UserProfile | null> {
    const supabase = getSupabaseClient()

    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single()

    if (error) {
      if (error.code === 'PGRST116') return null
      throw new Error(`사용자 조회 실패: ${error.message}`)
    }

    return {
      id: data.id,
      email: data.email,
      nickname: data.nickname,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
    }
  },

  async create(user: Omit<UserProfile, 'id' | 'createdAt' | 'updatedAt'>): Promise<UserProfile> {
    const supabase = getSupabaseClient()

    const { data, error } = await supabase
      .from('users')
      .insert({
        email: user.email,
        nickname: user.nickname,
      })
      .select()
      .single()

    if (error) throw new Error(`사용자 생성 실패: ${error.message}`)

    return {
      id: data.id,
      email: data.email,
      nickname: data.nickname,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
    }
  },

  async getUserSubscription(userId: string): Promise<UserSubscription | null> {
    const supabase = getSupabaseClient()

    const { data, error } = await supabase
      .from('user_subscriptions')
      .select(`
        *,
        subscription_plans (
          name
        )
      `)
      .eq('user_id', userId)
      .eq('status', 'active')
      .single()

    if (error) {
      if (error.code === 'PGRST116') return null
      throw new Error(`구독 조회 실패: ${error.message}`)
    }

    return {
      id: data.id,
      userId: data.user_id,
      planId: data.plan_id,
      planName: data.subscription_plans.name as any,
      status: data.status as any,
      startDate: new Date(data.start_date),
      endDate: data.end_date ? new Date(data.end_date) : null,
    }
  },
}
```

---

## 의존성 흐름 (Dependency Flow)

### 올바른 흐름 ✅

```
User clicks button
      ↓
Component calls hook
      ↓
Hook calls Zustand Store
      ↓
Store calls Service
      ↓
Service calls Repository
      ↓
Repository calls Supabase
      ↓
Data flows back up
```

**코드 예시**:
```tsx
// 1. Component (Presentation Layer)
function DashboardPage() {
  const { user } = useAuth() // Hook 호출
  return <div>{user?.nickname}</div>
}

// 2. Hook (Application Layer)
function useAuth() {
  const { user, loadUser } = useAuthStore() // Store 호출
  useEffect(() => { loadUser() }, [])
  return { user }
}

// 3. Store (Application Layer)
const useAuthStore = create((set) => ({
  user: null,
  loadUser: async () => {
    const user = await authService.getCurrentUser() // Service 호출
    set({ user })
  },
}))

// 4. Service (Application Layer)
const authService = {
  getCurrentUser: async () => {
    const user = await userRepository.findById(id) // Repository 호출
    return user
  },
}

// 5. Repository (Infrastructure Layer)
const userRepository = {
  findById: async (id) => {
    const { data } = await supabase.from('users').select('*').eq('id', id) // Supabase 호출
    return data
  },
}
```

### 잘못된 흐름 ❌

```tsx
// ❌ 잘못된 예: Component에서 직접 Supabase 호출
function DashboardPage() {
  const [user, setUser] = useState(null)

  useEffect(() => {
    createClient() // ❌ Infrastructure Layer 직접 호출
      .from('users')
      .select('*')
      .then(({ data }) => setUser(data))
  }, [])

  return <div>{user?.nickname}</div>
}

// ❌ 잘못된 예: Store에서 직접 Supabase 호출 (현재 상태)
const useAuthStore = create((set) => ({
  loadUser: async () => {
    const supabase = createClient() // ❌ Repository 없이 직접 호출
    const { data } = await supabase.from('users').select('*')
    set({ user: data })
  },
}))
```

---

## 리팩토링 로드맵

### Phase 1: 기초 구조 생성 (현재 → 1주 후)

**목표**: Repository, Service, Types 레이어 추가

**작업**:
1. ✅ **`types/` 디렉토리 생성**
   - `user.ts`, `subscription.ts`, `project.ts`
   - Database 스키마와 분리된 도메인 모델

2. ✅ **`repositories/` 디렉토리 생성**
   - `userRepository.ts`: users 테이블 CRUD
   - `subscriptionRepository.ts`: user_subscriptions CRUD
   - `projectRepository.ts`: projects 테이블 CRUD

3. ✅ **`services/` 디렉토리 생성**
   - `authService.ts`: 인증 비즈니스 로직
   - `subscriptionService.ts`: 구독 관리 로직
   - `projectService.ts`: 프로젝트 접근 제어 로직

4. ✅ **`authStore.ts` 리팩토링**
   - Supabase 직접 호출 → Service 호출로 변경
   - 비즈니스 로직 → Service로 이동

5. ✅ **`hooks/` 디렉토리 생성**
   - `useAuth.ts`: authStore wrapper
   - `useProjectAccess.ts`: 프로젝트 접근 권한

**예상 시간**: 2-3일

---

### Phase 2: 기능 컴포넌트 분리 (1주 → 2주 후)

**목표**: UI 컴포넌트를 도메인별로 구조화

**작업**:
1. ✅ **`components/features/` 디렉토리 생성**
   - `auth/LoginForm.tsx`, `auth/SignupForm.tsx`
   - `dashboard/ProjectCard.tsx`, `dashboard/SubscriptionBadge.tsx`
   - `projects/ProjectAccessGate.tsx`

2. ✅ **페이지 리팩토링**
   - `app/login/page.tsx`: LoginForm 컴포넌트 사용
   - `app/signup/page.tsx`: SignupForm 컴포넌트 사용
   - `app/dashboard/page.tsx`: ProjectCard 컴포넌트 사용

3. ✅ **Layout 컴포넌트 추가**
   - `components/layout/Header.tsx`
   - `components/layout/Footer.tsx`
   - `components/layout/Sidebar.tsx` (관리자용)

**예상 시간**: 2-3일

---

### Phase 3: 검증 및 유틸리티 (2주 → 3주 후)

**목표**: Validation, Utils, Constants 정리

**작업**:
1. ✅ **`validators/` 디렉토리 생성**
   - `authSchemas.ts`: 인증 Zod 스키마
   - `subscriptionSchemas.ts`: 구독 Zod 스키마
   - `projectSchemas.ts`: 프로젝트 Zod 스키마

2. ✅ **`utils/` 디렉토리 생성**
   - `dateUtils.ts`: 날짜 계산 함수
   - `formatters.ts`: 포맷팅 함수
   - `constants.ts`: 상수 정의

3. ✅ **기존 페이지에 Validator 적용**
   - LoginForm, SignupForm에 Zod 스키마 연동

**예상 시간**: 1-2일

---

## 테스트 전략 (Phase 2)

### Unit Tests (단위 테스트)

**대상**: Repository, Service, Utils

**도구**: Vitest + @testing-library

**예시**:
```typescript
// repositories/__tests__/userRepository.test.ts
import { describe, it, expect, beforeEach } from 'vitest'
import { userRepository } from '../userRepository'

describe('userRepository', () => {
  beforeEach(() => {
    // Mock Supabase client
  })

  it('should find user by id', async () => {
    const user = await userRepository.findById('test-id')
    expect(user).toBeDefined()
    expect(user?.id).toBe('test-id')
  })

  it('should return null for non-existent user', async () => {
    const user = await userRepository.findById('non-existent')
    expect(user).toBeNull()
  })
})
```

### Integration Tests (통합 테스트)

**대상**: API Routes, Middleware

**도구**: Playwright

**예시**:
```typescript
// tests/auth.spec.ts
import { test, expect } from '@playwright/test'

test('should login with email and password', async ({ page }) => {
  await page.goto('/login')
  await page.fill('input[type="email"]', 'test@example.com')
  await page.fill('input[type="password"]', 'password123')
  await page.click('button[type="submit"]')

  await expect(page).toHaveURL('/dashboard')
})
```

---

## 코드 품질 체크리스트

### 계층 분리 검증

- [ ] **Presentation Layer**: UI 컴포넌트가 Supabase를 직접 import하지 않는가?
- [ ] **Application Layer**: Store가 Repository를 통해서만 데이터 접근하는가?
- [ ] **Domain Layer**: Types, Validators가 외부 라이브러리에 의존하지 않는가?
- [ ] **Infrastructure Layer**: Repository만 Supabase를 호출하는가?

### 의존성 규칙 검증

- [ ] **상위 → 하위만 호출**: Component → Hook → Store → Service → Repository?
- [ ] **하위 → 상위 호출 없음**: Repository가 Store를 import하지 않는가?
- [ ] **도메인 독립성**: Domain Layer가 Infrastructure를 import하지 않는가?

### 파일 위치 검증

- [ ] **UI 컴포넌트**: `components/ui/` 또는 `components/features/`에 있는가?
- [ ] **비즈니스 로직**: `services/`에 있는가?
- [ ] **데이터 접근**: `repositories/`에 있는가?
- [ ] **타입 정의**: `types/`에 있는가?

---

## 다음 단계

1. ✅ **코드베이스 구조 문서 완성** (현재)
2. ⏭️ **Repository, Service, Types 레이어 생성** (Phase 1 리팩토링)
3. ⏭️ **04 Dataflow Schema Generator** (DB 스키마 최종 확정)
4. ⏭️ **05 UseCase Generator** (기능별 유스케이스 작성)

---

**문서 작성**: Claude Code + Solutions Architect
**버전**: 1.0
**최종 수정**: 2025-01-20
