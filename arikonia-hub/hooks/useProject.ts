import { useProjectStore } from '@/stores/projectStore'

// Core selectors
export const useProjectAccess = (projectCode: string) =>
  useProjectStore((state) => state.accessResults[projectCode]?.result)

export const useIsCheckingAccess = () =>
  useProjectStore((state) => state.isCheckingAccess)

export const useProjectError = () => useProjectStore((state) => state.error)

// Action selectors
export const useCheckAccess = () => useProjectStore((state) => state.checkAccess)

export const useClearAccessResult = () =>
  useProjectStore((state) => state.clearAccessResult)

export const useClearAllCache = () =>
  useProjectStore((state) => state.clearAllCache)

// Combined hook for convenience
export const useProject = () => ({
  isCheckingAccess: useIsCheckingAccess(),
  error: useProjectError(),
  checkAccess: useCheckAccess(),
  clearAccessResult: useClearAccessResult(),
  clearAllCache: useClearAllCache(),
})
