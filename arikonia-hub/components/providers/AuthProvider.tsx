'use client'

import { useEffect } from 'react'
import { useAuthStore } from '@/stores/authStore'
import { createClient } from '@/lib/supabase'

export function AuthProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    const supabase = createClient()

    // Initialize session from Supabase cookies
    useAuthStore.getState().initializeSession()

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (event === 'SIGNED_IN' && session?.user) {
          useAuthStore.setState({ user: session.user, session })
          await useAuthStore.getState().loadUserData(session.user.id)
        } else if (event === 'SIGNED_OUT') {
          useAuthStore.setState({
            user: null,
            session: null,
            profile: null,
            subscription: null,
          })
        }
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  return <>{children}</>
}
