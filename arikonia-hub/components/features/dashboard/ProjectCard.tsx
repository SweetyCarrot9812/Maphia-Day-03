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
  }
}

export function ProjectCard({ project }: ProjectCardProps) {
  const [loading, setLoading] = useState(false)
  const checkAccess = useProjectStore((state) => state.checkAccess)
  const session = useAuthStore((state) => state.session)

  const handleAccess = async () => {
    setLoading(true)

    try {
      const result = await checkAccess(project.code)

      if (result.has_access) {
        // Redirect to project with JWT token for SSO
        const token = session?.access_token
        const projectUrl = `${project.url}?token=${token}`

        toast.success('접속 중...', {
          description: `${project.name}로 이동합니다`,
        })

        // Redirect to project
        window.location.href = projectUrl
      } else {
        // Show error and required plan
        toast.error(result.error || '접근 권한이 없습니다', {
          description: result.required_plan
            ? `${result.required_plan.toUpperCase()} 플랜 이상이 필요합니다`
            : '구독 플랜을 업그레이드하세요',
        })
      }
    } catch (error: any) {
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
          <ExternalLink className="h-4 w-4 text-slate-400" />
        </CardTitle>
        <CardDescription className="dark:text-slate-400">
          {project.description}
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Button
          onClick={handleAccess}
          disabled={loading}
          className="w-full bg-amber-600 hover:bg-amber-700 dark:bg-amber-500 dark:hover:bg-amber-600"
        >
          {loading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              확인 중...
            </>
          ) : (
            <>
              <Lock className="mr-2 h-4 w-4" />
              접속하기
            </>
          )}
        </Button>
      </CardContent>
    </Card>
  )
}
