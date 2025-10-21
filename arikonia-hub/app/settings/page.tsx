'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { useAuthStore } from '@/stores/authStore'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage, FormDescription } from '@/components/ui/form'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import Link from 'next/link'
import { toast } from 'sonner'

// 국가 코드 목록 (signup과 동일)
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

const profileSchema = z.object({
  name: z.string().min(2, '이름은 최소 2자 이상이어야 합니다').max(50, '이름은 50자 이하이어야 합니다'),
  nickname: z.string().min(2, '닉네임은 최소 2자 이상이어야 합니다').max(20, '닉네임은 20자 이하이어야 합니다'),
  birthDate: z.string().min(1, '생년월일을 선택해주세요'),
  countryCode: z.string().min(1, '국가번호를 선택하세요'),
  phone: z.string()
    .min(8, '휴대전화번호는 최소 8자 이상이어야 합니다')
    .max(15, '휴대전화번호는 15자 이하이어야 합니다')
    .regex(/^[0-9]+$/, '숫자만 입력하세요 (하이픈 없이)'),
})

const passwordSchema = z.object({
  currentPassword: z.string().min(6, '현재 비밀번호를 입력하세요'),
  newPassword: z.string().min(6, '새 비밀번호는 최소 6자 이상이어야 합니다'),
  confirmPassword: z.string(),
}).refine((data) => data.newPassword === data.confirmPassword, {
  message: '비밀번호가 일치하지 않습니다',
  path: ['confirmPassword'],
})

type ProfileForm = z.infer<typeof profileSchema>
type PasswordForm = z.infer<typeof passwordSchema>

export default function SettingsPage() {
  const router = useRouter()
  const user = useAuthStore((state) => state.user)
  const profile = useAuthStore((state) => state.profile)
  const authLoading = useAuthStore((state) => state.isLoading)
  const updateProfile = useAuthStore((state) => state.updateProfile)
  const changePassword = useAuthStore((state) => state.changePassword)
  const [isUpdating, setIsUpdating] = useState(false)
  const [isChangingPassword, setIsChangingPassword] = useState(false)

  const profileForm = useForm<ProfileForm>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      name: '',
      nickname: '',
      birthDate: '',
      countryCode: '+82',
      phone: '',
    },
  })

  const passwordForm = useForm<PasswordForm>({
    resolver: zodResolver(passwordSchema),
    defaultValues: {
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    },
  })

  // Load user profile data
  useEffect(() => {
    if (profile) {
      // Parse phone number to extract country code and number
      const phone = profile.phone || ''
      let countryCode = '+82'
      let phoneNumber = ''

      if (phone) {
        // Find matching country code
        const matchedCountry = COUNTRY_CODES.find(c => phone.startsWith(c.code))
        if (matchedCountry) {
          countryCode = matchedCountry.code
          phoneNumber = phone.substring(matchedCountry.code.length)
        } else {
          phoneNumber = phone
        }
      }

      profileForm.reset({
        name: profile.name || '',
        nickname: profile.nickname || '',
        birthDate: profile.birth_date || '',
        countryCode,
        phone: phoneNumber,
      })
    }
  }, [profile, profileForm])

  const onProfileSubmit = async (data: ProfileForm) => {
    setIsUpdating(true)
    try {
      const fullPhone = `${data.countryCode}${data.phone}`

      await updateProfile({
        name: data.name,
        nickname: data.nickname,
        birth_date: data.birthDate,
        phone: fullPhone,
      })

      toast.success('프로필이 업데이트되었습니다')
    } catch (error: any) {
      toast.error(error.message || '프로필 업데이트에 실패했습니다')
    } finally {
      setIsUpdating(false)
    }
  }

  const onPasswordSubmit = async (data: PasswordForm) => {
    setIsChangingPassword(true)
    try {
      await changePassword(data.currentPassword, data.newPassword)

      toast.success('비밀번호가 변경되었습니다')
      passwordForm.reset()
    } catch (error: any) {
      toast.error(error.message || '비밀번호 변경에 실패했습니다')
    } finally {
      setIsChangingPassword(false)
    }
  }

  // Redirect to login if not authenticated
  useEffect(() => {
    if (!user && !authLoading) {
      router.push('/login')
    }
  }, [user, authLoading, router])

  if (!user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-slate-600 dark:text-slate-400">로그인이 필요합니다...</p>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-amber-50/30 to-slate-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900 py-12 px-4">
      <div className="max-w-4xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-slate-900 dark:text-slate-100">
              프로필 설정
            </h1>
            <p className="text-slate-600 dark:text-slate-400 mt-1">
              회원 정보를 관리하고 비밀번호를 변경할 수 있습니다
            </p>
          </div>
          <Link href="/">
            <Button variant="outline" className="dark:border-slate-600 dark:text-slate-300">
              홈으로
            </Button>
          </Link>
        </div>

        {/* Profile Information */}
        <Card className="border-slate-200 dark:border-slate-700 dark:bg-slate-800">
          <CardHeader>
            <CardTitle className="dark:text-slate-100">기본 정보</CardTitle>
            <CardDescription className="dark:text-slate-400">
              이름, 닉네임, 생년월일, 전화번호를 수정할 수 있습니다
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Form {...profileForm}>
              <form onSubmit={profileForm.handleSubmit(onProfileSubmit)} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <FormField
                    control={profileForm.control}
                    name="name"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="dark:text-slate-200">이름 (실명)</FormLabel>
                        <FormControl>
                          <Input
                            {...field}
                            disabled={isUpdating}
                            className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={profileForm.control}
                    name="nickname"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="dark:text-slate-200">닉네임</FormLabel>
                        <FormControl>
                          <Input
                            {...field}
                            disabled={isUpdating}
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
                </div>

                <FormField
                  control={profileForm.control}
                  name="birthDate"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="dark:text-slate-200">생년월일</FormLabel>
                      <FormControl>
                        <Input
                          type="date"
                          {...field}
                          disabled={isUpdating}
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
                      control={profileForm.control}
                      name="countryCode"
                      render={({ field }) => (
                        <FormItem className="w-[140px]">
                          <Select
                            onValueChange={field.onChange}
                            defaultValue={field.value}
                            disabled={isUpdating}
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
                      control={profileForm.control}
                      name="phone"
                      render={({ field }) => (
                        <FormItem className="flex-1">
                          <FormControl>
                            <Input
                              type="tel"
                              placeholder="1012345678"
                              {...field}
                              disabled={isUpdating}
                              className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                            />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>
                </div>

                <div className="flex justify-end">
                  <Button
                    type="submit"
                    disabled={isUpdating}
                    className="bg-amber-600 hover:bg-amber-700 dark:bg-amber-500 dark:hover:bg-amber-600"
                  >
                    {isUpdating ? '저장 중...' : '프로필 저장'}
                  </Button>
                </div>
              </form>
            </Form>
          </CardContent>
        </Card>

        {/* Password Change */}
        <Card className="border-slate-200 dark:border-slate-700 dark:bg-slate-800">
          <CardHeader>
            <CardTitle className="dark:text-slate-100">비밀번호 변경</CardTitle>
            <CardDescription className="dark:text-slate-400">
              보안을 위해 주기적으로 비밀번호를 변경하세요
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Form {...passwordForm}>
              <form onSubmit={passwordForm.handleSubmit(onPasswordSubmit)} className="space-y-4">
                <FormField
                  control={passwordForm.control}
                  name="currentPassword"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="dark:text-slate-200">현재 비밀번호</FormLabel>
                      <FormControl>
                        <Input
                          type="password"
                          {...field}
                          disabled={isChangingPassword}
                          className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={passwordForm.control}
                  name="newPassword"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="dark:text-slate-200">새 비밀번호</FormLabel>
                      <FormControl>
                        <Input
                          type="password"
                          {...field}
                          disabled={isChangingPassword}
                          className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={passwordForm.control}
                  name="confirmPassword"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="dark:text-slate-200">새 비밀번호 확인</FormLabel>
                      <FormControl>
                        <Input
                          type="password"
                          {...field}
                          disabled={isChangingPassword}
                          className="dark:bg-slate-700 dark:border-slate-600 dark:text-slate-100"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <div className="flex justify-end">
                  <Button
                    type="submit"
                    disabled={isChangingPassword}
                    variant="outline"
                    className="dark:border-slate-600 dark:text-slate-300"
                  >
                    {isChangingPassword ? '변경 중...' : '비밀번호 변경'}
                  </Button>
                </div>
              </form>
            </Form>
          </CardContent>
        </Card>

        {/* Account Information */}
        <Card className="border-slate-200 dark:border-slate-700 dark:bg-slate-800">
          <CardHeader>
            <CardTitle className="dark:text-slate-100">계정 정보</CardTitle>
            <CardDescription className="dark:text-slate-400">
              이메일과 가입일 정보입니다
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex justify-between items-center py-2 border-b border-slate-200 dark:border-slate-700">
              <span className="text-sm font-medium text-slate-700 dark:text-slate-300">이메일</span>
              <span className="text-sm text-slate-600 dark:text-slate-400">{user.email}</span>
            </div>
            {profile?.created_at && (
              <div className="flex justify-between items-center py-2 border-b border-slate-200 dark:border-slate-700">
                <span className="text-sm font-medium text-slate-700 dark:text-slate-300">가입일</span>
                <span className="text-sm text-slate-600 dark:text-slate-400">
                  {new Date(profile.created_at).toLocaleDateString('ko-KR')}
                </span>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
