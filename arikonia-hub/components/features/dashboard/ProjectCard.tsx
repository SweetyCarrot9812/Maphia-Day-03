'use client'

import { useState } from 'react'
import { useAuthStore } from '@/stores/authStore'
import { useProjectStore } from '@/stores/projectStore'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { toast } from 'sonner'
import { Loader2, Lock, ExternalLink } from 'lucide-react'

interface ProjectCardProps {
  project: {
    code: string
    name: string
    description: string
    url: string
    status?: 'active' | 'coming_soon'
  }
}

export function ProjectCard({ project }: ProjectCardProps) {
  const [loading, setLoading] = useState(false)
  const checkAccess = useProjectStore((state) => state.checkAccess)
  const session = useAuthStore((state) => state.session)

  const handleAccess = async () => {
    // Check if project is coming soon
    if (project.status === 'coming_soon') {
      toast.info('출시 예정', {
        description: `${project.name}은(는) 곧 만나보실 수 있습니다`,
      })
      return
    }

    setLoading(true)

    try {
      console.log('[ProjectCard] Checking access for:', project.code)
      console.log('[ProjectCard] Session:', session)

      // For now, skip access check and allow direct access
      // TODO: Re-enable after check_project_access function is deployed
      toast.success('접속 중...', {
        description: `${project.name}로 이동합니다`,
      })

      // Redirect to project SSO endpoint with JWT token
      const token = session?.access_token
      console.log('[ProjectCard] Token:', token ? `${token.substring(0, 20)}...` : 'null')

      const ssoUrl = `${project.url}/sso?token=${token}`
      console.log('[ProjectCard] Redirecting to:', ssoUrl)

      // Use window.location for full page redirect to allow cookie sharing
      window.location.href = ssoUrl

      /* Original access check - temporarily disabled
      const result = await checkAccess(project.code)
      console.log('[ProjectCard] Access result:', result)

      if (result.has_access) {
        toast.success('접속 중...', {
          description: `${project.name}로 이동합니다`,
        })

        const token = session?.access_token
        const ssoUrl = `${project.url}/sso?token=${token}`
        window.location.href = ssoUrl
      } else {
        toast.error(result.error || '접근 권한이 없습니다', {
          description: result.required_plan
            ? `${result.required_plan.toUpperCase()} 플랜 이상이 필요합니다`
            : '구독 플랜을 업그레이드하세요',
        })
      }
      */
    } catch (error: any) {
      console.error('[ProjectCard] Error:', error)
      toast.error('접근 권한 확인 실패', {
        description: error.message,
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card className="border-slate-200 dark:border-slate-700 dark:bg-slate-800 hover:shadow-lg transition-shadow">
      <CardHeader>
        <CardTitle className="text-xl font-bold text-slate-900 dark:text-slate-100 flex items-center gap-2">
          {project.name}
          {project.status === 'active' ? (
            <span className="ml-auto px-2 py-1 text-xs font-medium bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-full">
              운영중
            </span>
          ) : (
            <span className="ml-auto px-2 py-1 text-xs font-medium bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 rounded-full">
              출시 예정
            </span>
          )}
        </CardTitle>
        <CardDescription className="dark:text-slate-400">
          {project.description}
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Button
          onClick={handleAccess}
          disabled={loading || project.status === 'coming_soon'}
          className="w-full bg-amber-600 hover:bg-amber-700 dark:bg-amber-500 dark:hover:bg-amber-600 disabled:opacity-50"
        >
          {loading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              확인 중...
            </>
          ) : project.status === 'coming_soon' ? (
            <>
              <Lock className="mr-2 h-4 w-4" />
              출시 예정
            </>
          ) : (
            <>
              <ExternalLink className="mr-2 h-4 w-4" />
              접속하기
            </>
          )}
        </Button>
      </CardContent>
    </Card>
  )
}
