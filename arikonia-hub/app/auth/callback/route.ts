import { createServerSupabaseClient } from '@/lib/supabase-server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')
  const origin = requestUrl.origin

  if (code) {
    const supabase = await createServerSupabaseClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code)

    if (error) {
      console.error('OAuth error:', error)
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
