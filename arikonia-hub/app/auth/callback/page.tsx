'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import { useAuthStore } from '@/stores/authStore'

export default function AuthCallbackPage() {
  const router = useRouter()
  const loadUserData = useAuthStore((state) => state.loadUserData)

  useEffect(() => {
    const handleCallback = async () => {
      try {
        const supabase = createClient()

        // Exchange code from URL for session
        const code = new URL(window.location.href).searchParams.get('code')

        if (!code) {
          console.error('No code in callback URL')
          router.push('/login?error=no_code')
          return
        }

        const { data, error } = await supabase.auth.exchangeCodeForSession(code)

        if (error) {
          console.error('OAuth callback error:', error)
          router.push('/login?error=oauth_failed')
          return
        }

        const session = data.session

        if (session?.user) {
          // For Google OAuth, check if profile exists
          const { data: existingProfile } = await supabase
            .from('users')
            .select('id')
            .eq('id', session.user.id)
            .single()

          if (!existingProfile) {
            // Create profile for new OAuth user
            const nickname =
              session.user.user_metadata?.full_name ||
              session.user.email?.split('@')[0] ||
              'User'

            const avatarUrl = session.user.user_metadata?.avatar_url || null

            await supabase.from('users').insert({
              id: session.user.id,
              email: session.user.email!,
              nickname,
              avatar_url: avatarUrl,
            })

            // Free plan will be assigned by trigger handle_new_user()
          }

          // Load user data into store
          await loadUserData(session.user.id)

          // Redirect to dashboard
          router.push('/dashboard')
        } else {
          // No session - redirect to login
          router.push('/login')
        }
      } catch (error) {
        console.error('Callback handling error:', error)
        router.push('/login?error=callback_failed')
      }
    }

    handleCallback()
  }, [router, loadUserData])

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-50 via-amber-50/30 to-slate-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900">
      <div className="text-center">
        <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-amber-600 dark:border-amber-500 mb-4"></div>
        <p className="text-slate-900 dark:text-slate-100 text-lg font-medium">
          로그인 처리 중...
        </p>
      </div>
    </div>
  )
}
