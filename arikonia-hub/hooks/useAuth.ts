import { useAuthStore } from '@/stores/authStore'

// Core selectors
export const useIsAuthenticated = () =>
  useAuthStore((state) => !!state.user && !!state.session)

export const useUser = () => useAuthStore((state) => state.user)

export const useSession = () => useAuthStore((state) => state.session)

export const useUserProfile = () => useAuthStore((state) => state.profile)

export const useSubscription = () => useAuthStore((state) => state.subscription)

// UI State selectors
export const useAuthLoading = () => useAuthStore((state) => state.isLoading)

export const useAuthError = () => useAuthStore((state) => state.error)

// Action selectors
export const useSignUpWithEmail = () => useAuthStore((state) => state.signUpWithEmail)

export const useSignInWithEmail = () => useAuthStore((state) => state.signInWithEmail)

export const useSignInWithGoogle = () => useAuthStore((state) => state.signInWithGoogle)

export const useSignOut = () => useAuthStore((state) => state.signOut)

export const useLoadUserData = () => useAuthStore((state) => state.loadUserData)

export const useClearError = () => useAuthStore((state) => state.clearError)

// Computed selectors
export const useIsPremiumOrHigher = () =>
  useAuthStore((state) => {
    const plan = state.subscription?.plan_name
    return plan === 'premium' || plan === 'enterprise'
  })

export const useIsAdmin = () =>
  useAuthStore((state) => state.subscription?.plan_name === 'enterprise')

export const useIsSubscriptionExpired = () =>
  useAuthStore((state) => {
    const sub = state.subscription
    if (!sub || !sub.expires_at) return false
    return new Date(sub.expires_at) < new Date()
  })

// Combined hook for convenience
export const useAuth = () => ({
  user: useUser(),
  session: useSession(),
  profile: useUserProfile(),
  subscription: useSubscription(),
  isLoading: useAuthLoading(),
  error: useAuthError(),
  isAuthenticated: useIsAuthenticated(),
  isPremiumOrHigher: useIsPremiumOrHigher(),
  isAdmin: useIsAdmin(),
  isSubscriptionExpired: useIsSubscriptionExpired(),
  signUpWithEmail: useSignUpWithEmail(),
  signInWithEmail: useSignInWithEmail(),
  signInWithGoogle: useSignInWithGoogle(),
  signOut: useSignOut(),
  loadUserData: useLoadUserData(),
  clearError: useClearError(),
})
