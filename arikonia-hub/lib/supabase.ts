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

          if (options?.maxAge) {
            cookie += `; max-age=${options.maxAge}`
          }

          // Always set path to root
          cookie += `; path=${options?.path || '/'}`

          // Set domain to .arikonia.com for SSO across subdomains
          const domain = options?.domain || (typeof window !== 'undefined' && window.location.hostname.includes('arikonia.com')
            ? '.arikonia.com'
            : undefined)
          if (domain) {
            cookie += `; domain=${domain}`
          }

          if (options?.sameSite) {
            cookie += `; samesite=${options.sameSite}`
          }
          if (options?.secure !== false) {
            cookie += '; secure'
          }

          document.cookie = cookie
        },
        remove(name: string, options: any) {
          // Remove from current domain
          document.cookie = `${name}=; path=${options?.path || '/'}; max-age=0`

          // Also remove from .arikonia.com domain for SSO
          const domain = typeof window !== 'undefined' && window.location.hostname.includes('arikonia.com')
            ? '.arikonia.com'
            : undefined

          if (domain) {
            document.cookie = `${name}=; path=${options?.path || '/'}; domain=${domain}; max-age=0`
          }
        },
      },
    }
  )
}
