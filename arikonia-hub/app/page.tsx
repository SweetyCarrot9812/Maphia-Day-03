'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useUser, useSignOut, useSubscription } from '@/hooks/useAuth'
import { useProjectStore } from '@/stores/projectStore'
import { useAuthStore } from '@/stores/authStore'
import { createClient } from '@/lib/supabase'
import { toast } from 'sonner'

export default function HomePage() {
  const router = useRouter()
  const user = useUser()
  const subscription = useSubscription()
  const signOut = useSignOut()
  const [isDark, setIsDark] = useState(false)

  useEffect(() => {
    const saved = localStorage.getItem('darkMode')
    if (saved) {
      setIsDark(saved === 'true')
      document.documentElement.classList.toggle('dark', saved === 'true')
    }
  }, [])

  const toggleDark = () => {
    const newValue = !isDark
    setIsDark(newValue)
    localStorage.setItem('darkMode', String(newValue))
    document.documentElement.classList.toggle('dark', newValue)
  }

  const handleSignOut = async () => {
    try {
      await signOut()
      // Force page reload to clear all state
      window.location.reload()
    } catch (error) {
      console.error('로그아웃 실패:', error)
      // Force reload even on error to clear client state
      window.location.reload()
    }
  }

  const handleProjectAccess = async (projectCode: string, projectUrl: string, projectName: string) => {
    // Not logged in - redirect to login
    if (!user) {
      toast.error('로그인이 필요합니다', {
        description: '프로젝트에 접근하려면 먼저 로그인하세요',
      })
      router.push('/login')
      return
    }

    try {
      const supabase = createClient()

      // Check project access
      const { data, error } = await supabase.rpc('check_project_access', {
        p_user_id: user.id,
        p_project_code: projectCode,
      })

      if (error) {
        console.error('Access check error:', error)
        toast.error('접근 권한 확인 실패')
        return
      }

      if (!data?.has_access) {
        toast.error('접근 권한이 없습니다', {
          description: data?.required_plan
            ? `${data.required_plan.toUpperCase()} 플랜 이상이 필요합니다`
            : '구독 플랜을 업그레이드하세요',
        })
        return
      }

      // Get access token
      const { data: { session } } = await supabase.auth.getSession()

      if (!session?.access_token) {
        toast.error('인증 토큰을 가져올 수 없습니다')
        return
      }

      // Redirect to project with SSO token
      const ssoUrl = `${projectUrl}/sso?token=${session.access_token}`

      toast.success('접속 중...', {
        description: `${projectName}로 이동합니다`,
      })

      // Use window.location for full page navigation
      window.location.href = ssoUrl
    } catch (error: any) {
      console.error('Project access error:', error)
      toast.error('프로젝트 접속 실패', {
        description: error.message,
      })
    }
  }

  const projects = [
    {
      code: "carelit",
      name: "Care-Lit",
      nameKo: "케어릿",
      tagline: "돌봄을 위한 지식의 빛",
      description: "의학 및 간호학 국가고시 학습 플랫폼",
      color: "from-blue-500 to-cyan-400",
      icon: "💡",
      url: process.env.NEXT_PUBLIC_CARELIT_URL || "http://localhost:3001",
      status: "운영 중"
    },
    {
      code: "temflow",
      name: "Tem-Flow",
      nameKo: "템플로우",
      tagline: "내 몸을 성전처럼",
      description: "헬스 및 운동 관리 플랫폼",
      color: "from-green-500 to-emerald-400",
      icon: "🏃",
      url: "https://temflow.arikonia.com",
      status: "준비 중"
    },
    {
      code: "arisper",
      name: "Arisper",
      nameKo: "아리스퍼",
      tagline: "아름다운 속삭임",
      description: "언어 학습 플랫폼",
      color: "from-purple-500 to-pink-400",
      icon: "🗣️",
      url: "https://arisper.arikonia.com",
      status: "준비 중"
    },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-amber-50/30 to-slate-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900">
      {/* Header */}
      <header className="border-b border-slate-200 dark:border-slate-700 bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm sticky top-0 z-50 shadow-sm">
        <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-slate-900 dark:text-slate-100">
                Arikonia
              </h1>
              <p className="text-sm text-slate-600 dark:text-slate-400 mt-1">
                아름다운 지식 공동체
              </p>
            </div>
            <div className="flex items-center gap-4">
              <button
                onClick={toggleDark}
                className="rounded-lg p-2 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors"
                aria-label="다크모드 토글"
              >
                {isDark ? (
                  <svg className="w-5 h-5 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" clipRule="evenodd" />
                  </svg>
                ) : (
                  <svg className="w-5 h-5 text-slate-700" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z" />
                  </svg>
                )}
              </button>

              {user ? (
                <div className="flex items-center gap-3">
                  <div className="text-right hidden sm:block">
                    <p className="text-sm font-medium text-slate-900 dark:text-slate-100">{user.email}</p>
                    {subscription && (
                      <p className="text-xs text-amber-600 dark:text-amber-400">{subscription.plan_name.toUpperCase()}</p>
                    )}
                  </div>
                  <button
                    onClick={() => router.push('/settings')}
                    className="rounded-lg bg-amber-600 dark:bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-700 dark:hover:bg-amber-600 transition-colors"
                  >
                    프로필 설정
                  </button>
                  <button
                    onClick={handleSignOut}
                    className="rounded-lg bg-slate-200 dark:bg-slate-700 px-4 py-2 text-sm font-medium text-slate-900 dark:text-slate-100 hover:bg-slate-300 dark:hover:bg-slate-600 transition-colors"
                  >
                    로그아웃
                  </button>
                </div>
              ) : (
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => router.push('/login')}
                    className="rounded-lg px-4 py-2 text-sm font-medium text-slate-900 dark:text-slate-100 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors"
                  >
                    로그인
                  </button>
                  <button
                    onClick={() => router.push('/signup')}
                    className="rounded-lg bg-amber-600 dark:bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-700 dark:hover:bg-amber-600 transition-colors"
                  >
                    회원가입
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8">
        <div className="text-center">
          <h2 className="text-5xl font-bold text-slate-900 dark:text-slate-100 sm:text-6xl lg:text-7xl">
            아름다운 지식,
            <br />
            <span className="bg-gradient-to-r from-amber-600 to-amber-400 dark:from-amber-500 dark:to-amber-300 bg-clip-text text-transparent">
              함께 성장하는 공동체
            </span>
          </h2>
          <p className="mx-auto mt-6 max-w-2xl text-lg text-slate-600 dark:text-slate-300">
            <span className="font-semibold">아리코니아</span>는 의학, 언어, 운동, 경제, 음악, 신앙까지
            <br />
            전문성과 따뜻함이 공존하는 학습 생태계입니다
          </p>
          <div className="mt-8 flex justify-center gap-4">
            <div className="rounded-lg bg-white dark:bg-slate-800 px-6 py-3 shadow-md border border-slate-200 dark:border-slate-700">
              <div className="text-sm text-slate-500 dark:text-slate-400">아리</div>
              <div className="font-semibold text-slate-900 dark:text-slate-100">아름답고 곱다</div>
            </div>
            <div className="flex items-center text-2xl text-slate-400 dark:text-slate-500">+</div>
            <div className="rounded-lg bg-white dark:bg-slate-800 px-6 py-3 shadow-md border border-slate-200 dark:border-slate-700">
              <div className="text-sm text-slate-500 dark:text-slate-400">코이노니아</div>
              <div className="font-semibold text-slate-900 dark:text-slate-100">교제, 나눔, 공동체</div>
            </div>
          </div>
        </div>
      </section>

      {/* Projects Grid */}
      <section className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8">
        <div className="mb-12 text-center">
          <h3 className="text-3xl font-bold text-slate-900 dark:text-slate-100">우리의 프로젝트</h3>
          <p className="mt-3 text-slate-600 dark:text-slate-300">
            각 분야의 전문성과 기독교적 가치가 담긴 학습 플랫폼
          </p>
        </div>

        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          {projects.map((project) => (
            <div
              key={project.name}
              className={`group relative overflow-hidden rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 p-8 shadow-lg transition-all duration-300 hover:shadow-2xl hover:-translate-y-1 ${
                project.status === "준비 중" ? "opacity-75" : ""
              }`}
            >
              {/* Status Badge */}
              <div className="absolute right-4 top-4">
                <span className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-medium ${
                  project.status === "운영 중"
                    ? "bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300"
                    : project.status === "준비 중"
                    ? "bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300"
                    : "bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-300"
                }`}>
                  {project.status}
                </span>
              </div>

              {/* Icon */}
              <div className="mb-4 text-5xl">
                {project.icon}
              </div>

              {/* Title */}
              <h4 className="mb-2 text-2xl font-bold text-slate-900 dark:text-slate-100">
                {project.name}
                <span className="ml-2 text-lg text-slate-500 dark:text-slate-400">
                  {project.nameKo}
                </span>
              </h4>

              {/* Tagline */}
              <p className={`mb-3 bg-gradient-to-r ${project.color} bg-clip-text text-lg font-semibold text-transparent`}>
                {project.tagline}
              </p>

              {/* Description */}
              <p className="text-slate-600 dark:text-slate-300 mb-6">
                {project.description}
              </p>

              {/* Access Button */}
              {project.status === "운영 중" ? (
                <button
                  onClick={() => handleProjectAccess(project.code, project.url, project.name)}
                  className="w-full rounded-lg bg-gradient-to-r from-amber-600 to-amber-500 dark:from-amber-500 dark:to-amber-400 px-4 py-3 text-sm font-medium text-white hover:from-amber-700 hover:to-amber-600 dark:hover:from-amber-600 dark:hover:to-amber-500 transition-all duration-200 shadow-md hover:shadow-lg flex items-center justify-center gap-2"
                >
                  <span>프로젝트 접속</span>
                  <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                  </svg>
                </button>
              ) : (
                <div className="w-full rounded-lg bg-slate-100 dark:bg-slate-700 px-4 py-3 text-sm font-medium text-slate-500 dark:text-slate-400 text-center">
                  {project.status}
                </div>
              )}
            </div>
          ))}
        </div>
      </section>

      {/* Vision Section */}
      <section className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8">
        <div className="rounded-3xl bg-gradient-to-r from-amber-100 to-slate-100 dark:from-amber-900/20 dark:to-slate-800/50 border border-amber-200 dark:border-amber-800/30 p-12 text-center">
          <h3 className="text-3xl font-bold text-slate-900 dark:text-slate-100">우리의 비전</h3>
          <p className="mx-auto mt-6 max-w-3xl text-lg text-slate-700 dark:text-slate-300 leading-relaxed">
            <strong>Arikonia</strong>는 단순한 학습을 넘어,
            <br />
            지식과 경험을 공유하며 함께 성장하는 <span className="text-amber-700 dark:text-amber-400 font-semibold">열린 지식 공동체</span>를 만들어갑니다.
            <br />
            <br />
            한국적 감성과 세계적 전문성이 어우러진
            <br />
            새로운 교육 생태계를 함께 경험하세요.
          </p>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800">
        <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
          <div className="text-center">
            <p className="text-2xl font-bold text-slate-900 dark:text-slate-100 mb-2">Arikonia</p>
            <p className="text-sm text-slate-500 dark:text-slate-400">
              아름다운 지식 공동체 · Beautiful Knowledge Community
            </p>
            <p className="mt-4 text-xs text-slate-400 dark:text-slate-500">
              © 2025 Arikonia. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
