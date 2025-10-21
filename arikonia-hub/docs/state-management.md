# State Management Design (Zustand)

## 문서 정보
- **작성일**: 2025-10-21
- **버전**: 1.0
- **프레임워크**: Next.js 15 + React 19
- **상태관리 라이브러리**: Zustand 5.0.8
- **관련 문서**:
  - [PRD](./prd.md)
  - [Userflow](./userflow.md)
  - [Database](./database.md)
  - [UC-001 ~ UC-004](./001/spec.md)

---

## 목차
1. [개요](#개요)
2. [Store 설계](#store-설계)
3. [Actions 설계](#actions-설계)
4. [Computed State (Selectors)](#computed-state-selectors)
5. [Component-Store 매핑](#component-store-매핑)
6. [최적화 전략](#최적화-전략)
7. [에러 처리](#에러-처리)

---

## 개요

### Zustand 선택 이유

**장점**:
- ✅ 간결한 API (Redux보다 80% 적은 Boilerplate)
- ✅ TypeScript 완벽 지원
- ✅ React 외부에서도 사용 가능 (Middleware, API 호출)
- ✅ DevTools 지원 (Redux DevTools)
- ✅ 번들 크기 작음 (2.9KB gzipped)
- ✅ Context Provider 불필요

**프로젝트 적합성**:
- MVP 단계에 적합한 경량 솔루션
- 4개 Usecases의 상태 관리에 충분
- Supabase API와 자연스러운 통합

---

## Store 설계

### 1. Auth Store (`authStore`)

**책임**: 사용자 인증, 세션, 프로필, 구독 관리

#### State Interface

```typescript
import { User, Session } from '@supabase/supabase-js'

interface UserProfile {
  id: string
  email: string
  nickname: string
  avatar_url: string | null
  created_at: string
  updated_at: string
}

interface Subscription {
  plan_id: string
  plan_name: 'free' | 'basic' | 'premium' | 'enterprise'
  status: 'active' | 'expired' | 'cancelled'
  expires_at: string | null
  max_projects: number
  max_file_size_mb: number
}

interface AuthState {
  // Core State
  user: User | null
  session: Session | null
  profile: UserProfile | null
  subscription: Subscription | null

  // UI State
  isLoading: boolean
  error: string | null

  // Actions
  signUpWithEmail: (email: string, password: string, nickname: string) => Promise<void>
  signInWithEmail: (email: string, password: string) => Promise<void>
  signInWithGoogle: () => Promise<void>
  signOut: () => Promise<void>
  loadUserData: (userId: string) => Promise<void>
  clearError: () => void
}
```

#### Initial State

```typescript
const initialState = {
  user: null,
  session: null,
  profile: null,
  subscription: null,
  isLoading: false,
  error: null,
}
```

#### Store Implementation

```typescript
// src/stores/authStore.ts
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import { supabase } from '@/lib/supabase'

export const useAuthStore = create<AuthState>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial State
        ...initialState,

        // Actions
        signUpWithEmail: async (email, password, nickname) => {
          set({ isLoading: true, error: null })

          try {
            // UC-001: 회원가입 (이메일)
            const { data, error } = await supabase.auth.signUp({
              email,
              password,
              options: {
                data: { nickname }
              }
            })

            if (error) throw error

            set({
              user: data.user,
              session: data.session,
              isLoading: false
            })

            // Load profile and subscription
            if (data.user) {
              await get().loadUserData(data.user.id)
            }
          } catch (error: any) {
            set({
              error: error.message || '회원가입에 실패했습니다',
              isLoading: false
            })
            throw error
          }
        },

        signInWithEmail: async (email, password) => {
          set({ isLoading: true, error: null })

          try {
            // UC-003: 로그인 (이메일)
            const { data, error } = await supabase.auth.signInWithPassword({
              email,
              password
            })

            if (error) throw error

            set({
              user: data.user,
              session: data.session,
              isLoading: false
            })

            // Load profile and subscription
            if (data.user) {
              await get().loadUserData(data.user.id)
            }
          } catch (error: any) {
            set({
              error: error.message || '로그인에 실패했습니다',
              isLoading: false
            })
            throw error
          }
        },

        signInWithGoogle: async () => {
          set({ isLoading: true, error: null })

          try {
            // UC-002: 회원가입 (구글 OAuth)
            const { data, error } = await supabase.auth.signInWithOAuth({
              provider: 'google',
              options: {
                redirectTo: `${window.location.origin}/auth/callback`
              }
            })

            if (error) throw error

            // OAuth는 redirect되므로 여기서는 loading만 해제
            set({ isLoading: false })
          } catch (error: any) {
            set({
              error: error.message || '구글 로그인에 실패했습니다',
              isLoading: false
            })
            throw error
          }
        },

        signOut: async () => {
          set({ isLoading: true, error: null })

          try {
            const { error } = await supabase.auth.signOut()

            if (error) throw error

            set({
              ...initialState
            })
          } catch (error: any) {
            set({
              error: error.message || '로그아웃에 실패했습니다',
              isLoading: false
            })
            throw error
          }
        },

        loadUserData: async (userId: string) => {
          try {
            // Load profile
            const { data: profile, error: profileError } = await supabase
              .from('users')
              .select('*')
              .eq('id', userId)
              .single()

            if (profileError) throw profileError

            // Load subscription with plan details
            const { data: subscription, error: subError } = await supabase
              .from('user_subscriptions')
              .select(`
                *,
                subscription_plans (
                  name,
                  max_projects,
                  max_file_size_mb
                )
              `)
              .eq('user_id', userId)
              .single()

            if (subError) throw subError

            set({
              profile,
              subscription: {
                plan_id: subscription.plan_id,
                plan_name: subscription.subscription_plans.name,
                status: subscription.status,
                expires_at: subscription.expires_at,
                max_projects: subscription.subscription_plans.max_projects,
                max_file_size_mb: subscription.subscription_plans.max_file_size_mb
              }
            })
          } catch (error: any) {
            console.error('Failed to load user data:', error)
            set({ error: '사용자 정보를 불러오는데 실패했습니다' })
          }
        },

        clearError: () => set({ error: null })
      }),
      {
        name: 'auth-storage',
        partialize: (state) => ({
          // Only persist session-related data
          user: state.user,
          session: state.session,
          profile: state.profile,
          subscription: state.subscription
        })
      }
    ),
    { name: 'AuthStore' }
  )
)
```

---

### 2. Project Access Store (`projectStore`)

**책임**: 프로젝트 접근 제어, 권한 확인

#### State Interface

```typescript
interface ProjectAccessResult {
  has_access: boolean
  project_name: string
  access_level: 'view' | 'full' | 'admin'
  source: 'plan' | 'individual'
  error?: string
  required_plan?: string
}

interface ProjectState {
  // Core State
  accessResults: Record<string, ProjectAccessResult>

  // UI State
  isCheckingAccess: boolean
  error: string | null

  // Actions
  checkAccess: (projectCode: string) => Promise<ProjectAccessResult>
  clearAccessResult: (projectCode: string) => void
}
```

#### Store Implementation

```typescript
// src/stores/projectStore.ts
import { create } from 'zustand'
import { devtools } from 'zustand/middleware'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from './authStore'

export const useProjectStore = create<ProjectState>()(
  devtools(
    (set, get) => ({
      // Initial State
      accessResults: {},
      isCheckingAccess: false,
      error: null,

      // Actions
      checkAccess: async (projectCode: string) => {
        set({ isCheckingAccess: true, error: null })

        try {
          const user = useAuthStore.getState().user

          if (!user) {
            throw new Error('로그인이 필요합니다')
          }

          // UC-004: 프로젝트 접근 제어
          const { data, error } = await supabase.rpc('check_project_access', {
            p_user_id: user.id,
            p_project_code: projectCode
          })

          if (error) throw error

          const result = data as ProjectAccessResult

          // Cache result
          set({
            accessResults: {
              ...get().accessResults,
              [projectCode]: result
            },
            isCheckingAccess: false
          })

          return result
        } catch (error: any) {
          set({
            error: error.message || '접근 권한 확인에 실패했습니다',
            isCheckingAccess: false
          })
          throw error
        }
      },

      clearAccessResult: (projectCode: string) => {
        const { [projectCode]: _, ...rest } = get().accessResults
        set({ accessResults: rest })
      }
    }),
    { name: 'ProjectStore' }
  )
)
```

---

## Actions 설계

### Auth Actions

| Action | Parameters | Returns | Description | Related UC |
|--------|-----------|---------|-------------|------------|
| `signUpWithEmail` | `email, password, nickname` | `Promise<void>` | 이메일 회원가입 | UC-001 |
| `signInWithEmail` | `email, password` | `Promise<void>` | 이메일 로그인 | UC-003 |
| `signInWithGoogle` | - | `Promise<void>` | 구글 OAuth 로그인 | UC-002, UC-003 |
| `signOut` | - | `Promise<void>` | 로그아웃 | - |
| `loadUserData` | `userId` | `Promise<void>` | 프로필 및 구독 정보 조회 | UC-003 |
| `clearError` | - | `void` | 에러 메시지 초기화 | - |

### Project Actions

| Action | Parameters | Returns | Description | Related UC |
|--------|-----------|---------|-------------|------------|
| `checkAccess` | `projectCode` | `Promise<ProjectAccessResult>` | 프로젝트 접근 권한 확인 | UC-004 |
| `clearAccessResult` | `projectCode` | `void` | 캐시된 권한 결과 삭제 | - |

---

## Computed State (Selectors)

### Custom Hooks (Selectors)

Zustand에서는 selector를 사용하여 필요한 상태만 구독할 수 있습니다.

```typescript
// src/hooks/useAuth.ts

// 인증 상태 확인
export const useIsAuthenticated = () => {
  return useAuthStore((state) => !!state.user && !!state.session)
}

// 사용자 프로필
export const useUserProfile = () => {
  return useAuthStore((state) => state.profile)
}

// 구독 정보
export const useSubscription = () => {
  return useAuthStore((state) => state.subscription)
}

// 로딩 상태
export const useAuthLoading = () => {
  return useAuthStore((state) => state.isLoading)
}

// 에러 상태
export const useAuthError = () => {
  return useAuthStore((state) => state.error)
}

// Computed: 플랜 레벨 체크
export const useIsPremiumOrHigher = () => {
  return useAuthStore((state) => {
    const plan = state.subscription?.plan_name
    return plan === 'premium' || plan === 'enterprise'
  })
}

// Computed: 관리자 여부
export const useIsAdmin = () => {
  return useAuthStore((state) => {
    return state.user?.email === 'tkandpf18@naver.com'
  })
}

// Computed: 구독 만료 여부
export const useIsSubscriptionExpired = () => {
  return useAuthStore((state) => {
    const sub = state.subscription
    if (!sub || !sub.expires_at) return false
    return new Date(sub.expires_at) < new Date()
  })
}
```

```typescript
// src/hooks/useProject.ts

// 특정 프로젝트 접근 권한
export const useProjectAccess = (projectCode: string) => {
  return useProjectStore((state) => state.accessResults[projectCode])
}

// 프로젝트 접근 확인 중 여부
export const useIsCheckingAccess = () => {
  return useProjectStore((state) => state.isCheckingAccess)
}
```

---

## Component-Store 매핑

### 1. Register Page (`/signup`)

**Used Stores**: `authStore`

**Used Selectors**:
```typescript
const signUpWithEmail = useAuthStore((state) => state.signUpWithEmail)
const isLoading = useAuthLoading()
const error = useAuthError()
const clearError = useAuthStore((state) => state.clearError)
```

**Actions Flow**:
1. User fills form → validate client-side
2. User clicks "회원가입" → `signUpWithEmail(email, password, nickname)`
3. Success → redirect to `/login`
4. Error → display error message

---

### 2. Login Page (`/login`)

**Used Stores**: `authStore`

**Used Selectors**:
```typescript
const signInWithEmail = useAuthStore((state) => state.signInWithEmail)
const signInWithGoogle = useAuthStore((state) => state.signInWithGoogle)
const isLoading = useAuthLoading()
const error = useAuthError()
```

**Actions Flow**:
1. User enters credentials → `signInWithEmail(email, password)`
2. OR clicks "구글 로그인" → `signInWithGoogle()`
3. Success → redirect to `/dashboard`
4. Error → display error message

---

### 3. OAuth Callback Page (`/auth/callback`)

**Used Stores**: `authStore`

**Used Selectors**:
```typescript
const loadUserData = useAuthStore((state) => state.loadUserData)
```

**Actions Flow**:
1. Page loads with OAuth callback
2. Supabase SDK auto-handles token exchange
3. Get user from session → `loadUserData(user.id)`
4. Redirect to `/dashboard`

---

### 4. Dashboard Page (`/dashboard`)

**Used Stores**: `authStore`, `projectStore`

**Used Selectors**:
```typescript
const profile = useUserProfile()
const subscription = useSubscription()
const checkAccess = useProjectStore((state) => state.checkAccess)
```

**Actions Flow**:
1. Display user profile and subscription
2. User clicks project card → `checkAccess(projectCode)`
3. If access granted → redirect to project URL with JWT
4. If access denied → show upgrade modal

---

### 5. Project Card Component

**Used Stores**: `projectStore`

**Used Selectors**:
```typescript
const checkAccess = useProjectStore((state) => state.checkAccess)
const accessResult = useProjectAccess(projectCode)
const isChecking = useIsCheckingAccess()
```

**Rendering Logic**:
```typescript
const handleClick = async () => {
  const result = await checkAccess(projectCode)

  if (result.has_access) {
    // Redirect to project with JWT
    const token = session.access_token
    window.location.href = `${projectUrl}?token=${token}`
  } else {
    // Show error or upgrade modal
    toast.error(result.error)
  }
}
```

---

## 최적화 전략

### 1. Selector 최적화

**❌ Bad - 전체 상태 구독**:
```typescript
const state = useAuthStore() // 모든 변경에 리렌더
```

**✅ Good - 필요한 것만 구독**:
```typescript
const user = useAuthStore((state) => state.user) // user 변경 시만 리렌더
```

---

### 2. Shallow Comparison

**여러 값을 동시에 구독할 때**:
```typescript
import { shallow } from 'zustand/shallow'

const { user, profile } = useAuthStore(
  (state) => ({ user: state.user, profile: state.profile }),
  shallow // 얕은 비교로 불필요한 리렌더 방지
)
```

---

### 3. Computed State 메모이제이션

**useMemo로 계산 비용 큰 것만**:
```typescript
const isPremium = useMemo(() => {
  return subscription?.plan_name === 'premium' || subscription?.plan_name === 'enterprise'
}, [subscription?.plan_name])
```

---

### 4. Persist 선택적 적용

**민감한 정보 제외**:
```typescript
persist(
  (set, get) => ({ /* ... */ }),
  {
    name: 'auth-storage',
    partialize: (state) => ({
      // session은 저장하되, error는 저장 안함
      user: state.user,
      session: state.session
    })
  }
)
```

---

## 에러 처리

### 1. Store Level Error Handling

**모든 Actions에 try-catch**:
```typescript
signInWithEmail: async (email, password) => {
  set({ isLoading: true, error: null })

  try {
    // API call
  } catch (error: any) {
    set({
      error: error.message || '기본 에러 메시지',
      isLoading: false
    })
    throw error // 컴포넌트에서 추가 처리 가능
  }
}
```

---

### 2. Component Level Error Handling

**UI에서 에러 표시 및 처리**:
```typescript
const handleLogin = async () => {
  try {
    await signInWithEmail(email, password)
    router.push('/dashboard')
  } catch (error) {
    // Store에서 이미 에러 상태 설정됨
    // 추가 로직 (예: analytics 전송)
    console.error('Login failed:', error)
  }
}
```

---

### 3. Global Error Toast

**모든 에러를 toast로 표시**:
```typescript
// src/components/ErrorToast.tsx
import { useEffect } from 'react'
import { toast } from 'sonner'
import { useAuthError } from '@/hooks/useAuth'
import { useAuthStore } from '@/stores/authStore'

export function ErrorToast() {
  const error = useAuthError()
  const clearError = useAuthStore((state) => state.clearError)

  useEffect(() => {
    if (error) {
      toast.error(error)
      clearError()
    }
  }, [error, clearError])

  return null
}
```

---

## 파일 구조

```
src/
├── stores/
│   ├── authStore.ts         # 인증 상태 관리
│   └── projectStore.ts      # 프로젝트 접근 제어
├── hooks/
│   ├── useAuth.ts           # Auth selectors
│   └── useProject.ts        # Project selectors
├── lib/
│   └── supabase.ts          # Supabase client
└── components/
    ├── ErrorToast.tsx       # 전역 에러 토스트
    └── ...
```

---

## Session 복원

### Supabase Auth Listener

**세션 자동 복원**:
```typescript
// src/app/layout.tsx or src/providers/AuthProvider.tsx
import { useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from '@/stores/authStore'

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const loadUserData = useAuthStore((state) => state.loadUserData)

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) {
        useAuthStore.setState({
          user: session.user,
          session: session
        })
        loadUserData(session.user.id)
      }
    })

    // Listen for auth changes
    const {
      data: { subscription }
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session) {
        useAuthStore.setState({
          user: session.user,
          session: session
        })
        loadUserData(session.user.id)
      } else {
        useAuthStore.setState({
          user: null,
          session: null,
          profile: null,
          subscription: null
        })
      }
    })

    return () => subscription.unsubscribe()
  }, [loadUserData])

  return <>{children}</>
}
```

---

## Best Practices

### DO ✅
- Selector로 필요한 상태만 구독
- Actions에 try-catch 에러 처리
- Persist로 세션 유지
- DevTools로 디버깅
- TypeScript 타입 명시

### DON'T ❌
- Store에서 직접 `set()` 외부 호출 금지
- 불필요한 전역 상태 저장 금지
- 민감한 정보 localStorage 저장 금지
- 모든 상태를 하나의 Store에 몰아넣기 금지

---

## Testing Strategy

### 1. Store Unit Test

```typescript
import { renderHook, act } from '@testing-library/react'
import { useAuthStore } from '@/stores/authStore'

test('should sign in with email', async () => {
  const { result } = renderHook(() => useAuthStore())

  await act(async () => {
    await result.current.signInWithEmail('test@example.com', 'password123')
  })

  expect(result.current.user).toBeTruthy()
  expect(result.current.session).toBeTruthy()
})
```

### 2. Component Integration Test

```typescript
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import LoginPage from '@/app/login/page'

test('should display error on invalid credentials', async () => {
  render(<LoginPage />)

  await userEvent.type(screen.getByLabelText('이메일'), 'wrong@example.com')
  await userEvent.type(screen.getByLabelText('비밀번호'), 'wrongpassword')
  await userEvent.click(screen.getByText('로그인'))

  await waitFor(() => {
    expect(screen.getByText(/이메일 또는 비밀번호가 일치하지 않습니다/)).toBeInTheDocument()
  })
})
```

---

## Debugging

### Redux DevTools 사용

```typescript
// Zustand devtools 미들웨어 활성화됨
// Chrome Extension: Redux DevTools
// Actions 추적, Time Travel 가능
```

### Console Logging

```typescript
// 개발 환경에서만
if (process.env.NODE_ENV === 'development') {
  useAuthStore.subscribe((state) => {
    console.log('Auth State Changed:', state)
  })
}
```

---

## 다음 단계

1. ✅ **상태관리 문서 완성** (현재)
2. ⏭️ **07 Implementation Plan** (구현 계획 수립)
3. **08 Implementation Executor** (실제 코드 작성)
4. **09 Code Smell Analyzer** (코드 품질 검증)

---

**문서 작성**: Claude Code
**버전**: 1.0
**최종 수정**: 2025-10-21
