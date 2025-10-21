'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuth } from '@/hooks/useAuth'
import { ProjectCard } from '@/components/features/dashboard/ProjectCard'
import { Button } from '@/components/ui/button'
import { PROJECTS } from '@/lib/constants'

export default function DashboardPage() {
  const router = useRouter()
  const { user, profile, subscription, isLoading, signOut } = useAuth()

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login')
    }
  }, [user, isLoading, router])

  const handleSignOut = async () => {
    await signOut()
    router.push('/login')
  }

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-slate-900">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-amber-600 mb-4"></div>
          <p className="text-slate-600 dark:text-slate-300">로딩 중...</p>
        </div>
      </div>
    )
  }

  if (!user || !profile) {
    return null
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-amber-50/20 to-slate-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900">
      {/* Header */}
      <header className="bg-white dark:bg-slate-800 shadow-sm border-b border-slate-200 dark:border-slate-700">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold text-slate-900 dark:text-slate-100">
                대시보드
              </h1>
              <p className="text-sm text-slate-600 dark:text-slate-400 mt-1">
                환영합니다, <span className="font-semibold">{profile.nickname}</span>님!
              </p>
            </div>
            <div className="flex items-center gap-4">
              <div className="text-right">
                <p className="text-xs text-slate-500 dark:text-slate-400">현재 플랜</p>
                <p className="text-lg font-bold text-amber-600 dark:text-amber-500">
                  {subscription?.plan_name.toUpperCase() || 'FREE'}
                </p>
              </div>
              <Button
                variant="outline"
                onClick={handleSignOut}
                className="dark:bg-slate-700 dark:text-slate-100 dark:border-slate-600 dark:hover:bg-slate-600"
              >
                로그아웃
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        {/* Subscription Info */}
        <div className="mb-8 bg-white dark:bg-slate-800 rounded-lg shadow-sm border border-slate-200 dark:border-slate-700 p-6">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-xl font-semibold text-slate-900 dark:text-slate-100 mb-2">
                구독 정보
              </h2>
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-slate-600 dark:text-slate-400">플랜</p>
                  <p className="font-semibold text-slate-900 dark:text-slate-100">
                    {subscription?.plan_name.toUpperCase() || 'FREE'}
                  </p>
                </div>
                <div>
                  <p className="text-slate-600 dark:text-slate-400">상태</p>
                  <p className="font-semibold text-green-600 dark:text-green-500">
                    {subscription?.status === 'active' ? '활성' : '비활성'}
                  </p>
                </div>
                <div>
                  <p className="text-slate-600 dark:text-slate-400">최대 프로젝트</p>
                  <p className="font-semibold text-slate-900 dark:text-slate-100">
                    {subscription?.max_projects || 'N/A'}
                  </p>
                </div>
                <div>
                  <p className="text-slate-600 dark:text-slate-400">파일 크기 제한</p>
                  <p className="font-semibold text-slate-900 dark:text-slate-100">
                    {subscription?.max_file_size_mb
                      ? `${subscription.max_file_size_mb}MB`
                      : 'N/A'}
                  </p>
                </div>
              </div>
            </div>
            <Button className="bg-amber-600 hover:bg-amber-700 dark:bg-amber-500 dark:hover:bg-amber-600">
              플랜 업그레이드
            </Button>
          </div>
        </div>

        {/* Projects */}
        <div>
          <h2 className="text-2xl font-bold text-slate-900 dark:text-slate-100 mb-4">
            프로젝트
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {PROJECTS.map((project) => (
              <ProjectCard key={project.code} project={project} />
            ))}
          </div>
        </div>
      </main>
    </div>
  )
}
