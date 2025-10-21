import { create } from 'zustand'
import { devtools } from 'zustand/middleware'
import { createClient } from '@/lib/supabase'
import { CACHE_CONFIG } from '@/lib/constants'
import type { ProjectAccessResult } from '@/types'

interface CachedAccessResult {
  result: ProjectAccessResult
  timestamp: number
  expiresAt: number
}

interface ProjectState {
  accessResults: Record<string, CachedAccessResult>
  isCheckingAccess: boolean
  error: string | null

  checkAccess: (projectCode: string, forceRefresh?: boolean) => Promise<ProjectAccessResult>
  clearAccessResult: (projectCode: string) => void
  clearAllCache: () => void
}

export const useProjectStore = create<ProjectState>()(
  devtools((set, get) => ({
    accessResults: {},
    isCheckingAccess: false,
    error: null,

    checkAccess: async (projectCode: string, forceRefresh = false) => {
      try {
        // Check if we have a valid cached result
        const cached = get().accessResults[projectCode]
        const now = Date.now()

        if (cached && !forceRefresh && now < cached.expiresAt) {
          // Return cached result if still valid
          return cached.result
        }

        set({ isCheckingAccess: true, error: null })
        const supabase = createClient()

        // Get current user
        const {
          data: { user },
        } = await supabase.auth.getUser()

        if (!user) {
          const result: ProjectAccessResult = {
            has_access: false,
            project_name: projectCode,
            error: '로그인이 필요합니다',
            required_plan: 'free',
          }

          const cachedResult: CachedAccessResult = {
            result,
            timestamp: now,
            expiresAt: now + CACHE_CONFIG.PROJECT_ACCESS_TTL,
          }

          set((state) => ({
            accessResults: {
              ...state.accessResults,
              [projectCode]: cachedResult,
            },
            isCheckingAccess: false,
          }))

          return result
        }

        // Call check_project_access function
        const { data, error } = await supabase.rpc('check_project_access', {
          p_user_id: user.id,
          p_project_code: projectCode,
        })

        if (error) throw error

        const result: ProjectAccessResult = data || {
          has_access: false,
          project_name: projectCode,
          error: '접근 권한을 확인할 수 없습니다',
        }

        const cachedResult: CachedAccessResult = {
          result,
          timestamp: now,
          expiresAt: now + CACHE_CONFIG.PROJECT_ACCESS_TTL,
        }

        set((state) => ({
          accessResults: {
            ...state.accessResults,
            [projectCode]: cachedResult,
          },
          isCheckingAccess: false,
        }))

        return result
      } catch (error: any) {
        const errorResult: ProjectAccessResult = {
          has_access: false,
          project_name: projectCode,
          error: error.message,
        }

        const now = Date.now()
        const cachedResult: CachedAccessResult = {
          result: errorResult,
          timestamp: now,
          expiresAt: now + CACHE_CONFIG.PROJECT_ACCESS_TTL,
        }

        set((state) => ({
          accessResults: {
            ...state.accessResults,
            [projectCode]: cachedResult,
          },
          error: error.message,
          isCheckingAccess: false,
        }))

        return errorResult
      }
    },

    clearAccessResult: (projectCode: string) => {
      set((state) => {
        const { [projectCode]: _, ...rest } = state.accessResults
        return { accessResults: rest }
      })
    },

    clearAllCache: () => {
      set({ accessResults: {}, error: null })
    },
  }))
)
