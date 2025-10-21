import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import { createClient } from '@/lib/supabase'
import type { User, Session, UserProfile, Subscription } from '@/types'

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
  initializeSession: () => Promise<void>
  signUpWithEmail: (
    email: string,
    password: string,
    name: string,
    nickname: string,
    birthDate?: string,
    phone?: string
  ) => Promise<{ confirmationRequired: boolean }>
  signInWithEmail: (email: string, password: string) => Promise<void>
  signInWithGoogle: () => Promise<void>
  signOut: () => Promise<void>
  loadUserData: (userId: string) => Promise<void>
  updateProfile: (data: {
    name?: string
    nickname?: string
    birth_date?: string
    phone?: string
  }) => Promise<void>
  changePassword: (currentPassword: string, newPassword: string) => Promise<void>
  clearError: () => void
}

export const useAuthStore = create<AuthState>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial State
        user: null,
        session: null,
        profile: null,
        subscription: null,
        isLoading: false,
        error: null,

        // Sign Up with Email
        signUpWithEmail: async (
          email: string,
          password: string,
          name: string,
          nickname: string,
          birthDate?: string,
          phone?: string
        ) => {
          try {
            set({ isLoading: true, error: null })
            const supabase = createClient()

            // Step 1: Check if email already exists (중복 검사)
            const { data: existingUser, error: checkError } = await supabase
              .from('users')
              .select('email')
              .eq('email', email)
              .maybeSingle()

            if (checkError && checkError.code !== 'PGRST116') {
              // PGRST116 is "no rows returned" - this is expected
              throw new Error('이메일을 확인하는 중 오류가 발생했습니다')
            }

            if (existingUser) {
              throw new Error('이미 사용 중인 이메일입니다')
            }

            // 이메일 중복 없음 - 사용 가능
            set({ error: null })

            // Step 2: Create auth user
            const { data: authData, error: authError } = await supabase.auth.signUp({
              email,
              password,
              options: {
                data: {
                  name,
                  nickname,
                  birth_date: birthDate,
                  phone,
                }
              }
            })

            if (authError) {
              // Handle specific Supabase auth errors
              if (authError.message.includes('already registered')) {
                throw new Error('이미 가입된 이메일입니다. 로그인해주세요.')
              }
              throw authError
            }

            if (!authData.user) throw new Error('회원가입에 실패했습니다')

            // Step 3: Insert user profile (trigger will handle subscription)
            const { error: profileError } = await supabase
              .from('users')
              .insert({
                id: authData.user.id,
                email,
                name,
                nickname,
                birth_date: birthDate,
                phone: phone,
                avatar_url: null,
              })

            if (profileError) {
              // Handle duplicate email error
              if (profileError.code === '23505') {
                throw new Error('이미 사용 중인 이메일입니다')
              }
              throw profileError
            }

            set({ isLoading: false })

            // Return confirmation required status
            return {
              confirmationRequired: !authData.session, // No session = email confirmation needed
            }
          } catch (error: any) {
            set({ error: error.message, isLoading: false })
            throw error
          }
        },

        // Sign In with Email
        signInWithEmail: async (email: string, password: string) => {
          try {
            set({ isLoading: true, error: null })
            const supabase = createClient()

            const { data, error } = await supabase.auth.signInWithPassword({
              email,
              password,
            })

            if (error) throw error

            // Set user and session first
            set({ user: data.user, session: data.session })

            // Load additional user data (profile + subscription)
            if (data.user) {
              await get().loadUserData(data.user.id)
            }

            set({ isLoading: false })
          } catch (error: any) {
            set({ error: error.message, isLoading: false })
            throw error
          }
        },

        // Sign In with Google OAuth
        signInWithGoogle: async () => {
          try {
            set({ isLoading: true, error: null })
            const supabase = createClient()

            const { error } = await supabase.auth.signInWithOAuth({
              provider: 'google',
              options: {
                redirectTo: `${window.location.origin}/auth/callback`,
                queryParams: {
                  access_type: 'offline',
                  prompt: 'consent',
                },
              },
            })

            if (error) throw error

            // OAuth flow redirects automatically
            // Callback page will handle the rest
          } catch (error: any) {
            set({ error: error.message, isLoading: false })
            throw error
          }
        },

        // Sign Out
        signOut: async () => {
          try {
            set({ isLoading: true, error: null })
            const supabase = createClient()

            const { error } = await supabase.auth.signOut()

            if (error) throw error

            // Clear state
            set({
              user: null,
              session: null,
              profile: null,
              subscription: null,
              isLoading: false,
            })

            // Clear localStorage to remove persisted state
            localStorage.removeItem('auth-storage')
          } catch (error: any) {
            set({ error: error.message, isLoading: false })
            // Clear localStorage even on error
            localStorage.removeItem('auth-storage')
            throw error
          }
        },

        // Initialize Session from Supabase cookies
        initializeSession: async () => {
          try {
            const supabase = createClient()
            const { data: { session } } = await supabase.auth.getSession()

            if (session?.user) {
              set({ user: session.user, session })
              await get().loadUserData(session.user.id)
            }
          } catch (error: any) {
            console.error('[Auth] Session initialization failed:', error)
            set({ error: error.message })
          }
        },

        // Load User Data (Profile + Subscription) - Optimized with JOIN
        loadUserData: async (userId: string) => {
          try {
            const supabase = createClient()

            // Single query with JOIN for better performance
            const { data, error } = await supabase
              .from('users')
              .select(`
                *,
                user_subscriptions!inner (
                  plan_id,
                  status,
                  expires_at,
                  subscription_plans (
                    id,
                    name,
                    display_name
                  )
                )
              `)
              .eq('id', userId)
              .eq('user_subscriptions.status', 'active')
              .single()

            if (error) throw error

            // Extract profile data
            const { user_subscriptions, ...profileData } = data

            // Extract subscription data (take first active subscription)
            const subData = user_subscriptions?.[0]
            const subscription: Subscription | null = subData
              ? {
                  plan_id: subData.plan_id,
                  plan_name: subData.subscription_plans.name as 'free' | 'basic' | 'premium' | 'enterprise',
                  status: subData.status,
                  expires_at: subData.expires_at,
                }
              : null

            set({
              profile: profileData,
              subscription,
            })
          } catch (error: any) {
            set({ error: error.message })
            throw error
          }
        },

        // Clear Error
        // Update Profile
        updateProfile: async (data: {
          name?: string
          nickname?: string
          birth_date?: string
          phone?: string
        }) => {
          try {
            set({ isLoading: true, error: null })
            const supabase = createClient()
            const user = useAuthStore.getState().user

            if (!user) throw new Error('로그인이 필요합니다')

            const { error } = await supabase
              .from('users')
              .update({
                ...data,
                updated_at: new Date().toISOString(),
              })
              .eq('id', user.id)

            if (error) throw error

            // Reload user data
            await useAuthStore.getState().loadUserData(user.id)

            set({ isLoading: false })
          } catch (error: any) {
            set({ error: error.message, isLoading: false })
            throw error
          }
        },

        // Change Password
        changePassword: async (currentPassword: string, newPassword: string) => {
          try {
            set({ isLoading: true, error: null })
            const supabase = createClient()

            // Verify current password by attempting re-authentication
            const user = useAuthStore.getState().user
            if (!user?.email) throw new Error('로그인이 필요합니다')

            const { error: signInError } = await supabase.auth.signInWithPassword({
              email: user.email,
              password: currentPassword,
            })

            if (signInError) {
              throw new Error('현재 비밀번호가 올바르지 않습니다')
            }

            // Update password
            const { error } = await supabase.auth.updateUser({
              password: newPassword,
            })

            if (error) throw error

            set({ isLoading: false })
          } catch (error: any) {
            set({ error: error.message, isLoading: false })
            throw error
          }
        },

        clearError: () => set({ error: null }),
      }),
      {
        name: 'auth-storage',
        partialize: (state) => ({
          // Only persist minimal non-sensitive user info
          // Session tokens managed by Supabase (secure httpOnly cookies)
          user: state.user ? {
            id: state.user.id,
            email: state.user.email,
          } : null,
        }),
      }
    )
  )
)
