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
    console.log('[Logout] Button clicked')
    try {
      console.log('[Logout] Calling signOut...')
      await signOut()
      console.log('[Logout] SignOut success')
    } catch (error) {
      console.error('[Logout] SignOut failed:', error)
    } finally {
      console.log('[Logout] Redirecting to /')
      // Force redirect to root to clear all state
      window.location.href = '/'
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
      tagline: "데이터로 읽는 내 몸의 흐름",
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
                <div className="flex items-center gap-2 sm:gap-3">
                  <div className="text-right hidden md:block">
                    <p className="text-sm font-medium text-slate-900 dark:text-slate-100">{user.email}</p>
                    {subscription && (
                      <p className="text-xs text-amber-600 dark:text-amber-400">{subscription.plan_name.toUpperCase()}</p>
                    )}
                  </div>
                  <button
                    onClick={() => router.push('/settings')}
                    className="rounded-lg bg-amber-600 dark:bg-amber-500 px-3 sm:px-4 py-2 text-xs sm:text-sm font-medium text-white hover:bg-amber-700 dark:hover:bg-amber-600 transition-colors"
                  >
                    <span className="hidden sm:inline">프로필 설정</span>
                    <span className="sm:hidden">설정</span>
                  </button>
                  <button
                    onClick={handleSignOut}
                    className="rounded-lg bg-slate-200 dark:bg-slate-700 px-3 sm:px-4 py-2 text-xs sm:text-sm font-medium text-slate-900 dark:text-slate-100 hover:bg-slate-300 dark:hover:bg-slate-600 transition-colors"
                  >
                    로그아웃
                  </button>
                </div>
              ) : (
                <div className="flex items-center gap-2 sm:gap-3">
                  <button
                    onClick={() => router.push('/login')}
                    className="rounded-lg px-3 sm:px-4 py-2 text-xs sm:text-sm font-medium text-slate-900 dark:text-slate-100 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors"
                  >
                    로그인
                  </button>
                  <button
                    onClick={() => router.push('/signup')}
                    className="rounded-lg bg-amber-600 dark:bg-amber-500 px-3 sm:px-4 py-2 text-xs sm:text-sm font-medium text-white hover:bg-amber-700 dark:hover:bg-amber-600 transition-colors"
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
      <section className="relative mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8 overflow-hidden">
        {/* Background decorations */}
        <div className="absolute inset-0 -z-10">
          <div className="absolute top-0 left-1/4 w-96 h-96 bg-amber-200/30 dark:bg-amber-500/10 rounded-full blur-3xl animate-pulse"></div>
          <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-blue-200/30 dark:bg-blue-500/10 rounded-full blur-3xl animate-pulse delay-1000"></div>
        </div>

        <div className="text-center relative">
          <div className="inline-block mb-4 px-4 py-2 bg-amber-100 dark:bg-amber-900/30 rounded-full border border-amber-200 dark:border-amber-800/50">
            <span className="text-sm font-medium text-amber-800 dark:text-amber-300">아름다운 지식 공동체</span>
          </div>

          <h2 className="text-4xl font-extrabold text-slate-900 dark:text-slate-100 sm:text-6xl lg:text-7xl leading-tight">
            지식과 성장,
            <br />
            <span className="relative inline-block">
              <span className="bg-gradient-to-r from-amber-600 via-amber-500 to-orange-500 dark:from-amber-400 dark:via-amber-300 dark:to-orange-400 bg-clip-text text-transparent animate-gradient">
                함께 만들어가는 여정
              </span>
              <svg className="absolute -bottom-2 left-0 right-0 h-3" viewBox="0 0 200 6" preserveAspectRatio="none">
                <path d="M0,3 Q50,1 100,3 T200,3" stroke="url(#gradient)" strokeWidth="3" fill="none" />
                <defs>
                  <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="0%">
                    <stop offset="0%" stopColor="#d97706" />
                    <stop offset="100%" stopColor="#f59e0b" />
                  </linearGradient>
                </defs>
              </svg>
            </span>
          </h2>

          <p className="mx-auto mt-8 max-w-2xl text-lg sm:text-xl text-slate-600 dark:text-slate-300 leading-relaxed">
            의학부터 음악까지, <span className="font-bold text-amber-700 dark:text-amber-400">전문성</span>과
            <span className="font-bold text-blue-700 dark:text-blue-400"> 따뜻함</span>이 어우러진 학습 생태계
          </p>

          <div className="mt-12 flex flex-wrap justify-center gap-6 sm:gap-8">
            <div className="group relative">
              <div className="absolute inset-0 bg-gradient-to-r from-amber-500 to-orange-500 rounded-2xl blur opacity-25 group-hover:opacity-40 transition-opacity"></div>
              <div className="relative rounded-2xl bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm px-6 py-4 shadow-xl border border-amber-200/50 dark:border-amber-700/50 hover:scale-105 transition-transform">
                <div className="text-xs font-medium text-amber-600 dark:text-amber-400 mb-1">아리 (雅麗)</div>
                <div className="font-bold text-slate-900 dark:text-slate-100">아름답고 곱다</div>
              </div>
            </div>

            <div className="flex items-center">
              <div className="text-3xl font-light text-amber-400 dark:text-amber-500">×</div>
            </div>

            <div className="group relative">
              <div className="absolute inset-0 bg-gradient-to-r from-blue-500 to-cyan-500 rounded-2xl blur opacity-25 group-hover:opacity-40 transition-opacity"></div>
              <div className="relative rounded-2xl bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm px-6 py-4 shadow-xl border border-blue-200/50 dark:border-blue-700/50 hover:scale-105 transition-transform">
                <div className="text-xs font-medium text-blue-600 dark:text-blue-400 mb-1">κοινωνία</div>
                <div className="font-bold text-slate-900 dark:text-slate-100">교제, 나눔, 공동체</div>
              </div>
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

        <div className="grid gap-6 sm:gap-8 md:grid-cols-2 lg:grid-cols-3">
          {projects.map((project, index) => (
            <div
              key={project.name}
              className={`group relative overflow-hidden rounded-3xl bg-gradient-to-br from-white to-slate-50 dark:from-slate-800 dark:to-slate-900 border border-slate-200/50 dark:border-slate-700/50 p-6 sm:p-8 shadow-xl transition-all duration-500 hover:shadow-2xl hover:-translate-y-2 ${
                project.status === "준비 중" ? "opacity-75" : ""
              }`}
              style={{ animationDelay: `${index * 100}ms` }}
            >
              {/* Gradient overlay on hover */}
              <div className={`absolute inset-0 bg-gradient-to-br ${project.color} opacity-0 group-hover:opacity-5 transition-opacity duration-500`}></div>

              {/* Status Badge */}
              <div className="absolute right-4 top-4 z-10">
                <span className={`inline-flex items-center rounded-full px-3 py-1.5 text-xs font-bold shadow-lg ${
                  project.status === "운영 중"
                    ? "bg-gradient-to-r from-green-500 to-emerald-500 text-white"
                    : project.status === "준비 중"
                    ? "bg-gradient-to-r from-yellow-500 to-amber-500 text-white"
                    : "bg-gradient-to-r from-gray-400 to-gray-500 text-white"
                }`}>
                  {project.status}
                </span>
              </div>

              {/* Icon with glow effect */}
              <div className="relative mb-6">
                <div className={`absolute inset-0 bg-gradient-to-r ${project.color} blur-2xl opacity-20 group-hover:opacity-40 transition-opacity`}></div>
                <div className="relative text-6xl sm:text-7xl transform group-hover:scale-110 transition-transform duration-300">
                  {project.icon}
                </div>
              </div>

              {/* Title */}
              <h4 className="mb-3 text-xl sm:text-2xl font-bold text-slate-900 dark:text-slate-100 group-hover:text-amber-700 dark:group-hover:text-amber-400 transition-colors">
                {project.name}
                <span className="block text-sm sm:text-base font-medium text-slate-500 dark:text-slate-400 mt-1">
                  {project.nameKo}
                </span>
              </h4>

              {/* Tagline with gradient */}
              <p className={`mb-4 bg-gradient-to-r ${project.color} bg-clip-text text-base sm:text-lg font-bold text-transparent`}>
                {project.tagline}
              </p>

              {/* Description */}
              <p className="text-sm sm:text-base text-slate-600 dark:text-slate-300 mb-6 line-clamp-2">
                {project.description}
              </p>

              {/* Access Button */}
              {project.status === "운영 중" ? (
                <button
                  onClick={() => handleProjectAccess(project.code, project.url, project.name)}
                  className="group/btn relative w-full overflow-hidden rounded-xl bg-gradient-to-r from-amber-600 via-amber-500 to-orange-500 px-4 py-3.5 text-sm font-bold text-white shadow-lg transition-all duration-300 hover:shadow-amber-500/50 hover:shadow-2xl hover:scale-105"
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-amber-700 to-orange-600 opacity-0 group-hover/btn:opacity-100 transition-opacity"></div>
                  <span className="relative flex items-center justify-center gap-2">
                    <span>프로젝트 접속</span>
                    <svg className="w-4 h-4 transform group-hover/btn:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                    </svg>
                  </span>
                </button>
              ) : (
                <div className="w-full rounded-xl bg-gradient-to-r from-slate-200 to-slate-300 dark:from-slate-700 dark:to-slate-600 px-4 py-3.5 text-sm font-bold text-slate-600 dark:text-slate-300 text-center shadow-inner">
                  {project.status}
                </div>
              )}
            </div>
          ))}
        </div>
      </section>

      {/* Vision Section */}
      <section className="mx-auto max-w-7xl px-4 py-12 sm:py-16 md:py-20 sm:px-6 lg:px-8">
        <div className="group relative overflow-hidden rounded-3xl">
          {/* Animated background gradients */}
          <div className="absolute inset-0 bg-gradient-to-br from-amber-100 via-orange-50 to-slate-100 dark:from-amber-900/20 dark:via-orange-900/10 dark:to-slate-800/50 animate-gradient bg-[length:200%_200%]"></div>

          {/* Glow effect */}
          <div className="absolute inset-0 bg-gradient-to-r from-amber-400/20 to-orange-400/20 blur-3xl opacity-0 group-hover:opacity-30 transition-opacity duration-700"></div>

          {/* Content */}
          <div className="relative border border-amber-200/50 dark:border-amber-800/30 backdrop-blur-sm p-8 sm:p-10 md:p-12 lg:p-16 text-center">
            {/* Badge */}
            <div className="inline-flex items-center gap-2 rounded-full bg-gradient-to-r from-amber-600 to-orange-500 px-4 sm:px-5 py-2 text-xs sm:text-sm font-semibold text-white shadow-lg mb-6 sm:mb-8">
              <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z"/>
              </svg>
              <span>Our Vision</span>
            </div>

            <h3 className="text-2xl sm:text-3xl md:text-4xl font-bold text-slate-900 dark:text-slate-100 mb-6 sm:mb-8">
              우리의 비전
            </h3>

            <p className="mx-auto max-w-3xl text-base sm:text-lg md:text-xl text-slate-700 dark:text-slate-300 leading-relaxed space-y-4 sm:space-y-6">
              <span className="block">
                <strong className="text-amber-700 dark:text-amber-400 font-bold">Arikonia</strong>는 단순한 학습을 넘어,
                <br className="hidden sm:inline" />
                <span className="sm:ml-2">지식과 경험을 공유하며 함께 성장하는</span>
                <br />
                <span className="inline-flex items-center gap-2 mt-2 px-3 py-1 rounded-lg bg-amber-100 dark:bg-amber-900/30">
                  <svg className="w-5 h-5 text-amber-600 dark:text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
                  </svg>
                  <span className="text-amber-700 dark:text-amber-400 font-bold">열린 지식 공동체</span>
                </span>
                <span className="block mt-2">를 만들어갑니다.</span>
              </span>

              <span className="block pt-4 sm:pt-6 text-slate-600 dark:text-slate-400 text-sm sm:text-base md:text-lg">
                한국적 감성과 세계적 전문성이 어우러진
                <br />
                <span className="text-amber-600 dark:text-amber-400 font-semibold">새로운 교육 생태계</span>를 함께 경험하세요.
              </span>
            </p>

            {/* Decorative elements */}
            <div className="mt-8 sm:mt-12 flex justify-center gap-3 sm:gap-4 flex-wrap">
              <div className="flex items-center gap-2 px-3 sm:px-4 py-2 rounded-full bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm border border-amber-200 dark:border-amber-700/50 shadow-sm">
                <span className="text-xl sm:text-2xl">🌱</span>
                <span className="text-xs sm:text-sm font-medium text-slate-700 dark:text-slate-300">성장</span>
              </div>
              <div className="flex items-center gap-2 px-3 sm:px-4 py-2 rounded-full bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm border border-amber-200 dark:border-amber-700/50 shadow-sm">
                <span className="text-xl sm:text-2xl">🤝</span>
                <span className="text-xs sm:text-sm font-medium text-slate-700 dark:text-slate-300">협력</span>
              </div>
              <div className="flex items-center gap-2 px-3 sm:px-4 py-2 rounded-full bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm border border-amber-200 dark:border-amber-700/50 shadow-sm">
                <span className="text-xl sm:text-2xl">✨</span>
                <span className="text-xs sm:text-sm font-medium text-slate-700 dark:text-slate-300">혁신</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="relative overflow-hidden border-t border-slate-200/50 dark:border-slate-700/50 bg-gradient-to-b from-white to-slate-50 dark:from-slate-800 dark:to-slate-900">
        {/* Background decoration */}
        <div className="absolute inset-0 -z-10">
          <div className="absolute top-0 left-1/3 w-64 h-64 bg-amber-200/20 dark:bg-amber-500/5 rounded-full blur-3xl"></div>
          <div className="absolute bottom-0 right-1/3 w-64 h-64 bg-blue-200/20 dark:bg-blue-500/5 rounded-full blur-3xl"></div>
        </div>

        <div className="mx-auto max-w-7xl px-4 py-12 sm:py-16 md:py-20 sm:px-6 lg:px-8">
          <div className="text-center">
            {/* Logo with gradient */}
            <div className="inline-block mb-6">
              <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold bg-gradient-to-r from-amber-600 via-orange-500 to-amber-600 bg-clip-text text-transparent animate-gradient bg-[length:200%_200%]">
                Arikonia
              </h2>
              <div className="mt-2 h-1 bg-gradient-to-r from-transparent via-amber-500 to-transparent"></div>
            </div>

            {/* Tagline */}
            <p className="text-sm sm:text-base md:text-lg text-slate-600 dark:text-slate-400 font-medium mb-8 sm:mb-10">
              <span className="inline-block px-4 py-2 rounded-full bg-gradient-to-r from-amber-100 to-orange-100 dark:from-amber-900/30 dark:to-orange-900/30 border border-amber-200/50 dark:border-amber-700/50">
                아름다운 지식 공동체 · Beautiful Knowledge Community
              </span>
            </p>

            {/* Project links grid */}
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 sm:gap-4 max-w-2xl mx-auto mb-10 sm:mb-12">
              <a href="https://carelit.arikonia.com" className="group px-4 py-3 rounded-xl bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm border border-slate-200 dark:border-slate-700 hover:border-amber-300 dark:hover:border-amber-600 transition-all hover:shadow-lg hover:scale-105">
                <div className="text-2xl mb-1">💊</div>
                <div className="text-xs sm:text-sm font-semibold text-slate-700 dark:text-slate-300 group-hover:text-amber-600 dark:group-hover:text-amber-400">Care-Lit</div>
              </a>
              <a href="https://areumfit.arikonia.com" className="group px-4 py-3 rounded-xl bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm border border-slate-200 dark:border-slate-700 hover:border-amber-300 dark:hover:border-amber-600 transition-all hover:shadow-lg hover:scale-105">
                <div className="text-2xl mb-1">💪</div>
                <div className="text-xs sm:text-sm font-semibold text-slate-700 dark:text-slate-300 group-hover:text-amber-600 dark:group-hover:text-amber-400">AreumFit</div>
              </a>
              <a href="https://lingumo.arikonia.com" className="group px-4 py-3 rounded-xl bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm border border-slate-200 dark:border-slate-700 hover:border-amber-300 dark:hover:border-amber-600 transition-all hover:shadow-lg hover:scale-105 col-span-2 sm:col-span-1">
                <div className="text-2xl mb-1">🗣️</div>
                <div className="text-xs sm:text-sm font-semibold text-slate-700 dark:text-slate-300 group-hover:text-amber-600 dark:group-hover:text-amber-400">Lingumo</div>
              </a>
            </div>

            {/* Divider */}
            <div className="h-px bg-gradient-to-r from-transparent via-slate-300 dark:via-slate-700 to-transparent mb-8"></div>

            {/* Copyright */}
            <p className="text-xs sm:text-sm text-slate-400 dark:text-slate-500">
              © 2025 Arikonia. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
