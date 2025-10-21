# Arikonia Hub - Google OAuth Login Issue Specification

## Problem Summary
Google OAuth login fails with "Invalid API key" error on Vercel production, but works locally.

---

## Current Status

### Error Message (Vercel Production Log)
```
2025-10-21T12:46:28.973Z [error] OAuth error: Error [AuthApiError]: Invalid API key
    at bN (.next/server/app/auth/callback/route.js:21:31977)
    at async bP (.next/server/app/auth/callback/route.js:21:32951)
    at async bO (.next/server/app/auth/callback/route.js:21:32361)
    at async cl._exchangeCodeForSession (.next/server/app/auth/callback/route.js:34:5370)
    at async (.next/server/app/auth/callback/route.js:34:10745) {
  __isAuthError: true,
  status: 401,
  code: undefined
}
```

### Symptoms
1. User clicks "Google로 로그인" button
2. Redirects to Google account chooser ✅
3. User selects account ✅
4. Redirects to Google consent screen ✅
5. User clicks "Continue" button ✅
6. Redirects back to `/auth/callback` with code ✅
7. **FAILS**: Server-side `exchangeCodeForSession()` throws 401 error ❌
8. Redirects to `/login?error=auth_failed` ❌

### Environment
- **Framework**: Next.js 15.1.3 (App Router)
- **Deployment**: Vercel Production (https://www.arikonia.com)
- **Auth Provider**: Supabase Auth with Google OAuth
- **Supabase Project**: `bijluuvpkzhjbypbhlqy.supabase.co`
- **Package**: `@supabase/ssr` version (check package.json)

---

## Technical Details

### 1. Supabase Configuration

**Environment Variables (Verified set in Vercel)**:
```env
NEXT_PUBLIC_SUPABASE_URL=https://bijluuvpkzhjbypbhlqy.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpamx1dXZwa3poamJ5cGJobHF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5MDA4NTYsImV4cCI6MjA3NjQ3Njg1Nn0.QELIrKy2hYSrBYAl3gi-SHKolI12jX0Wyh3vXnJRzOk
```

**Supabase Auth Settings**:
- Site URL: `https://www.arikonia.com`
- Redirect URLs: `https://www.arikonia.com/auth/callback`
- Google OAuth Provider: Enabled
- Client ID: `681902870139-811mguf7aagsfkipsee0ac6lad8i2gpa.apps.googleusercontent.com`

### 2. Code Implementation

#### File: `lib/supabase.ts` (Client-side)
```typescript
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          const cookie = document.cookie
            .split('; ')
            .find((row) => row.startsWith(`${name}=`))
          return cookie ? decodeURIComponent(cookie.split('=')[1]) : null
        },
        set(name: string, value: string, options: any) {
          let cookie = `${name}=${encodeURIComponent(value)}`
          if (options?.maxAge) cookie += `; max-age=${options.maxAge}`
          if (options?.path) cookie += `; path=${options.path}`
          if (options?.domain) cookie += `; domain=${options.domain}`
          if (options?.sameSite) cookie += `; samesite=${options.sameSite}`
          if (options?.secure) cookie += '; secure'
          document.cookie = cookie
        },
        remove(name: string, options: any) {
          document.cookie = `${name}=; path=${options?.path || '/'}; max-age=0`
        },
      },
    }
  )
}
```

#### File: `lib/supabase-server.ts` (Server-side)
```typescript
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createServerSupabaseClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing
            // user sessions.
          }
        },
      },
    }
  )
}
```

#### File: `app/auth/callback/route.ts` (OAuth Callback Handler)
```typescript
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
```

#### File: `stores/authStore.ts` (OAuth Initiation)
```typescript
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
  } catch (error: any) {
    set({ error: error.message, isLoading: false })
    throw error
  }
},
```

### 3. OAuth Flow Trace (from Playwright test)

```
1. User clicks "Google로 로그인"
   → Client-side: supabase.auth.signInWithOAuth()
   → Generates PKCE code_challenge and code_verifier
   → Stores code_verifier in cookies
   ✅ SUCCESS

2. Redirect to Google OAuth
   → https://accounts.google.com/o/oauth2/v2/auth?...&code_challenge=auYb_r_ErYOimvXB8yqMDFVzBp6jJ7yZE4mVxeE-KuM...
   ✅ SUCCESS

3. Google authorization flow
   → User selects account
   → User consents
   → Google issues authorization code
   ✅ SUCCESS

4. Redirect to Supabase callback
   → https://bijluuvpkzhjbypbhlqy.supabase.co/auth/v1/callback?state=...&code=4/0Ab32j93V...
   → Supabase validates Google code
   → Supabase issues new code for app
   ✅ SUCCESS

5. Redirect to app callback
   → https://www.arikonia.com/auth/callback?code=9bdba626-55d8-4e40-ae44-c533780ef1e1
   → Server-side route handler executes
   → Calls supabase.auth.exchangeCodeForSession(code)
   ❌ FAILS with "Invalid API key" (401)

6. Error handling
   → Redirects to /login?error=auth_failed
   ✅ Error handled correctly
```

---

## What We've Tried

### Attempt 1: Client-side callback page
- **Method**: Used client-side `page.tsx` for callback
- **Result**: FAILED - Same 401 error
- **Reason**: Client-side can't properly handle PKCE verification

### Attempt 2: Added cookie handlers to client
- **Method**: Added custom cookie get/set/remove to `createBrowserClient()`
- **Result**: FAILED - Same 401 error
- **Reason**: Cookie handling wasn't the issue

### Attempt 3: Server-side route handler (current)
- **Method**: Created `app/auth/callback/route.ts` with `createServerClient()`
- **Result**: FAILED - "Invalid API key" error
- **Reason**: Unknown - possibly environment variable issue or PKCE verification problem

### Attempt 4: Set Vercel environment variables
- **Method**: Set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in Vercel
- **Result**: FAILED - Same "Invalid API key" error
- **Reason**: Unknown

---

## Questions for Investigation

1. **Environment Variables**:
   - Are environment variables correctly loaded in production?
   - How to verify environment variables are available in server-side route handlers?
   - Is there a difference between `NEXT_PUBLIC_*` and non-prefixed env vars for server-side?

2. **PKCE Flow**:
   - Is the `code_verifier` being properly stored in cookies during OAuth initiation?
   - Is the server-side route handler able to read the `code_verifier` cookie?
   - Does Supabase require the `code_verifier` to be explicitly passed?

3. **Supabase SSR Package**:
   - Is our `@supabase/ssr` version compatible with Next.js 15?
   - Should we use middleware instead of route handlers?
   - Are there known issues with PKCE in production environments?

4. **Cookie Configuration**:
   - Are cookies being set with correct domain/path/secure flags?
   - Does Vercel production handle cookies differently than localhost?
   - Should we use `httpOnly` cookies for PKCE?

5. **API Key Validation**:
   - Why does Supabase say "Invalid API key" when the key is correctly set?
   - Is there a service role key requirement for `exchangeCodeForSession()`?
   - Could rate limiting or IP restrictions cause this error?

---

## Expected Behavior

After clicking "Continue" on Google consent screen:
1. Should redirect to `/auth/callback?code=...`
2. Server should exchange code for session using PKCE verification
3. User profile should be created/verified in database
4. Should redirect to `/dashboard` with authenticated session

---

## Actual Behavior

After clicking "Continue" on Google consent screen:
1. ✅ Redirects to `/auth/callback?code=...`
2. ❌ `exchangeCodeForSession()` throws "Invalid API key" (401)
3. ❌ Redirects to `/login?error=auth_failed`
4. ❌ User is NOT authenticated

---

## Repository & Deployment Info

- **GitHub**: https://github.com/SweetyCarrot9812/Arikonia
- **Vercel Project**: arikonia (tkandpf26-9808s-projects)
- **Production URL**: https://www.arikonia.com
- **Latest Deployment**: 2025-10-21 (after environment variables set)

---

## Package Versions

Check `package.json` for:
- `next`: version
- `@supabase/ssr`: version
- `@supabase/supabase-js`: version (if installed)
- `react`: version
- `typescript`: version

---

## Additional Context

### Local Development
- ✅ OAuth works perfectly on `localhost:3000`
- ✅ Environment variables loaded from `.env.local`
- ✅ All callbacks and authentication flow working

### Production (Vercel)
- ❌ OAuth fails with "Invalid API key"
- ✅ Environment variables set in Vercel dashboard
- ❌ `exchangeCodeForSession()` fails
- ✅ Error handling works (redirects to login)

---

## Requested Help

Please help identify why `exchangeCodeForSession()` is throwing "Invalid API key" error in production but works locally. Specifically:

1. Is there a configuration difference needed for production?
2. Should we use middleware instead of route handlers for OAuth callback?
3. Are environment variables being loaded correctly in server-side route handlers?
4. Is there a Supabase Auth configuration we're missing?
5. Could this be a PKCE verification issue rather than an API key issue?

---

## Files to Review

Key files in the repository:
- `/lib/supabase.ts` - Client-side Supabase client
- `/lib/supabase-server.ts` - Server-side Supabase client
- `/app/auth/callback/route.ts` - OAuth callback handler
- `/stores/authStore.ts` - OAuth initiation logic (signInWithGoogle method)
- `/.env.local` - Local environment variables (not in repo)
- `/package.json` - Dependencies

---

## Last Known Working State

None - OAuth has never worked in production. This is the initial deployment attempt.

---

**Date**: 2025-10-21
**Status**: BLOCKED - Cannot proceed with deployment until OAuth is fixed
**Priority**: CRITICAL - Blocking user authentication
