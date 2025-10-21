import { createServerSupabaseClient } from '@/lib/supabase-server'
import { NextResponse } from 'next/server'

// Node 런타임 강제 및 동적 처리 강제
export const runtime = 'nodejs'
export const dynamic = 'force-dynamic'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')
  const origin = requestUrl.origin

  // 진단 로그: 환경변수 존재 여부 확인
  const hasUrl = !!(process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL)
  const hasKey = !!(process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)
  const keyLength = (process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '').length
  const keyPrefix = (process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '').substring(0, 10)

  console.log('[Auth Callback] ENV 체크', { hasUrl, hasKey, keyLength, keyPrefix })

  if (code) {
    const supabase = await createServerSupabaseClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code)

    if (error) {
      console.error('[Auth Callback] OAuth error:', error)
      return NextResponse.redirect(`${origin}/login?error=auth_failed`)
    }

    // Get session to check if user profile exists
    const {
      data: { session },
    } = await supabase.auth.getSession()

    if (session?.user) {
      // Check if user profile exists
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

        await supabase.from('users').insert({
          id: session.user.id,
          email: session.user.email!,
          nickname,
          avatar_url: session.user.user_metadata?.avatar_url || null,
        })
      }
    }
  }

  // URL to redirect to after sign in process completes
  return NextResponse.redirect(`${origin}/dashboard`)
}
