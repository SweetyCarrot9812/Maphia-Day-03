'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { useAuthStore } from '@/stores/authStore'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage, FormDescription } from '@/components/ui/form'
import { Checkbox } from '@/components/ui/checkbox'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import Link from 'next/link'
import { toast } from 'sonner'

// 국가 코드 목록 (주요 국가)
const COUNTRY_CODES = [
  { code: '+82', name: '대한민국 (+82)', flag: '🇰🇷' },
  { code: '+1', name: '미국/캐나다 (+1)', flag: '🇺🇸' },
  { code: '+81', name: '일본 (+81)', flag: '🇯🇵' },
  { code: '+86', name: '중국 (+86)', flag: '🇨🇳' },
  { code: '+44', name: '영국 (+44)', flag: '🇬🇧' },
  { code: '+33', name: '프랑스 (+33)', flag: '🇫🇷' },
  { code: '+49', name: '독일 (+49)', flag: '🇩🇪' },
  { code: '+39', name: '이탈리아 (+39)', flag: '🇮🇹' },
  { code: '+34', name: '스페인 (+34)', flag: '🇪🇸' },
  { code: '+61', name: '호주 (+61)', flag: '🇦🇺' },
  { code: '+65', name: '싱가포르 (+65)', flag: '🇸🇬' },
  { code: '+852', name: '홍콩 (+852)', flag: '🇭🇰' },
  { code: '+886', name: '대만 (+886)', flag: '🇹🇼' },
  { code: '+66', name: '태국 (+66)', flag: '🇹🇭' },
  { code: '+84', name: '베트남 (+84)', flag: '🇻🇳' },
  { code: '+63', name: '필리핀 (+63)', flag: '🇵🇭' },
  { code: '+60', name: '말레이시아 (+60)', flag: '🇲🇾' },
  { code: '+62', name: '인도네시아 (+62)', flag: '🇮🇩' },
  { code: '+91', name: '인도 (+91)', flag: '🇮🇳' },
  { code: '+7', name: '러시아 (+7)', flag: '🇷🇺' },
]

const signupSchema = z.object({
  email: z.string().email('올바른 이메일 주소를 입력하세요'),
  name: z.string().min(2, '이름은 최소 2자 이상이어야 합니다').max(50, '이름은 50자 이하이어야 합니다'),
  nickname: z.string().min(2, '닉네임은 최소 2자 이상이어야 합니다').max(20, '닉네임은 20자 이하이어야 합니다'),
  birthDate: z.string().min(1, '생년월일을 선택해주세요'),
  countryCode: z.string().min(1, '국가번호를 선택하세요'),
  phone: z.string()
    .min(8, '휴대전화번호는 최소 8자 이상이어야 합니다')
    .max(15, '휴대전화번호는 15자 이하이어야 합니다')
    .regex(/^[0-9]+$/, '숫자만 입력하세요 (하이픈 없이)'),
  password: z.string().min(6, '비밀번호는 최소 6자 이상이어야 합니다'),
  passwordConfirm: z.string(),
  agreeTerms: z.boolean().refine((val) => val === true, {
    message: '이용약관에 동의해주세요',
  }),
  agreePrivacy: z.boolean().refine((val) => val === true, {
    message: '개인정보처리방침에 동의해주세요',
  }),
}).refine((data) => data.password === data.passwordConfirm, {
  message: '비밀번호가 일치하지 않습니다',
  path: ['passwordConfirm'],
})

type SignupForm = z.infer<typeof signupSchema>

export default function SignupPage() {
  const router = useRouter()
  const signUp = useAuthStore((state) => state.signUpWithEmail)
  const signInWithGoogle = useAuthStore((state) => state.signInWithGoogle)
  const isLoading = useAuthStore((state) => state.isLoading)
  const error = useAuthStore((state) => state.error)
  const clearError = useAuthStore((state) => state.clearError)
  const user = useAuthStore((state) => state.user)
  const [showEmailConfirmation, setShowEmailConfirmation] = useState(false)
  const [signupEmail, setSignupEmail] = useState('')

  const form = useForm<SignupForm>({
    resolver: zodResolver(signupSchema),
    defaultValues: {
      email: '',
      name: '',
      nickname: '',
      birthDate: '',
      countryCode: '+82', // 기본값: 대한민국
      phone: '',
      password: '',
      passwordConfirm: '',
      agreeTerms: false,
      agreePrivacy: false,
    },
  })

  useEffect(() => {
    if (user) {
      router.push('/dashboard')
    }
  }, [user, router])

  const onSubmit = async (data: SignupForm) => {
    try {
      clearError() // Clear previous errors

      // 전화번호 결합 (국가코드 + 전화번호)
      const fullPhone = `${data.countryCode}${data.phone}`

      const result = await signUp(
        data.email,
        data.password,
        data.name,
        data.nickname,
        data.birthDate,
        fullPhone
      )

      if (result.confirmationRequired) {
        // Email confirmation required
        setSignupEmail(data.email)
        setShowEmailConfirmation(true)
        toast.success('회원가입 성공!', {
          description: '이메일을 확인하여 인증을 완료해주세요.',
        })
      } else {
        // No confirmation needed, redirect to login
        toast.success('회원가입이 완료되었습니다!')
        router.push('/login')
      }
    } catch (err) {
      // Error handled by store and displayed in UI
      console.error('Signup error:', err)
    }
  }

  const handleGoogleSignup = async () => {
    try {
      await signInWithGoogle()
    } catch (err) {
      // Error handled by store
    }
  }

  // Email confirmation success UI
  if (showEmailConfirmation) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-slate-50 via-amber-50/30 to-slate-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900 px-4 py-12">
        <Card className="w-full max-w-md border-slate-200 dark:border-slate-700 dark:bg-slate-800">
          <CardHeader className="space-y-1 text-center">
            <div className="mx-auto w-12 h-12 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center mb-4">
              <svg className="w-6 h-6 text-green-600 dark:text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
            </div>
            <CardTitle className="text-2xl font-bold dark:text-slate-100">이메일 확인 필요</CardTitle>
            <CardDescription className="dark:text-slate-400 text-base">
              회원가입이 거의 완료되었습니다!
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="rounded-lg bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 p-4 space-y-3">
              <div className="flex items-start gap-3">
                <div className="flex-shrink-0 w-5 h-5 rounded-full bg-blue-600 dark:bg-blue-500 text-white flex items-center justify-center text-xs font-bold">
                  1
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-blue-900 dark:text-blue-200">
                    이메일을 확인하세요
                  </p>
                  <p className="text-sm text-blue-700 dark:text-blue-300 mt-1">
                    <span className="font-semibold">{signupEmail}</span>로 인증 링크를 전송했습니다
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <div className="flex-shrink-0 w-5 h-5 rounded-full bg-blue-600 dark:bg-blue-500 text-white flex items-center justify-center text-xs font-bold">
                  2
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-blue-900 dark:text-blue-200">
                    확인 링크를 클릭하세요
                  </p>
                  <p className="text-sm text-blue-700 dark:text-blue-300 mt-1">
                    이메일에서 "이메일 확인" 버튼을 클릭하세요
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <div className="flex-shrink-0 w-5 h-5 rounded-full bg-blue-600 dark:bg-blue-500 text-white flex items-center justify-center text-xs font-bold">
                  3
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-blue-900 dark:text-blue-200">
                    로그인하세요
                  </p>
                  <p className="text-sm text-blue-700 dark:text-blue-300 mt-1">
                    이메일 확인 후 로그인 페이지에서 로그인할 수 있습니다
                  </p>
                </div>
              </div>
            </div>

            <div className="rounded-lg bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 p-3 text-sm text-amber-800 dark:text-amber-300">
              <p className="font-medium mb-1">이메일이 오지 않았나요?</p>
              <ul className="list-disc list-inside space-y-1 text-xs">
                <li>스팸 메일함을 확인해보세요</li>
                <li>몇 분 정도 소요될 수 있습니다</li>
                <li>이메일 주소가 정확한지 확인하세요</li>
              </ul>
            </div>
          </CardContent>
          <CardFooter className="flex flex-col space-y-2">
            <Button
              onClick={() => router.push('/login')}
              className="w-full bg-amber-600 hover:bg-amber-700 dark:bg-amber-500 dark:hover:bg-amber-600"
            >
              로그인 페이지로 이동
            </Button>
            <Button
              variant="ghost"
              onClick={() => setShowEmailConfirmation(false)}
              className="w-full text-slate-600 dark:text-slate-400"
            >
              회원가입 화면으로 돌아가기
            </Button>
          </CardFooter>
        </Card>
      </div>
    )
  }

  // Normal signup form
  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-slate-50 via-amber-50/30 to-slate-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900 px-4 py-12">
      <Card className="w-full max-w-md border-slate-200 dark:border-slate-700 dark:bg-slate-800">
        <CardHeader className="space-y-1 text-center">
          <Link href="/" className="inline-block">
            <h1 className="text-3xl font-bold text-slate-900 dark:text-slate-100 mb-2">
              Arikonia
            </h1>
          </Link>
          <CardTitle className="text-2xl font-bold dark:text-slate-100">회원가입</CardTitle>
          <CardDescription className="dark:text-slate-400">
            아름다운 지식 공동체의 회원이 되어보세요
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
              {error && (
                <div className="rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 p-3 text-sm text-red-800 dark:text-red-300">
                  {error}
                </div>
              )}
              <FormField
                control={form.control}
                name="email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="dark:text-slate-200">이메일</FormLabel>
                    <FormControl>
                      <Input
                        type="email"
                        placeholder="example@email.com"
                        {...field}
                        disabled={isLoading}
                        className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="dark:text-slate-200">이름 (실명)</FormLabel>
                    <FormControl>
                      <Input
                        type="text"
                        placeholder="홍길동"
                        {...field}
                        disabled={isLoading}
                        className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="nickname"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="dark:text-slate-200">닉네임</FormLabel>
                    <FormControl>
                      <Input
                        type="text"
                        placeholder="아리코니아"
                        {...field}
                        disabled={isLoading}
                        className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                      />
                    </FormControl>
                    <FormDescription className="text-xs dark:text-slate-400">
                      다른 사용자에게 표시되는 이름입니다
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="birthDate"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="dark:text-slate-200">생년월일</FormLabel>
                    <FormControl>
                      <Input
                        type="date"
                        {...field}
                        disabled={isLoading}
                        className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <div className="space-y-2">
                <label className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 dark:text-slate-200">
                  휴대전화번호
                </label>
                <div className="flex gap-2">
                  <FormField
                    control={form.control}
                    name="countryCode"
                    render={({ field }) => (
                      <FormItem className="w-[140px]">
                        <Select
                          onValueChange={field.onChange}
                          defaultValue={field.value}
                          disabled={isLoading}
                        >
                          <FormControl>
                            <SelectTrigger className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100">
                              <SelectValue placeholder="국가" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {COUNTRY_CODES.map((country) => (
                              <SelectItem key={country.code} value={country.code}>
                                {country.flag} {country.code}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name="phone"
                    render={({ field }) => (
                      <FormItem className="flex-1">
                        <FormControl>
                          <Input
                            type="tel"
                            placeholder="1012345678"
                            {...field}
                            disabled={isLoading}
                            className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>
                <p className="text-xs text-slate-500 dark:text-slate-400">
                  하이픈 없이 숫자만 입력하세요 (예: 1012345678)
                </p>
              </div>

              <FormField
                control={form.control}
                name="password"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="dark:text-slate-200">비밀번호</FormLabel>
                    <FormControl>
                      <Input
                        type="password"
                        placeholder="••••••"
                        {...field}
                        disabled={isLoading}
                        className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="passwordConfirm"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="dark:text-slate-200">비밀번호 확인</FormLabel>
                    <FormControl>
                      <Input
                        type="password"
                        placeholder="••••••"
                        {...field}
                        disabled={isLoading}
                        className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              {/* Terms and Privacy Checkboxes */}
              <div className="space-y-3">
                <FormField
                  control={form.control}
                  name="agreeTerms"
                  render={({ field }) => (
                    <FormItem className="flex flex-row items-start space-x-3 space-y-0">
                      <FormControl>
                        <Checkbox
                          checked={field.value}
                          onCheckedChange={field.onChange}
                          disabled={isLoading}
                        />
                      </FormControl>
                      <div className="space-y-1 leading-none">
                        <FormLabel className="text-sm font-normal dark:text-slate-300">
                          <Link href="/terms" target="_blank" className="text-amber-600 dark:text-amber-400 hover:underline font-medium">
                            이용약관
                          </Link>에 동의합니다 (필수)
                        </FormLabel>
                        <FormMessage />
                      </div>
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="agreePrivacy"
                  render={({ field }) => (
                    <FormItem className="flex flex-row items-start space-x-3 space-y-0">
                      <FormControl>
                        <Checkbox
                          checked={field.value}
                          onCheckedChange={field.onChange}
                          disabled={isLoading}
                        />
                      </FormControl>
                      <div className="space-y-1 leading-none">
                        <FormLabel className="text-sm font-normal dark:text-slate-300">
                          <Link href="/privacy" target="_blank" className="text-amber-600 dark:text-amber-400 hover:underline font-medium">
                            개인정보처리방침
                          </Link>에 동의합니다 (필수)
                        </FormLabel>
                        <FormMessage />
                      </div>
                    </FormItem>
                  )}
                />
              </div>

              <div className="rounded-lg bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 p-3 text-sm text-amber-800 dark:text-amber-300">
                회원가입 시 무료 플랜이 자동으로 할당됩니다
              </div>
              <Button
                type="submit"
                className="w-full bg-amber-600 hover:bg-amber-700 dark:bg-amber-500 dark:hover:bg-amber-600"
                disabled={isLoading}
              >
                {isLoading ? '가입 중...' : '이메일로 회원가입'}
              </Button>
            </form>
          </Form>

          <div className="relative my-4">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t border-slate-300 dark:border-slate-600" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-white dark:bg-slate-800 px-2 text-slate-500 dark:text-slate-400">
                또는
              </span>
            </div>
          </div>

          <Button
            type="button"
            variant="outline"
            className="w-full border-slate-300 dark:border-slate-600 dark:bg-slate-700 dark:text-slate-100 dark:hover:bg-slate-600"
            onClick={handleGoogleSignup}
            disabled={isLoading}
          >
            <svg className="mr-2 h-4 w-4" viewBox="0 0 24 24">
              <path
                fill="currentColor"
                d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
              />
              <path
                fill="currentColor"
                d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              />
              <path
                fill="currentColor"
                d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
              />
              <path
                fill="currentColor"
                d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
              />
            </svg>
            Google로 시작하기
          </Button>
        </CardContent>
        <CardFooter className="flex flex-col space-y-2">
          <div className="text-sm text-slate-600 dark:text-slate-400 text-center">
            이미 계정이 있으신가요?{' '}
            <Link href="/login" className="text-amber-600 dark:text-amber-400 hover:underline font-medium">
              로그인
            </Link>
          </div>
          <div className="text-xs text-slate-500 dark:text-slate-500 text-center">
            <Link href="/" className="hover:underline">
              메인으로 돌아가기
            </Link>
          </div>
        </CardFooter>
      </Card>
    </div>
  )
}
